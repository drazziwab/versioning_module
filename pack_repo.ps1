# pack_repo.ps1 (fixed version)
# PowerShell script to run Repomix and pack the current folder automatically

# Add global npm bin folder to PATH (if not already added)
$NpmBinPath = "$env:APPDATA\npm"
if (-not ($env:Path -split ";" | Where-Object { $_ -eq $NpmBinPath })) {
    $env:Path += ";$NpmBinPath"
}

# Ensure the script is run from the directory you want to pack
$CurrentDir = Get-Location
$OutputFile = "$($CurrentDir.Path)\packed_repo.md"

# Confirm repomix is available
try {
    repomix --version | Out-Null
} catch {
    Write-Error "❌ Repomix is not installed or not found even after PATH fix. Please reinstall with 'npm install -g repomix'."
    exit
}

# Run repomix with desired options
Write-Output "🚀 Packing repository from: $CurrentDir"
repomix -o "$OutputFile" --compress --remove-comments --remove-empty-lines --style markdown

# Confirm output
if (Test-Path $OutputFile) {
    Write-Output "✅ Repository packed successfully: $OutputFile"
} else {
    Write-Error "❌ Failed to create output file."
}
