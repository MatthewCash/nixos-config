{ lib, ... }:

{
    home.activation.configRepo = lib.hm.dag.entryAfter [ "writeBoundary" ] /* sh */ ''
        $DRY_RUN_CMD cp -r ${../../..} ~/nixos-config
        $DRY_RUN_CMD chown -R $USER ~/nixos-config
        $DRY_RUN_CMD chmod -R 755 ~/nixos-config
    '';

    programs.zsh.initContent = /* zsh */ ''
        cd ~/nixos-config
    '';
}
