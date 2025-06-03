%{ for name, node in nodes ~}
Host ${name}
  HostName ${node.ip}
  User ubuntu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

%{ endfor ~}
