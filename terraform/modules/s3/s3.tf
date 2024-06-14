resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
    #  Environment = "Dev"
  }
}


resource "aws_s3_bucket_versioning" "versioning_tf_state_bucket" {

  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

