resource "aws_iam_policy" "allow_kube2iam" {
  name = "${var.name}-kube2iam"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_assume_role_for_kube2iam" {
  role = "${aws_iam_role.allow_node.name}"
  policy_arn = "${aws_iam_policy.allow_kube2iam.arn}"
}
