{ pkgsStable, pkgsUnstable, stableLib, config, users, homeMountPath, ... }:

let
    pamServices = [ "login" "sshd" ];

    mountpoint = "${pkgsStable.util-linux}/bin/mountpoint";

    pamMountUsers = builtins.attrNames (
        stableLib.attrsets.filterAttrs (name: config: config ? usePamMount && config.usePamMount) users
    );

    usePamMount = name: builtins.elem name pamMountUsers;
in

{
    security.pam.mount = {
        enable = true;
        createMountPoints = true;
        cryptMountOptions = [ "allow_discard" ];
    };

    # Disable home-manager on boot for users without a pamMount path
    systemd.services = stableLib.attrsets.mapAttrs' (name: value: stableLib.attrsets.nameValuePair "home-manager-${name}" { wantedBy = stableLib.mkForce [ ]; })
        (stableLib.attrsets.filterAttrs (name: value: usePamMount name) config.home-manager.users);

    environment.etc = builtins.listToAttrs (builtins.map (service: let
        systemctl = "${pkgsStable.systemd}/bin/systemctl";
        checkScript = pkgsStable.writeShellScript "check_for_mount.sh" /* bash */ ''
            ${mountpoint} -q "${homeMountPath}/$PAM_USER"
        '';
        hmScript = pkgsStable.writeShellScript "run_hm.sh" /* bash */ ''
            if [[ -n $(${systemctl} list-unit-files | grep "^home-manager-$PAM_USER") ]]; then
                ${systemctl} restart home-manager-$PAM_USER
            fi
        '';

        # Verify that mount does not already exist
        pamCheckLine = "session [success=2 default=ignore] ${pkgsStable.linux-pam}/lib/security/pam_exec.so quiet ${checkScript}";
        pamMountLine = "session optional ${pkgsUnstable.pam_mount}/lib/security/pam_mount.so disable_interactive";
        # Run home-manager activation for user
        pamExecLine = "session optional ${pkgsStable.linux-pam}/lib/security/pam_exec.so ${hmScript}";

        pamLoginText = builtins.replaceStrings
            [ pamMountLine ]
            [ "${pamCheckLine}\n${pamMountLine}\n${pamExecLine}" ]
            config.security.pam.services.login.text;
    in { name = "pam.d/${service}"; value.text = stableLib.mkForce pamLoginText; }) pamServices)

        # Force ssh password auth if mount does not exist
        // { "ssh/get_authorized_keys" = {
            mode = "0555";
            text = /* bash */ ''
                #!${pkgsStable.bash}/bin/bash

                ${mountpoint} -q "${homeMountPath}/$1" ||
                echo ${builtins.toString pamMountUsers} | ${pkgsStable.coreutils}/bin/grep -w -q $1 &&
                ${pkgsStable.coreutils}/bin/cat /etc/ssh/authorized_keys.d/$1
            '';
        };
    };

    services.openssh = {
        authorizedKeysFiles = stableLib.mkForce [ "none" ];
        authorizedKeysCommandUser = "root";
        authorizedKeysCommand = "/etc/ssh/get_authorized_keys %u";
        settings.PasswordAuthentication = true;
        settings.KbdInteractiveAuthentication = false;
    };
}
