{ pkgsUnstable, config, ... }:

{
    home.packages = [ pkgsUnstable.dotnet-sdk_8 ];

    home.sessionVariables = {
        DOTNET_ROOT = "${config.xdg.configHome}/.dotnet";
        DOTNET_CLI_HOME = config.xdg.configHome;
        NUGET_PACKAEGS = "${config.xdg.cacheHome}/NuGetPackages";
    };
}
