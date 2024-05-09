# WireGuard Easy REST API

![Build Status](https://github.com/leonovk/wg-rest-api/actions/workflows/ruby.yml/badge.svg)

## Features
* REST API for manage WireGuard server
* Easy installation, simple to use.
* List, create, delete, clients.


## Requirements

* A host with a kernel that supports WireGuard (all modern kernels).
* A host with Docker installed.

### 1. Install Docker

If you haven't installed Docker yet, install it by running:

```bash
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $(whoami)
exit
```
clone this repository and build the image from the dockerfile

To automatically run simply run:

```
  docker run -d \
  -e WG_HOST=<🚨YOUR_SERVER_IP> \
  -e AUTH_TOKEN=<🚨YOUR_ADMIN_API_TOKEN> \
  -e WG_PORT=51820 \
  -v ~/.wg-rest:/etc/wireguard \
  -p 51820:51820/udp \
  -p 3000:3000 \
  --cap-add=NET_ADMIN \
  wg-rest-api
```

## API

All requests are authorized using the boomer token that you specified in variable AUTH_TOKEN!

### GET /clients

Returns an array with all clients on the server

### POST /clients

Creates a new client

### GET /clients/:id

returns a specific one client

### DELETE /clients/:id

deletes a specific one client
