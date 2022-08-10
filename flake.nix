{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.wbba = {
    url = "github:sohalt/write-babashka-application";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, flake-utils, wbba, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ wbba.overlays.default ];
        };
        hello-babashka = pkgs.writeBabashkaApplication {
          name = "hello";
          text = ''
            (ns hello
              (:require [babashka.process :refer [sh]]))

            (-> (sh ["cowsay" "hello from babashka"])
                 :out
                 print)
          '';
          runtimeInputs = with pkgs;[
            cowsay
          ];
        };
      in
      {
        defaultApp = hello-babashka;
        defaultPackage = hello-babashka;
      });
}
