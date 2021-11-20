get-ciminstance win32_networkadapterconfiguration |
where { $_.ipenabled -eq "True"} |
Format-table Description, Index, IPAddress, IPSubnet, DNSDomain, DNSServerSearchOrder