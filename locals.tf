provider "tls" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_ssh" {
  filename        = "id_rsa"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "public_ssh" {
  filename        = "id_rsa.pub"
  content         = tls_private_key.ssh.public_key_openssh
  file_permission = "0600"
}

resource "local_file" "hosts" {
  filename = "ansible/hosts"
  content = templatefile("hosts.tpl",
    {
      iscsi_hosts   = yandex_compute_instance.iscsi.*.hostname
      db_hosts      = yandex_compute_instance.db.*.hostname
      nginx_hosts   = yandex_compute_instance.nginx.*.hostname
      backend_hosts = yandex_compute_instance.backend.*.hostname
  })
  depends_on = [
    yandex_compute_instance.iscsi,
    yandex_compute_instance.db,
    yandex_compute_instance.nginx,
    yandex_compute_instance.backend
  ]
}
