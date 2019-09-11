provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
  access_key = ""
  secret_key = ""
}

resource "aws_security_group" "gateway-prod" {
  name        = "gateway-prod"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "influxdb_grafana" {
  name        = "influxdb_grafana"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["${aws_security_group.front-end.id}","${aws_security_group.newsfeed.id}","${aws_security_group.quotes.id}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "front-end" {
  name        = "front-end"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway.id}"]
  }

  ingress {
    from_port   = 7878
    to_port     = 7878
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "newsfeed" {
  name        = "newsfeed"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "quotes" {
  name        = "quotes"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.gateway.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "gateway" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  count = "1"

  tags = {
    application  = "gateway"
    env  = "prod"
  }

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.gateway.id}"]
}

resource "aws_instance" "influxdb_grafana" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  tags = {
    application  = "influxdb_grafana"
    env  = "prod"
  }

  count = "1"

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.influxdb_grafana.id}"]
}

resource "aws_instance" "front-end" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  tags = {
    application  = "front-end"
    env  = "prod"
  }

  count = "1"

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.front-end.id}"]
}

resource "aws_instance" "newsfeed" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }
  
  tags = {
    application  = "newsfeed"
    env  = "prod"
  }

  count = "1"

  instance_type = "t2.micro"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.newsfeed.id}"]
}

resource "aws_instance" "quotes" {
  connection {
    user = "ec2-user"
    host = "${self.public_ip}"
  }

  tags = {
    application  = "quotes"
    env  = "prod"
  }

  count = "1"

  instance_type = "t3a.medium"
  ami = "ami-01f7527546b557442"
  key_name   = "assignment"
  vpc_security_group_ids = ["${aws_security_group.quotes.id}"]
}

resource "aws_elb" "influxdb_grafana" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "front-end" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 7878
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "newsfeed" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb" "quotes" {
  availability_zones = ["ap-southeast-1a"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_elb_attachment" "influxdb_grafana" {
  elb      = "${aws_elb.influxdb_grafana.id}"
  instance = "${aws_instance.influxdb_grafana.id}"
}

resource "aws_elb_attachment" "front-end" {
  elb      = "${aws_elb.front-end.id}"
  instance = "${aws_instance.front-end.id}"
}

resource "aws_elb_attachment" "newsfeed" {
  elb      = "${aws_elb.newsfeed.id}"
  instance = "${aws_instance.newsfeed.id}"
}

resource "aws_elb_attachment" "quotes" {
  elb      = "${aws_elb.quotes.id}"
  instance = "${aws_instance.quotes.id}"
}
