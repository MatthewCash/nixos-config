{ ... }:

{
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            # Web
            "x-scheme-handler/http" = [ "org.mozilla.Firefox.floating.desktop" ];
            "x-scheme-handler/https" = [ "org.mozilla.Firefox.floating.desktop" ];
            "application/pdf"       = [ "org.kde.okular.desktop" "org.mozilla.Firefox.floating.desktop" ];

            # Files
            "inode/directory" = [ "org.kde.dolphin.desktop" ];

            # Mail
            "x-scheme-handler/mailto" = [ "org.kde.kmail.desktop" ];

            # Images
            "image/jpeg"  = [ "org.kde.gwenview.desktop" ];
            "image/bmp"   = [ "org.kde.gwenview.desktop" ];
            "image/gif"   = [ "org.kde.gwenview.desktop" ];
            "image/jpg"   = [ "org.kde.gwenview.desktop" ];
            "image/pjpeg" = [ "org.kde.gwenview.desktop" ];
            "image/png"   = [ "org.kde.gwenview.desktop" ];
            "image/tiff"  = [ "org.kde.gwenview.desktop" ];
            "image/x-bmp" = [ "org.kde.gwenview.desktop" ];
            "image/x-gray" = [ "org.kde.gwenview.desktop" ];
            "image/x-icb" = [ "org.kde.gwenview.desktop" ];
            "image/x-ico" = [ "org.kde.gwenview.desktop" ];
            "image/x-png" = [ "org.kde.gwenview.desktop" ];
            "image/x-portable-anymap" = [ "org.kde.gwenview.desktop" ];
            "image/x-portable-bitmap" = [ "org.kde.gwenview.desktop" ];
            "image/x-portable-graymap" = [ "org.kde.gwenview.desktop" ];
            "image/x-portable-pixmap" = [ "org.kde.gwenview.desktop" ];
            "image/x-xbitmap" = [ "org.kde.gwenview.desktop" ];
            "image/x-xpixmap" = [ "org.kde.gwenview.desktop" ];
            "image/x-pcx" = [ "org.kde.gwenview.desktop" ];
            "image/svg+xml" = [ "org.kde.gwenview.desktop" ];
            "image/svg+xml-compressed" = [ "org.kde.gwenview.desktop" ];
            "image/vnd.wap.wbmp" = [ "org.kde.gwenview.desktop" ];
            "image/x-icns" = [ "org.kde.gwenview.desktop" ];
        };
    };
}

