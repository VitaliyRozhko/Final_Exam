# saving arguments to variables (ex .\task1.ps1 "10.3.218.15" "10.2.208.16" "255.255.255.0" or XX)
$ip1=$args[0]
$ip2=$args[1]
$mask=$args[2]
# check if all arguments are entered
if ($args.count -ne 3) { Write-Host "Not all arguments entered"; Exit }

# create patterns for checking the entered arguments
$pattern1 = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"
$pattern2 = "^([1[0-9]|1[0-9]|3[0-2])$"
$valid_mask = $False
$valid_ip1 = $ip1 -match $pattern1
$valid_ip2 = $ip2 -match $pattern1
$valid_mask1 = $mask -match $pattern1
$valid_mask2 = $mask -match $pattern2

if ($valid_ip1) {$ip1 = [IPAddress]$ip1} 
else {Write-Output 'Incorrectly specified IP1'}
if ($valid_ip2) {$ip2 = [IPAddress]$ip2} 
else {Write-Output 'Incorrectly specified IP2'}
if ($valid_mask1) {$mask = [IPAddress]$mask; $valid_mask = $True} 
elseif ($valid_mask2) {
    $mask1 = ([Math]::Pow(2, $mask) - 1) * [Math]::Pow(2, (32 - $mask)) #((2n)-1) × (2(32-n))
    $bytes = [BitConverter]::GetBytes([UInt32] $mask1)
    $mask=(($bytes.Count - 1)..0 | ForEach-Object { [String] $bytes[$_] }) -join "."
    $valid_mask = $True}
else {Write-Output 'Incorrectly specified Network_mask'; Exit}   
# check if ip_address_1 and ip_address_2 belong to the same network or not
if ($valid_ip1 -and $valid_ip2 -and $valid_mask) {
    if (($ip1.address -band $mask.address) -eq ($ip2.address -band $mask.address)) {Write-Output 'YES'}
else {Write-Output 'NO'}
}
else {Exit}
