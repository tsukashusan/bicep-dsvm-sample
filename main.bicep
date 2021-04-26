//scope
targetScope = 'resourceGroup'
//Storage account for deployment scripts
var location = resourceGroup().location
param ipaddress string
var vNetIpPrefix  = '192.168.0.0/24'
var defaultSubnetIpPrefix = '192.168.0.0/27'
var bastionSubnetIpPrefix = '192.168.0.32/27'

//Storage account for deployment scripts
module storage './storage-account.bicep' = {
  name: 'deploymentScriptStorage'
  params: {
    location: location
    ipaddress: ipaddress
  }
}

module vnet './virtual_network.bicep' = {
  name: 'vnet'
  params:{
    virtualNetworkName: 'vnet01'
    vNetIpPrefix: vNetIpPrefix
    defaultSubnetIpPrefix: defaultSubnetIpPrefix
    location: location
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
  }
}

module dsvmlinux './dsvm-linux.bicep' = {
  name: 'dsvmlinux'
  params:{
    name: 'dsvmlinux'
    location: location
    vmSize: 'Standard_NC6s_v3'
    subnetId: vnet.outputs.subnetid
    offer: 'ubuntu-1804'
    publisher: 'microsoft-dsvm'
    sku: '1804'
    version: 'latest'
    adminUsername: 'adminuser'
    ssh_public_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwTXfsS4+FRigKOYxWt9NYIQ2nSEA+dRu40d2+gkYEaZEuXpTL1VO+PNHzibC9v6zKwBD2bTyvCGb88/ybB6uKicUKlZhNKZs+tSvyrhgF+15Xh/3K1gS+ZAGszt3xUBHPynM4HcOU/anx32zO+lHCRUDPkbSeRlXzUsUJ0tC0aoye9kQsh96jF9Z2OrTPL42eLmLtK+uVNHwQvrhmuYrRAdlTM1we6Brf0AqeX8t1qNTMF9oURNSAFL5S21V+gYQlXIflUSEoFpHEWy/I9Drt6OREW6alxbuTHTw8LFk0E4yIWuOUXgYsnJt84W0EElyip7LJyzEtdg06NSeVhxSB'
    storageAccountType: 'StandardSSD_LRS'
  }
  dependsOn:[
    [
      vnet
    ]
  ]
}

module dsvmwin './dsvm-windows.bicep' = {
  name: 'dsvmwin'
  params:{
    name: 'dsvmwin'
    location: location
    vmSize: 'Standard_NC6s_v3'
    subnetId: vnet.outputs.subnetid
    offer: 'dsvm-win-2019'
    publisher: 'microsoft-dsvm'
    sku: 'server-2019'
    version: 'latest'
    adminUsername: 'adminuser'
    vmpassword: '1qaz@wsx3edC'
    storageAccountType: 'StandardSSD_LRS'
  }
  dependsOn:[
    [
      vnet
    ]
  ]
}

module bastion 'bastionhost.bicep' = {
  name: 'bastion'
  params:{
    location: location
    bastionHostName: 'bastionhost'
    virtualNetworkName: vnet.outputs.vnetname
    bastionSubnetIpPrefix: bastionSubnetIpPrefix
    ipaddress: ipaddress
  }
  dependsOn:[
    [
      vnet
    ]
  ]
}

module databricks 'databricks.bicep' = {
  name: 'databricks'
  params:{
    location: location
  }
}
