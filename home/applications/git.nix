{ ... }:

{
    programs.git = {
        enable = true;

        settings = {
            user = {
                name = "Matthew_Cash";
                email = "matthew@matthew-cash.com";
            };

            init.defaultBranch = "main";
            core.whitespace = "trailing-space,space-before-tab";
            push.autoSetupRemote = true;
        };

        signing = {
            signByDefault = true;
            key = "7449B33FA8E4C190";
        };

        lfs.enable = true;
	};

	programs.difftastic.enable = true;
}
