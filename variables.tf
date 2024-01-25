variable "host_os" {
  description = "The OS of the host machine"
  type        = string
  default     = "windows"
}
variable "resource_group_name" {
  default     = "msimpson-sandbox"
  description = "msimpson-sandbox"
  type        = string
}
variable "location" {
  default     = "East US"
  description = "Region"
  type        = string
}
variable "tenant_id" {
  description = "Azure Tenant ID"
  default     = "f4f9dc8e-ef90-45c0-b2c9-133bc28404ac"
  type        = string

}
variable "subscription_id" {
  default = "c759eb32-e9c8-4e19-9f2f-d036cf250f5c"
  type    = string
}

variable "client_id" {
  default = "f4f9dc8e-ef90-45c0-b2c9-133bc28404ac"
  type    = string
}
