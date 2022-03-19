{ config, ... }:

let
    windowsMountOptions = [ "credentials=${config.age.secrets.nixvm-smb-creds.path}" "uid=matthew" "gid=users" "nofail" "noauto" "noatime" "exec" "x-systemd.automount" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" "mfsymlinks" ];
    windowsBindMountOptions = [ "bind" "nofail" ];
in

{
    age.secrets.nixvm-smb-creds.file = ../../../secrets/nixvm-smb-creds.age;    

    services.samba.enable = true;

    fileSystems = {
        windows = {
            device = "//host/Windows";
            fsType = "cifs";
            mountPoint = "/mnt/win";
            options = windowsMountOptions;
        };

        storage = {
            device = "//host/Storage";
            fsType = "cifs";
            mountPoint = "/mnt/storage";
            options = windowsMountOptions;
        };

        archive = {
            device = "//host/Archive";
            fsType = "cifs";
            mountPoint = "/mnt/archive";
            options = windowsMountOptions;
        };

        # Windows Bind Mounts

        windows-code = {
            device = "/mnt/win/Users/Matthew/Code";
            mountPoint = "/home/matthew/code";
            options = windowsBindMountOptions;
        };

        windows-downloads = {
            device = "/mnt/win/Users/Matthew/Downloads";
            mountPoint = "/home/matthew/downloads";
            options = windowsBindMountOptions;
        };

        storage-documents = {
            device = "/mnt/storage/Libraries/Documents";
            mountPoint = "/home/matthew/documents";
            options = windowsBindMountOptions;
        };

        storage-videos = {
            device = "/mnt/storage/Libraries/Videos";
            mountPoint = "/home/matthew/videos";
            options = windowsBindMountOptions;
        };

        storage-pictures = {
            device = "/mnt/storage/Libraries/Pictures";
            mountPoint = "/home/matthew/pictures";
            options = windowsBindMountOptions;
        };

        archive-torrents = {
            device = "/mnt/archive/Torrents";
            mountPoint = "/home/matthew/torrents";
            options = windowsBindMountOptions;
        };
    };
}
