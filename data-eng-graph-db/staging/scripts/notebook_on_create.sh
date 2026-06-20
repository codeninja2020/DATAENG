#!/bin/bash
set -ex

sudo -u ec2-user -i <<'EOF'
pip install graph-notebook
python -m graph_notebook.static_resources.install
python -m graph_notebook.nbextensions.install
EOF
