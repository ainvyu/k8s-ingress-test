resource "aws_s3_bucket" "test_bucket" {
  bucket = "k8s-test-bucket-for-kube2iam"
}

resource "aws_s3_bucket_object" "test_txt" {
  bucket = "${aws_s3_bucket.test_bucket.bucket}"
  key = "test.txt"
  content = "Hello World"
}
