output "gateway_address-beta" {
  value = "${aws_instance.gateway-beta.public_ip}"
}

output "influxdb_grafana-beta_elb_address" {
  value = "${aws_elb.influxdb_grafana-beta.dns_name}"
}

output "front-end-beta_elb_address" {
  value = "${aws_elb.front-end-beta.dns_name}"
}

output "newsfeed-beta_elb_address" {
  value = "${aws_elb.newsfeed-beta.dns_name}"
}

output "quotes-beta_elb_address" {
  value = "${aws_elb.quotes-beta.dns_name}"
}

