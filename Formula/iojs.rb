class Iojs < Formula
  homepage "https://iojs.org/"
  url "https://iojs.org/dist/v2.5.0/iojs-v2.5.0.tar.xz"
  sha256 "0ad1bca083cbdf9a67fc55e1b1d47d8cc3bc6473e4a3af083c9f67ace3e7e75e"

  conflicts_with "node", :because => "io.js includes a symlink named node for compatibility."

  option "with-debug", "Build with debugger hooks"
  option "without-npm", "npm will not be installed"
  option "without-completion", "npm bash completion will not be installed"

  depends_on :python => :build

  resource "npm" do
    url "https://registry.npmjs.org/npm/-/npm-2.13.2.tgz"
    sha256 "e9714e307b3ab13630ab0e32de35405e522802ba755f502edca81c4c6b60bec8"
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
        system "./configure", "--prefix=#{libexec}/npm"
        system "make", "install"
      end

      # Pre-download the sources for node-gyp until github.com/TooTallNate/node-gyp/pull/564 is resolved
      if File.directory?("#{ENV['HOME']}/.node-gyp/#{version}")
        system "rm", "-rf", "#{ENV['HOME']}/.node-gyp/#{version}"
      end
      system "mkdir", "-p", "#{ENV['HOME']}/.node-gyp/#{version}"
      system "cp", "-a", "#{buildpath}/.", "#{ENV['HOME']}/.node-gyp/#{version}"
      # mimick node-gyp version install. The number '9' has not changed since June 2012:
      # https://github.com/TooTallNate/node-gyp/commit/569a9b2b4f55faa4347448058f6c4b2e791c3934
      File.open("#{ENV['HOME']}/.node-gyp/#{version}/installVersion", 'w') {|f| f.write("9") }

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
