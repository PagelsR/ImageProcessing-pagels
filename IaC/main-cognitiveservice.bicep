param cognitiveServiceName string
param location string
param defaultTags object

@allowed([
  'S0'
  'S1'
])
param sku string = 'S0'

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: cognitiveServiceName
  tags: defaultTags
  location: location
  sku: {
    name: sku
  }
  kind: 'CognitiveServices'
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    customSubDomainName: 'imageprocessing-${uniqueString(resourceGroup().id)}'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    apiProperties: {
      statisticsEnabled: false
    }
    publicNetworkAccess: 'Enabled'
  }
}
