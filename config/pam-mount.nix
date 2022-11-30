{ pkgsStable, pkgsUnstable, stableLib, config, ... }:

{
    security.pam.mount = {
        enable = true;
        createMountPoints = true;
    };

    # Disable home-manager on boot for users without a pamMount path
    systemd.services = stableLib.attrsets.mapAttrs' (name: value: stableLib.attrsets.nameValuePair "home-manager-${name}" { wantedBy = stableLib.mkForce []; })
        (stableLib.attrsets.filterAttrs (name: value: config.users.extraUsers.${name}.pamMount ? path) config.home-manager.users);

    environment.etc."pam.d/login".text = let
        systemctl = "${pkgsStable.systemd}/bin/systemctl";
        checkScript = pkgsStable.writeShellScript "check_for_mount.sh" ''
            mountpoint -q "/mnt/storage/$PAM_USER"
        '';
        hmScript = pkgsStable.writeShellScript "run_hm.sh" ''
            if [[ -n $(${systemctl} list-unit-files | grep "^home-manager-$PAM_USER") ]]; then
                ${systemctl} restart home-manager-$PAM_USER
            fi
        '';

        # Verify that mount does not already exist
        pamCheckLine = "session [success=2 default=ignore] ${pkgsStable.linux-pam}/lib/security/pam_exec.so ${checkScript} quiet";
        pamMountLine = "session optional ${pkgsUnstable.pam_mount}/lib/security/pam_mount.so disable_interactive";
        # Run home-manager activation for user
        pamExecLine = "session optional ${pkgsStable.linux-pam}/lib/security/pam_exec.so ${hmScript}";

        pamLoginText = builtins.replaceStrings
            [ pamMountLine ]
            [ "${pamCheckLine}\n${pamMountLine}\n${pamExecLine}" ]
            config.security.pam.services.login.text;
    in stableLib.mkForce pamLoginText;
}
