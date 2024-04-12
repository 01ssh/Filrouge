
locals {
  iam = {
    "terraform" : local.terraform,
    "dst"       : local.dst,
    "marcdst"   : local.marcdst,
    "seehanedst" : local.seehanedst
  }
}