#-----------------------------------------------------
# General
#-----------------------------------------------------

Import-Module posh-git

# PowerShell Core7でもConsoleのデフォルトエンコーディングはsjisなので必要
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# git logなどのマルチバイト文字を表示させるため (絵文字含む)
$env:LESSCHARSET = "utf-8"

# 音を消す
Set-PSReadlineOption -BellStyle None

# 予測インテリセンス
Set-PSReadLineOption -PredictionSource History

#-----------------------------------------------------
# Key binding
#-----------------------------------------------------

# Emacsベース
Set-PSReadLineOption -EditMode Emacs

#-----------------------------------------------------
# Powerline
#-----------------------------------------------------

Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})

oh-my-posh init pwsh --config '~\AppData\Local\Programs\oh-my-posh\themes\slimfat.omp.json' | Invoke-Expression

#-----------------------------------------------------
# fzf
#-----------------------------------------------------

# fzf
$env:FZF_DEFAULT_OPTS="--reverse --border --height 50%"
$env:FZF_DEFAULT_COMMAND='fd -HL --exclude ".git" .'
function _fzf_compgen_path() {
    fd -HL --exclude ".git" . "$1"
}
function _fzf_compgen_dir() {
    fd --type d -HL --exclude ".git" . "$1"
}

# PSFzf
# https://gist.github.com/nv-h/081684cee2505cd336e26c2660fc7541
# Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
#     $command = Get-Content (Get-PSReadlineOption).HistorySavePath | tac | awk '!a[$0]++' | Invoke-Fzf -NoSort -Exact
#     [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
# 
#     if (!$command) {
#       return
#     }
# 
#     [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
# }
#
# 下記のコマンドの実行が必要（PSFzfのPowerShellへのインストール）
# Install-Module -Scope CurrentUser PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

#-----------------------------------------------------
# Linux like commands
#-----------------------------------------------------

# https://secon.dev/entry/2020/08/17/070735/
@"
  arch, base32, base64, basename, cat, cksum, comm, cp, cut, date, df, dircolors, dirname,
  echo, env, expand, expr, factor, false, fmt, fold, hashsum, head, hostname, join, link, ln,
  ls, md5sum, mkdir, mktemp, more, mv, nl, nproc, od, paste, printenv, printf, ptx, pwd,
  readlink, realpath, relpath, rm, rmdir, seq, sha1sum, sha224sum, sha256sum, sha3-224sum,
  sha3-256sum, sha3-384sum, sha3-512sum, sha384sum, sha3sum, sha512sum, shake128sum,
  shake256sum, shred, shuf, sleep, sort, split, sum, sync, tac, tail, tee, test, touch, tr,
  true, truncate, tsort, unexpand, uniq, wc, whoami, yes
"@ -split ',' |
ForEach-Object { $_.trim() } |
Where-Object { ! @('tee', 'sort', 'sleep').Contains($_) } |
ForEach-Object {
    $cmd = $_
    if (Test-Path Alias:$cmd) { Remove-Item -Path Alias:$cmd }
    $fn = '$input | coreutils ' + $cmd + ' $args'
    Invoke-Expression "function global:$cmd { $fn }"
}

# ⚠ readonlyのaliasなので問題が発生するかも..
# Remove-Item alias:sort -Force
# function sort() { $input | coreutils sort $args}

# 代替コマンドを使用
Set-Alias grep rg
function ls() { coreutils ls $args }
function tree() { exa --icons -T $args}

# Linuxコマンドのエイリアス
function ll() { exa --icons -l --git $args}

#-----------------------------------------------------
# Useful commands
#-----------------------------------------------------

# Neovim
Set-Alias vim nvim

# cd
function ..() { cd ../ }
function ...() { cd ../../ }
function ....() { cd ../../../ }
function cdpro() { cd "~\OneDrive\ドキュメント\PowerShell\" }
function cdr() { fd -H -t d -E .git -E node_modules | fzf | cd }
Set-Alias cdz zi

# Copy current path
function cpwd() { Convert-Path . | Set-Clipboard }

# git flow
function gf()  { git fetch --all }
function gd()  { git diff $args }
function gds()  { git diff --staged $args }
function ga()  { git add $args }
function gaa() { git add --all }
function gco() { git commit -m $args[0] }

# git switch
function gb()  { git branch -l | rg -v '^\* ' | % { $_ -replace " ", "" } | fzf | % { git switch $_ } }
function gbr() { git branch -rl | rg -v "HEAD|master" | % { $_ -replace "  origin/", "" } | fzf | % { git switch $_ } }
function gbc() { git switch -c $args[0] }
function gbm()  { git branch -l | rg -v '^\* ' | % { $_ -replace " ", "" } | fzf | % { git merge --no-ff $_ } }

# git log
function gls()   { git log -3}
function gll()   { git log -10 --oneline --all --graph --decorate }
function glll()  { git log --graph --all --date=format:'%Y-%m-%d %H:%M' --pretty=format:'%C(auto)%d%Creset\ %C(yellow)%h%Creset %C(magenta)%ae%Creset %C(cyan)%ad%Creset%n%C(white bold)%w(80)%s%Creset%n%b' }
function glls()  { git log --graph --all --date=format:'%Y-%m-%d %H:%M' --pretty=format:'%C(auto)%d%Creset\ %C(yellow)%h%Creset %C(magenta)%ae%Creset %C(cyan)%ad%Creset%n%C(white bold)%w(80)%s%Creset%n%b' -10}

# git status
function gs()  { git status --short }
function gss() { git status -v }

# git push
function gs()  { git push -u origin main }

# explorer
function open() { explorer $args }

