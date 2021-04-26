param location string
param bastionHostName string
param virtualNetworkName string
param bastionSubnetIpPrefix string
param ipaddress string

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${bastionHostName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource BastionIngressEgressTrafficeNSG 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: '${bastionHostName}-nsg'
  location:location
  properties:{
    securityRules:[
      {
        name: 'AllowHttpsInbound'
        properties:{
          protocol:'Tcp'
          direction:'Inbound'
          access:'Allow'
          sourceAddressPrefixes:[
            ipaddress
          ]
          destinationPortRanges:[
            '443'
          ]
          priority: 100
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties:{
          protocol:'Tcp'
          direction:'Inbound'
          access:'Allow'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRanges:[
            '443'
          ]
          priority: 110
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties:{
          protocol:'Tcp'
          direction:'Inbound'
          access:'Allow'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRanges:[
            '443'
          ]
          priority: 120
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties:{
          protocol:'*'
          direction:'Inbound'
          access:'Allow'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges:[
            '8080'
            '5701'
          ]
          priority: 130
          destinationAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties:{
          protocol:'Tcp'
          direction:'Outbound'
          access:'Allow'
          sourceAddressPrefix: '*'
          destinationPortRanges:[
            '22'
            '3389'
          ]
          priority: 100
          destinationAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties:{
          protocol:'Tcp'
          direction:'Outbound'
          access:'Allow'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
          priority: 110
        }
      }
      {
        name: 'AllowBastioncommunication'
        properties:{
          protocol:'Tcp'
          direction:'Outbound'
          access:'Allow'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          priority: 120
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties:{
          protocol:'*'
          direction:'Outbound'
          access:'Allow'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '80'
          priority: 130
        }
      }
    ]
  }
}

resource subNet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${virtualNetworkName}/AzureBastionSubnet'
  properties: {
    addressPrefix: bastionSubnetIpPrefix
    networkSecurityGroup:{
      id:BastionIngressEgressTrafficeNSG.id
    }
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subNet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}
