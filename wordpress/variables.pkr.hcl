variable "common_data_source" {
  type        = string
  description = "The provisioning data source. (e.g. 'http' or 'disk')"
  default     = "http"
}

variable "iso_url" {
  type = string
  default = "https://cdimage.ubuntu.com/cdimage/ubuntu-server/jammy/daily-live/pending/jammy-live-server-arm64.iso"
}

variable "iso_checksum" {
  type = string
  default = "file:https://cdimage.ubuntu.com/cdimage/ubuntu-server/jammy/daily-live/pending/SHA256SUMS"
}