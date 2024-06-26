{ ... }:

{
    programs.git = {
        enable = true;

        userName = "Matthew_Cash";
        userEmail = "matthew@matthew-cash.com";

        signing = {
            signByDefault = true;
            key = "7449B33FA8E4C190";
        };

        extraConfig = {
            init.defaultBranch = "main";
            core.whitespace = "trailing-space,space-before-tab";
            push.autoSetupRemote = true;
        };

        difftastic.enable = true;

        lfs.enable = true;
	};
}
