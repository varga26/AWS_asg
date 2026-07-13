resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform-state-bucket-7779823758347t093"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

module "network" {
  source = "./network"
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
  source             = "./vm"
  public_subnet_1_id = module.network.public_subnet_1_id
  bastion_sg_id      = module.security.bastion_sg_id
  key_pair_name      = module.asg.ollama_key_pair_name
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
}
