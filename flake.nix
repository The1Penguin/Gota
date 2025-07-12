{
  description = "Gota";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {inherit system;};
        toolchain = pkgs.rustPlatform;
      in rec
      {
        packages.default = toolchain.buildRustPackage {
          pname = "gota";
          version = "0.1.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;

          # For other makeRustPlatform features see:
          # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md#cargo-features-cargo-features
          nativeBuildInputs = with pkgs; [
            pkg-config
            openssl
            openssl.dev
          ];
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        };

        apps.default = utils.lib.mkApp {drv = packages.default;};

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (with toolchain; [
              cargo
              rustc
              rustLibSrc
            ])
            clippy
            rustfmt
            rust-analyzer
            pkg-config
            gdb
            lldb
          ];

          # Specify the rust-src path (many editors rely on this)
          RUST_SRC_PATH = "${toolchain.rustLibSrc}";
        };
      }
    );
}
