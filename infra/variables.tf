variable "orders_db_password" {
  description = "Password for Orders database"
  type        = string
  sensitive   = true
}

variable "catalog_db_password" {
  description = "Password for Catalog database"
  type        = string
  sensitive   = true
}