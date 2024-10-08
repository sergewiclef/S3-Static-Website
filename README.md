This blog post explores Terraform code for deploying a static website on Amazon S3. We'll break down the code step-by-step, explaining how each section creates a specific resource.
Setting Up Providers

Terraform

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

This block defines the required Terraform provider for interacting with AWS resources. We're using the hashicorp/aws provider with version 5.65.0.

The aws provider block sets the AWS region where the resources will be created. The actual region name is specified in a variable named region.

Creating the S3 Bucket

Terraform

resource "aws_s3_bucket" "static-website-smw" {
  bucket = var.bucket-name
  tags = {
    environment = var.tags-name
  }
}

This section creates an S3 bucket named after the value stored in the bucket-name variable. It also assigns a tag to the bucket with a key of "environment" and a value retrieved from the tags-name variable. This helps categorize and identify the bucket later.

Configuring the Bucket as a Website

Terraform

resource "aws_s3_bucket_website_configuration" "static-website-smw" {
  bucket = aws_s3_bucket.static-website-smw.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
  depends_on = [aws_s3_bucket.static-website-smw]
}

This section configures the S3 bucket to serve as a static website. It defines the index_document block, specifying that files with the suffix ".html" should be treated as the default index page when a user requests the root of the website (e.g., https://your-bucket-name.s3.amazonaws.com/).

Similarly, the error_document block sets a custom error page (stored as "error.html" in the bucket) to be displayed for any non-existent resources. The depends_on block ensures that this configuration is applied only after the S3 bucket itself is created.

Setting Bucket Ownership and Permissions

Terraform

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.static-website-smw.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "static-website-acl" {
  bucket = aws_s3_bucket.static-website-smw.id
  acl = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

This section defines access control for the S3 bucket. The aws_s3_bucket_ownership_controls resource ensures that the objects uploaded to the bucket will be owned by the account that created the bucket (ObjectWriter). The subsequent aws_s3_bucket_acl resource sets the overall access permission for the bucket to "public-read." This allows anyone to access and download the website files stored within the bucket. The depends_on block ensures that the ACL configuration happens only after the ownership control is set.

This section (commented out by default) disables some of the public access restrictions offered by S3 Block Public Access. By default, these

Configuring Public Access for a Static Website on S3

Public Access Block Configuration:

Terraform

resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.static-website-smw.id
  block_public_acls = false 
  block_public_policy = false 
  ignore_public_acls = false 
  restrict_public_buckets = false 
  depends_on = [
    aws_s3_bucket.static-website-smw   
  ]
}

This configuration allows some level of public access to the S3 bucket. While it doesn't actively block existing public access settings, it prevents future accidental public exposure through ACLs or bucket policies.

Uploading Website Files:

Terraform

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static-website-smw.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
  depends_on = [
    aws_s3_bucket.static-website-smw
  ]
}

These blocks define resources of type aws_s3_object named index and error. These blocks upload the website's HTML files (index.html and error.html) to the S3 bucket and configure them to be publicly readable. This allows anyone to access your website by navigating to the S3 bucket's public URL. Alternatively, you can use looping to upload multiple html files at the same time to avoid repeating the same code lines for each page. 

This blog post provides a basic understanding of how to configure public access for a static website on S3 using Terraform. Remember to adjust the code based on your specific website content and security requirements.

Hope you enjoyed reading this post!
