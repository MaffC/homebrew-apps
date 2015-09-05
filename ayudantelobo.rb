class Ayudantelobo < Formula
  homepage "https://github.com/MaffC/ayudante-lobo"
  url "https://github.com/MaffC/ayudante-lobo/archive/v0.7.tar.gz"
  sha256 "fe9dbf371c7923acb355723fa3af099c9a34cbf5ec4734dd3cb74ec0af6dbb6e"
  head "https://github.com/MaffC/ayudante-lobo.git"

  depends_on "cpanminus"
  depends_on "libssh2" if MacOS.version <= :yosemite
  depends_on "libssh2" => "with-libressl" if MacOS.version > :yosemite
  depends_on "libgcrypt" if MacOS.version > :yosemite

  def install
  bin.mkpath
  share.mkpath
  lib.mkpath
  bin.install "ayudante-lobo"
  share.install "sample.ayudante-loborc"
  prefix.install_metafiles
  cpanm_args = ["-q","--exclude-vendor","-l","#{prefix}"]
  system "cpanm", *cpanm_args,
    "Mac::Pasteboard", "POE::Component::DirWatch::WithCaller",
    "Try::Tiny", "Unix::PID", "YAML"
  cpanm_ext = []
  cpanm_ext = ["--configure-args","gcrypt"] if MacOS.version > :yosemite
  system "cpanm", *cpanm_args, *cpanm_ext
    "Net::SSH2"
  end

  test do
    system "perl -c #{bin}/ayudante-lobo"
  end

  def caveats
    "You'll need to copy #{share}/sample.ayudante-loborc to ~/.ayudante-loborc and then edit it to your needs before loading the launchd agent. The agent is designed such that if ayudante-lobo encounters an error, it will be silently restarted and the error will be logged to wherever you've configured it to log errors to."
  end

#        <key>EnvironmentVariables</key>
#        <dict>
#          <key>PERL5LIB</key>
#          <string>#{lib}:#{lib}/perl5:#{lib}/perl5/darwin-thread-multi-2level</string>
#        </dict>
  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>Program</key>
        <string>#{bin}/ayudante-lobo</string>
      </dict>
    </plist>
    EOS
  end
end
