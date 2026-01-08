param(
    # File that contains the list of labs (one URL per line)
    [string]$LabFile = ".\labs.txt",

    # File that stores completed labs across runs
    [string]$StateFile = ".\labs_done.txt"
)

Write-Host "`n=== PortSwigger Lab Roulette ===`n"

# Check lab file
if (-not (Test-Path $LabFile)) {
    Write-Host "❌ Lab file not found: $LabFile" -ForegroundColor Red
    exit 1
}

# Read all labs from file
$labs = Get-Content $LabFile |
    Where-Object { $_ -and $_.Trim() -ne "" } |
    ForEach-Object { $_.Trim() } |
    Select-Object -Unique

if ($labs.Count -eq 0) {
    Write-Host "❌ No labs found in $LabFile" -ForegroundColor Red
    exit 1
}

# Load previously completed labs
$done = @()
if (Test-Path $StateFile) {
    $done = Get-Content $StateFile |
        Where-Object { $_ -and $_.Trim() -ne "" } |
        ForEach-Object { $_.Trim() } |
        Select-Object -Unique
}

# Filter remaining labs
$remaining = $labs | Where-Object { $done -notcontains $_ }

if ($remaining.Count -eq 0) {
    Write-Host "🎉 All labs already completed!" -ForegroundColor Green
    exit 0
}

Write-Host "Total labs: $($labs.Count)"
Write-Host "Completed: $($done.Count)"
Write-Host "Remaining: $($remaining.Count)`n"

# Make sure state file exists
if (-not (Test-Path $StateFile)) {
    New-Item -ItemType File -Path $StateFile -Force | Out-Null
}

# Roulette loop
while ($remaining.Count -gt 0) {

    $index = Get-Random -Minimum 0 -Maximum $remaining.Count
    $selected = $remaining[$index]

    Write-Host "🎯 Selected lab:" -NoNewline
    Write-Host " $selected" -ForegroundColor Cyan

    # Do not auto-open a browser (requested!)
    Write-Host "Copy or open manually when you're ready."

    # Mark lab as done in persistent state
    Add-Content -Path $StateFile -Value $selected

    # Remove from remaining list
    $remaining = $remaining | Where-Object { $_ -ne $selected }

    if ($remaining.Count -eq 0) {
        Write-Host "`n🎉 No more labs left. All done!" -ForegroundColor Green
        break
    }

    $input = Read-Host "`nPress ENTER for next random lab, or 'q' to stop"
    if ($input -eq 'q') {
        Write-Host "`nStopping early. Progress saved to $StateFile." -ForegroundColor Yellow
        break
    }
}
