###########################################
################# Outputs #################
###########################################

output "Pacman" {
  value = "http://${data.aws_s3_bucket.pacman.website_endpoint}"
}

output "ksqlDB" {
  value = "http://${aws_alb.ksqldb_lbr.dns_name}"
}
