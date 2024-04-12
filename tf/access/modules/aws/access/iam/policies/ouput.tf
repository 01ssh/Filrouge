
output "arn_policies_ecr_RO" {
  value = [ aws_iam_policy.ecr_RO.arn ]
}

output "arn_policies_keyAccess_RO" {
  value = [ aws_iam_policy.keyAccess_RO.arn ]
}

output "arn_policies_RDSS3Bucket_RO" {
  value = [ aws_iam_policy.rds_s3_RO.arn ]
}

output "arn_policies_vpcPolicy_RO" {
  value = [ aws_iam_policy.vpcPolicy_RO.arn ]
}

output "arn_policies_groupPolicy_RO" {
  value = [ aws_iam_policy.groupPolicy_RO.arn ]
}

output "arn_policies_load_balancer_management_RO" {
  value = [ aws_iam_policy.load_balancer_management_RO.arn ]
}

output "arn_policies_ecr_RW" {
  value = [ aws_iam_policy.ecr_RW.arn ]
}

output "arn_policies_eks_RW" {
  value = [ aws_iam_policy.ecr_RW.arn ]
}

output "arn_policies_keyAccess_RW" {
  value = [ aws_iam_policy.keyAccess_RW.arn ]
}

output "arn_policies_RDSS3Bucket_RW" {
  value = [ aws_iam_policy.rds_s3_RW.arn ]
}

output "arn_policies_vpcPolicy_RW" {
  value = [ aws_iam_policy.vpcPolicy_RW.arn ]
}

output "arn_policies_groupPolicy_RW" {
  value = [ aws_iam_policy.groupPolicy_RW.arn ]
}

output "arn_OperationonPolicy_RO" {
   value = [ aws_iam_policy.operationonPolicy_RO.arn ]
}

output "arn_policies_load_balancer_management_RW" {
  value = [ aws_iam_policy.load_balancer_management_RW.arn ]
}

output "arn_policies_RO" {
  value = [ 
            aws_iam_policy.keyAccess_RO.arn,
            aws_iam_policy.ecr_RO.arn,
            aws_iam_policy.rds_s3_RO.arn,
            aws_iam_policy.vpcPolicy_RO.arn,
            aws_iam_policy.groupPolicy_RO.arn,
            aws_iam_policy.load_balancer_management_RO.arn,
            aws_iam_policy.operationonPolicy_RO.arn
           ]
}

output "arn_policies_admin_RW" {
  value = [ 
            aws_iam_policy.ecr_RW.arn,
            aws_iam_policy.eks_RW.arn,
            aws_iam_policy.rds_s3_RW.arn,
            aws_iam_policy.groupPolicy_RW.arn,
            aws_iam_policy.vpcPolicy_RW.arn,
            aws_iam_policy.load_balancer_management_RW.arn,
            aws_iam_policy.operationonPolicy_RW.arn,
            aws_iam_policy.keyAccess_RW.arn
           ]
}
