{ config, pkgsUnstable, stableLib, users, homeMountPath, ... }:

let
    lib = stableLib;
    pkgs = pkgsUnstable;
    pamServices = [ "login" "sshd" ];
    managedUsers = lib.filterAttrs (_: user: user.usePamMount or false) users;
    userNames = builtins.attrNames managedUsers;
    mountpoint = lib.getExe' pkgs.util-linux "mountpoint";
    systemctl = lib.getExe' config.systemd.package "systemctl";
    pmvarrun = lib.getExe' pkgs.pam_mount "pmvarrun";
    initializingMessage = pkgs.writeText "pam-mount-initializing" "Initializing Home Directory...";

    userCase = name:
        let
            home = config.users.users.${name}.home;
            target = "home-files${builtins.replaceStrings [ "/" ] [ "-" ] home}.target";
            homeManager = lib.optionalString
                (builtins.hasAttr name (config.home-manager.users or { }))
                ''home_manager="home-manager-${name}.service"'';
        in ''
            ${lib.escapeShellArg name})
                mount_path=${lib.escapeShellArg "${homeMountPath}/${name}"}
                target=${lib.escapeShellArg target}
                ${homeManager}
                ;;
        '';

    sessionHook = pkgs.writeShellScript "pam-mount-session" ''
        set -u

        home_manager=
        case "''${PAM_USER:-}" in
            ${lib.concatMapStrings userCase userNames}
            *) exit 0 ;;
        esac

        case "''${1:-}:''${PAM_TYPE:-}" in
            activate:open_session)
                # pam_mount has already run. Starting active units is harmless,
                # so every session can execute this without becoming the owner.
                ${mountpoint} --quiet -- "$mount_path" || exit 0
                ${systemctl} start "$target" || exit 0
                if [ -n "$home_manager" ]; then
                    ${systemctl} start "$home_manager" || true
                fi
                ;;
            cleanup:close_session)
                # This hook precedes pam_mount. Tear persistence down only for
                # the final session so bind mounts do not block crypt unmounting.
                count=$(${pmvarrun} -u "$PAM_USER" -o 0) || exit 0
                [ "$count" -le 1 ] || exit 0
                if [ -n "$home_manager" ]; then
                    ${systemctl} stop "$home_manager" || true
                fi
                ${systemctl} list-dependencies --plain --no-legend "$target" |
                    while read -r unit; do
                        [ -n "$unit" ] && ${systemctl} stop "$unit" || true
                    done
                ${systemctl} stop "$target" || true
                ;;
        esac
    '';

    messageCheck = pkgs.writeShellScript "pam-mount-message-check" ''
        case "''${PAM_TYPE:-}:''${PAM_USER:-}" in
            ${lib.concatMapStringsSep "|" (name: "open_session:${lib.escapeShellArg name}") userNames})
                ${mountpoint} --quiet -- "${homeMountPath}/$PAM_USER"
                ;;
            *) exit 0 ;;
        esac
    '';

    authorizedKeys = pkgs.writeShellScript "pam-mount-authorized-keys" ''
        set -eu
        [ "$#" -eq 1 ] || exit 1
        user=$1
        case "$user" in
            ${lib.concatMapStringsSep "|" lib.escapeShellArg userNames})
                ${mountpoint} --quiet -- "${homeMountPath}/$user" || exit 1
                ;;
        esac
        exec ${lib.getExe' pkgs.coreutils "cat"} -- "/etc/ssh/authorized_keys.d/$user"
    '';
in
{
    config = lib.mkIf (userNames != [ ]) {
        security.pam.mount = {
            # Enable pam_mount only on the login entry points below. Enabling it
            # globally would count sudo, screen unlocks, and other PAM users.
            enable = false;
            createMountPoints = true;
            removeCreatedMountPoints = false;
            cryptMountOptions = [ "allow_discard" ];
            logoutWait = 500000;
            logoutHup = true;
            logoutTerm = true;
        };

        security.pam.services = lib.genAttrs pamServices (service: {
            pamMount = true;
            rules.session = {
                pam-mount-message-check = {
                    order = config.security.pam.services.${service}.rules.session.mount.order - 3;
                    control = "[success=1 default=ignore]";
                    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
                    args = [ "quiet" (toString messageCheck) ];
                };
                pam-mount-message = {
                    order = config.security.pam.services.${service}.rules.session.mount.order - 2;
                    control = "optional";
                    modulePath = "${config.security.pam.package}/lib/security/pam_echo.so";
                    args = [ "file=${initializingMessage}" ];
                };
                pam-mount-cleanup = {
                    order = config.security.pam.services.${service}.rules.session.mount.order - 1;
                    control = "optional";
                    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
                    args = [ "quiet" (toString sessionHook) "cleanup" ];
                };
                pam-mount-session = {
                    order = config.security.pam.services.${service}.rules.session.mount.order + 1;
                    control = "optional";
                    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
                    args = [ "quiet" (toString sessionHook) "activate" ];
                };
            };
        });

        # Home persistence is unavailable until pam_mount opens the encrypted
        # volume, so neither these targets nor Home Manager may start at boot.
        systemd.targets = lib.genAttrs (map (name:
            "home-files${builtins.replaceStrings [ "/" ] [ "-" ] config.users.users.${name}.home}"
        ) userNames) (_: { wantedBy = lib.mkForce [ ]; });
        systemd.services = lib.mapAttrs' (name: _:
            lib.nameValuePair "home-manager-${name}" { wantedBy = lib.mkForce [ ]; }
        ) (lib.filterAttrs (name: _: builtins.elem name userNames) (config.home-manager.users or { }));

        # OpenSSH rejects commands reached through a group-writable /nix/store
        # ancestor. Install a real root-owned runtime copy instead.
        system.activationScripts.pamMountAuthorizedKeys.text = ''
            ${lib.getExe' pkgs.coreutils "install"} -m 0755 ${authorizedKeys} /run/pam-mount-authorized-keys
        '';

        services.openssh = {
            authorizedKeysFiles = lib.mkForce [ "none" ];
            authorizedKeysCommandUser = "root";
            authorizedKeysCommand = "/run/pam-mount-authorized-keys %u";
            settings.PasswordAuthentication = true;
            settings.KbdInteractiveAuthentication = false;
        };
    };
}
