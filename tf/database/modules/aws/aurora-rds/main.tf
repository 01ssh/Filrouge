
data "aws_kms_alias" "by_alias" {
   name = join("/", ["alias", lower(var.database_name)])
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.cluster_identifier
  subnet_ids = var.private_subnets_ids
}

data "aws_subnets" "app_net" {
    filter {
    name   = "tag:Name"
    values = ["*_app_subnet_*"]
  }   
}

data "aws_subnets" "pub_net" {
    filter {
    name   = "tag:Name"
    values = ["*_public_subnet_*"]
  }
}

module "rdsaurora" {
  source = "registry.terraform.io/terraform-aws-modules/rds-aurora/aws"
  name                        = var.cluster_identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  database_name               = var.database_name
  master_username             = var.master_username
  master_password             = var.master_password
  subnets                     = var.private_subnets_ids
  kms_key_id                  = data.aws_kms_alias.by_alias.id
  availability_zones          = var.availability_zones
  manage_master_user_password = var.manage_master_user_password 
  iam_database_authentication_enabled = false
  
  instances  = {
    1 = {
      identifier          = "${var.database_name}-1"
      instance_class      = var.instance_class
      availability_zone   = var.availability_zones[0]
    }
    2 = {
      identifier          = "${var.database_name}-2"
      instance_class      = var.instance_class
      availability_zone   = var.availability_zones[1]
    }
    3 = {
      identifier          = "${var.database_name}-3"
      instance_class      = var.instance_class
      availability_zone   = var.availability_zones[2]
    }
  }

  vpc_id                  = var.vpc_id
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  security_group_rules    = {
    vpc_ingress = {
      cidr_blocks         = var.vpc_cidr_blocks
    }
  }

  
  apply_immediately       = true
  skip_final_snapshot     = true

  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = var.database_name
  db_cluster_parameter_group_family      = "aurora-mysql8.0"
  db_cluster_parameter_group_description = "${var.database_name} cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 120
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
      }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
      }, {
      name         = "aurora_parallel_query"
      value        = "OFF"
      apply_method = "pending-reboot"
      }, {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "require_secure_transport"
      value        = "OFF"
      apply_method = "immediate"
      }, {
      name         = "tls_version"
      value        = "TLSv1.2"
      apply_method = "pending-reboot"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = var.database_name
  db_parameter_group_family      = "aurora-mysql8.0"
  db_parameter_group_description = "${var.database_name} wordpress DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 60
      apply_method = "immediate"
      }, {
      name         = "general_log"
      value        = 0
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "pending-reboot"
      }, {
      name         = "long_query_time"
      value        = 5
      apply_method = "immediate"
      }, {
      name         = "max_connections"
      value        = 2000
      apply_method = "immediate"
      }, {
      name         = "slow_query_log"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }
  ]

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  backup_retention_period      = 0
  preferred_backup_window      = null
  preferred_maintenance_window = null
}

