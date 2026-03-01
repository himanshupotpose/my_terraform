output vpc_id {
  value       = aws_vpc.vpc.id
}

output pri_subnet_id {
  value       = aws_subnet.private.id
}

output pub_subnet_id {
  value       = aws_subnet.public.id
}   