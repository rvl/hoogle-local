FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y curl bzip2 adduser perl git

RUN adduser --disabled-password --gecos '' hoogle

RUN mkdir -m 0755 /nix && chown hoogle /nix

USER hoogle
ENV USER hoogle
WORKDIR /home/hoogle

RUN curl https://nixos.org/nix/install | sh
RUN . ~/.nix-profile/etc/profile.d/nix.sh && nix-channel --remove nixpkgs
RUN git clone --depth 1 https://github.com/nixos/nixpkgs /home/hoogle/.nix-defexpr/nixpkgs
ENV NIX_PATH /home/hoogle/.nix-defexpr

RUN . ~/.nix-profile/etc/profile.d/nix.sh && nix-env -u --leq

RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
  nix-env -Q -j4 -k -iA nixpkgs.haskellPackages.ghc

RUN . ~/.nix-profile/etc/profile.d/nix.sh && \
  nix-env -Q -j4 -k -iA nixpkgs.haskellPackages.hoogle_4_2_43

COPY hinst .

RUN ./hinst Boolean \
            HTTP \
            HUnit \
            IfElse \
            MemoTrie \
            MissingH \
            MonadCatchIO-transformers \
            QuickCheck \
            abstract-deque \
            abstract-par \
            adjunctions \
            aeson \
            async \
            attempt \
            attoparsec \
            attoparsec-conduit \
            attoparsec-enumerator \
            base-unicode-symbols \
            base16-bytestring \
            base64-bytestring \
            basic-prelude \
            bifunctors \
            bindings-DSL \
            blaze-builder \
            blaze-builder-conduit \
            blaze-builder-enumerator \
            blaze-html \
            blaze-markup \
            blaze-textual \
            bool-extras \
            byteable \
            byteorder \
            bytes \
            bytestring-mmap \
            case-insensitive \
            cassava \
            categories \
            cereal \
            cereal-conduit \
            charset \
            chunked-data \
            classy-prelude \
            classy-prelude-conduit \
            cmdargs \
            comonad \
            comonad-transformers \
            compdata \
            composition \
            compressed \
            cond

#             data-fin
#             filepath
#             haskeline
#             hoopl
RUN ./hinst conduit \
            conduit-combinators \
            conduit-extra \
            configurator \
            constraints \
            contravariant \
            convertible \
            cpphs \
            criterion \
            cryptohash \
            css-text \
            curl \
            data-checked \
            data-default \
            data-fix \
            derive \
            distributive \
            dlist \
            dlist-instances \
            dns \
            doctest \
            doctest-prop \
            either \
            enclosed-exceptions \
            errors \
            exceptions \
            exceptions \
            extensible-exceptions \
            failure \
            fast-logger \
            fgl \
            file-embed \
            fingertree \
            fmlist \
            foldl \
            free \
            fsnotify \
            ghc-paths \
            graphviz \
            groups \
            hamlet \
            hashable \
            hashtables \
            haskell-lexer \
            haskell-src \
            haskell-src-exts

#             language-java
RUN ./hinst hslogger \
            hspec \
            hspec-expectations \
            hspec-wai \
            html \
            http-client \
            http-date \
            http-types \
            io-memoize \
            io-storage \
            io-streams \
            json \
            kan-extensions \
            keys \
            language-c \
            lattices \
            lens \
            lens-action \
            lens-aeson \
            lens-datetime \
            lens-family \
            lens-family-core \
            lifted-async \
            lifted-base \
            linear \
            list-extras \
            list-t \
            logict \
            machines \
            mime-mail \
            mime-types \
            mmorph \
            monad-control \
            monad-coroutine \
            monad-loops \
            monad-par \
            monad-par-extras \
            monad-stm \
            monadloc \
            mono-traversable \
            monoid-extras \
            mtl \
            multimap \
            multirec \
            network \
            newtype \
            numbers \
            operational

#            recursion-schemes
RUN ./hinst optparse-applicative \
            pandoc \
            parallel \
            parallel-io \
            parsec \
            parsers \
            pipes \
            pipes-attoparsec \
            pipes-binary \
            pipes-bytestring \
            pipes-concurrency \
            pipes-extras \
            pipes-group \
            pipes-http \
            pipes-network \
            pipes-parse \
            pipes-safe \
            pipes-text \
            pointed \
            posix-paths \
            postgresql-simple \
            pretty-show \
            profunctors \
            random

RUN ./hinst reducers \
            reflection \
            regex-applicative \
            regex-base \
            regex-compat \
            regex-posix \
            resourcet \
            retry \
            safe \
            sbv \
            scalpel \
            scotty \
            semigroupoids \
            semigroups \
            shake \
            shakespeare \
            shelly \
            simple-reflect \
            singletons \
            speculation \
            split \
            spoon

RUN ./hinst stm \
            stm-chans \
            stm-stats \
            streaming \
            streaming-bytestring \
            strict \
            stringsearch \
            strptime \
            syb \
            system-fileio \
            system-filepath \
            tagged \
            tar \
            tardis \
            tasty \
            tasty-hspec \
            tasty-hunit \
            tasty-quickcheck \
            tasty-smallcheck \
            temporary \
            text \
            text-format \
            these \
            thyme

#            timeparsers
RUN ./hinst time-recurrence \
            total \
            transformers-base \
            turtle \
            uniplate \
            units \
            unix-compat \
            unordered-containers \
            uuid \
            vector \
            void \
            wai \
            warp \
            yaml \
            zippers \
            zlib

ENV PORT 8687
EXPOSE $PORT

COPY package-list .
COPY runhoogle .
COPY wraphoogle .

RUN ./wraphoogle "echo built"

ENTRYPOINT ["./wraphoogle", "hoogle server --local -p 8687"]
