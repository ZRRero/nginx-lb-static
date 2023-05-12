data "aws_iam_policy_document" "load_balancer_policy" {
  statement {
    sid = "AllowS3Download"
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.configuration_bucket.arn}/${aws_s3_object.load_balancer_config.key}"]
  }
  statement {
    sid = "AllowDescribeInstances"
    effect = "Allow"
    actions = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "static_policy" {
  statement {
    sid = "AllowS3Download"
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.configuration_bucket.arn}/${aws_s3_object.index.key}",
      "${aws_s3_bucket.configuration_bucket.arn}/${aws_s3_object.static_config.key}"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "load_balancer_role" {
  provider = aws.master_region
  name = "load_balancer_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name = "policy"
    policy = data.aws_iam_policy_document.load_balancer_policy.json
  }
}

resource "aws_iam_role" "static_role" {
  provider = aws.master_region
  name = "static_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name = "policy"
    policy = data.aws_iam_policy_document.load_balancer_policy.json
  }
}

resource "aws_iam_instance_profile" "load_balancer_instance_profile" {
  provider = aws.master_region
  name = "load_balancer_instance_profile"
  role = aws_iam_role.load_balancer_role.name
}

resource "aws_iam_instance_profile" "static_instance_profile" {
  provider = aws.master_region
  name = "load_balancer_instance_profile"
  role = aws_iam_role.load_balancer_role.name
}