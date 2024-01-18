# Create load balancer
resource "azurerm_lb" "msimpson-lb" {
  name                = "msimpson-lb"
  location            = azurerm_resource_group.msimpson.location
  resource_group_name = azurerm_resource_group.msimpson.name
  #sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "msimpson-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.msimpson-lbpip.id
  }

  tags = {
    environment = "Dev-TFC"
  }
}
resource "azurerm_lb_backend_address_pool" "msimpson-lbbackendpool" {
  name            = "msimpson-lbbackendpool"
  loadbalancer_id = azurerm_lb.msimpson-lb.id
  #  resource_group_name = azurerm_resource_group.msimpson.name
}
resource "azurerm_lb_backend_address_pool_address" "msimpson-lbbackendpooladdress" {
  name                      = "msimpson-lbbackendpooladdress"
  resource_group_name      = azurerm_resource_group.msimpson.name
  # Remove the loadbalancer_id attribute
  # loadbalancer_id           = azurerm_lb.msimpson-lb.id
  backend_address_pool_id   = azurerm_lb_backend_address_pool.msimpson-lbbackendpool.id
  backend_ip_configuration = azurerm_network_interface.msimpson-nic.ip_configuration[0].id
}

resource "azurerm_lb_nat_rule" "msimpson-lbnatrule" {
  name                           = "msimpson-lbnatrule"
  resource_group_name            = azurerm_resource_group.msimpson.name
  loadbalancer_id                = azurerm_lb.msimpson-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "msimpson-PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.msimpson-lbbackendpool.id
#  frontend_port_start            = 80
#  frontend_port_end              = 8080
}
resource "azurerm_lb_rule" "msimpson-lbrule" {
  name = "msimpson-lbrule"
  #  resource_group_name            = azurerm_resource_group.msimpson.name
  loadbalancer_id                = azurerm_lb.msimpson-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "msimpson-PublicIPAddress"
  #  backend_address_pool_id        = azurerm_lb_backend_address_pool.msimpson-lbbackendpool.id
}
resource "azurerm_lb_probe" "msimpson-lbprobe" {
  name = "msimpson-lbprobe"
  #  resource_group_name = azurerm_resource_group.msimpson.name
  loadbalancer_id = azurerm_lb.msimpson-lb.id
  port            = 80
  protocol        = "Tcp"
  #  interval            = 5
  number_of_probes = 2
}
