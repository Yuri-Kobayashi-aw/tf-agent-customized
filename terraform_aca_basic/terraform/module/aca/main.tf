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