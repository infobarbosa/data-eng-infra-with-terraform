resource "aws_glue_catalog_database" "dataeng_modulo_3_db" {
  name = var.database_name
}

resource "aws_glue_catalog_table" "dataeng_modulo_3_tb_clientes" {
  database_name = aws_glue_catalog_database.dataeng_modulo_3_db.name
  name          = "tb_raw_clientes"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    classification = "csv"
  }
  storage_descriptor {
    columns = jsondecode(file("${path.module}/tables/tb_raw_clientes.json"))
    location = "s3://path-to-your-bucket/tb_raw_clientes/"
    input_format = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed = false
    number_of_buckets = -1
    serde_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
      }
    }
  }
}

resource "aws_glue_catalog_table" "dataeng_modulo_3_tb_pedidos" {
  database_name = aws_glue_catalog_database.dataeng_modulo_3_db.name
  name          = "tb_raw_pedidos"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    classification = "csv"
  }
  storage_descriptor {
    columns = jsondecode(file("${path.module}/tables/tb_raw_pedidos.json"))
    location = "s3://path-to-your-bucket/tb_raw_pedidos/"
    input_format = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed = false
    number_of_buckets = -1
    serde_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
      }
    }
  }
}