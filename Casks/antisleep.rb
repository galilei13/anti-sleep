cask "antisleep" do
  version "1.0.0"
  sha256 "<SHA256_PLACEHOLDER>"

  url "https://github.com/galilei13/dont-sleep-project/releases/download/v#{version}/AntiSleep-#{version}.dmg"
  name "AntiSleep"
  desc "Menu bar app that keeps your Mac awake"
  homepage "https://github.com/galilei13/dont-sleep-project"

  app "AntiSleep.app"

  zap trash: [
    "~/Library/Preferences/com.antisleep.AntiSleep.plist",
    "~/Library/Application Support/AntiSleep",
  ]
end
