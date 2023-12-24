resource "yandex_lb_target_group" "nginx" {
  name = "nginx-workers"

  target {
    subnet_id = yandex_vpc_subnet.subnet01.id
    address   = yandex_compute_instance.nginx.0.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet01.id
    address   = yandex_compute_instance.nginx.1.network_interface.0.ip_address
  }

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "yandex_lb_network_load_balancer" "lb01" {
  name = "nlb01"
  listener {
    name = "listener01"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.nginx.id
    healthcheck {
      name = "healthchecker01"
      http_options {
        port = 80
      }
      interval = 2
    }
  }
}
