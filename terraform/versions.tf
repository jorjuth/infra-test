terraform {
  required_version = "~> 0.14"

  required_providers {
    aws = {
      version = "~> 3.0"
    }
    external = {
      version = "~> 1.0"
    }
    random = {
      version = "~> 2.0"
    }
    archive = {
      version = "~> 2.0"
    }
    template = {
      version = "~> 2.0"
    }
    local = {
      version = "~> 2.0"
    }
  }
}
