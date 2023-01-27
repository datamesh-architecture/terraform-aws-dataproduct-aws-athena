resource "confluent_service_account" "app-connector" {
  display_name = "app-connector-${var.kafka_app_name}"
}

resource "confluent_connector" "sink" {
  environment {
    id = var.kafka.environment.id
  }
  kafka_cluster {
    id = var.kafka.cluster.id
  }

  // Block for custom *sensitive* configuration properties that are labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
  config_sensitive = {
    "aws.access.key.id"     = var.aws.access_key
    "aws.secret.access.key" = var.aws.secret_key
  }

  // Block for custom *nonsensitive* configuration properties that are *not* labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
  config_nonsensitive = {
    "topics"                   = join(",", var.kafka_topics)
    "input.data.format"        = "JSON"
    "s3.bucket.name"           = var.s3_bucket.bucket
    "connector.class"          = "S3_SINK"
    "name"                     = "S3_SINKConnector_0"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-connector.id
    "output.headers.format"    = "JSON"
    "tasks.max"                = "1"
    "time.interval"            = "DAILY"
    # "flush.size"               = "1000" # Default: 1000
    # "store.kafka.headers"      = false # Default: false
    #  If no value for this property is provided, the value specified for the ‘input.data.format’ property is used.
    # "output.data.format"       = var.dataproduct.input_port.format
  }

  depends_on = [
    confluent_kafka_acl.app-connector-describe-on-cluster,
    confluent_kafka_acl.app-connector-read-on-target-topic,
    confluent_kafka_acl.app-connector-create-on-dlq-lcc-topics,
    confluent_kafka_acl.app-connector-write-on-dlq-lcc-topics,
    confluent_kafka_acl.app-connector-create-on-success-lcc-topics,
    confluent_kafka_acl.app-connector-write-on-success-lcc-topics,
    confluent_kafka_acl.app-connector-create-on-error-lcc-topics,
    confluent_kafka_acl.app-connector-write-on-error-lcc-topics,
    confluent_kafka_acl.app-connector-read-on-connect-lcc-group,
  ]
}

resource "confluent_kafka_acl" "app-connector-describe-on-cluster" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-read-on-target-topic" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "${var.kafka_app_name}-reader"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-create-on-dlq-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-write-on-dlq-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-create-on-success-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "success-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-write-on-success-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "success-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-create-on-error-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "error-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-write-on-error-lcc-topics" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "TOPIC"
  resource_name = "error-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}

resource "confluent_kafka_acl" "app-connector-read-on-connect-lcc-group" {
  kafka_cluster {
    id = var.kafka.cluster.id
  }
  resource_type = "GROUP"
  resource_name = "connect-lcc"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = var.kafka.cluster.rest_endpoint
  credentials {
    key    = var.kafka_api_credentials.api_key_id
    secret = var.kafka_api_credentials.api_key_secret
  }
}
