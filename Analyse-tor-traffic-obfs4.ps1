<#
=========================================================
SCRIPT: Analyse-Tor-Traffic-Obfs4.ps1
FUNCTION: 
    1️⃣ Checks if an IP belongs to a Tor exit node block (/24).
    2️⃣ Lists TCP connections of tor.exe and lyrebird.exe.
    3️⃣ Exports connections to CSV in %USERPROFILE%\toranalyse.
    4️⃣ (Optional) Continuous monitoring of connections.

USAGE:

# Check a specific IP and export current connections
.\Analyse-Tor-Traffic-Obfs4.ps1 -IpAddress "51.222.13.177"

# Continuous monitoring every 5 seconds (tor.exe / lyrebird.exe)
# Replace -Continuous:$false with -Continuous:$true in the List-TorConnections call
# CSV will be saved automatically in %USERPROFILE%\toranalyse
List-TorConnections -Continuous:$true

PARAMETERS:

-IpAddress <string>  : IP to check against the public Tor exit nodes list.

IMPORTANT VARIABLES:

$ExportPath : Full path of the CSV where remote IPs/ports will be saved.
$Continuous : Switch to update the screen continuously (True/False).

EXAMPLES:

# 1️⃣ Check IP and export connections
.\Analyse-Tor-Traffic-Obfs4.ps1 -IpAddress "51.222.13.177"

# 2️⃣ Continuous monitoring without exporting
List-TorConnections -Continuous:$true

# 3️⃣ Continuous monitoring with export
List-TorConnections -Continuous:$true

=========================================================
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$IpAddress
)

# ==============================
# Create folder for CSV output
# ==============================
$torAnalyseFolder = Join-Path $env:USERPROFILE "toranalyse"

if (-not (Test-Path $torAnalyseFolder)) {
    New-Item -Path $torAnalyseFolder -ItemType Directory | Out-Null
    Write-Host "Folder created at $torAnalyseFolder" -ForegroundColor Green
}

$csvPath = Join-Path $torAnalyseFolder "tor_connections.csv"

# ==============================
# Function: Check Tor Exit Node
# ==============================
function Check-TorExitNode {
    param([string]$Ip)

    $torListUrl = "https://check.torproject.org/torbulkexitlist"

    # Get the first 3 octets of the IP
    $ipParts = $Ip -split '\.'
    if ($ipParts.Length -ne 4) {
        Write-Host "[ERROR] Invalid IP." -ForegroundColor Red
        return
    }
    $ipPrefix = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2])"

    Write-Output "Checking IP $Ip (prefix $ipPrefix) against public Tor exit nodes list..."

    try {
        $torExitNodes = Invoke-WebRequest -Uri $torListUrl -UseBasicParsing
        $torExitNodes = $torExitNodes.Content -split "`n"

        $torPrefixes = $torExitNodes | ForEach-Object {
            $parts = $_ -split '\.'
            if ($parts.Length -eq 4) { "$($parts[0]).$($parts[1]).$($parts[2])" }
        }

        if ($torPrefixes -contains $ipPrefix) {
            Write-Host "$Ip BELONGS to a Tor exit node block!" -ForegroundColor Green
        } else {
            Write-Host "$Ip does NOT belong to any Tor exit node block." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[WARN] Error checking Tor exit nodes. Check your connection." -ForegroundColor Yellow
    }
}

# ==============================
# Function: List Tor/Lyrebird connections
# ==============================
function List-TorConnections {
    param([switch]$Continuous, [string]$ExportPath)

    do {
        Clear-Host
        Write-Output "Tor and Lyrebird connections as of $(Get-Date)"

        $processIds = @()
        $detected = @()

        foreach ($proc in @("tor","lyrebird")) {
            try {
                $p = Get-Process -Name $proc -ErrorAction SilentlyContinue
                if ($p) {
                    $processIds += $p.Id
                    $detected += $proc
                }
            } catch {}
        }

        if ($detected.Count -eq 0) {
            Write-Host "No Tor or Lyrebird processes running." -ForegroundColor Yellow
        } else {
            Write-Host "Detected processes: $($detected -join ', ')" -ForegroundColor Green

            $connections = Get-NetTCPConnection | Where-Object { $_.OwningProcess -in $processIds } |
                Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State

            $connections | Format-Table

            if ($ExportPath) {
                $connections | Select-Object RemoteAddress,RemotePort |
                    Export-Csv -Path $ExportPath -NoTypeInformation
                Write-Host "`nConnections exported to $ExportPath"
            }
        }

        if ($Continuous) { Start-Sleep -Seconds 5 }
    } while ($Continuous)
}

# ==============================
# Execution
# ==============================
# 1️⃣ Check if IP belongs to Tor
Check-TorExitNode -Ip $IpAddress

# 2️⃣ List connections and export to toranalyse folder
List-TorConnections -Continuous:$false -ExportPath $csvPath
