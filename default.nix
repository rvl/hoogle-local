{ nixpkgs ? import <nixpkgs> {} }:

let
  # nixos-unstable as of 20170507
  pkgs = import (nixpkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "c5badb123a2dd6e2b38dcd2ddbe73e13dc6b554f";
    sha256 = "1ay1jy5xrb9cj8x7wz7a7l3zahyhx7m5yky4s206sjl5nrx0xggf";
  }) {};

  hooglePort = "8687";
  hp = (pkgs.haskellPackages.override {
    overrides = self: super: {
      hoogle = super.hoogle.override {
        mkDerivation = args: super.mkDerivation (args // {
          enableSharedExecutables = false;
          #configureFlags = [ "--ghc-option=-optl=-static" "--ghc-option=-optl=-pthread" ];
        });
      };
    };
  }).ghcWithHoogle (import ./package-list.nix);
  hoogle = hp.haskellPackages.hoogle;
  dockerfile = pkgs.writeText "Dockerfile" ''
    FROM alpine:3.3
    COPY tmp /
    EXPOSE ${hooglePort}
    CMD ["/bin/hoogle", "server", "--local", "-p", "${hooglePort}" ]
  '';
in pkgs.writeScript "build.sh" ''
  #!/${pkgs.stdenv.shell} -e

  export PATH=${pkgs.docker}/bin:${pkgs.gnused}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.cpio}/bin:${pkgs.nix}/bin:$PATH

  # copy docs out of haskellPackages nix closure
  for thing in $(nix-store -qR ${hp}); do
      echo "copying $thing"
      find $thing -depth -print | egrep '\.(hoo|css|js|html|png)' | cpio -pvd tmp
  done

  # finds the store path of the hoogle local wrapper (not the best way)
  HOOGLE_LOCAL=$(dirname $(dirname $(readlink ${hp}/bin/hoogle)))

  for thing in ${hp} ${hoogle} ${hp.haskellPackages.ghc.doc} $HOOGLE_LOCAL ${pkgs.glibc} ${pkgs.gmp} ${pkgs.zlib} ${pkgs.stdenv.shell}; do
      echo "fully copying $thing"
      find $thing -depth -print | cpio -pvd tmp
  done

  # install wrapper script in easy-to-inspect place
  mkdir -p tmp/bin
  cp -L ${hp}/bin/hoogle tmp/bin

  # files copied from nix store are read-only, fix that
  chmod -R u+w tmp

  # naughty link fixup -- some browsers don't like file:/// links any more.
  # hoogle also edits the links to add /file prefix
  find tmp -type f -name '*.html' -exec sed -i 's=file:///nix/store=/nix/store=g' '{}' ';'

  # Set up a Dockerfile for the docker build of temp directory
  cp --no-preserve=mode ${dockerfile} tmp-Dockerfile
  docker build -t jwiegley/hoogle-local:latest -f tmp-Dockerfile .
  rm -rf tmp tmp-Dockerfile
''
