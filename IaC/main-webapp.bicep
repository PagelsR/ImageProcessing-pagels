param skuName string = 'S1'
//param skuCapacity int = 1
param location string = resourceGroup().location
param webAppPlanName string
param webSiteName string
param resourceGroupName string
param appInsightsName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param defaultTags object

// Add role assigment for Service Identity
// Azure built-in roles - https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// App Configuration Data Reader	Allows read access to App Configuration data.	516239f1-63e1-4d78-a4de-a74fb236a071
//var AppConfigDataReaderRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: webAppPlanName
  location: location
  tags: defaultTags
  properties: {}
  sku: {
    name: skuName
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: webSiteName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  tags: defaultTags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      healthCheckPath: '/healthy'
    }
  }
}

resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: appService
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: '1'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    WebAppUrl: 'https://${appService.name}.azurewebsites.net/'
    ASPNETCORE_ENVIRONMENT: 'Development'
  }
}

// resource webSiteWebSettingsStrings 'Microsoft.Web/sites/config@2022-03-01' = {
//   parent: appService
//   name: 'web'
//   properties: {
//     numberOfWorkers: 1
//     defaultDocuments: [
//       'Default.htm'
//       'Default.html'
//       'Default.asp'
//       'index.htm'
//       'index.html'
//       'iisstart.htm'
//       'default.aspx'
//       'index.php'
//       'hostingstart.html'
//     ]
//     netFrameworkVersion: 'v7.0'
//     phpVersion: '5.6'
//     requestTracingEnabled: false
//     remoteDebuggingEnabled: false
//     httpLoggingEnabled: false
//     acrUseManagedIdentityCreds: false
//     logsDirectorySizeLimit: 35
//     detailedErrorLoggingEnabled: false
//     publishingUsername: '$app-ImageProcessing-rpagels'
//     scmType: 'ExternalGit'
//     use32BitWorkerProcess: true
//     webSocketsEnabled: true
//     alwaysOn: false
//     managedPipelineMode: 'Integrated'
//     virtualApplications: [
//       {
//         virtualPath: '/'
//         physicalPath: 'site\\wwwroot'
//         preloadEnabled: false
//       }
//     ]
//     loadBalancing: 'LeastRequests'
//     experiments: {
//       rampUpRules: []
//     }
//     autoHealEnabled: false
//     vnetRouteAllEnabled: false
//     vnetPrivatePortsCount: 0
//     localMySqlEnabled: false
//     ipSecurityRestrictions: [
//       {
//         ipAddress: 'Any'
//         action: 'Allow'
//         priority: 2147483647
//         name: 'Allow all'
//         description: 'Allow all access'
//       }
//     ]
//     scmIpSecurityRestrictions: [
//       {
//         ipAddress: 'Any'
//         action: 'Allow'
//         priority: 2147483647
//         name: 'Allow all'
//         description: 'Allow all access'
//       }
//     ]
//     scmIpSecurityRestrictionsUseMain: false
//     http20Enabled: false
//     minTlsVersion: '1.2'
//     scmMinTlsVersion: '1.2'
//     ftpsState: 'AllAllowed'
//     preWarmedInstanceCount: 0
//     functionsRuntimeScaleMonitoringEnabled: false
//     minimumElasticInstanceCount: 0
//     azureStorageAccounts: {
//     }
//   }
// }

// Location population tags
// https://docs.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability

resource standardWebTestPageHome  'Microsoft.Insights/webtests@2022-06-15' = {
  name: 'Page Home'
  location: location
  tags: {
    'hidden-link:${subscription().id}/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
   }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Page Home'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/'
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      IgnoreHttpsStatusCode: false
      ContentValidation: null
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}

resource standardWebTestPageNutritions  'Microsoft.Insights/webtests@2022-06-15' = {
  name: 'Page Nutritions'
  location: location
  tags: {
    'hidden-link:${subscription().id}/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Page Nutritions'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Nutritions/'
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      IgnoreHttpsStatusCode: false
      ContentValidation: null
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}

resource standardWebTestPageExercises  'Microsoft.Insights/webtests@2022-06-15' = {
  name: 'Page Exercises'
  location: location
  tags: {
     'hidden-link:${subscription().id}/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Page Exercises'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Exercises/'
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      IgnoreHttpsStatusCode: false
      ContentValidation: null
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}

output out_appService string = appService.id
output out_webSiteName string = appService.properties.defaultHostName
output out_appServiceprincipalId string = appService.identity.principalId
