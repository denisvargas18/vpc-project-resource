# VPC resource
resource "aws_vpc" "terra_vpc" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "${var.tenancy}"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = "${var.tags_secondary}" #Using variable root

    #tags = { Using local
    #    Name = "vpc-source-${var.environment}-${substr(uuid(), 1,10)}"
    #    Country = "Perú"
    #    City = "Lima"
    #    Cost_Center = "1256"
    #    Cost_Number = "0520"
    #}
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
    vpc_id = "${aws_vpc.terra_vpc.id}" #se commitea para trabajar con module
    #tags = "${var.tags}"
    #tags = {
    #    Name = "igw-source-${var.environment}-${substr(uuid(), 1,10)}"
    #    Region = "${var.aws_region}"
    #}
    tags = merge(
        "${var.global_tags}",
        {
            Name = "igw-source-${var.environment}-${substr(uuid(), 1,10)}"
            Region = "${var.aws_region}"
        }
    )
    depends_on = [aws_vpc.terra_vpc]
}

# Elastic IP
resource "aws_eip" "terra_eip" {
    vpc = true
    #tags = "${var.tags}"
    tags = {
        Name = "eip-source-${var.environment}-${substr(uuid(), 1,10)}"
        Region = "${var.aws_region}"
    }
}

# Nat Gateway #revisar obtner solo un id para atachar a nat gateway
resource "aws_nat_gateway" "terra_ngw" { #refactorizar para crear 2 nat en cada subnet publica.
    allocation_id = "${aws_eip.terra_eip.id}"
    subnet_id = "${aws_subnet.subnet_public.1.id}"
    #tags = "${var.tags}"
    tags = {
        Name = "ngw-source-${var.environment}-${substr(uuid(), 1,10)}"
        Region = "${var.aws_region}"
    }
    depends_on = [aws_internet_gateway.terra_igw, aws_eip.terra_eip, aws_subnet.subnet_public]
}


# Subnets: public
resource "aws_subnet" "subnet_public" {
    count = "${length(var.subnet_cidr_pub)}"
    vpc_id = "${aws_vpc.terra_vpc.id}"
    map_public_ip_on_launch = true # auto-assing public ip
    cidr_block = "${element(var.subnet_cidr_pub, count.index)}"
    availability_zone = "${element(var.azs_pub, count.index)}"
    tags = {
        Name = "subnet-pbl-source-${var.environment}-${substr(uuid(), 1,10)}"
        Region = "${var.aws_region}"
    }
    depends_on = [aws_vpc.terra_vpc]
}

# Subnets: private
resource "aws_subnet" "subnet_private" {
    count = "${length(var.subnet_cidr_prv)}"
    vpc_id = "${aws_vpc.terra_vpc.id}"
    map_public_ip_on_launch = false
    cidr_block = "${element(var.subnet_cidr_prv, count.index)}"
    availability_zone = "${element(var.azs_prv, count.index)}"
    #tags = "${var.tags}"
    tags = {
        Name = "subnet-prv-source-${var.environment}-${substr(uuid(), 1,10)}"
        Region = "${var.aws_region}"
    }
    depends_on = [aws_vpc.terra_vpc]
}

# Route Table: Attach IGW
resource "aws_route_table" "rbt_public" {
    vpc_id = "${aws_vpc.terra_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.terra_igw.id}"
    }
    #tags = "${var.tags}"
    tags = {
        Name = "rbt-public-source-${var.environment}-${substr(uuid(), 1,10)}"
        Region = "${var.aws_region}"
    }
    depends_on = [aws_internet_gateway.terra_igw]
}


# Route Table: Attach NGW
resource "aws_route_table" "rbt_private" {
    vpc_id = "${aws_vpc.terra_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.terra_ngw.id}"
    }
    #tags = "${var.tags}"
    tags = {
        Name = "rbt-private-source-${var.environment}-${substr(uuid(), 1,10)}"
        Region = "${var.aws_region}"
    }
    depends_on = [aws_nat_gateway.terra_ngw]
}


# Associations rbt for subnets public
resource "aws_route_table_association" "as_rbt_pub" {
    count = "${length(var.subnet_cidr_pub)}"
    subnet_id = "${element(aws_subnet.subnet_public.*.id, count.index)}"
    route_table_id = "${aws_route_table.rbt_public.id}"
}


# Associations rbt for subnets private
resource "aws_route_table_association" "as_rbt_prv" {
    count = "${length(var.subnet_cidr_prv)}"
    subnet_id = "${element(aws_subnet.subnet_private.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.rbt_private.*.id, count.index)}"
}

# Default security to vpc eggress / ingress
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.terra_vpc.id}"
  depends_on  = [aws_vpc.terra_vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}