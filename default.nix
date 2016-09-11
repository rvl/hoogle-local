{ pkgs ? import <nixpkgs> {} }:

let
  hooglePort = "8687";
  hp = pkgs.haskellPackages.ghcWithHoogle (import ./package-list.nix);
in
pkgs.dockerTools.buildImage {
  name = "jwiegley/hoogle-local";
  contents = [ hp ];
  config = {
    Cmd = [ "${hp}/bin/hoogle" "server" "--local" "-p" "${hooglePort}" ];
    ExposedPorts = {
      "${hooglePort}/tcp" = {};
    };
  };
}
