class Iojs < Formula
  homepage "https://iojs.org/"
  url "https://iojs.org/dist/v2.2.1/iojs-v2.2.1.tar.xz"
  sha256 "26cce6e3581185ef3b1fe486a86ba9e18d611f6dfe439cfcbcfc8e639436a5bd"

  conflicts_with "node", :because => "io.js includes a symlink named node for compatibility."

  option "with-debug", "Build with debugger hooks"
  option "without-npm", "npm will not be installed"
  option "without-completion", "npm bash completion will not be installed"

  depends_on :python => :build

  resource "npm" do
    url "https://registry.npmjs.org/npm/-/npm-2.11.0.tgz"
    sha256 "c35f1b89705d63e76c8548647b0fa016e0bedee899a51ba93895db1d5eda940b"
  end

  def install
    args = %W[--prefix=#{prefix} --without-npm]
    args << "--debug" if build.with? "debug"

    system "./configure", *args
    system "make", "install"

    if build.with? "npm"
      resource("npm").stage buildpath/"npm_install"

      # make sure npm can find iojs
      ENV.prepend_path "PATH", bin

      # set log level temporarily for npm's `make install`
      ENV["NPM_CONFIG_LOGLEVEL"] = "verbose"

      cd buildpath/"npm_install" do
        # Patch node-gyp until github.com/TooTallNate/node-gyp/pull/564 is resolved
        # Patch extracted from https://github.com/iojs/io.js/commit/82227f3
        p = Patch.create(:p1, :DATA)
        p.path = Pathname.new(__FILE__).expand_path
        p.apply
        system "./configure", "--prefix=#{libexec}/npm"
        system "make", "install"
      end

      if build.with? "completion"
        bash_completion.install \
          buildpath/"npm_install/lib/utils/completion.sh" => "npm"
      end
    end
  end

  def post_install
    return if build.without? "npm"

    node_modules = HOMEBREW_PREFIX/"lib/node_modules"
    node_modules.mkpath
    npm_exec = node_modules/"npm/bin/npm-cli.js"
    # Kill npm but preserve all other modules across iojs updates/upgrades.
    rm_rf node_modules/"npm"

    cp_r libexec/"npm/lib/node_modules/npm", node_modules
    # This symlink doesn't hop into homebrew_prefix/bin automatically so
    # remove it and make our own. This is a small consequence of our bottle
    # npm make install workaround. All other installs **do** symlink to
    # homebrew_prefix/bin correctly. We ln rather than cp this because doing
    # so mimics npm's normal install.
    ln_sf npm_exec, "#{HOMEBREW_PREFIX}/bin/npm"

    # Let's do the manpage dance. It's just a jump to the left.
    # And then a step to the right, with your hand on rm_f.
    ["man1", "man3", "man5", "man7"].each do |man|
      mkdir_p HOMEBREW_PREFIX/"share/man/#{man}"
      rm_f Dir[HOMEBREW_PREFIX/"share/man/#{man}/{npm.,npm-,npmrc.}*"]
      Dir[libexec/"npm/share/man/#{man}/npm*"].each { |f| ln_sf f, HOMEBREW_PREFIX/"share/man/#{man}" }
    end

    npm_root = node_modules/"npm"
    npmrc = npm_root/"npmrc"
    npmrc.atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  def caveats
    s = ""

    if build.with? "npm"
      s += <<-EOS.undent
        npm has been installed and updated to latest. To update run
          npm install -g npm@latest

        You can install global npm packages with
          npm install -g <package>

        They will install into the global node_modiles directory
          /usr/local/lib/node_modules

        Do NOT use the npm update command with global modules.
        The upstream-recommended way to update global modules is:
          npm install -g <package>@latest
      EOS
    else
      s += <<-EOS.undent
        Homebrew has NOT installed npm. If you later install it, you should supplement
        your NODE_PATH with the npm module folder:
          #{HOMEBREW_PREFIX}/lib/node_modules
      EOS
    end

    s
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = `#{bin}/iojs #{path}`.strip
    assert_equal "hello", output
    assert_equal 0, $?.exitstatus

    if build.with? "npm"
      # make sure npm can find node
      ENV.prepend_path "PATH", opt_bin
      assert_equal which("node"), opt_bin/"node"
      assert (HOMEBREW_PREFIX/"bin/npm").exist?, "npm must exist"
      assert (HOMEBREW_PREFIX/"bin/npm").executable?, "npm must be executable"
      system "#{HOMEBREW_PREFIX}/bin/npm", "--verbose", "install", "npm@latest"
      system "#{HOMEBREW_PREFIX}/bin/npm", "--verbose", "install", "buffertools"
    end
  end
end

__END__
diff --git a/node_modules/node-gyp/lib/install.js b/node_modules/node-gyp/lib/install.js
index 6f72e6a..ebc4e57 100644
--- a/node_modules/node-gyp/lib/install.js
+++ b/node_modules/node-gyp/lib/install.js
@@ -39,7 +39,7 @@ function install (gyp, argv, callback) {
     }
   }

-  var distUrl = gyp.opts['dist-url'] || gyp.opts.disturl || 'http://nodejs.org/dist'
+  var distUrl = gyp.opts['dist-url'] || gyp.opts.disturl || 'https://iojs.org/dist'


   // Determine which node dev files version we are installing
@@ -185,7 +185,7 @@ function install (gyp, argv, callback) {

       // now download the node tarball
       var tarPath = gyp.opts['tarball']
-      var tarballUrl = tarPath ? tarPath : distUrl + '/v' + version + '/node-v' + version + '.tar.gz'
+      var tarballUrl = tarPath ? tarPath : distUrl + '/v' + version + '/iojs-v' + version + '.tar.gz'
         , badDownload = false
         , extractCount = 0
         , gunzip = zlib.createGunzip()
