logging {
  level  = "error"
  format = "json"
}

component "discovery.docker" "linux" {
  host = "unix:///var/run/docker.sock"
}

component "discovery.relabel" "main" {
  targets = component.discovery.docker.linux.targets

  rule {
    source_labels = ["__meta_docker_container_name"]
    regex         = "/(.*)"
    target_label  = "container"
  }

  rule {
    source_labels = ["__meta_docker_network_ip"]
    target_label  = "ip"
  }

  rule {
    source_labels = ["__meta_docker_container_label_com_docker_compose_service"]
    target_label  = "compose_service"
  }
}

component "loki.source.docker" "default" {
  host         = "unix:///var/run/docker.sock"
  targets      = component.discovery.relabel.main.output
  labels       = {
    type = "docker"
  }
  relabel_rules = component.discovery.relabel.main.rules
  forward_to   = [component.loki.relabel.add_static_labels.receiver]
}

component "local.file_match" "logs" {
  path_targets = [
    {
      __path__ = "/nginx_logs/access*.log"
      source   = "nginx"
      type     = "access"
    },
    {
      __path__ = "/nginx_logs/error*.log"
      source   = "nginx"
      type     = "error"
    },
  ]
}

component "loki.source.file" "nginx" {
  targets    = component.local.file_match.logs.targets
  forward_to = [component.loki.relabel.add_static_labels.receiver]
}

component "loki.relabel" "add_static_labels" {
  forward_to = [component.loki.write.bbloki.receiver]

  rule {
    target_label = "namespace"
    replacement  = "mdb"
  }

  rule {
    target_label = "environment"
    replacement  = "production"
  }
}

component "loki.write" "bbloki" {
  endpoint {
    url = "loki api push endpoint"

    basic_auth {
      username = "..."
      password = "..."
    }
  }
}
