resource "aws_route_table" "rtb" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = lookup(route.value, "gateway_id", null)
      nat_gateway_id = lookup(route.value, "nat_gateway_id", null)
      transit_gateway_id = lookup(route.value, "transit_gateway_id", null)
    }
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "rbtas" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.rtb.id
}