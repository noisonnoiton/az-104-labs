resource "azurerm_storage_account" "this" {
  name                     = "st${local.storage_prefix}${random_string.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = local.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # HTTPS 전용
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # Blob public access 비활성화 (보안 권장)
  allow_nested_items_to_be_public = false

  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = [azurerm_subnet.storage.id]
    bypass                     = ["AzureServices"]
  }

  tags = local.tags
}

resource "azurerm_storage_container" "blob" {
  name                  = var.blob_container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_storage_share" "files" {
  name               = var.file_share_name
  storage_account_id = azurerm_storage_account.this.id
  quota              = var.file_share_quota
}
