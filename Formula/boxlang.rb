class Boxlang < Formula
  desc "BoxLang - A next-generation multi-runtime dynamic language for the JVM"
  homepage "https://boxlang.io"
  url "https://github.com/ortus-boxlang/boxlang-quick-installer/archive/refs/tags/v1.16.6.tar.gz"
  sha256 "76f3d65edc54769a385c39c6b0f44aec222b80f0eaf36d2f68cf6bdaafb1c93d"
  version "1.16.6"
  license "Apache-2.0"

  depends_on "curl"
  depends_on "jq"
  depends_on "openjdk@21"
  depends_on "unzip"

  def install
    # Replace the build-time version placeholder with the actual release version
    inreplace "src/install-boxlang.sh", "@build.version@", version

    # Install only BoxLang-related scripts into libexec so relative paths resolve correctly
    libexec.install "src/install-boxlang.sh", "src/install-bx-module.sh", "src/install-bx-site.sh"

    # Create thin wrappers in bin so the commands appear in PATH
    (bin/"install-boxlang").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/install-boxlang.sh" "$@"
    EOS

    (bin/"install-bx-module").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/install-bx-module.sh" "$@"
    EOS

    (bin/"install-bx-site").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/install-bx-site.sh" "$@"
    EOS
  end

  def caveats
    <<~EOS
      The BoxLang installer has been set up. To install BoxLang, run:
        install-boxlang

      Additional options:
        install-boxlang --with-jre     # Auto-install Java 21 JRE if not found
        install-boxlang --yes          # Accept all defaults (non-interactive)
        sudo install-boxlang --system  # Install system-wide

      After installation, add the following to your shell profile
      (~/.zshrc or ~/.bashrc) and restart your terminal:
        export PATH="$HOME/.local/bin:$PATH"

      You can then run BoxLang with:
        boxlang               # Start the BoxLang REPL
        boxlang --version     # Check the installed version
        boxlang-miniserver    # Start the BoxLang MiniServer

      To install BoxLang modules:
        install-bx-module bx-orm

      For system-wide installs, BoxLang binaries are placed in /usr/local/bin.
    EOS
  end

  test do
    # Verify the wrapper scripts exist and the installer scripts are valid bash
    assert_predicate bin/"install-boxlang", :exist?
    system "bash", "-n", libexec/"install-boxlang.sh"
    system "bash", "-n", libexec/"install-bx-module.sh"
  end
end
