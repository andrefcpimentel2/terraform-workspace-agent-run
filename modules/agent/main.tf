
resource "aws_iam_instance_profile" "agent_profile" {
  name = "${var.namespace}-instance-profile"
  role = aws_iam_role.agent-role.name
}

resource "aws_instance" "agent" {
  count = var.instances
  ami           = var.ami
  instance_type = var.instance_type_worker
  key_name      = aws_key_pair.deployer.key_name
  user_data     = templatefile("modules/agent/templates/user-data.tpl", {
      TFC_AGENT_TOKEN       = var.TFC_AGENT_TOKEN,
      TFC_AGENT_NAME = "${var.TFC_AGENT_NAME}-${count.index}"
  })
  subnet_id              = aws_subnet.agent_subnet[0].id
  vpc_security_group_ids = [aws_security_group.agent_sg.id]
  iam_instance_profile = aws_iam_instance_profile.agent_profile.name
  associate_public_ip_address = true

  root_block_device{
    volume_size           = "50"
    delete_on_termination = "true"
  }

   ebs_block_device  {
    device_name           = "/dev/xvdd"
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }


  tags = local.common_tags
}



output "eip" {
  value    = aws_instance.agent.*.public_ip
}