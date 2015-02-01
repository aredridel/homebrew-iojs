# homebrew-iojs
A Homebrew formula for https://iojs.org.  Includes the following patches to `npm`:

- https://github.com/iojs/io.js/commit/82227f3 deps: make node-gyp fetch tarballs from iojs.org

> the patch is still compatible with joyent node: http://logs.libuv.org/npm/2015-01-28#21:53:34.823

**NOTE**:  Work on the official homebrew `iojs` formula is ongoing. Follow [the progress here](https://github.com/Homebrew/homebrew/pull/36369)!

## How do I install this formula?
`brew install aredridel/homebrew-iojs/iojs`

Or `brew tap aredridel/homebrew-iojs` and then `brew install iojs`.

## Documentation
`brew help`, `man brew` or check [Homebrew's documentation](https://github.com/Homebrew/homebrew/tree/master/share/doc/homebrew#readme).
