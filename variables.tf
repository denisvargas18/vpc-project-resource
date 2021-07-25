variable "tags_secondary" {
  type = map
  default = {}
}

variable "global_tags" {
  type = map
  default = {}
}

variable "vpc_cidr" {
    description = "Valor de CIDR Segmento de Red de VPC."
    type = string
    #default = "190.160.0.0/16"
}

variable "subnet_cidr_pub" {
    description = "Lista de Segmentos de SubRed Publica de VPC."
    type = list
    #default = ["190.160.1.0/24","190.160.2.0/24"]
}

variable "subnet_cidr_prv" {
    description = "Lista de Segmentos de SubRed Privada de VPC."
    type = list
    #default = ["190.160.3.0/24","190.160.4.0/24"]
}

variable "azs_pub" {
    description = "Lista de Zonas de Disponibilidad Publica de Región."
    type = list
    #default = ["us-east-1a","us-east-1b"]
}

variable "azs_prv" {
    description = "Lista de Zonas de Disponibilidad Privada de Región."
    type = list
    #default = ["us-east-1c","us-east-1d"]
}

variable "tenancy" {
  description = "Tipo de VPC en AWS."
  type = string
  #default = ""
}

variable "aws_region" {
  description = "Define la region de AWS."
  type = string
}

variable "environment" {
  description = "Define ambiente de AWS."
  type = string
}
