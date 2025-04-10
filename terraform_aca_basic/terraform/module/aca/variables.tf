variable "system_name" {
  description = "システム名"
  default     = ""
}

variable "resource_group_name" {
  description = "リソースグループ名"
  default     = ""
}

variable "vnet_resource_group_name" {
  description = "VNET リソースグループ名"
  default     = ""
}

variable "virtual_network_name" {
  description = "仮想ネットワーク名"
  default     = ""
}

variable "aca_subnet_name" {
  description = "ACA 用サブネット名"
  default     = ""
}

variable "la_ws_suffix" {
  description = "Log Analytics ワークスペースのサフィックス"
  default     = ""
}

variable "workload_profile_type" {
  description = "ワークロードプロファイルのタイプ"
  default     = "D8"
}

variable "maximum_count" {
  description = "ワークロードプロファイルインスタンスの最大数"
  default     = "5"
}

variable "minimum_count" {
  description = "ワークロードプロファイルインスタンスの最小数"
  default     = "3"
}

variable "tags" {
  type = map(string)
  default = {
    source = "terraform"
  }
}

# 複数リージョンデプロイのための変数追加
variable "region_code" {
  description = "リージョンコード（例：japaneast, japanwest）"
  default     = "japaneast"
}

# 顧客単位のパーティション対応
variable "customer_id" {
  description = "顧客識別子"
  default     = "default"
}

# スケーリング設定
variable "scaling_rules" {
  description = "KEDAスケーリングルールのマップ"
  type = list(object({
    name            = string
    metric_type     = string
    target_value    = number
    polling_interval = number
    cooldown_period = number
  }))
  default = []
}

# スケジュールベーススケーリング設定
variable "schedule_scaling_rules" {
  description = "スケジュールベースのスケーリングルール"
  type = list(object({
    name      = string
    schedule  = string
    replica_count = number
  }))
  default = []
}

# パスベースルーティング対応
variable "path_prefix" {
  description = "アプリケーションパスプレフィックス"
  default     = "/"
}