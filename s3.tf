# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "aws_s3_bucket" "main" {
	bucket = lower( "${var.prefix}-${var.identifier}-bucket" )
	force_destroy = true
	
	tags = {
		Name: "${var.name} Bucket"
	}
}


resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
	bucket = aws_s3_bucket.main.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource "aws_s3_bucket_public_access_block" "main" {
	bucket = aws_s3_bucket.main.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}