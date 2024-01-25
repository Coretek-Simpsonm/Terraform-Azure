#create external PIP
resource "azurerm_public_ip" "msimpson-lbepip" {
  name                = "msimpson-lbepip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Dev-TFC"
  }

}
# Create load balancer
resource "azurerm_lb" "msimpson-lb" {
  name                = "msimpson-lb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.msimpson.name
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name = "msimpson-PublicIPAddress"
    #subnet_id            = azurerm_subnet.msimpson-subnet.id
    public_ip_address_id = azurerm_public_ip.msimpson-lbepip.id
  }

  tags = {
    environment = "Dev-TFC"
  }
}
resource "azurerm_lb_backend_address_pool" "msimpson-lbbackendpool" {
  name            = "msimpson-lbbackendpool"
  loadbalancer_id = azurerm_lb.msimpson-lb.id
  # virtual_network_id = azurerm_virtual_network.msimpson-evnet.id

}
resource "azurerm_lb_backend_address_pool_address" "msimpson-lbbackendpooladdress" {
  name = "msimpson-lbbackendpooladdress"
  # resource_group_name     = data.azurerm_resource_group.msimpson.name
  #loadbalancer_id         = azurerm_lb.msimpson-lb.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.msimpson-lbbackendpool.id
  # /subscriptions/c759eb32-e9c8-4e19-9f2f-d036cf250f5c/
  #backend_ip_configuration       = azurerm_network_interface.msimpson-nic.ip_configuration[0].id
  ip_address         = "10.10.1.1"
  virtual_network_id = azurerm_virtual_network.msimpson-evnet.id



}

#resource "azurerm_lb_nat_rule" "msimpson-lbnatrule" {
#  name                           = "msimpson-lbnatrule"
#  resource_group_name            = data.azurerm_resource_group.msimpson.name
#  loadbalancer_id                = azurerm_lb.msimpson-lb.id
#  protocol                       = "Tcp"
#  frontend_port                  = 80
#  backend_port                   = 80
#  frontend_ip_configuration_name = "msimpson-PublicIPAddress"
#  backend_address_pool_id        = azurerm_lb_backend_address_pool.msimpson-lbbackendpool.id
#  frontend_port_start            = 80
#  frontend_port_end              = 8080
#}
resource "azurerm_lb_rule" "msimpson-lbrule" {
  name = "msimpson-lbrule"
  #  resource_group_name            = data.azurerm_resource_group.msimpson.name
  loadbalancer_id                = azurerm_lb.msimpson-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "msimpson-PublicIPAddress"
  #  backend_address_pool_id        = azurerm_lb_backend_address_pool.msimpson-lbbackendpool.id
}

#create health probe
resource "azurerm_lb_probe" "msimpson-lbprobe" {
  name = "msimpson-lbprobe"
  #  resource_group_name = data.azurerm_resource_group.msimpson.name
  loadbalancer_id = azurerm_lb.msimpson-lb.id
  port            = 80
  protocol        = "Tcp"
  #  interval            = 5
  number_of_probes = 2
}
