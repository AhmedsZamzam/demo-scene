###########################################
################## AWS ####################
###########################################
locals {
  resource_prefix = "${var.global_prefix}${random_string.random_string2.result}"
  bucket_pacman = "%{ if var.s3_bucket_name != "" }${var.s3_bucket_name}%{ else }${var.global_prefix}${random_string.random_string.result}%{ endif }"
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_string" "random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  numeric = false
}

resource "random_string" "random_string2" {
  length = 2
  special = false
  upper = false
  lower = true
  numeric = false
}

resource "aws_s3_bucket" "pacman" {
  bucket = local.bucket_pacman
  
}

resource "aws_s3_bucket_ownership_controls" "pacman" {
  bucket = aws_s3_bucket.pacman.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pacman" {
  bucket = aws_s3_bucket.pacman.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "pacman" {
  depends_on = [
    aws_s3_bucket_ownership_controls.pacman,
    aws_s3_bucket_public_access_block.pacman,
  ]

  bucket = aws_s3_bucket.pacman.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "allow_access_from_public" {
  bucket = aws_s3_bucket.pacman.id
  policy = data.aws_iam_policy_document.allow_access_from_public.json
}

data "aws_iam_policy_document" "allow_access_from_public" {
  statement {
    sid = "PublicReadGetObject"
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.pacman.arn,
      "${aws_s3_bucket.pacman.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "pacman" {
  bucket = aws_s3_bucket.pacman.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "pacman" {
  bucket = aws_s3_bucket.pacman.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
  }
}


