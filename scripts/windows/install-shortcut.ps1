# sas-transcription - raccourci Windows lancant Meetily dans WSL2 (Ubuntu) via WSLg.
# A executer cote Windows depuis le dossier du depot clone :
#   powershell -ExecutionPolicy Bypass -File ".\scripts\windows\install-shortcut.ps1"
$ErrorActionPreference = "Stop"

$distro = "Ubuntu"
# Chemin du lanceur deduit de l'emplacement de ce script : marche quel que soit
# le dossier ou le depot a ete clone (pas de chemin en dur).
$launchWin  = (Resolve-Path (Join-Path $PSScriptRoot "..\meetily-launch.sh")).Path
$launchPath = (wsl.exe -d $distro wslpath -a "$launchWin").Trim()
$target     = "$env:WINDIR\System32\wsl.exe"
$arguments  = "-d $distro -- bash -lc `"$launchPath`""
$iconIco    = "$env:USERPROFILE\meetily.ico"   # optionnel

# Icone (best-effort) : convertir le PNG de l'appli en .ico via ImageMagick dans WSL, si dispo.
if (-not (Test-Path $iconIco)) {
  $wslIco = "/mnt/c/Users/$env:USERNAME/meetily.ico"
  wsl.exe -d $distro -- bash -lc "command -v convert >/dev/null && convert /usr/share/icons/hicolor/256x256/apps/meetily.png -define icon:auto-resize=256,128,64,48,32,16 '$wslIco' 2>/dev/null || true" | Out-Null
}

# Resoudre les dossiers speciaux via l'API Windows (gere OneDrive et la localisation
# FR "Bureau", contrairement a un chemin en dur $env:USERPROFILE\Desktop).
$desktop  = [Environment]::GetFolderPath('Desktop')
$programs = [Environment]::GetFolderPath('Programs')

foreach ($dir in @($desktop, $programs)) {
  if (-not (Test-Path $dir)) { Write-Host "Dossier absent, ignore : $dir"; continue }
  $lnk = Join-Path $dir "Meetily (souverain).lnk"
  $sh  = New-Object -ComObject WScript.Shell
  $s   = $sh.CreateShortcut($lnk)
  $s.TargetPath  = $target
  $s.Arguments   = $arguments
  $s.Description  = "Transcription souveraine 100% locale (Whisper large-v3, GPU)"
  if (Test-Path $iconIco) { $s.IconLocation = $iconIco }
  $s.Save()
  Write-Host "Raccourci cree : $lnk"
}
