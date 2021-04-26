//scope
targetScope = 'resourceGroup'
//Storage account for deployment scripts
var location = resourceGroup().location
param ipaddress string
param dsvmLinuxSize string
param dsvmWindowsSize string
param vmuser string
param vmpassword string
param sshPublicKey string
var vNetIpPrefix  = '192.168.0.0/24'
var defaultSubnetIpPrefix = '192.168.0.0/27'
var bastionSubnetIpPrefix = '192.168.0.32/27'

//Storage account for deployment scripts
module storage 'storage-account.bicep' = {
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

module dsvmlinux 'dsvm-linux.bicep' = {
  name: 'dsvmlinux'
  params:{
    name: 'dsvmlinux'
    location: location
    vmSize: dsvmLinuxSize
    subnetId: vnet.outputs.subnetid
    offer: 'ubuntu-1804'
    publisher: 'microsoft-dsvm'
    sku: '1804'
    version: 'latest'
    adminUsername: vmuser
    ssh_public_key: sshPublicKey
    storageAccountType: 'StandardSSD_LRS'
  }
  dependsOn:[
    [
      vnet
    ]
  ]
}

module dsvmwin 'dsvm-windows.bicep' = {
  name: 'dsvmwin'
  params:{
    name: 'dsvmwin'
    location: location
    vmSize: dsvmWindowsSize
    subnetId: vnet.outputs.subnetid
    offer: 'dsvm-win-2019'
    publisher: 'microsoft-dsvm'
    sku: 'server-2019'
    version: 'latest'
    adminUsername: vmuser
    vmpassword: vmpassword
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
