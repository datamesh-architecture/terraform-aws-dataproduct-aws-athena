output "kafka_api_credentials" {
  value = {
    api_key_id = confluent_api_key.app-manager-kafka-api-key.id
    api_key_secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  sensitive = true
}

output "kafka_cluster" {
  value = {
    id = confluent_kafka_cluster.kafka_cluster.id
    rest_endpoint = confluent_kafka_cluster.kafka_cluster.rest_endpoint
  }
}
