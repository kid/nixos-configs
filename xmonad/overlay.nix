_: pkgs: rec {
  haskellPackages = pkgs.haskellPackages.override (old: {
    overrides = pkgs.lib.composeExtensions (old.overrides or (_: _: { })) (self: super: rec {
      xmonad-kid = self.callCabal2nix "xmonad-kid"
        (
          pkgs.lib.sourceByRegex ./.
            [
              "xmonad.hs"
              "xmonad-kid.cabal"
            ]
        )
        { };
    });
  });
}
