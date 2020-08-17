# load ACME client to renew Let's Encrypt certs
# requires executable from https://github.com/acmesh-official/acme.sh
[[ -f "$HOME/.acme.sh/acme.sh.env" ]] && source "$HOME/.acme.sh/acme.sh.env"
