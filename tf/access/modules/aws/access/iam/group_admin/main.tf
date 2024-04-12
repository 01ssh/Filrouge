data "aws_caller_identity" "current" {}

resource "aws_iam_user" "administrator" {
  count         = length(var.group_iam.group.group_members)
  name          = var.group_iam.group.group_members[count.index]
  force_destroy = true
}

resource "aws_iam_group" "group" {
    name       = "${var.group_name}"
}

resource "aws_iam_access_key" "administrator" {
  count        = length(var.group_iam.group.group_members)
  user         = var.group_iam.group.group_members[count.index]
  depends_on   = [
    aws_iam_user.administrator
  ]
}

resource "aws_iam_user_login_profile" "administrator" {
    count      = length(var.group_iam.group.group_members)
    user       = var.group_iam.group.group_members[count.index]
#   pgp_key    = "keybase:${var.group_iam.group.group_members[count.index]}"
    password_reset_required = false
    depends_on = [
               aws_iam_access_key.administrator
    ]
}

resource "aws_iam_group_membership" "group" {
   name        = var.group_name
   group       = aws_iam_group.group.name
   users       = var.group_iam.group.group_members
   depends_on  = [ 
    aws_iam_group.group,
    aws_iam_access_key.administrator
   ]
}


resource "vault_generic_secret" "administrator" {
   count        = length(var.group_iam.group.group_members)
   path         = lower(join("/", ["secret/aws", var.group_name]))
   namespace    = split("_", var.group_iam.group.group_members[count.index])[2]
   disable_read = false
   data_json    = jsonencode({
    join("_", ["AWS_ACCESS_KEY", var.group_iam.group.group_members[count.index]]) = aws_iam_access_key.administrator[count.index].id
    join("_", ["AWS_SECRET_KEY", var.group_iam.group.group_members[count.index]]) = aws_iam_access_key.administrator[count.index].secret
    join("_", ["AWS_WEB_PASS",   var.group_iam.group.group_members[count.index]]) = aws_iam_user_login_profile.administrator[count.index].password
  })
  depends_on = [ 
    aws_iam_user.administrator,
    aws_iam_group.group,
    aws_iam_access_key.administrator
   ]
}

resource "random_password" "password" {
  count            = length(var.group_iam.group.group_members)
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "vault_generic_secret" "db" {
   count        = length(var.group_iam.group.group_members)
   path         = lower( join("/", ["secret/aws", join("_", [var.group_name, "db"] )] ))
   namespace    = split("_", var.group_iam.group.group_members[count.index])[2]
   disable_read = false
   data_json    = jsonencode({
    "AWS_DB_AURORA_USER_${var.group_iam.group.group_members[count.index]}" = join("_", ["dbuser", split("_", var.group_iam.group.group_members[count.index])[2]])
    "AWS_DB_AURORA_NAME_${var.group_iam.group.group_members[count.index]}" = lower(join("", ["WORDPRESS", split("_", var.group_iam.group.group_members[count.index])[2]]))
    "AWS_DB_AURORA_PASSWORD_${var.group_iam.group.group_members[count.index]}" = random_password.password[count.index]
  })
  depends_on = [ 
    aws_iam_user.administrator,
    aws_iam_group.group,
    aws_iam_access_key.administrator
   ]
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", 
                     "ec2.amazonaws.com", 
                     "rds.amazonaws.com",
                     "kms.amazonaws.com",
                     "s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "administrators" {
  name = "administrators_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  tags = {
    tag-key = "administrators_role"
  }
}

resource "aws_iam_role_policy_attachment" "role-administrators" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ])
  role       = aws_iam_role.administrators.name
  policy_arn = each.value
}

resource "aws_kms_key" "administrators" {
  description = "KMS Key for administrators"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "KMS-Key-Policy-For-Admin-${data.aws_caller_identity.current.account_id}",
    "Statement" : [
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [ 
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_root}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[0]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[1]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[2]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/administrators_role" ]
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },
      {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_root}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[0]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[1]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[2]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/administrators_role"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:DescribeKey",
                "kms:GetPublicKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_root}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[0]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[1]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.group_iam.group.group_members[2]}",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/administrators_role"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ],
    }
  )
}

resource "aws_kms_alias" "administrators" {
  count         = length(var.group_iam.group.group_members)
  name          = join("/", ["alias",lower(join("", ["WORDPRESS", split("_", var.group_iam.group.group_members[count.index])[2]]))])
  target_key_id = aws_kms_key.administrators.key_id
}