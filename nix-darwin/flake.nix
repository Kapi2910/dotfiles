{
  description = "Kapi nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
	url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    felixkratz-formulae = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, ... }:
  let
    configuration = { pkgs, ... }: {
      system.primaryUser = "kapi";
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [ 
        pkgs.git
        pkgs.neovim
        pkgs.wget
        pkgs.neofetch
        pkgs.git
      ];

      nixpkgs.config.allowBroken = true;
      
      homebrew = {
        enable = true;

        # Uncomment to install cli packages from Homebrew.
        brews = [
           "mas"
	    "stow"
	   "htop"
	  "borders" # JankyBorders
	  "sketchybar"
    "nvm"
        ];

        # Uncomment to install cask packages from Homebrew.
        casks = [
          "balenaetcher"
          "logi-options+"
	  "firefox"
	  "warp"
	  "thunderbird"
	  "discord"
	  "obsidian"
	  "aerospace" # Tiling Manager
    "font-sketchybar-app-font"
    "font-sf-pro"
        ];

        # Uncomment to install app store apps using mas-cli.
        masApps = {
           "WhatsApp" = 310633997;
        };

        # Uncomment to remove any non-specified homebrew packages.
        onActivation.cleanup = "zap";

        # Uncomment to automatically update Homebrew and upgrade packages.
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

	    #List Fonts we want to install
      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ]; 
      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.services.sudo_local.touchIdAuth = true;
      system.defaults = {
        dock.autohide  = true;
        dock.magnification = false;
        dock.mineffect = "genie";
 	dock.persistent-apps = [
		"/Applications/Warp.App"
		"/Applications/Firefox.App"
		"/Applications/Thunderbird.App"
	];
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.KeyRepeat = 2;

	# Finder Settings
	finder.AppleShowAllExtensions = true;
	finder.FXDefaultSearchScope = "SCc";
        finder.FXPreferredViewStyle = "clmv";
	finder.NewWindowTarget = "Home";
	finder.ShowPathbar = true;
	finder.ShowStatusBar = true;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "kapi";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
	      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
	      "nikitabobko/homebrew-tap" = inputs.homebrew-tap;
	      "FelixKratz/homebrew-formulae" = inputs.felixkratz-formulae;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;

            # Automatically migrate existing Homebrew installations
	    autoMigrate = true;
          };
        }
      ];
    };
  };
}
