FROM debian:wheezy

RUN apt-get update
RUN apt-get install -y curl bzip2 adduser perl git

RUN adduser --disabled-password --gecos '' hoogle

RUN mkdir -m 0755 /nix && chown hoogle /nix

USER hoogle
ENV USER hoogle
WORKDIR /home/hoogle

RUN curl https://nixos.org/nix/install | sh
RUN . ~/.nix-profile/etc/profile.d/nix.sh && nix-channel --remove nixpkgs
RUN git clone https://github.com/nixos/nixpkgs .nix-defexpr/nixpkgs
ENV NIX_PATH /home/hoogle/.nix-defexpr

RUN mkdir .nixpkgs
COPY config.nix .nixpkgs
COPY local.nix .nixpkgs
COPY hoogle-local-wrapper.sh .nixpkgs

RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
    nix-env -f '<nixpkgs>' -Q --fallback -i env-ghc710 --show-trace

ENV PORT 8687
EXPOSE $PORT

ENTRYPOINT ["~/.nix-profile/bin/load-env-ghc710", "hoogle"]
