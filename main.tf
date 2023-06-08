module "security_group_checker" {
  source              = "./modules"
  security_group_id   = "sg-****"
  port                = 9042
}

output "is_port_public" {
  value = module.security_group_checker.is_public
}

