{ lib, package }:
{
  programs.agent-browser = {
    enable = lib.mkEnableOption "agent-browser, a browser automation CLI for AI agents";

    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "agent-browser package to install.";
    };
  };
}
