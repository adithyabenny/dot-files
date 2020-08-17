# load ACME client to renew Let's Encrypt certs
# requires additional packages
#     `curl https://get.acme.sh | sh`
[[ -f "$HOME/.acme.sh/acme.sh.env" ]] && source "$HOME/.acme.sh/acme.sh.env"
