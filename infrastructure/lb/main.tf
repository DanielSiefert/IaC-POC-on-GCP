resource "google_compute_network_endpoint_group" "neg_for_http_lb_primary" {
    name = "neg-for-http-lb"
    project = var.project_id
    zone = "us-east1-b"
    network = "projects/host-5d52/regions/us-east1/networks/shared-vpc"
    subnetwork = "projects/host-5d52/regions/us-east1/subnetworks/subnet-03"
    default_port = 80
}

data "google_storage_bucket_object_content" "redhat-vm2-name" {
  name = "org_hierarchy/outputs/redhat-vm2-name.txt"
  bucket = var.gcp_storage_bucket
}

resource "google_compute_network_endpoint" "httpd_primary_http_endpoint" {
  project = var.project_id
  zone = "us-east1-b"
  network_endpoint_group = google_compute_network_endpoint_group.neg_for_http_lb_primary.name
  instance   = data.google_storage_bucket_object_content.redhat-vm2-name.content
  port       = google_compute_network_endpoint_group.neg_for_http_lb_primary.default_port
  ip_address = google_compute_instance.httpd_primary.network_interface[0].network_ip
}

resource "google_compute_health_check" "healthcheck_http" {
  name = "${var.project_id}-hc-http"
  project = var.project_id
  check_interval_sec = 15
  timeout_sec = 15
  healthy_threshold   = 4
  unhealthy_threshold = 2
  
  tcp_health_check {
    port_specification = "USE_SERVING_PORT"
    request = "/index.html"
  }
}

resource "google_compute_backend_service" "gcp_lb_http_backend_service" {
  project = var.project_id
  name = "${var.project_id}-lb-http-be-svc"
  health_checks = [google_compute_health_check.healthcheck_http.id]
  timeout_sec = 1200 #20 minutes (to cover report time generation)
  connection_draining_timeout_sec = 1200
  session_affinity = "GENERATED_COOKIE"
  affinity_cookie_ttl_sec = 3600 #1hr

  backend {
    group = google_compute_network_endpoint_group.neg_for_http_lb_primary.id
    balancing_mode = "RATE"
    max_rate = "500"
  }

}

resource "google_compute_url_map" "lb-url-map-http-be-svc" {
  #https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map
  project = var.project_id
  name = "${var.project_id}-lb-http-svc" 
  default_service = google_compute_backend_service.gcp_lb_http_backend_service.id  
  
}


resource "google_compute_target_http_proxy" "lb-http-proxy" {
  name             = "${var.project_id}-lb-http-proxy"
  project = var.project_id
  url_map          = google_compute_url_map.lb-url-map-http-be-svc.id
   
}

resource "google_compute_global_forwarding_rule" "lb-forwarding-rule-http-tcp" {
  depends_on = [
    google_compute_target_http_proxy.lb-http-proxy,
    google_compute_global_address.gcp_load_balancer_ip
  ]
  name = "${var.project_id}-lb-forwarding-rule-http-tcp"
  project = var.project_id
  ip_protocol = "TCP"
  port_range = "80"
  target = google_compute_target_http_proxy.lb-http-proxy.id
  ip_address = google_compute_global_address.gcp_load_balancer_ip.id
}

