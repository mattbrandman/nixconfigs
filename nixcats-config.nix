# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
/*
  Call this file with:
  myNixCats = import ./path/to/this/dir { inherit inputs; };
  And the new variable myNixCats will contain all outputs of the normal flake format.
  You could put myNixCats.packages.${pkgs.system}.thepackagename in your packages list.
  You could install them with the module and reconfigure them too if you want.
  You should definitely re export them under packages.${system}.packagenames
  from your system flake so that you can still run it via nix run from anywhere.

  The following is just the outputs function from the flake template.
*/
{ inputs, ... }@attrs:
let
  inherit (inputs) nixpkgs; # <-- nixpkgs = inputs.nixpkgsSomething;
  inherit (inputs.nixCats) utils;
  luaPath = "${./.}";
  forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
  # the following extra_pkg_config contains any values
  # which you want to pass to the config set of nixpkgs
  # import nixpkgs { config = extra_pkg_config; inherit system; }
  # will not apply to module imports
  # as that will have your system values
  extra_pkg_config = {
    # allowUnfree = true;
  };
  inherit
    (forEachSystem (
      system:
      let
        # see :help nixCats.flake.outputs.overlays
        # This overlay grabs all the inputs named in the format
        # `plugins-<pluginName>`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a set of our plugins.
        dependencyOverlays = # (import ./overlays inputs) ++
          [
            (utils.standardPluginOverlay inputs)
            # add any flake overlays here.
          ];
      in
      {
        inherit dependencyOverlays;
      }
    ))
    dependencyOverlays
    ;

  categoryDefinitions =
    {
      pkgs,
      settings,
      categories,
      name,
      ...
    }@packageDef:
    {
      # @dependencies
      lspsAndRuntimeDeps = {
        general =
          with pkgs;
          [
            universal-ctags
            ripgrep
            fd
            stdenv.cc.cc
            wl-clipboard

            # language servers
            basedpyright
            bash-language-server
            gleam
            lua-language-server
            marksman
            nixd
            typos-lsp
            yaml-language-server
            gopls

            # formatting
            nixfmt-rfc-style
            codespell
            nodePackages.prettier
            black
            isort
            stylua
            gawk # trim_whitespace
          ]
          ++ (with python3Packages; [
            debugpy
            python-lsp-server
            pylsp-mypy
            pylsp-rope
          ]);
      };

      # @plugins
      startupPlugins =
        with pkgs.vimPlugins;
        # these are custom plugins, defined as inputs in flake and prefixed with `plugins-`
        with pkgs.neovimPlugins;
        {
          general = [
            vim-sleuth
            lazy-nvim
            comment-nvim
            gitsigns-nvim
            which-key-nvim
            telescope-nvim
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            nvim-web-devicons
            plenary-nvim
            nvim-lspconfig
            lazydev-nvim
            fidget-nvim
            conform-nvim
            nvim-cmp
            luasnip
            cmp_luasnip
            cmp-nvim-lsp
            cmp-path
            tokyonight-nvim
            todo-comments-nvim
            mini-nvim
            nvim-treesitter.withAllGrammars
            indent-blankline-nvim
            nvim-lint

            # debug
            nvim-dap
            nvim-dap-ui
            nvim-nio
            nvim-dap-python
          ];
          themer = with pkgs.vimPlugins;
            (builtins.getAttr categories.colorscheme {
                # Theme switcher without creating a new category
                "onedark" = onedark-nvim;
                "catppuccin" = catppuccin-nvim;
                "catppuccin-mocha" = catppuccin-nvim;
                "tokyonight" = tokyonight-nvim;
                "tokyonight-day" = tokyonight-nvim;
              }
            );
            # This is obviously a fairly basic usecase for this, but still nice.
          # Checking packageDefinitions also has the bonus
          # of being able to be easily set by importing flakes.
        };

      environmentVariables = { };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      extraPython3Packages = {
        general = [ (_: [ ]) ];
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        general = [ (_: [ ]) ];
      };

    };

  packageDefinitions = {
    nixCats =
      { pkgs, ... }:
      {
        # they contain a settings set defined above
        # see :help nixCats.flake.outputs.settings
        settings = {
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = [
            "v"
            "vim"
            "nvim"
          ];

          withRuby = false;
          withPython3 = true;
          withNodeJs = false;
          withPerl = false;

          wrapRc = true;
        };
        categories.general = true;
        categories.coloscheme = "catppuccin-mocha";
      };
    # nvim which loads configuration from ~/.config/nvim, instead
    # of the store
    testNvim =
      { pkgs, ... }:
      {
        settings = {
          aliases = [ "tnvim" ];

          withRuby = false;
          withPython3 = true;
          withNodeJs = false;
          withPerl = false;

          wrapRc = false;
        };
        categories.general = true;
      };
  };
  # In this section, the main thing you will need to do is change the default package name
  # to the name of the packageDefinitions entry you wish to use as the default.
  defaultPackageName = "nixCats";
in
# see :help nixCats.flake.outputs.exports
forEachSystem (
  system:
  let
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit
        system
        dependencyOverlays
        extra_pkg_config
        nixpkgs
        ;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
  in
  {
    # this will make a package out of each of the packageDefinitions defined above
    # and set the default package to the one passed in here.
    packages = utils.mkAllWithDefault defaultPackage;
  }
)
// {
  # this will make an overlay out of each of the packageDefinitions defined above
  # and set the default overlay to the one named here.
  overlays = utils.makeOverlays luaPath {
    # we pass in the things to make a pkgs variable to build nvim with later
    inherit nixpkgs dependencyOverlays extra_pkg_config;
    # and also our categoryDefinitions
  } categoryDefinitions packageDefinitions defaultPackageName;

  # we also export a nixos module to allow reconfiguration from configuration.nix
  nixosModules.default = utils.mkNixosModules {
    inherit
      defaultPackageName
      dependencyOverlays
      luaPath
      categoryDefinitions
      packageDefinitions
      extra_pkg_config
      nixpkgs
      ;
  };
  # and the same for home manager
  homeModule = utils.mkHomeModules {
    inherit
      defaultPackageName
      dependencyOverlays
      luaPath
      categoryDefinitions
      packageDefinitions
      extra_pkg_config
      nixpkgs
      ;
  };
  inherit utils;
  inherit (utils) templates;
}