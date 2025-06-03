all:
  children:
    k3s_cluster:
      children:
        k3s_servers:
          hosts:
%{ for name, node in control_plane_nodes ~}
            ${name}:
              ansible_host: ${node.ip}
              k3s_type: server
              k3s_control_node: true
%{ endfor ~}
%{ if length(worker_nodes) > 0 ~}
        k3s_workers:
          hosts:
%{ for name, node in worker_nodes ~}
            ${name}:
              ansible_host: ${node.ip}
              k3s_type: agent
%{ endfor ~}
%{ endif ~}
  vars:
    ansible_user: ubuntu
    ansible_port: 22
    ansible_python_interpreter: /usr/bin/python3
