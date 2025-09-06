# Analyse-Tor-Traffic-Obfs4

PowerShell script to monitor Tor/obfs4 traffic, identify exit nodes and generate CSV with tor.exe/lyrebird.exe connections

Overview
--------
Analyse-Tor-Traffic-Obfs4.ps1 is a PowerShell script designed to monitor Tor traffic and bridges (obfs4) on Windows.
It helps you:
- Check if a given IP belongs to a Tor exit node block (/24).
- List TCP connections for tor.exe and lyrebird.exe.
- Export remote IPs and ports to a CSV file.
- Optionally monitor connections continuously in real-time.

The script automatically creates a folder:
%USERPROFILE%\toranalyse
where all CSV outputs are saved.

Features
--------
1. Check Tor Exit Node
- Downloads the public Tor exit node list from https://check.torproject.org/torbulkexitlist.
- Compares the first three octets of the IP against Tor blocks.
- Outputs example:

Checking IP 51.222.13.177 (prefix 51.222.13) against public Tor exit nodes list...
51.222.13.177 BELONGS to a Tor exit node block!

or

51.222.13.177 does NOT belong to any Tor exit node block.

2. List Tor/Lyrebird Connections
- Detects running processes tor.exe and lyrebird.exe.
- Lists active TCP connections:

Detected processes: tor, lyrebird

LocalAddress  LocalPort  RemoteAddress   RemotePort  State
------------  ---------  -------------  ----------  -----
192.168.0.5   443        185.220.101.1  443        Established
192.168.0.5   9001       178.62.99.12   9001       Established

- If no processes are running:

No Tor or Lyrebird processes running.

3. Export CSV
- Automatically creates:
C:\Users\<YourUser>\toranalyse
- CSV saved as tor_connections.csv with columns:

RemoteAddress, RemotePort
185.220.101.1, 443
178.62.99.12, 9001

4. Continuous Monitoring (Optional)
List-TorConnections -Continuous:$true
- Updates the console every 5 seconds.
- CSV is continuously overwritten with latest connections.
- Great for real-time tracking of Tor traffic.

Usage Examples
--------------
# Check a specific IP and export connections
.\Analyse-Tor-Traffic-Obfs4.ps1 -IpAddress "51.222.13.177"

# Continuous monitoring without specifying CSV (uses default folder)
List-TorConnections -Continuous:$true

# Check IP and export connections continuously
List-TorConnections -Continuous:$true

Parameters
----------
Parameter      Description
-IPAddress     Mandatory. IP address to check against the Tor exit node list.
-Continuous    Optional. Enables continuous real-time monitoring.
-ExportPath    Optional. Full path to export CSV. Default is %USERPROFILE%\toranalyse\tor_connections.csv.

Notes
-----
- Only monitors connections for tor.exe and lyrebird.exe.
- CSV contains only RemoteAddress and RemotePort.
- Continuous monitoring overwrites the CSV each iteration.
- Works best with PowerShell running as Administrator.
