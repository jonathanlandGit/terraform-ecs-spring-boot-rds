# Fetch AZs in the current region
data "aws_availability_zones" "available" {}

data "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

# Create var.az_count private subnets, each in a different AZ
data "aws_subnet" "private" {
  id = "subnet-34bcc152"
}

# Create var.az_count public subnets, each in a different AZ
data "aws_subnet" "public" {
  id = "subnet-60641f41"

}

# IGW for the public subnet
data "aws_internet_gateway" "gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

# Route the public subnet trafic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = "rtb-a87367d6"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.gw.id
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  count      = var.az_count
  vpc        = true
  depends_on = ["data.aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  subnet_id     = element(data.aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count = var.az_count
  # vpc_id = aws_vpc.main.id
  vpc_id = var.vpc_id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
    #gateway_id          = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "vpc-sb-private-route-table"
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
# resource "aws_route_table_association" "private" {
#   count          = var.az_count
#   subnet_id      = element(data.aws_subnet.private.*.id, count.index)
#   route_table_id = element(aws_route_table.private.*.id, count.index)
# }
