param location string
param ipaddress string

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'sadscript${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties:{
    accessTier:'Hot'
    allowBlobPublicAccess:false
    networkAcls:{
      defaultAction:'Deny'
      ipRules:[
        {
          action:'Allow'
          value: ipaddress
        }
      ]
    }
  }
}

output name string = stg.name
output id string = stg.id
