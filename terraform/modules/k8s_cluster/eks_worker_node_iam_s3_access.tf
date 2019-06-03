resource "aws_iam_role" "access_s3" {
  name = "${var.name}-cluster-allow-pot-access-s3"
  // language=json
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    },
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "AWS":  "${aws_iam_role.allow_node.arn}"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "access_s3_and_allow_assume_by_kube2iam" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Put*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_s3_and_allow_assume_by_kube2iam" {
  role = "${aws_iam_role.access_s3.name}"
  policy_arn = "${aws_iam_policy.access_s3_and_allow_assume_by_kube2iam.arn}"
}
