#!/bin/bash
cat > index.html <<EOF
<h1>Hello, Version 2</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

nohup python3 -m http.server ${server_port} &
