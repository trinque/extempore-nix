# extempore

Extempore as a Nix flake, built against nixpkgs' libraries. It lives here at
`music/extempore` and is published on its own as `github:trinque/extempore-nix`
by `git subtree`, so everything in this directory, this brief included, is
public. The fleet consumes it as the `extempore` input of `cfg/flake.nix`, with
its nixpkgs following the fleet's.

Where this brief conflicts with the monorepo's, this one governs inside
`music/extempore`.

## What is here

- `package.nix`: the derivation, and Extempore's kiss_fft fork beside it.
- `system-deps.patch`: adds `EXTEMPORE_SYSTEM_DEPS` to upstream's CMake. It is
  ours to maintain, and it is written to the standard upstream would accept
  if they take it: opt-in, refusing the options it cannot honour (`JACK`,
  `EXTERNAL_SHLIBS_GRAPHICS`, Windows) rather than ignoring them, documented
  in `BUILDING.md`, and leaving the default build exactly as it was. Upstream
  may well decline, since a performance tool's authors may want to choose the
  LLVM themselves; offering it is not a condition of keeping it.
- `flake.nix`: `packages`, `overlays.default`, and `checks`, which is the
  package, since its check phase runs upstream's CI test suite.

## Bumping Extempore

1. Set `version` and the source `hash` in `package.nix`.
2. Apply the patch to a checkout of the new tag. Where it no longer applies,
   redo the change against the new CMake, in the patch's existing style, and
   regenerate the patch with `git diff` from that checkout.
3. If upstream moved a pin the patch reads (`DEP_LLVM_VERSION` sets the LLVM
   series), make sure nixpkgs has it.
4. `nix build .#extempore`. The build runs the test suite, and every label
   upstream's CI runs has to pass.
5. Check the default build is untouched: configure the new tag with and
   without the patch, both with `FETCHCONTENT_SOURCE_DIR_{LLVM,PCRE2,GOOGLETEST}`
   pointing at one shared copy of the sources, and diff the two `build.ninja`
   after replacing the source and build directories with fixed names and
   `CMakeFiles/d/<hash>.d` with a constant. The diff must be empty.

## Publishing

From the monorepo root:

    git subtree push --prefix=music/extempore git@github.com:trinque/extempore-nix.git main

A commit here that touches both this directory and the rest of the tree is
split by subtree, but its message goes out whole, so say what a reader of
extempore-nix alone needs in the part about this directory.
