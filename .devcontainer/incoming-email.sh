#!/usr/bin/env sh

export GEM_HOME=/usr/local/bundle
export PATH=/usr/local/bin
bin/rails action_mailbox:ingress:postfix URL=http://web:3000/rails/action_mailbox/relay/inbound_emails INGRESS_PASSWORD=abc123 RAILS_ENV=production