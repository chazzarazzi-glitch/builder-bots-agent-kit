# Builder Bots -> a bot folder for Claude Code, Codex, Cursor and other AI tools (Windows)
#
# For holders of a forged Builder Bot. Give it your .agent name; it finds your forged bot on
# Robinhood Chain and builds a folder those tools read on their own:
#   CLAUDE.md        Claude Code
#   AGENTS.md        Codex, Cursor and most agent tools
#   GEMINI.md        Gemini CLI and Antigravity
#   SOUL.md          paste into ChatGPT or any web chat
#   chainsearch.js   the bot's access to the Genie chain (Node, works inside Codex's sandbox)
#   chainsearch.ps1  the same, in PowerShell, for machines without Node
#
#   bot-anywhere yourname.agent
#   bot-anywhere yourname.agent --token 316     (if your wallet holds more than one forged bot)
#   bot-anywhere yourname.agent C:\Bots         (choose where the folder goes)
. "$PSScriptRoot\bb-common.ps1"

$kit = Read-KitArgs $args
$prompted = -not $kit.Name
if ($prompted) { $kit.Name = Read-AgentNamePrompt 'bot-anywhere' }
$label = Get-AgentLabel $kit.Name
$where = if ($kit.Rest.Count) { $kit.Rest[0] } elseif ($prompted) { [Environment]::GetFolderPath('Desktop') } else { (Get-Location).Path }

# The name is its own bot. A forged Builder Bot is installed only when asked for with --token.
if ($kit.Token) { $found = @(Find-BotsForName $label) }
else {
  Say "Looking up $label.agent on Robinhood Chain..."
  $script:NameRegistered = [bool](Resolve-AgentName $label)
  if ($script:NameRegistered) { Say '  name found' } else { Say "  $label.agent is not registered on Robinhood Chain. Installing it anyway." }
  $found = @()
}
if ($found.Count) {
  $bot  = Select-Bot $found $kit.Token
  if ($bot) { Say "  forged bot: $($bot.Collection) #$($bot.Token)" }
}
if ($bot) {
  $meta = Get-BotMetadata $bot
  $id   = New-BotIdentity $label $bot $meta
} else {
  $bot = $null
  $id  = New-NameIdentity $label
  $meta = $id.Meta
}

$DIR = Join-Path $where $id.Slug
if (Test-Path $DIR) { Fail "  $DIR already exists." }
New-Item -ItemType Directory -Force $DIR | Out-Null
Say "Building $DIR ..."

# Run from inside the bot folder, which is where these tools open. Node first: Codex's Windows
# sandbox blocks PowerShell's web requests, and Codex and Claude Code both come with Node.
$SEARCH = 'node ./chainsearch.js'
$FALLBACK = 'powershell -NoProfile -ExecutionPolicy Bypass -File ./chainsearch.ps1'
Write-File "$DIR\chainsearch.js" $script:CHAINSEARCH_JS
Write-File "$DIR\chainsearch.ps1" $script:CHAINSEARCH_PS1
$soul = (Get-SoulText $id $SEARCH).Replace("Rules you do not break:",
  "If ``node`` is not installed, run the same commands with ``$FALLBACK`` instead.`n`nRules you do not break:")
foreach ($f in 'SOUL.md', 'AGENTS.md', 'CLAUDE.md', 'GEMINI.md') { Write-File "$DIR\$f" $soul }
Ok ("  personality written" + $(if ($bot) { " from $($meta.Traits.Count) traits" } else { '' }))
$about = if ($bot) { "$($id.Display), $($bot.Collection) #$($bot.Token)" } else { $id.Display }

Write-File "$DIR\README.txt" @"
This folder is $about.

Claude Code:  open a terminal in this folder and run  claude
Codex:        open a terminal in this folder and run  codex
Cursor and most others: open this folder. They read AGENTS.md.
Gemini CLI and Antigravity: open this folder. They read GEMINI.md.
ChatGPT or any web chat: paste SOUL.md in as the instructions. A web chat can't run the
chain search, so the bot keeps its personality but can't browse the library there.

Chain search works in any terminal in this folder:
  $SEARCH rooms
  $FALLBACK rooms      (if Node isn't installed)

"@
Ok '  chain search installed'
Say ''
Say "Done: $DIR"
Say "Claude Code:  cd `"$DIR`"  then  claude"
Say "Codex:        cd `"$DIR`"  then  codex"
