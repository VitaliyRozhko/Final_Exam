[string]$path=$args[0] #.\accounts.csv
#convert csv format
$CSVdata = Get-Content -Path $path | ConvertFrom-Csv 
#change to a capital letter in the first and last name
(Get-Culture).TextInfo.ToTitleCase($CSVdata.name)
#fill in the email field
$CSVdata | ForEach-Object {
    $First, $Rest = $_.name -Split ' '
    $First = $First.ToLower()
    $_.email = $First[0] + $Rest.ToLower() + '@abc.com'
    }
#choose unique names and surnames
$DupName = $CSVdata.email | Group-Object | Sort-Object Count | Where-Object { $_.Count -gt 1 } | Select-Object Name
#check for identical first and last names and add ID to email
$DupName | ForEach-Object {
        $CSVdata | ForEach-Object {         
        $First, $Rest = $_.name -Split ' '
        $First = $First.ToLower()
        if ($DupName.name -eq $_.email) {
        $_.email = $First[0] + $Rest.ToLower() + $_.location_id + '@abc.com'
        }
    }
}
#convert to csv and save to current folder
$path_save = $path -replace "accounts.csv", "accounts_new.csv"
$CSVdata | ConvertTo-Csv | Set-Content -Path $path_save 