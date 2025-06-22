output "ghost_url" {
  value = "http://${aws_instance.ghost.public_ip}:2368"
}
