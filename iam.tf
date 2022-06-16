resource "aws_iam_role_policy" "app1-s3-policy" {
  name = "app1-s3-policy"
  role = aws_iam_role.app1-s3-role.id

  policy = file("s3-policy.json")
}

resource "aws_iam_role" "app1-s3-role" {
  name = "app1-s3-role"

  assume_role_policy = file("s3-assume-policy.json")
}

resource "aws_iam_instance_profile" "app1-s3-profile" {
  name = "app1-s3-profile"
  role = aws_iam_role.app1-s3-role.name
}
