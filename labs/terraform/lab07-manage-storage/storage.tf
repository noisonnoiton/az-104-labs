resource "azurerm_storage_account" "this" {
  name                     = "st${local.storage_prefix}${random_string.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = local.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # HTTPS 전용
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # Blob public access 허용 (Lab 테스트용 — 운영에서는 false 권장)
  allow_nested_items_to_be_public = true

  network_rules {
    default_action             = var.network_default_action
    virtual_network_subnet_ids = [azurerm_subnet.vm.id]
    bypass                     = ["AzureServices"]
  }

  tags = local.tags
}

# ── Public container (anonymous read) ─────────────────────────────
resource "azurerm_storage_container" "web" {
  name                  = "web"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "blob"
}

# ── HTML 파일 업로드 ──────────────────────────────────────────────
resource "azurerm_storage_blob" "index_html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  content_type           = "text/html"
  source_content         = <<-HTML
    <!DOCTYPE html>
    <html lang="en">
    <head><meta charset="UTF-8"><title>AZ-104 Lab 07</title></head>
    <body>
      <h1>Hello from AZ-104 Lab 07!</h1>
      <p>Storage Account: ${azurerm_storage_account.this.name}</p>
      <p>This page is served from Azure Blob Storage (public container).</p>
    </body>
    </html>
  HTML
}

resource "azurerm_storage_share" "files" {
  name               = var.file_share_name
  storage_account_id = azurerm_storage_account.this.id
  quota              = var.file_share_quota
}
