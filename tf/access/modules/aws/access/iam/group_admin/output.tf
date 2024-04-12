output  "aws_iam_group_arn" {
  value = aws_iam_group.group.arn
}

output  "aws_iam_group_name" {
  value = aws_iam_group.group.name
}

output  "passwords" {
  value = [aws_iam_user_login_profile.administrator[*].encrypted_password]
}