variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "cloud_id" {
  type    = string
}

variable "folder_id" {
  type    = string
}

variable "image_id" {
  type = string

  default = "fd8mcvr7idjrbd9kopru" # alma 8
}

variable "yc_token" {
  type    = string
}
