# Key Vault(s) to Event Grid to Logic Apps to Azure Pipelines

Demo about Azure Key Vault event notifications via Event Grid and Logic Apps to Azure Pipelines.

![Demo architecture](https://user-images.githubusercontent.com/2357647/104630691-bddd7f80-56a3-11eb-94c9-ccbff02fe9b6.png)

Create one or more Key Vaults. This demo now relies for following Key Vaults:

```powershell
az group create -n rg-keyvault1 -l northeurope
$kv1=az keyvault create -n kv1000000000010 -g rg-keyvault1 -l northeurope --query id -o tsv

az group create -n rg-keyvault2 -l northeurope
$kv2=az keyvault create -n kv2000000000010 -g rg-keyvault2 -l northeurope --query id -o tsv
```

```powershell
.\deploy.ps1 -KeyVaults $kv1,$kv2
```

## Links

[Monitoring Key Vault with Azure Event Grid](https://docs.microsoft.com/en-us/azure/key-vault/general/event-grid-overview)

[Azure Key Vault as Event Grid source](https://docs.microsoft.com/en-us/azure/event-grid/event-schema-key-vault)

[Allow Event Grid topics and subscriptions to be in separate resource groups](https://feedback.azure.com/forums/909934-azure-event-grid/suggestions/40903996-allow-event-grid-topics-and-subscriptions-to-be-in)