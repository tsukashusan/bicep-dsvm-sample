param location string
var workspacename = 'databrickswork'
var managedResourceGroupId = concat('databricks-rg-', workspacename, '-', uniqueString(workspacename, resourceGroup().id))

resource databricks 'Microsoft.Databricks/workspaces@2018-04-01'={
  name: 'databricks'
  location: location
  sku:{
    name: 'Trial'
    tier: 'Standard'
  }
  properties:{
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupId)
  }
}


