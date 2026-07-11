# Backends

log4types runs on the `chez` (default), `racket`, `refc`, and `node` code
generators. The library contains a single `%foreign` declaration (the
`rename` used by file rotation), provided for both the C family and node;
everything else is pure Idris plus `base` primitives. `chez-sep` and incremental compilation are build variants of the
Chez runtime and need no separate support.

## Selecting a backend

With [pack](https://github.com/stefan-hoeck/idris2-pack), pass the code
generator per invocation:

```sh
pack --cg node test log4types
```

or set it in your `pack.toml`:

```toml
[idris2]
codegen = "node"
```

## Per-backend notes

- `node`: file logging, rotation (rename via `fs.renameSync`), and TTY
  detection (`tty.isatty`) all work. One cosmetic difference: JSON *number*
  formatting follows the backend's `Show Double` - an integer field renders
  as `{"count":99.0}` on chez but `{"count":99}` on node. Both parse to the
  same value; do not string-match numeric log output across backends.
- `refc`: the C-family `%foreign` declarations (including `rename` from
  libc) are native here. A known upstream idris2 bug miscompiles casts from
  `String` on refc; `JSON.parse` triggers it, so the log4types-json test
  suite is skipped on the refc CI leg. The library's encoding path is
  unaffected.
- `racket`: consumes the same C support library as chez; log4types uses no
  concurrency primitives.
