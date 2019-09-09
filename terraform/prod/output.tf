output "gateway_address" {
  value = "${aws_instance.gateway.public_ip}"
}

output "influxdb_grafana_elb_address" {
  value = "${aws_elb.influxdb_grafana.dns_name}"
}

output "front-end_elb_address" {
  value = "${aws_elb.front-end.dns_name}"
}

output "newsfeed_elb_address" {
  value = "${aws_elb.newsfeed.dns_name}"
}

output "quotes_elb_address" {
  value = "${aws_elb.quotes.dns_name}"
}

