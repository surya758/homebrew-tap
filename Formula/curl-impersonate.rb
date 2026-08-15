# Homebrew formula for curl-impersonate.
#
# Lives here rather than being installed by hand because `kuro`'s anidb provider
# cannot reach its site without it, and upstream is not in Homebrew core. Making it
# a dependency of `kuro` is what keeps `brew install surya758/tap/kuro` a single
# step.
#
# Upstream ships a relocatable binary — `otool -L` shows only macOS system
# frameworks, no bundled dylibs — so this copies it into place with no rpath work.
# Only the bare binary is installed: the tarball also carries ~40 `curl_<browser>`
# wrapper scripts, and kuro drives the binary directly with `--impersonate`.
class CurlImpersonate < Formula
  desc "Curl build that performs a browser-shaped TLS handshake"
  homepage "https://github.com/lexiforest/curl-impersonate"
  version "2.1.0"
  license "MIT"

  # `on_arm`/`on_intel` blocks may not carry `url` at formula level, so the release
  # is selected here instead.
  if Hardware::CPU.arm?
    url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.1.0/curl-impersonate-v2.1.0.arm64-macos.tar.gz"
    sha256 "eaba6c9f8246310dae2d7168f2264f458518a0894262230da7309b9cdb1c5260"
  else
    url "https://github.com/lexiforest/curl-impersonate/releases/download/v2.1.0/curl-impersonate-v2.1.0.x86_64-macos.tar.gz"
    sha256 "8a945a35cb715dab02958ffb4a49ae2f6f9f146c8e366a3201942e30a4993384"
  end

  def install
    bin.install "curl-impersonate"
  end

  test do
    # Deliberately offline: `brew test` should not depend on a network round-trip.
    assert_match "curl", shell_output("#{bin}/curl-impersonate --version")
  end
end
