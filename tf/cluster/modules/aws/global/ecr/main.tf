resource "aws_ecr_repository" "registry" {
  count                = length(var.repos)
  name                 = element(var.repos, count.index)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push       = true
  }
}