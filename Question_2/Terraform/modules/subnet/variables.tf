variable "name" {
  description = "The name of subnet"
  type = string
}

variable "vpc_id" {
  description = "The vpc id"
  type = string
}

variable "cidr_block" {
  description = "The cidr block"
  type = string
}


variable "zone" {
  description = "The subnet zone"
  type = string
}