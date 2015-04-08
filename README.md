# homebrew-iojs
A Homebrew formula for https://iojs.org.

Mimicks the execution of `node-gyp install`:

- Avoid re-downloading the iojs sources
- Avoid patching node-gyp
- Fully compatible with nodejs

**NOTE**:  Work on the official homebrew `iojs` formula is ongoing. Follow [the progress here](https://github.com/Homebrew/homebrew/pull/36369)!

## How do I install this formula?
`brew install aredridel/homebrew-iojs/iojs`

Or `brew tap aredridel/iojs` and then `brew install aredridel/iojs/iojs`.

## Documentation

Since there is an existing `iojs` formula in the offical homebrew repository, you have to reference the fully-qualified formula name when interacting with this formula.  e.g.
```
brew install aredridel/iojs/iojs
brew upgrade aredridel/iojs/iojs
brew info aredridel/iojs/iojs
brew uninstall aredridel/iojs/iojs
brew unlink aredridel/iojs/iojs
brew link aredridel/iojs/iojs
```

`brew help`, `man brew` or check [Homebrew's documentation](https://github.com/Homebrew/homebrew/tree/master/share/doc/homebrew#readme).
