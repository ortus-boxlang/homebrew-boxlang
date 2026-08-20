class Bvm < Formula
  desc "BoxLang Version Manager - install and manage multiple BoxLang versions"
  homepage "https://boxlang.io"
  url "https://github.com/ortus-boxlang/boxlang-quick-installer/archive/refs/tags/v1.33.0.tar.gz"
  sha256 "c1df764c06455df212bdac6d0a0e115915db31372dd22fac598cc336ce0925a5"
  version "1.33.0"
  license "Apache-2.0"

  depends_on "curl"
  depends_on "jq"
  depends_on "openjdk@21"
  depends_on "unzip"

  def install
    # Replace the build-time version placeholder with the actual release version
    inreplace "src/bvm.sh", "@build.version@", version
    inreplace "src/install-bvm.sh", "@build.version@", version

    # Install only BVM scripts and shared helpers into libexec so relative paths resolve correctly
    bvm_files = Dir["src/*"].reject { |f| File.basename(f).start_with?("boxlang") }
    libexec.install bvm_files

    # Create thin wrappers in bin so the commands appear in PATH
    (bin/"bvm").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bvm.sh" "$@"
    EOS

    (bin/"install-bvm").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/install-bvm.sh" "$@"
    EOS
  end

  def caveats
    <<~EOS
      BVM (BoxLang Version Manager) has been installed.

      Install and activate the latest BoxLang version:
        bvm install latest
        bvm use latest

      Common BVM commands:
        bvm install latest    # Install the latest stable BoxLang
        bvm use latest        # Switch to the latest installed version
        bvm list              # List locally installed versions
        bvm current           # Show the active version
        bvm help              # Show all available commands

      After a version is installed and activated you can run:
        boxlang               # Start the BoxLang REPL
        boxlang-miniserver    # Start the BoxLang MiniServer
    EOS
  end

  test do
    # Verify the wrapper script exists and bvm.sh is valid bash
    assert_predicate bin/"bvm", :exist?
    system "bash", "-n", libexec/"bvm.sh"
    system "bash", "-n", libexec/"install-bvm.sh"
  end
end
