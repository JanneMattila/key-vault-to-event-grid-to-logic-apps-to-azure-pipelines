Param (
    [Parameter(HelpMessage = "Deployment target resource group")] 
    [string] $ResourceGroupName = "rg-keyvault-event-prod",

    [Parameter(HelpMessage = "Deployment target resource group location")] 
    [string] $Location = "North Europe",

    [string] $Template = "azuredeploy.json",
    [string] $TemplateParameters = "$PSScriptRoot\azuredeploy.parameters.json"
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$deploymentName = "Local-$date"

if ([string]::IsNullOrEmpty($env:RELEASE_DEFINITIONNAME)) {
    Write-Host (@"
Not executing inside Azure DevOps Release Management.
Make sure you have done "Login-AzAccount" and
"Select-AzSubscription -SubscriptionName name"
so that script continues to work correctly for you.
"@)
}
else {
    $deploymentName = $env:RELEASE_RELEASENAME
}

# Target deployment resource group
if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue)) {
    Write-Warning "Resource group '$ResourceGroupName' doesn't exist and it will be created."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose
}

# Additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable
$additionalParameters['httpPostUri'] = "https://echo.jannemattila.com/api/echo"

$result = New-AzResourceGroupDeployment `
    -DeploymentName $deploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateUri ($templateUrl + $Template + $templateToken) `
    -TemplateParameterFile $TemplateParameters `
    @additionalParameters `
    -Mode Complete -Force `
    -Verbose

if ($null -eq $result.Outputs.logicApp) {
    Throw "Template deployment didn't return web app information correctly and therefore deployment is cancelled."
}

$logicApp = $result.Outputs.logicApp.value

# Publish variable to the Azure DevOps agents so that they
# can be used in follow-up tasks such as application deployment
Write-Host "##vso[task.setvariable variable=Custom.LogicApp;]$logicApp"
