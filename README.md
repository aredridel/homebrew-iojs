# homebrew-iojs

A Homebrew formula for https://iojs.org.  Includes the following `iojs` compatibility patches to `npm`:

- https://github.com/iojs/io.js/commit/82227f3 deps: make node-gyp fetch tarballs from iojs.org

> the patch is still compatible with joyent node: http://logs.libuv.org/npm/2015-01-28#21:53:34.823

**NOTE**:  Work on the official homebrew `iojs` formula is ongoing. Follow [the progress here](https://github.com/Homebrew/homebrew/pull/36369)!

## How do I install this formula?
`brew install aredridel/iojs/iojs`

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

## Node 4+

Now including a Node 4+ formula!

```
$ brew update
$ brew install node-alt
```

This is just an alias to this tap's node formula and will install in place of the offical homebrew node formula.

