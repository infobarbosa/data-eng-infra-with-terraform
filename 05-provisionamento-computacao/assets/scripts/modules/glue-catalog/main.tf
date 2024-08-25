resource "aws_glue_catalog_database" "dataeng_modulo_4_db" {
  name = var.database_name
}

resource "aws_glue_catalog_table" "dataeng_modulo_4_tb_clientes" {
  database_name = aws_glue_catalog_database.dataeng_modulo_4_db.name
  name          = "tb_raw_clientes"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    classification = "csv",
    "compressionType" = "gzip",
    "skip.header.line.count" = "1"
  }
  storage_descriptor {
    location = "s3://dataeng-modulo-1-260762633884-gntxzg/raw/clientes/"
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

resource "aws_glue_catalog_table" "dataeng_modulo_4_tb_pedidos" {
  database_name = aws_glue_catalog_database.dataeng_modulo_4_db.name
  name          = "tb_raw_pedidos"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    classification = "csv",
    "compressionType" = "gzip",
    "skip.header.line.count" = "1"
  }
  storage_descriptor {
    location = "s3://dataeng-modulo-1-260762633884-gntxzg/raw/pedidos/"
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
        name = "id_pedido"
        type = "string"
    }

    columns {
        name = "produto"
        type = "string"
    }

    columns {
        name = "valor_unitario"
        type = "float"
    }

    columns {
        name = "quantidade"
        type = "bigint"
    }

    columns {
        name = "data_criacao"
        type = "timestamp"
    }      

    columns {
        name = "uf"
        type = "string"
    }

    columns {
        name = "id_cliente"
        type = "bigint"
    }  
  } 
}