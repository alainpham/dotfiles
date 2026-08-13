# Enroll this Windows Syncthing instance with the central Syncthing hub.
# Run as the user that runs Syncthing, after Syncthing has been installed.
# The hub must be reachable over HTTP and SSH:
#   .\syncthing-enroll.ps1

[CmdletBinding()]
param(
    [string]$HubLanHost = "192.168.8.100",
    [string]$HubVpnHost = "10.13.13.2",
    [string]$HubSshUser = "user",
    [string]$HubConfigPath = "~/apps/syncthing/data/config.xml",
    [string]$HubApiKey = "",
    [switch]$SkipGuiPassword
)

$ErrorActionPreference = "Stop"
$LocalBaseUrl = "http://127.0.0.1:8384"
$FolderId = "syncthing"
$FolderPath = "C:\syncthing"
$ComputerName = $env:COMPUTERNAME

function Invoke-SyncthingApi {
    param(
        [Parameter(Mandatory)] [string]$BaseUrl,
        [Parameter(Mandatory)] [string]$ApiKey,
        [Parameter(Mandatory)] [string]$Endpoint,
        [ValidateSet("Get", "Post", "Put", "Patch", "Delete")]
        [string]$Method = "Get",
        [object]$Body
    )

    $request = @{
        Uri         = "$BaseUrl$Endpoint"
        Method      = $Method
        Headers     = @{ "X-API-Key" = $ApiKey }
        ErrorAction = "Stop"
        TimeoutSec  = 15
    }

    if ($null -ne $Body) {
        $request.Body = $Body | ConvertTo-Json -Depth 10 -Compress
        $request.ContentType = "application/json"
    }

    try {
        return Invoke-RestMethod @request
    }
    catch {
        throw "Syncthing API request failed [$Method $BaseUrl$Endpoint]: $($_.Exception.Message)"
    }
}

function Get-ApiKeyFromConfig {
    param([Parameter(Mandatory)] [string[]]$Paths)

    foreach ($path in $Paths) {
        if (!(Test-Path $path)) { continue }

        $contents = Get-Content -Path $path -Raw
        $match = [regex]::Match($contents, '<apikey>\s*([^<\s]+)\s*</apikey>')
        if ($match.Success) { return $match.Groups[1].Value }
    }

    return $null
}

function Get-LocalConfigPaths {
    return @(
        "$env:LOCALAPPDATA\Syncthing\config.xml",
        "$env:APPDATA\Syncthing\config.xml",
        "$env:ProgramData\Syncthing\config.xml"
    ) | Where-Object { $_ -and $_ -ne "\Syncthing\config.xml" }
}

function Wait-ForLocalSyncthing {
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        try {
            Invoke-WebRequest "$LocalBaseUrl/rest/noauth/health" -UseBasicParsing -TimeoutSec 2 | Out-Null
            return
        }
        catch {
            Start-Sleep -Seconds 1
        }
    }

    throw "Syncthing did not become available at $LocalBaseUrl."
}

function Set-SyncthingDevice {
    param(
        [Parameter(Mandatory)] [string]$BaseUrl,
        [Parameter(Mandatory)] [string]$ApiKey,
        [Parameter(Mandatory)] [System.Collections.IDictionary]$Device
    )

    $devices = @(Invoke-SyncthingApi -BaseUrl $BaseUrl -ApiKey $ApiKey -Endpoint "/rest/config/devices")
    $existing = $devices | Where-Object { $_.deviceID -eq $Device["deviceID"] } | Select-Object -First 1

    if ($null -ne $existing) {
        foreach ($property in $Device.GetEnumerator()) {
            $existing | Add-Member -MemberType NoteProperty -Name $property.Key -Value $property.Value -Force
        }
        Invoke-SyncthingApi -BaseUrl $BaseUrl -ApiKey $ApiKey `
            -Endpoint "/rest/config/devices/$($Device["deviceID"])" -Method Put -Body $existing | Out-Null
        Write-Host "Updated device $($Device["deviceID"]) on $BaseUrl"
    }
    else {
        Invoke-SyncthingApi -BaseUrl $BaseUrl -ApiKey $ApiKey `
            -Endpoint "/rest/config/devices" -Method Post -Body $Device | Out-Null
        Write-Host "Added device $($Device["deviceID"]) on $BaseUrl"
    }
}

function Get-HubApiKey {
    if (![string]::IsNullOrWhiteSpace($HubApiKey)) { return $HubApiKey }

    if (!(Get-Command "ssh.exe" -ErrorAction SilentlyContinue)) {
        throw "ssh.exe is required to read the hub API key, or pass -HubApiKey explicitly."
    }

    Write-Host "Reading the hub API key over SSH from $HubSshUser@$HubHostIP ..."
    $remoteConfig = & ssh.exe "$HubSshUser@$HubHostIP" "cat $HubConfigPath" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read the hub configuration over SSH. Verify SSH access and -HubConfigPath."
    }

    $match = [regex]::Match(($remoteConfig -join [Environment]::NewLine), '<apikey>\s*([^<\s]+)\s*</apikey>')
    if (!$match.Success) { throw "No API key was found in the hub configuration." }
    return $match.Groups[1].Value
}

