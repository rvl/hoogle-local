This nix derivation builds a Hoogle database within a container, so that it can
be queried on your local machine.

To rebuild the docker image, run:

    nix-build && ./result

To run the Hoogle server:

    docker run -d -p 8687:8687 -ti jwiegley/hoogle-local

Point your browser at http://localhost:8687 after it starts running to
perform queries.
