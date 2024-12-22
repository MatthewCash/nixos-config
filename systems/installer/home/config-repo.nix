{ lib, ... }:

{
    home.activation.configRepo = lib.hm.dag.entryAfter [ "writeBoundary" ] /* sh */ ''
        $DRY_RUN_CMD cp -r ${../../..} ~/nixos-config
        $DRY_RUN_CMD chown -R $USER ~/nixos-config
        $DRY_RUN_CMD chmod 755 ~/nixos-config
    '';

    programs.zsh.initExtra = /* zsh */ ''
        cd ~/nixos-config
    '';
}
