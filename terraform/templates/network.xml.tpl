<network>
  <name>${network_name}</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr1' stp='on' delay='0'/>
  <ip address='${base_ip}.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='${base_ip}.100' end='${base_ip}.254'/>
%{ for name, node in nodes ~}
      <host mac='${node.mac}' name='${node.hostname}' ip='${node.ip}'/>
%{ endfor ~}
    </dhcp>
  </ip>
</network>
