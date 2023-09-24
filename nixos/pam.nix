{ ... }:

{
    security.pam.services = {
        sudo.nodelay = true;
        login.nodelay = true;
        polkit-1.nodelay = true;
    };
}
