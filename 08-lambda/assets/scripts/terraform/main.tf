module "dataeng_lambda" {
    source = "./modules/lambda"

    dataeng_emr_cluster_id = module.emr.dataeng_emr_cluster_id
    dataeng_bucket_name = module.s3.dataeng_bucket
}
