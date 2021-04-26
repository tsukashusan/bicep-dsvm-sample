param virtualNetworkName string
param vNetIpPrefix string
param defaultSubnetIpPrefix string
param location string
param bastionSubnetIpPrefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetIpPrefix
      ]
    }
  }
}

resource subNet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${virtualNetwork.name}/default'
  properties: {
    addressPrefix: defaultSubnetIpPrefix
    networkSecurityGroup:{
      id: IngressTrafficeFromBastoinNSG.id
    }
  }
}

resource IngressTrafficeFromBastoinNSG 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: '${virtualNetworkName}-nsg'
  location:location
  properties:{
    securityRules:[
      {
        name: 'AllowSshRdpOutbound'
        properties:{
          protocol:'Tcp'
          direction:'Inbound'
          access:'Allow'
          sourceAddressPrefix: bastionSubnetIpPrefix
          destinationPortRanges:[
            '22'
            '3389'
          ]
          priority: 100
          destinationAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

output vnetname string = virtualNetwork.name
output subnetid string = subNet.id
