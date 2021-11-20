function get-hardwareinfo {
Write-Host "Computer Hardware Inforamtion:"
Get-cimInstance -ClassName Win32_ComputerSystem| format-list
}

function get-myos {
Write-Host "OS Info:"
get-CimInstance -ClassName Win32_operatingsystem | format-list Name, version
}

function get-myprocessor {
Write-Host "Processor Details:"
get-CimInstance -Class win32_processor | fl Description, MaxClockSpeed, NumberOfCores,
@{n="L1CacheSize";e={switch($_.L1CacheSize){$null{$OutputVariable="Information is not available..";$OutputVariable}};
if($null -ne $_.L1CacheSize){$_.L1CacheSize}}}, L2CacheSize, L3CacheSize
}

function get-mymem {
Write-Host "RAM info:"
$cinitapacity = 0
get-CimInstance -Class win32_physicalmemory |
foreach {
New-Object -TypeName psobject -Property @{
Manufacturer = $_.Manufacturer
Description = $_.description
"Size(GB)" = $_.Capacity/1gb
Bank = $_.banklabel
Slot = $_.Devicelocator
}
$cinitapacity += $_.capacity/1gb
} |
Format-table Manufacturer, Description, "Size(GB)", Bank, Slot
"Total RAM: ${cinitapacity}GB"
}

function get-mydisks {
Write-Host "Physical drive in Details:"
Get-WmiObject -class Win32_DiskDrive | ? DeviceID -ne $null |
foreach {
$drive = $_
$drive.GetRelated("Win32_DiskPartition")|
foreach {$logicaldisk= $_.GetRelated("win32_LogicalDisk");
if ($logicaldisk.size) {
New-Object -TypeName PSobject -Property @{
Manufacturer = $drive.manufacturer
DriveLetter = $logicaldisk.deviceID
Model = $drive.Model
Size = [string]($logicaldisk.size/1gb -as [int])+"GB"
Free= [String]((($logicaldisk.freespace / $logicaldisk.size) * 100) -as [int]) +"%"
FreeSpace = [string]($logicaldisk.freespace / 1gb -as [int])+ "GB"
}|
ft -AutoSize }}}}

function get-mynetwork {
Write-Host "NETWORK INFORMATION:"
get-ciminstance win32_networkadapterconfiguration |
where { $_.ipenabled -eq "True"} |
Format-table Description, Index, IPAddress, IPSubnet, 
@{n="DNSDomain";
e={switch($_.DNSdomain)
{$null{$OutputVariable1="Information is not available..";$OutputVariable1 }};
if($null -ne $_.DNSdomain){$_.DNSdomain }}},
@{n="DNSServerSearchorder";
e={switch($_.DNSServerSearchorder)
{$null{$OutputVariable2="Information is not available..";$OutputVariable2 }};
if($null -ne $_.DNSServerSearchorder){$_.DNSServerSearchorder }}}
}

function get-mygpu {
Write-Host "GPU resolution in details:"
$HX=(gwmi -class Win32_videocontroller).CurrentHorizontalResolution -as [String]
$VX=(gwmi -class win32_videocontroller).CurrentVerticalResolution -as [string]
$Bit=(gwmi -class win32_Videocontroller).CurrentBitsPerPixel -as [String]
$sum= $HX + " x " + $VX + " and " + $Bit + " bits"
gwmi win32_videocontroller |
format-list @{n="Video Card Vendor"; e={$_.Adaptercompatibility}},
Description,@{n="Resolution"; e={$sum -as [string]}}
}

get-hardwareinfo
get-myos
get-myprocessor
get-mymem
get-mydisks
get-mynetwork
get-mygpu
