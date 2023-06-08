variable "security_group_id" {
  description = "ID of the security group to check"
}

variable "port" {
  description = "Port to check for public access"
}

data "aws_security_group" "target" {
  id = var.security_group_id
}

output "is_public" {
  value = contains(
    [for rule in data.aws_security_group.target.ingress : rule.from_port <= var.port && var.port <= rule.to_port],
    true
  )
}

resource "aws_security_group" "example" {
  name        = "intern bastion host"
  description = "Security group for Cassandra client"

  dynamic "ingress" {
    for_each = data.aws_security_group.target.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks

      dynamic "cidr_blocks" {
        for_each = var.is_public ? ["your_ip_address/32"] : []
        content {
          cidr_block = cidr_blocks.value
        }
      }
    }
  }
}
