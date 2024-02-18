# Budget
resource "azurerm_consumption_budget_subscription" "example_subscription" {
  name            = "example_subscription_budget-${var.environment}"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  filter {
    dimension {
      name = "ResourceGroupName"
      values = [
        azurerm_resource_group.example.name, data.azurerm_resource_group.aks_mc.name
      ]
    }
  }

  notification {
    enabled   = true
    threshold = 70.0
    operator  = "EqualTo"

    contact_groups = [
      azurerm_monitor_action_group.example_subscription.id,
    ]

    contact_roles = [
      "Owner",
    ]
  }

  notification {
    enabled   = true
    threshold = 100.0
    operator  = "EqualTo"

    contact_groups = [
      azurerm_monitor_action_group.example_subscription.id,
    ]

    contact_roles = [
      "Owner",
    ]
  }


  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = [
      "jam.kuong@gtomato.com",
      "marco.kh.tam@gtomato.com"
    ]

    # contact_groups = [
    #   azurerm_monitor_action_group.example_subscription.id,
    # ]

    # contact_roles = [
    #   "Owner",
    # ]
  }

  lifecycle {
    ignore_changes = [
      time_period
    ]
  }
}



# Action Group for Contact
resource "azurerm_monitor_action_group" "example_subscription" {
  name                = "example_subscription_monitoring_${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "example"

  email_receiver {
    name          = "sendtoadmin"
    email_address = "marco.kh.tam@gtomato.com"
  }

  email_receiver {
    name                    = "sendtodevops"
    email_address           = "jam.kuong@gtomato.com"
    use_common_alert_schema = true
  }
}
