{ ... }:

{
    # disable pointer acceleration
    programs.plasma.configFile.kcminputrc = {
        "Libinput/9610/51/Glorious Model D".PointerAccelerationProfile = 1;
    };
}
