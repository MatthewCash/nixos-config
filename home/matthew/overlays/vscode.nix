self: super:

{
  
    vscode-fhs = super.vscode-fhs.overrideAttrs (oldAttrs: rec {
      desktopItem = super.makeDesktopItem {
      name = "code";
      icon = "vscode";
      desktopName = "Visual Studio Code";
      comment = "Code Editing. Redefined.";
      genericName = "Text Editor";
      exec = "code";
      startupNotify = "true";
      categories = "Utility;TextEditor;Development;IDE;";
      mimeType = "text/plain;inode/directory;";
      extraEntries = ''
        StartupWMClass=code
        Actions=new-empty-window;
        Keywords=vscode;

        [Desktop Action new-empty-window]
        Name=New Empty Window
        Exec=code %F
        Icon=vscode
      '';
        };
    });
}
