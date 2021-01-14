# Key Vault(s) to Event Grid to Logic Apps to Azure Pipelines

Demo about Azure Key Vault event notifications via Event Grid and Logic Apps to Azure Pipelines.

![Demo architecture](https://user-images.githubusercontent.com/2357647/104630691-bddd7f80-56a3-11eb-94c9-ccbff02fe9b6.png)

Create one or more Key Vaults. Is this demo we'll create two:

```powershell
az group create -n rg-keyvault1 -l northeurope
$kv1=az keyvault create -n kv1000000000010 -g rg-keyvault1 -l northeurope --query id -o tsv

az group create -n rg-keyvault2 -l northeurope
$kv2=az keyvault create -n kv2000000000010 -g rg-keyvault2 -l northeurope --query id -o tsv
```

To deploy the demo infrastructure run following script:

```powershell
cd deploy
.\deploy.ps1 -KeyVaults $kv1,$kv2
```

*Note*: It deploys Event Grid System topics to the resource groups
of the key vaults since that's currently required. See this feedback
item for more details:
[Allow Event Grid topics and subscriptions to be in separate resource groups](https://feedback.azure.com/forums/909934-azure-event-grid/suggestions/40903996-allow-event-grid-topics-and-subscriptions-to-be-in)

You should now have following Logic App deployed:

![Deployed Logic App](https://user-images.githubusercontent.com/2357647/104639767-76a9bb80-56b0-11eb-8eca-60b531e4dc0d.png)

## Demo

Create or update secret in one of your Key Vaults:

```powershell
az keyvault secret set -n abc --vault-name kv2000000000010 --value "Hello!"
```

After a while you should see following data coming into your request bin:

```json
{
  "eventType": "Microsoft.KeyVault.SecretNewVersionCreated",
  "objectName": "abc",
  "objectType": "Secret",
  "vaultName": "kv2000000000010"
}
```

Also your Azure DevOps pipeline should be executed and they
would have now access to freshly updated key vault secrets!

[![Build status](https://dev.azure.com/jannemattila/jannemattila/_apis/build/status/jannemattila-CI)](https://dev.azure.com/jannemattila/jannemattila/_build/latest?definitionId=57)

## Logic Apps development flow

Developing in Azure Portal is easy and you can use 
[jeffhollan/LogicAppTemplateCreator](https://github.com/jeffhollan/LogicAppTemplateCreator)
for extracting your templates out. In a nutshell like this:

```powershell
Import-Module .\LogicAppTemplate.dll

Get-LogicAppTemplate `
  -LogicApp keyvault-event-handler `
  -ResourceGroup rg-keyvault-event-local `
  -SubscriptionId <your-subscription-id-> `
  -TenantName <your-tenant>.onmicrosoft.com `
  -DiagnosticSettings > azuredeploy-export.json
```

## Links

[Monitoring Key Vault with Azure Event Grid](https://docs.microsoft.com/en-us/azure/key-vault/general/event-grid-overview)

[Azure Key Vault as Event Grid source](https://docs.microsoft.com/en-us/azure/event-grid/event-schema-key-vault)
