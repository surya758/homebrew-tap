# Homebrew formula for kuro.
#
# Lives in the tap repo `surya758/homebrew-tap`, which Homebrew refers to as
# `surya758/tap`. Install with either:
#
#     brew tap surya758/tap && brew install kuro      # then just `kuro`
#     brew install surya758/tap/kuro                  # one-liner
#
# The stable spec pins a git tag plus its revision rather than a release tarball,
# so no sha256 is needed and no GitHub release has to exist. When cutting a new
# version, bump both `tag` and `revision` together.
class Kuro < Formula
  desc "Terminal anime streaming client that plays in IINA"
  homepage "https://github.com/surya758/kuro"
  url "https://github.com/surya758/kuro.git",
      tag:      "v0.6.5",
      revision: "c76c75a0eb6c261d4e3378f9c179c5b8b831ccc3"
  license "MIT"
  head "https://github.com/surya758/kuro.git", branch: "main"

  depends_on "rust" => :build
  depends_on :macos
  # Sources that publish no muxed rendition are resolved by the player itself,
  # which IINA cannot do. kuro uses mpv for those and IINA for everything else.
  depends_on "mpv"
  # The anidb provider sits behind a challenge that inspects the TLS handshake, so
  # no ordinary client reaches it. Depending on this is what saves users a manual
  # binary install; kuro still runs without it, minus that one provider.
  depends_on "surya758/tap/curl-impersonate"
  depends_on "yt-dlp"

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/kuro-cli")

    # No `shell_parameter_format:` — omitting it passes the bare shell name
    # positionally, i.e. `kuro completions bash`. (`:arg` would send
    # `--shell=bash`, `:flag` `--bash`, and `:none` no argument at all.)
    generate_completions_from_executable(bin/"kuro", "completions")
  end

  def caveats
    <<~EOS
      kuro plays video through IINA, which is a cask rather than a formula:

        brew install --cask iina

      Run `kuro doctor` to check that everything is wired up.
    EOS
  end

  test do
    assert_match "kuro", shell_output("#{bin}/kuro --version")

    # Providers are compiled into the binary, so this needs no network access
    # and no config file.
    assert_match "luciferdonghua", shell_output("#{bin}/kuro provider list")
  end
end
