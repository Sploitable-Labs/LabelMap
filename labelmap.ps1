## Pre-requs.
# 1. Elevate your MS access via PIM.
# 2. Open a PowerShell console as local admin.

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
Install-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement

# You will be prompted to login...
Connect-IPPSSession

if (-Not (Test-Path -Path "$HOME\rules")) {
    New-Item -ItemType Directory -Path "$HOME\rules"
}

$match_string = "something_from_your_policy_naming_convention"

# Download all the matching policies - this takes a few minutes - go make a brew.
$policies = Get-DlpCompliancePolicy | Where-Object { $_.Name -like "*$($match_string)*"}

$totalPolicies = $policies.Count
$currentPolicy = 0

foreach ($policy in $policies) {
    $currentPolicy++
    Write-Output "[ $currentPolicy / $totalPolicies] Extracting rules from policy: $($policy.name)"
    
    # Download the rules for this policy.
    $rules = Get-DlpComplianceRule - policy "$($policy.Name)"

    # Santize the policy name to create a valid file name.
    $sanitizedPolicyName = $policy.Name -replace '[<>:"/\\|?*]', '_'

    # Define the file path for each policy's rules.
    $filePath = "$HOME\rules\$($sanitizedPolicyName)_Rules.json"

    # Convert the rules to JSON and write to the file.
    $rules | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $filePath
}

