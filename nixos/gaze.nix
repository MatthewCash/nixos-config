{ inputs, persistPath, ... }:

{
    imports = [ inputs.gaze.nixosModules.default ];

    services.gaze = {
        enable = true;
        mutableConfig = false;

        settings = {
            cameras = {
                ir = "usb:13d3:56eb";
                emitter_enabled = true;
                parallel_capture = "never";
            };
            liveness.threshold = 0.1;
        };
    };

    security.pam.services.sudo.gaze.simultaneous = true;

    environment.persistence.${persistPath}.directories = [
        "/var/lib/gaze"
        "/var/cache/gaze"
    ];
}
