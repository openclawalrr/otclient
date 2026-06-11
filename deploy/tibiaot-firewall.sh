#!/usr/bin/env bash
set -euo pipefail

DB_PORTS="3306,5432,6379,11211,27017,27018"

apply_rules() {
  local cmd="$1"
  local chain="$2"
  shift 2
  local rule=("$@")

  if ! $cmd -C "$chain" "${rule[@]}" >/dev/null 2>&1; then
    $cmd -I "$chain" 1 "${rule[@]}"
  fi
}

apply_rules iptables INPUT -p tcp ! -i lo -m multiport --dports "${DB_PORTS}" -j DROP
apply_rules iptables DOCKER-USER -p tcp -m multiport --dports "${DB_PORTS}" -j DROP
apply_rules ip6tables INPUT -p tcp ! -i lo -m multiport --dports "${DB_PORTS}" -j DROP
apply_rules ip6tables DOCKER-USER -p tcp -m multiport --dports "${DB_PORTS}" -j DROP
