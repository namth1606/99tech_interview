variable "name" {
  description = "The name of rtb"
  type = string
}

variable "vpc_id" {
  description = "The id of vpc"
  type = string
}

variable "subnet_ids" {
  description = "The list id of subnet"
  type = list(string)
}

variable "routes" {
  description = "Danh sách các route cần tạo"
  type = list(object({
    cidr_block       = string
    gateway_id       = optional(string)
    nat_gateway_id   = optional(string)
    transit_gateway_id = optional(string)
  }))
  default = []
}