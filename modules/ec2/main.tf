resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow HTTP, SSH, and MySQL access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "login_page" {
  ami                    = "ami-xxxxxxxx"  # Use the correct Ubuntu AMI ID for your region
  instance_type           = "t2.micro"
  key_name                = "my-key-pair"
  security_groups         = [aws_security_group.ec2_sg.name]
  user_data               = <<-EOT
                            #!/bin/bash
                            sudo apt update -y
                            sudo apt install apache2 php libapache2-mod-php php-mysql -y
                            sudo systemctl start apache2
                            sudo systemctl enable apache2
                            sudo rm /var/www/html/index.html
                            echo "<?php
                            \$host = \"${rds_endpoint}\";  // Replace RDS endpoint
                            \$db_user = \"${db_username}\";  // Replace DB username
                            \$db_pass = \"${db_password}\";  // Replace DB password
                            \$db_name = \"${db_name}\";  // Replace DB name

                            \$conn = new mysqli(\$host, \$db_user, \$db_pass, \$db_name);
                            if (\$conn->connect_error) {
                                die(\"Database connection failed: \" . \$conn->connect_error);
                            }

                            if (isset(\$_POST[\"register\"])) {
                                \$username = \$conn->real_escape_string(\$_POST['username']);
                                \$password = \$_POST['password'];

                                \$check_query = \"SELECT * FROM users WHERE username=?\";
                                \$stmt = \$conn->prepare(\$check_query);
                                \$stmt->bind_param(\"s\", \$username);
                                \$stmt->execute();
                                \$stmt->store_result();

                                if (\$stmt->num_rows > 0) {
                                    \$error = \"Username already exists!\";
                                } else {
                                    \$query = \"INSERT INTO users (username, password) VALUES (?, ?)\";
                                    \$stmt = \$conn->prepare(\$query);
                                    \$stmt->bind_param(\"ss\", \$username, \$password);
                                    if (\$stmt->execute()) {
                                        \$success = \"Registration successful! You can now log in.\";
                                    } else {
                                        \$error = \"Error: \" . \$stmt->error;
                                    }
                                }
                                \$stmt->close();
                            }

                            if (isset(\$_POST[\"login\"])) {
                                \$username = \$conn->real_escape_string(\$_POST['username']);
                                \$password = \$_POST['password'];

                                \$query = \"SELECT password FROM users WHERE username=?\";
                                \$stmt = \$conn->prepare(\$query);
                                \$stmt->bind_param(\"s\", \$username);
                                \$stmt->execute();
                                \$result = \$stmt->get_result();

                                if (\$result->num_rows > 0) {
                                    \$row = \$result->fetch_assoc();
                                    if (\$password == \$row['password']) {
                                        \$_SESSION['username'] = \$username;
                                    } else {
                                        \$error = \"Invalid username or password!\";
                                    }
                                } else {
                                    \$error = \"Invalid username or password!\";
                                }
                            }

                            if (isset(\$_GET[\"logout\"])) {
                                session_destroy();
                                header(\"Location: index.php\");
                                exit();
                            }
                            ?>" > /var/www/html/index.php
                            EOT

  tags = {
    Name = "LoginPageEC2"
  }
}

output "public_ip" {
  value = aws_instance.login_page.public_ip
}
