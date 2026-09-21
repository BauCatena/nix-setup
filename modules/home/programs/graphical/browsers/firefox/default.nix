{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf types mkMerge optionalAttrs mkEnableOption;

  inherit (lib.bautinix) mkBoolOpt mkOpt;

  cfg = config.bautinix.programs.graphical.browsers.firefox;
  font = config.bautinix.fonts;
in
{
  options.bautinix.programs.graphical.browsers.firefox = with types; {
    enable = mkEnableOption "firefox";

    extraConfig = mkOpt str "" "Extra configuration for profile";
      gpuAcceleration = mkBoolOpt false "Enable GPU acceleration.";
      hardwareDecoding = mkBoolOpt false "Enable hardware video decoding.";

      policies = mkOpt attrs {

        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = true;
        DontCheckDefaultBrowser = true;

        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        PasswordManagerEnabled = false;

        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      } "Policies for firefox";

    settings = mkOpt attrs { } "Settings";
  };

  imports = [
    ./extensions.nix
  ];


  config = mkIf cfg.enable {

    programs.firefox = {
      enable = true;

      inherit (cfg) policies;

      profiles = {
        ${config.bautinix.user.name} = {
          inherit (cfg) extraConfig;
          inherit (config.bautinix.user) name;
          id = 0;
          isDefault = true;   # <-- make this the one Firefox actually opens
          settings = mkMerge [
              cfg.settings
              {
                "accessibility.typeaheadfind.enablesound" = false;
                "accessibility.typeaheadfind.flashBar" = 0;

                "browser.aboutConfig.showWarning" = true;
                "browser.aboutwelcome.enabled" = false;
                "browser.bookmarks.autoExportHTML" = true;
                "browser.bookmarks.showMobileBookmarks" = true;
                "browser.chrome.site_icons" = true;
                "browser.meta_refresh_when_inactive.disabled" = true;
                "browser.newtabpage.activity-stream.default.sites" = "";
                "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
                "browser.newtabpage.activity-stream.showSponsored" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                "browser.search.hiddenOneOffs" = "Google,Amazon.com,Bing,DuckDuckGo,eBay,Wikipedia (en)";
                "browser.search.suggest.enabled" = false;
                "browser.sessionstore.warnOnQuit" = true;
                "browser.shell.checkDefaultBrowser" = false;
                "browser.ssb.enabled" = true;
                "browser.startup.homepage.abouthome_cache.enabled" = true;
                "browser.startup.page" = 3;
                "browser.urlbar.keepPanelOpenDuringImeComposition" = true;
                "browser.urlbar.suggest.quicksuggest.sponsored" = false;

                "devtools.chrome.enabled" = true;
                "devtools.debugger.remote-enabled" = true;
                "dom.forms.autocomplete.formautofill" = true;
                "dom.storage.next_gen" = true;
                "extensions.formautofill.addresses.enabled" = false;
                "extensions.formautofill.creditCards.enabled" = false;
                "extensions.htmlaboutaddons.recommendations.enabled" = false;

                "general.autoScroll" = false;
                "general.smoothScroll.msdPhysics.enabled" = true;
                "geo.enabled" = false;
                "geo.provider.use_corelocation" = false;
                "geo.provider.use_geoclue" = false;
                "geo.provider.use_gpsd" = false;

                "intl.accept_languages" = "en-US,en";
                "media.eme.enabled" = true;
                "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;

                "signon.autofillForms" = false;
                "signon.firefoxRelay.feature" = "disabled";
                "signon.generation.enabled" = false;
                "signon.management.page.breach-alerts.enabled" = false;
                "signon.rememberSignons" = false;

                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                "xpinstall.signatures.required" = false;

                "browser.startup.homepage" = "about:blank";
                "browser.newtab.url" = "about:blank";
                "browser.ctrlTab.sortByRecentlyUsed" = false;
                "browser.tabs.closeWindowWithLastTab" = true;

                "browser.download.start_downloads_in_tmp_dir" = true;
                "browser.download.useDownloadDir" = true;

                "media.block-autoplay-until-in-foreground" = true;
                "media.block-play-until-document-interaction" = true;
                "media.block-play-until-visible" = true;

                "privacy.clearOnShutdown.history" = false;
                "privacy.donottrackheader.enabled" = true;
                "privacy.trackingprotection.enabled" = true;
                "privacy.trackingprotection.socialtracking.enabled" = true;
                "device.sensors.enabled" = false;
                # Bluetooth location tracking
                "beacon.enabled" = false;

                "browser.send_pings" = false;
                "toolkit.telemetry.archive.enabled" = false;
                "toolkit.telemetry.enabled" = false;
                "toolkit.telemetry.server" = "";
                "toolkit.telemetry.unified" = false;
                "extensions.webcompat-reporter.enabled" = false;
                "datareporting.policy.dataSubmissionEnabled" = false;
                "datareporting.healthreport.uploadEnabled" = false;
                "browser.ping-centre.telemetry" = false;
                "browser.urlbar.eventTelemetry.enabled" = false;
                "browser.tabs.crashReporting.sendReport" = false;

                "app.normandy.enabled" = false;
                "app.shield.optoutstudies.enabled" = false;

                "extensions.pocket.enabled" = false;
                "browser.vpn_promo.enabled" = false;
                "extensions.abuseReport.enabled" = false;

                # Firefox login
                # "identity.fxaccounts.enabled" = false;
                # "identity.fxaccounts.toolbar.enabled" = false;
                # "identity.fxaccounts.pairing.enabled" = false;
                # "identity.fxaccounts.commands.enabled" = false;

                # Firefox password manager
                "browser.contentblocking.report.lockwise.enabled" = false;
                "browser.uitour.enabled" = false;

                "dom.push.enabled" = false;
                "dom.push.connection.enabled" = false;
                "dom.battery.enabled" = false;
                "dom.private-attribution.submission.enabled" = false;

              }
              (optionalAttrs cfg.gpuAcceleration {
                "dom.webgpu.enabled" = true;
                "gfx.webrender.all" = true;
                "layers.gpu-process.enabled" = true;
              })
              (optionalAttrs cfg.hardwareDecoding {
                "media.ffmpeg.vaapi.force-surface-zero-copy" = true;
                "media.gpu-process-decoder" = true;
                "media.gpu-process-encoder" = true;
                "media.hardware-video-decoding.enabled" = true;
              })
            ];
          };
        };
    };
  };
}
