#!/bin/bash
set -ex

cat > /home/ec2-user/graph_notebook_config.json << 'EOF'
{
  "host": "${neptune_endpoint}",
  "port": 8182,
  "ssl": true,
  "ssl_verify": true,
  "iam_credentials_provider_type": "ROLE",
  "aws_region": "${aws_region}",
  "sparql": {
    "path": "sparql"
  },
  "gremlin": {
    "traversal_source": "g",
    "username": "",
    "password": "",
    "message_serializer": "graphsonv3d0"
  }
}
EOF

chown ec2-user:ec2-user /home/ec2-user/graph_notebook_config.json

sudo -u ec2-user -i <<'EOF2'
jupyter nbextension enable --py --sys-prefix graph_notebook.widgets
EOF2
