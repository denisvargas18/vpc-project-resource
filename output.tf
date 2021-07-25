output "vpc_id" {
  value = ["${aws_vpc.terra_vpc.id}"]
  #sensitive = true
}

output "subnet_id_pb" {
  value = ["${aws_subnet.subnet_public.*.id}"]
}

output "subnet_id_pr" {
 value = ["${aws_subnet.subnet_private.*.id}"]
}

output "igw_id" {
  value = ["${aws_internet_gateway.terra_igw.id}"]
}

output "ngw_id" {
  value = ["${aws_nat_gateway.terra_ngw.id}"]
}
