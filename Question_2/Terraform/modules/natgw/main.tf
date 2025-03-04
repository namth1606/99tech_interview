resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "tech_ip"
  }
}

resource "aws_nat_gateway" "natgw" {
  subnet_id = var.subnet_id
  allocation_id = aws_eip.nat_eip.id
  tags = {
    Name = var.name
  }
}