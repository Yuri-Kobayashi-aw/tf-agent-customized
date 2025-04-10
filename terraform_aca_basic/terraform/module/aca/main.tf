# *** コンテナオーケストレーションの定義 ***

# ローカル変数
locals {
  la_name               = "${var.system_name}-la"
  managed_identity_name = "${var.system_name}-${var.region_code}-aca-mid"
  aca_name              = "${var.system_name}-${var.region_code}-aca"
  ui_name               = "${var.system_name}-${var.region_code}-${var.customer_id}-ui"
  service_name          = "${var.system_name}-${var.region_code}-${var.customer_id}-svc"
  acr_name              = "${var.system_name}${var.region_code}registry"

  # カスタマイズ: 命名規則例に従った名前付け
  container_app_name    = "${var.system_name}-${var.region_code}-${var.customer_id}-app"
}

# プロバイダの設定
terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">=1.12.1"
    }
  }
}

# Azure Resource Manager プロバイダーの構成
data "azurerm_client_config" "current" {}

# リソースグループ「rg」を参照する
# 備考：ACA環境で利用するサービスを保持するリソースグループ
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# リソースグループ「rg_vnet」を参照する
# 備考：ACA環境のネットワークを保持するリソースグループ
data "azurerm_resource_group" "rg_vnet" {
  name = var.vnet_resource_group_name
}

# 仮想ネットワーク「aca_vnet」を参照する
# 備考：ACA環境の仮想ネットワーク
data "azurerm_virtual_network" "aca_vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg_vnet.name
}

# サブネット「aca_subnet」を参照する
# 備考：ACA 用のサブネット
data "azurerm_subnet" "aca_subnet" {
  name                 = var.aca_subnet_name
  virtual_network_name = data.azurerm_virtual_network.aca_vnet.name
  resource_group_name  = data.azurerm_resource_group.rg_vnet.name
}

# Log Analytics ワークスペース「la_ws」を参照する
data "azurerm_log_analytics_workspace" "la_ws" {
  name                = "${local.la_name}-${var.la_ws_suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Azure Container Apps 環境「aca_env」を作成する
resource "azurerm_container_app_environment" "aca_env" {
  name                           = local.aca_name
  resource_group_name            = data.azurerm_resource_group.rg.name
  location                       = data.azurerm_resource_group.rg.location
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.la_ws.id
  internal_load_balancer_enabled = true
  
  # 変更点: すべての環境でゾーン冗長性を有効化し、地理的冗長性要件に対応
  zone_redundancy_enabled        = true
  
  infrastructure_subnet_id       = data.azurerm_subnet.aca_subnet.id

  workload_profile {
    name                  = "default"
    workload_profile_type = var.workload_profile_type
    maximum_count         = var.maximum_count
    minimum_count         = var.minimum_count
  }

  tags = var.tags
}

# ストレージアカウントの名前の末尾に付与する8桁のランダムなIDを作成する
resource "random_id" "aca_storage_suffix" {
  byte_length = 8
}

# ストレージアカウント「aca_storage」を作成する
resource "azurerm_storage_account" "aca_storage" {
  name                          = "sa${var.region_code}${random_id.aca_storage_suffix.dec}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  
  # 変更点: すべての環境でZRSを有効化
  account_replication_type      = "ZRS"
  
  public_network_access_enabled = false
  network_rules {
    default_action = "Deny"
  }
  tags = var.tags
}