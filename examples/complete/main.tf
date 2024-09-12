module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.13"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name
      location = "westeurope"
    }
  }
}

module "analytics" {
  source  = "cloudnationhq/law/azure"
  version = "~> 1.0"

  workspace = {
    name           = module.naming.log_analytics_workspace.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
  }
}

module "appi" {
  source = "cloudnationhq/appi/azure"
  version = "~> 1.0"

  config = {
    name             = module.naming.application_insights.name
    resource_group   = module.rg.groups.demo.name
    location         = module.rg.groups.demo.location
    application_type = "web"
    workspace_id     = module.analytics.workspace.id

    analytics_items = {
      item1 = {
        name    = "item1"
        content = "requests //simple example query"
        scope   = "shared"
        type    = "query"
      }
    }

    api_keys = {
      key1 = {
        name              = "key1"
        read_permissions  = ["api"]
        write_permissions = ["annotations"]
      }
    }

    smart_detection_rules = {
      sdr1 = {
        name                          = "Slow server response time"
        enabled                       = true
        send_emails_to_subscription_owners = false
      }
    }

    standard_web_tests = {
      swt1 = {
        name          = "swt1"
        geo_locations = ["emea-nl-ams-azr"]
        description   = "Standard Web Test"
        enabled       = true
        frequency     = 300
        retry_enabled = true
        request = {
          url = "http://www.example.com"
        }
      }
    }

    web_tests = {
      wt1 = {
        name          = "wt1"
        geo_locations = ["emea-nl-ams-azr"]
        description   = "Web Test"
        kind = "ping"
        configuration = <<XML
<WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="http://microsoft.com" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
      }
    }
  }
}
