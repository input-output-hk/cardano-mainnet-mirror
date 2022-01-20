{
  outputs = { nixpkgs, self }:
  let
    overlay = self: super: {
      chain = self.callPackage ./chain.nix {};
    };
  in
  {
    overlay = overlay;
    defaultPackage.x86_64-linux = (import nixpkgs { system = "x86_64-linux"; overlays = [ overlay ]; }).chain;
  };
}
