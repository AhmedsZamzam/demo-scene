module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/../../games"
  template_vars = {
    # Pass in any values that you wish to use in your templates.
    #vpc_id = "vpc-abc123"
  }
}

resource "aws_s3_object" "files" {
  for_each = module.template_files.files

  bucket = aws_s3_bucket.games.bucket
  key          = each.key
  content_type = each.value.content_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.source_path
  content = each.value.content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.digests.md5
}

locals {
  # Env vars file from template
  env_vars_js = templatefile("${path.module}/../../games/templates/env-vars.js", {
        cloud_provider = "AWS"
        ksqldb_endpoint = "/${aws_api_gateway_stage.event_handler_v1.stage_name}${aws_api_gateway_resource.event_handler_resource.path}"
    })
} 

resource "aws_s3_object" "env_vars_js" {
  depends_on = [aws_s3_object.files]
  bucket = aws_s3_bucket.games.bucket
  key = "js/env-vars.js"
  content_type = "text/javascript"
  content = local.env_vars_js
  etag  = md5(local.env_vars_js)
}

