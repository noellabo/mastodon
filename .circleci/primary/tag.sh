#!/bin/bash

set -eu -o pipefail

cd $(dirname $0)/..

ruby -ryaml -e 'puts YAML.load_file("config.yml")["aliases"][0]["docker"][0]["image"]'
