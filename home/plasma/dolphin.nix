{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.libsForQt5; [ dolphin ];

    programs.plasma.configFile."dolphinrc" = {
        General.Version = 202;
        MainWindow.MenuBar = "Disabled";
    };

    programs.plasma.dataFile."dolphin/dolphinstaterc" = {
        State = {
            RestorePositionForNextInstance = false;
            State = "AAAA/wAAAAD9AAAAAwAAAAAAAADGAAACG/wCAAAAAvsAAAAWAGYAbwBsAGQAZQByAHMARABvAGMAawAAAAAA/////wAAAAIA////+wAAABQAcABsAGEAYwBlAHMARABvAGMAawEAAAAAAAACGwAAAFUA////AAAAAQAAAAAAAAAA/AIAAAAB+wAAABAAaQBuAGYAbwBEAG8AYwBrAAAAAAD/////AAAAAgD///8AAAADAAAAAAAAAAD8AQAAAAH7AAAAGAB0AGUAcgBtAGkAbgBhAGwARABvAGMAawAAAAAA/////wAAAAIA////AAAC4AAAAhsAAAAEAAAABAAAAAgAAAAI/AAAAAEAAAACAAAAAQAAABYAbQBhAGkAbgBUAG8AbwBsAEIAYQByAAAAAAD/////AAAAAAAAAAA=";
        };
    };
}
