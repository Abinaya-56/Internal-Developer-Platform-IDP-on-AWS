resource "aws_s3_bucket" "idp_test" {
  bucket = "idp-terraform-test-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}
