$timestamp = Get-Date -Format "yyyy-MM-dd_hh-mm"
do {
    $driveLetter = Read-Host "Enter the drive letter where you want to save the outputs (e.g., 'E:')"
    $driveExists = Test-Path -Path "${driveLetter}:\"
    if (-not $driveExists) {
        Write-Host "Specified drive $driveLetter does not exist. Please enter a valid drive letter."
    }
} until ($driveExists)

# Grabs DNS cache and saves it to a file
Get-DnsClientCache > "${driveLetter}:\$($timestamp)_DNS_Cache.txt"

#Grabs WiFi passwords and saves it to a file
    $wifiProfiles = netsh wlan show profiles | 
     Select-String ":(.+)$" | 
     ForEach-Object {
         $name = $_.Matches.Groups[1].Value.Trim()
         netsh wlan show profile name="$name" key=clear
      } | 
      Select-String "Key Content\W+\:(.+)$" | 
      ForEach-Object {
          $password = $_.Matches.Groups[1].Value.Trim()
          [PSCustomObject]@{ SSID = $name; PASSWORD = $password }
      }
$wifiProfiles | Format-Table -AutoSize | Out-File "${driveLetter}:\${timestamp}_WiFi_Passwords.txt"