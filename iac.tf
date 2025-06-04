# Configure the AWS Provider
provider "" {
  region = ""
  access_key = ""
  secret_key = ""
}

resource "<provider>_<resource_type>" "name" {
  key1 = "value1"
  key2 = "value2"
}