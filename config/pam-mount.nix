{ pkgsStable, pkgsUnstable, stableLib, config, pamMountUsers, homeMountPath, ... }:

let
    pamServices = [ "login" "sshd" ];
in

{
    security.pam.mount = {
        enable = true;
        createMountPoints = true;
    };

    # Disable home-manager on boot for users without a pamMount path
    systemd.services = stableLib.attrsets.mapAttrs' (name: value: stableLib.attrsets.nameValuePair "home-manager-${name}" { wantedBy = stableLib.mkForce [ ]; })
        (stableLib.attrsets.filterAttrs (name: value: builtins.elem name pamMountUsers) config.home-manager.users);

    environment.etc = builtins.listToAttrs (builtins.map (service: let
        systemctl = "${pkgsStable.systemd}/bin/systemctl";
        checkScript = pkgsStable.writeShellScript "check_for_mount.sh" /* bash */ ''
            mountpoint -q "${homeMountPath}/$PAM_USER"
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
    in { name = "pam.d/${service}"; value.text = stableLib.mkForce pamLoginText; }) pamServices);
}
