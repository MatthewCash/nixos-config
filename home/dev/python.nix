{ pkgsStable, pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, config, ... }:

let
    # Adapted from https://unix.stackexchange.com/a/675631
    pythonStartup = pkgsStable.writeText "startup.py" /* python */ ''
        import os
        import atexit
        import readline

        history = os.path.realpath('${config.xdg.cacheHome}/python/repl_history')

        try:
            readline.read_history_file(history)
        except OSError:
            pass

        def write_history():
            try:
                readline.write_history_file(history)
            except OSError:
                pass

        atexit.register(write_history)
    '';
in

{
    home.persistence."${persistenceHomePath}" = stableLib.mkIf useImpermanence {
        files = [
            ".cache/python/repl_history"
        ];
    };

    home.sessionVariables = {
        PYTHONSTARTUP = pythonStartup;
    };

    home.packages = with pkgsUnstable; [
        (python3.withPackages (pyPkgs: with pyPkgs; [
            requests
            uv
        ]))
    ];
}
