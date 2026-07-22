module "network" {
  source   = "./modules/network"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "db" {
  source                  = "./modules/db"
  rds_sg_id               = module.security.rds_sg_id
  private_subnet_1_rds_id = module.network.private_subnet_1_rds_id
  private_subnet_2_rds_id = module.network.private_subnet_2_rds_id
  allocated_storage       = var.db_allocated_storage
  db_name                 = var.db_name
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  parameter_group_name    = var.db_parameter_group_name
  db_username             = var.db_username
  db_password             = var.db_password
}

module "lb" {
  source              = "./modules/lb"
  lb_sg_id            = module.security.lb_sg_id
  public_subnet_1_id  = module.network.public_subnet_1_id
  public_subnet_2_id  = module.network.public_subnet_2_id
  private_subnet_1_id = module.network.private_subnet_1_az_id
  private_subnet_2_id = module.network.private_subnet_2_az_id
  vpc_id              = module.network.vpc_id
  grafana_instance_id = module.vm.grafana_instance_id
}

module "vm" {
  source                = "./modules/vm"
  public_subnet_1_id    = module.network.public_subnet_1_id
  private_subnet_1_id   = module.network.private_subnet_1_az_id
  bastion_sg_id         = module.security.bastion_sg_id
  grafana_sg_id         = module.security.grafana_sg_id
  key_pair_name         = module.asg.ollama_key_pair_name
  bastion_ami           = var.bastion_ami
  bastion_instance_type = var.bastion_instance_type
  grafana_instance_type = var.grafana_instance_type
}

module "asg" {
  source                  = "./modules/asg"
  grafana_private_ip      = module.vm.grafana_private_ip
  asg_sg_id               = module.security.asg_sg_id
  private_subnet_1_az_id  = module.network.private_subnet_1_az_id
  private_subnet_2_az_id  = module.network.private_subnet_2_az_id
  target_group_arn        = module.lb.target_group_arn
  ollama_target_group_arn = module.lb.ollama_target_group_arn
  ollama_base_url         = module.lb.ollama_base_url
  openwebui_database_url  = module.db.openwebui_database_url
  ollama_instance_type    = var.ollama_instance_type
  openwebui_instance_type = var.openwebui_instance_type
  webui_secret_key        = var.webui_secret_key
}

module "sns" {
  source   = "./modules/sns"
  protocol = var.protocol
  endpoint = var.endpoint
}


module "monitoring" {
  source = "./modules/monitoring"

  aws_region                        = var.aws_region
  sns_topic_arn                     = module.sns.sns_topic_arn
  alb_dns_name                      = module.lb.alb_dns_name
  alb_arn_suffix                    = module.lb.alb_arn_suffix
  target_group_arn_suffix           = module.lb.target_group_arn_suffix
  ollama_lb_arn_suffix              = module.lb.ollama_lb_arn_suffix
  ollama_target_group_arn_suffix    = module.lb.ollama_target_group_arn_suffix
  ollama_asg_name                   = module.asg.ollama_asg_name
  rds_identifier                    = module.db.rds_identifier
  endpoint                          = var.endpoint
  slack_webhook_url                 = var.slack_webhook_url
  pagerduty_integration_key         = var.pagerduty_integration_key
}
