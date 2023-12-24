terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.96"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
