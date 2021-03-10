###########################################
################## AWS ####################
###########################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = local.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_string" "random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  number = false
}

resource "random_string" "random_string2" {
  length = 2
  special = false
  upper = false
  lower = true
  number = false
}

data "template_file" "bucket_pacman" {
  template = "%{ if var.bucket_name != "" }${var.bucket_name}%{ else }${var.global_prefix}${random_string.random_string.result}%{ endif }"
}

data "template_file" "resource_prefix" {
  template = "${var.global_prefix}${random_string.random_string2.result}"
}

resource "aws_s3_bucket" "pacman" {
  bucket = data.template_file.bucket_pacman.rendered
  acl = "public-read"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
  }
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${data.template_file.bucket_pacman.rendered}/*"
        }
    ]
}
EOF
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

###########################################
############## AWS Variables ##############
###########################################

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

###########################################
############ CCloud Variables #############
###########################################

variable "bootstrap_server" {
  type = string
}

variable "cluster_api_key" {
  type = string
}

variable "cluster_api_secret" {
  type = string
}

locals {
  region = split(".", var.bootstrap_server)[1]
}

variable "scoreboard_topic" {
  type = string
  default = "SCOREBOARD"
}

###########################################
############ Alexa Variables ##############
###########################################

# variable "alexa_enabled" {
#   type = bool
#   default = false
# }

# variable "pacman_players_skill_id" {
#   type = string
#   default = ""
# }

###########################################
############ Other Variables ##############
###########################################

variable "global_prefix" {
  type = string
  default = "streaming-pacman"
}

variable "bucket_name" {
  type = string
}

variable "ksql_endpoint" {
  type = string
}

variable "ksql_basic_auth_user_info" {
  type = string
}

