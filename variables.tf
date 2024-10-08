variable "region" {
  type = string
  default = "us-east-1"
}

variable "bucket-name" {
  type = string
  default = "static-website-smw"
}

variable "domain-name" {
    type = string
    default = "mystatic-website.com"
}

variable "tags-name" {
  type = string
  default = "My static website example"
}