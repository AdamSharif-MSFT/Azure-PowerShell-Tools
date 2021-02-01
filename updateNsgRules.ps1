param($overwrite=$false)

$publicIp = ((Invoke-WebRequest ipv4.icanhazip.com -UserAgent curl/7.68.0).Content).Trim()
$regex = [regex] "\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}"

if ($publicIp -match $regex) {

    Write-Host "`r`nPublic IP $publicIp is valid. Updating NSGs...`r`n" -BackgroundColor Yellow -ForegroundColor Black

    $collection = Get-AzNetworkSecurityGroup
    foreach ($item in $collection) {
        if ($item.SecurityRules.Priority.contains(100)) {
            $nsgName = $item.Name
            if ($overwrite -eq $false) {
                Write-Host "Updating NSG: $nsgName" -ForegroundColor Green
                Set-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $item -Name "Home" -Direction Inbound -SourceAddressPrefix $publicIp -Protocol * -Access Allow  -SourcePortRange * -DestinationPortRange * -DestinationAddressPrefix * -Priority 100 | Set-AzNetworkSecurityGroup | Format-Table
            }
            else {
                Write-Host "Removing existing NSG: $nsgName" -ForegroundColor Green
                $existingRule = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $item | Where-Object {$_.Priority -eq 100}
                Remove-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $item -Name $existingRule.Name | Set-AzNetworkSecurityGroup | Format-Table
                Write-Host "Adding rule to NSG: $nsgName" -ForegroundColor Green
                Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $item -Name "Home"-Direction Inbound -SourceAddressPrefix $publicIp -Protocol * -Access Allow -SourcePortRange * -DestinationPortRange * -DestinationAddressPrefix * -Priority 100 | Set-AzNetworkSecurityGroup | Format-Table
            }
        }
        else {
            $nsgName = $item.Name
            Write-Host "Adding rule to NSG: $nsgName" -ForegroundColor Green
            Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $item -Name "Home"-Direction Inbound -SourceAddressPrefix $publicIp -Protocol * -Access Allow -SourcePortRange * -DestinationPortRange * -DestinationAddressPrefix * -Priority 100 | Set-AzNetworkSecurityGroup | Format-Table
        }
    }

    Write-Host "Done!`r`n" -ForegroundColor Black -BackgroundColor Yellow

}
else {
    Write-Error -Message "Invalid public IP`r`n" -ErrorAction Stop
}
