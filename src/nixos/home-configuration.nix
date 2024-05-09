{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    extraConfig.credential = {
      credentialStore = "secretservice"; # https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/credstores.md
      helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "{{ VERSION_ID }}";
}
