Param ( [switch]$System, [switch]$Disks,
        [switch]$Network)

Import-Module Muskan

if ($System -eq $false -and $Disks -eq $false -and $Network -eq $false) {
      Muskan-System; Muskan-Disks; Muskan-Network;
} else {
      if ($System) {Muskan-System;}
      if ($Disks) {Muskan-Disks;}
      if ($Network) {Muskan-Network;}
}