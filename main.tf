terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.65.0"
    }
  }
}

provider "aws" {
    region = var.region
  
}

# Create a S3 bucket

resource "aws_s3_bucket" "static-website-smw" {
    bucket = var.bucket-name
    tags = {
            environment = var.tags-name
            }
  
}

resource "aws_s3_bucket_website_configuration" "static-website-smw" {
    bucket = aws_s3_bucket.static-website-smw.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }
    depends_on = [ aws_s3_bucket.static-website-smw ]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.static-website-smw.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "static-website-acl" {
    bucket = aws_s3_bucket.static-website-smw.id
    acl = "public-read"
    depends_on = [ aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
    
}

resource "aws_s3_bucket_public_access_block" "public-access" {
    bucket = aws_s3_bucket.static-website-smw.id
    block_public_acls = false 
    block_public_policy = false 
    ignore_public_acls = false 
    restrict_public_buckets = false 
    depends_on = [ aws_s3_bucket.static-website-smw ]
  
}

resource "aws_s3_object" "index" {
    bucket = aws_s3_bucket.static-website-smw.id
    key = "index.html"
    source = "index.html"
    acl = "public-read"
    content_type = "text/html"
    depends_on = [ aws_s3_bucket.static-website-smw ]
}

resource "aws_s3_object" "error" {
    bucket = aws_s3_bucket.static-website-smw.id
    key = "error.html"
    source = "error.html"
    acl = "public-read"
    content_type = "text/html"
    depends_on = [ aws_s3_bucket.static-website-smw ]
  
}

