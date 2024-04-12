output "lb_endpoint" {
  value = var.enable==true?aws_lb.load_balancer[*].dns_name:null
}