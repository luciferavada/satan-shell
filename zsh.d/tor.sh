## Tor
#  SSH over Tor Socks proxy.
function torssh() {
  ssh -o ProxyCommand="nc -x localhost:9050 %h %p" ${@}
}

#  Curl via Tor Socks5h.
#  The socks5h protocol forwards DNS requests through Tor
function torcurl() {
  curl --proxy "socks5h://localhost:9050" ${@}
}
