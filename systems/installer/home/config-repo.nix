{ ... }:

{
    home.file."nixos-config".source = ../../..;

    programs.zsh.initExtra = /* zsh */ ''
        cd ~/nixos-config
    '';
}
