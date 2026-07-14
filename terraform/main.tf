

module "network" {
  source   = "./network"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./security"
  vpc_id = module.network.vpc_id
}
module "db" {
  source                  = "./db"
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
  source              = "./lb"
  lb_sg_id            = module.security.lb_sg_id
  public_subnet_1_id  = module.network.public_subnet_1_id
  public_subnet_2_id  = module.network.public_subnet_2_id
  private_subnet_1_id = module.network.private_subnet_1_az_id
  private_subnet_2_id = module.network.private_subnet_2_az_id
  vpc_id              = module.network.vpc_id
}
module "vm" {
  source                = "./vm"
  public_subnet_1_id    = module.network.public_subnet_1_id
  bastion_sg_id         = module.security.bastion_sg_id
  key_pair_name         = module.asg.ollama_key_pair_name
  bastion_ami           = var.bastion_ami
  bastion_instance_type = var.bastion_instance_type
}
module "asg" {
  source                  = "./asg"
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
