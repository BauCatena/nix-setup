{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.bautinix) mkOpt;

  cfg = config.bautinix.programs.graphical.browsers.firefox;
  extensionPackages = cfg.extensions.packages ++ cfg.extensions.extraPackages;
  globalExtensions = map (package: {
    inherit package;
    settings.updates_disabled = true;
  }) extensionPackages;
in
{
  options.bautinix.programs.graphical.browsers.firefox = {
    extensions = {
      installMethod = mkOpt (lib.types.enum [
        "profile"
        "policy"
      ]) "profile" "How to install Firefox extensions.";

      packages = mkOpt (with lib.types; listOf package) (with pkgs.firefox-addons; [
        bitwarden
        darkreader
        ublock-origin
        sponsorblock
        surfingkeys
      ]) "Extensions to install";

      extraPackages = mkOpt (with lib.types; listOf package) [ ] "Additional extensions to install.";

      settings = mkOpt (with lib.types; attrsOf anything) {
      } "Settings to apply to the extensions.";

      policy = {
        installationMode = mkOpt (lib.types.enum [
          "force_installed"
          "normal_installed"
        ]) "force_installed" "Firefox ExtensionSettings installation mode.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion =
              cfg.extensions.installMethod != "policy"
              || cfg.extensions.policy.installationMode == "force_installed";
            message = "Firefox native globalExtensions only supports force_installed policy installs.";
          }
        ];

        programs.firefox.profiles.${config.bautinix.user.name}.extensions = {
          inherit (cfg.extensions) settings;
          force = true;
        };
      }

      (lib.mkIf (cfg.extensions.installMethod == "profile") {
        programs.firefox.profiles.${config.bautinix.user.name}.extensions = {
          packages = extensionPackages;
        };
      })
      (lib.mkIf (cfg.extensions.installMethod == "policy") {
        programs.firefox.policies.ExtensionSettings = lib.listToAttrs (
          map (pkg: {
            name = pkg.addonId;
            value = {
              installation_mode = cfg.extensions.policy.installationMode;
              install_url = "file://${pkg}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${pkg.addonId}.xpi";
            };
          }) extensionPackages
        );
      })
    ]
  );
}
