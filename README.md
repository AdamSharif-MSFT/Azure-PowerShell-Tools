# Azure-PowerShell-Tools

A simple script to update all NSG rules in your subscription to with an Allow rule (priority 100) inbound, from your current public IP to all IPs/ports in the VNet.

By default the script will only update existing rules named "Home" with priority 100 and add new rules to VNets which don't have a rule at priority 100.

If you wish to instead overwrite existing priority 100 rules, use the following flag:

`./updateNsgRules.ps1 -overwrite $true`

_Note:_ updated the script to use ipv4.icanhazip.com to obtain current public IP, since curl.ifconfig.co sometimes returns an IPv6 address and there's no easy way to 'force' it to return the IPv6 address
