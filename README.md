# extempore-nix

[Extempore](https://github.com/digego/extempore), the live-coding environment
for music and audio, as a Nix flake.

```sh
nix run github:trinque/extempore-nix
```

or, in a flake:

```nix
inputs.extempore.url = "github:trinque/extempore-nix";
# then extempore.packages.${system}.extempore, or extempore.overlays.default
# for pkgs.extempore
```

## How it differs from upstream's build

Upstream's CMake downloads and compiles its own LLVM, PCRE2, PortAudio,
portmidi, rtmidi, libsndfile and GoogleTest, at versions it pins. The build
sandbox has no network, and nixpkgs has all of them, so
[`system-deps.patch`](system-deps.patch) adds an opt-in CMake option,
`EXTEMPORE_SYSTEM_DEPS`, that finds the installed ones instead. With the option
off, upstream's build is unchanged. The patch is written to be offered
upstream.

- LLVM is nixpkgs' `llvmPackages_22`, the release series upstream pins (22.1),
  linked statically from its component libraries as upstream links its own.
- Extempore's fork of KISS FFT is not in nixpkgs and is built here.
- The binary sits with `runtime/`, `libs/` and `examples/` beside it under
  `share/extempore`, the layout of upstream's release archives, and the
  standard library is AOT-compiled during the build.

The build runs the test suite upstream's CI runs, so a package that builds has
passed it.

## Editors

Extempore listens on TCP port 7099. For Emacs, `extempore-mode` is in nixpkgs
(`emacsPackages.extempore-mode`) and finds `extempore` on `PATH`.

## Platforms

Linux, `x86_64-linux` and `aarch64-linux`. Built and tested on
`x86_64-linux`. Not macOS yet.

## License

This repository's own files are in the public domain (see `LICENSE`).
Extempore is BSD-3-Clause, and the patch modifies its build files.
