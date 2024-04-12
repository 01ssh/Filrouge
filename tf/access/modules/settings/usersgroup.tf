locals {
     terraform        = {  
                          iam_root             = "TERRAFORM"
                          organization         = var.profile
                          region               = "eu-west-3"
                          group = {
                               organization    = var.profile
                               group_name      = join("_",  [var.profile, "administrators" ])
                               groups          = ["group_administrators"]
                               group_members   = [
                                                  join("_", [var.profile, "admin", "development"]),
                                                  join("_", [var.profile, "admin", "preprod"]), 
                                                  join("_", [var.profile, "admin", "production"])
                                                 ]
                               group_policies  = []
                              }
                           }
}

locals {
     dst        = {  
                          iam_root             = "student17_jan24_bootcamp_devops_services"
                          organization         = var.profile
                          region               = "eu-west-3"
                          group = {
                               organization    = var.profile
                               group_name      = join("_",  [var.profile, "administrators" ])
                               groups          = ["group_administrators"]
                               group_members   = [
                                                  join("_", [var.profile, "admin", "development"]),
                                                  join("_", [var.profile, "admin", "preprod"]), 
                                                  join("_", [var.profile, "admin", "production"])
                                                 ]
                               group_policies  = []
                              }
                           }
}


locals {
     marcdst        = {  
                          iam_root             = "Alumni-DST"
                          organization         = var.profile
                          region               = "eu-west-3"
                          group = {
                               organization    = var.profile
                               group_name      = join("_",  [var.profile, "administrators" ])
                               groups          = ["group_administrators"]
                               group_members   = [
                                                  join("_", [var.profile, "admin", "development"]),
                                                  join("_", [var.profile, "admin", "preprod"]), 
                                                  join("_", [var.profile, "admin", "production"])
                                                 ]
                               group_policies  = []
                              }
                           }
}

locals {
     seehanedst        = {  
                          iam_root             = "seehanedst"
                          organization         = var.profile
                          region               = "eu-west-3"
                          group = {
                               organization    = var.profile
                               group_name      = join("_",  [var.profile, "administrators" ])
                               groups          = ["group_administrators"]
                               group_members   = [
                                                  join("_", [var.profile, "admin", "development"]),
                                                  join("_", [var.profile, "admin", "preprod"]), 
                                                  join("_", [var.profile, "admin", "production"])
                                                 ]
                               group_policies  = []
                              }
                           }
}