Wait-ForLocalSyncthing

$localConfigPaths = Get-LocalConfigPaths
$localApiKey = Get-ApiKeyFromConfig -Paths $localConfigPaths
if ([string]::IsNullOrWhiteSpace($localApiKey)) {
    throw "Could not find the local Syncthing API key. Checked: $($localConfigPaths -join ', ')"
}

$localStatus = Invoke-SyncthingApi -BaseUrl $LocalBaseUrl -ApiKey $localApiKey -Endpoint "/rest/system/status"
$localDeviceId = $localStatus.myID
if ([string]::IsNullOrWhiteSpace($localDeviceId)) { throw "Could not determine the local Syncthing device ID." }

$localDevice = [ordered]@{
    name = $ComputerName
}
Invoke-SyncthingApi -BaseUrl $LocalBaseUrl -ApiKey $localApiKey `
    -Endpoint "/rest/config/devices/$localDeviceId" -Method Patch -Body $localDevice | Out-Null
Write-Host "Named the local Syncthing device $ComputerName."

$options = [ordered]@{
    globalAnnounceEnabled = $false
    localAnnounceEnabled = $false
    urAccepted = -1
}
Invoke-SyncthingApi -BaseUrl $LocalBaseUrl -ApiKey $localApiKey `
    -Endpoint "/rest/config/options" -Method Patch -Body $options | Out-Null
Write-Host "Disabled Syncthing discovery and usage reporting."

if (!$SkipGuiPassword) {
    # Same bcrypt hash as the Linux enrollment script (GUI user: user).
    $gui = [ordered]@{
        user = "user"
        password = '$2y$05$sm/CRM2ip72y1NhHnGCznej.DcLEN4VxG2XHcJNWDQSKyfa0w37ia'
    }
    Invoke-SyncthingApi -BaseUrl $LocalBaseUrl -ApiKey $localApiKey `
        -Endpoint "/rest/config/gui" -Method Patch -Body $gui | Out-Null
    Write-Host "Configured the Syncthing GUI credentials."
}

if ($ComputerName -ieq "aaon") {
    Write-Host "This is the hub host; skipping remote enrollment."
    exit 0
}

$HubHostIP = $null
try {
    Invoke-WebRequest "http://${HubLanHost}:8384/rest/noauth/health" -UseBasicParsing -TimeoutSec 3 | Out-Null
    $HubHostIP = $HubLanHost
    Write-Host "Using the LAN hub endpoint: $HubHostIP"
}
catch {
    $HubHostIP = $HubVpnHost
    Write-Host "LAN hub unavailable; using the VPN hub endpoint: $HubHostIP"
}

$HubBaseUrl = "http://${HubHostIP}:8384"
$hubApiKey = Get-HubApiKey
$hubStatus = Invoke-SyncthingApi -BaseUrl $HubBaseUrl -ApiKey $hubApiKey -Endpoint "/rest/system/status"
$hubDeviceId = $hubStatus.myID
if ([string]::IsNullOrWhiteSpace($hubDeviceId)) { throw "Could not determine the hub Syncthing device ID." }

$hubDevice = [ordered]@{
    deviceID = $localDeviceId
    name = $ComputerName
    autoAcceptFolders = $true
}
Set-SyncthingDevice -BaseUrl $HubBaseUrl -ApiKey $hubApiKey -Device $hubDevice

$localHubDevice = [ordered]@{
    deviceID = $hubDeviceId
    addresses = @(
        "tcp://${HubLanHost}:22000",
        "tcp://${HubVpnHost}:22000"
    )
}
Set-SyncthingDevice -BaseUrl $LocalBaseUrl -ApiKey $localApiKey -Device $localHubDevice

New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
try {
    Invoke-SyncthingApi -BaseUrl $LocalBaseUrl -ApiKey $localApiKey `
        -Endpoint "/rest/config/folders/$FolderId" -Method Delete | Out-Null
}
catch {
    if (!$_.Exception.Message.Contains("404")) { throw }
}

$folder = [ordered]@{
    id = $FolderId
    path = $FolderPath
    devices = @(
        [ordered]@{ deviceID = $hubDeviceId }
    )
}
Invoke-SyncthingApi -BaseUrl $LocalBaseUrl -ApiKey $localApiKey `
    -Endpoint "/rest/config/folders" -Method Post -Body $folder | Out-Null

Write-Host "Enrolled $ComputerName with hub $hubDeviceId and configured $FolderPath." -ForegroundColor Green
