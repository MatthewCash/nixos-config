{ persistenceHomePath, ... }:

{
  programs.opencode = {
    enable = true;

    settings = {
      autoupdate = false;
      model = "openai/gpt-5.5";
    };

    tui = {
      theme = "system";
    };
  };

  home.persistence."${persistenceHomePath}".files = [
    ".local/share/opencode/auth.json"
  ];
}
