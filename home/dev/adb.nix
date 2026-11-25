{ pkgsUnstable, persistenceHomePath, ... }:

{
    home.packages = [ pkgsUnstable.android-tools ];

    home.persistence."${persistenceHomePath}".files = [
        ".android/adbkey"
        ".android/adbkey.pub"
    ];
}
