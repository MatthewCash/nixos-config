{ ... }:

{
    security.pam.services = {
        sudo.nodelay = true;
        login.nodelay = true;
    };
}
