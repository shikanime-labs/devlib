{ pkgs, ... }: {
  home.packages = with pkgs; [
    ghstack
    tea
    glab
  ];

  programs.gh.enable = true;
}
