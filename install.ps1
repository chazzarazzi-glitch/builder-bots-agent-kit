# Builder Bots Agent Kit, one line install for Windows (PowerShell).
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/chazzarazzi-glitch/builder-bots-agent-kit/main/install.ps1))) yourname.agent
#   add  --folder  to build a bot folder instead of a Hermes bot
#   add  --token N  if your wallet holds more than one forged Builder Bot
# Reads public chain data only. No keys, no wallet access.
$folder = $args -contains '--folder'
$rest = @($args | Where-Object { $_ -ne '--folder' })
$tmp = Join-Path $env:TEMP ("bbkit-" + [guid]::NewGuid())
New-Item -ItemType Directory $tmp | Out-Null
foreach ($f in 'bb-common.ps1', 'install-bot.ps1', 'bot-anywhere.ps1') {
  Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/chazzarazzi-glitch/builder-bots-agent-kit/main/windows/$f" -OutFile (Join-Path $tmp $f)
}
$script = if ($folder) { 'bot-anywhere.ps1' } else { 'install-bot.ps1' }
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $tmp $script) @rest
Remove-Item -Recurse -Force $tmp
