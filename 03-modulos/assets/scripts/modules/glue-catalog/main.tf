resource "aws_glue_catalog_database" "dataeng-glue-database" {
    name = var.database_name
}

resource "aws_glue_catalog_table" "dataeng-glue-table-clientes" {
    database_name = aws_glue_catalog_database.dataeng-glue-database.name
    name          = "tb_raw_clientes"
    table_type    = "EXTERNAL_TABLE"
    parameters = {
    classification = "csv",
    "compressionType" = "gzip",
    "skip.header.line.count" = "1"
    }
    storage_descriptor {
        location = "s3://${var.bucket_name}/raw/clientes/"

        input_format = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        compressed = false
        number_of_buckets = -1
        ser_de_info {
            serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
            parameters = {
            "field.delim" = ";"
            }
        }
        columns {
            name = "id"
            type = "int"
        }
        columns {
            name = "nome"
            type = "string"
        }
        columns {
            name = "data_nasc"
            type = "date"
        }
        columns {
            name = "cpf"
            type = "string"
        }
        columns {
            name = "email"
            type = "string"
        }  
    }
}
