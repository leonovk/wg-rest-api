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
  -v ~/.wg-rest:/etc/wireguard \
  -p 51820:51820/udp \
  -p 3000:3000 \
  --cap-add=NET_ADMIN \
  wg-rest-api
```

## API

All requests are authorized using the bearer token that you specified in variable AUTH_TOKEN!

### GET /clients

Returns an array with all clients on the server

Example response:

```json
{
  "6": {
    "id": 6,
    "address": "10.8.0.7",
    "private_key": "private_key",
    "public_key": "public_key",
    "preshared_key": "preshared_key",
    "data": {
      "params": "value"
    }
}
```

### POST /clients

Creates a new client. The response will be the new client created. You can pass your parameters in the request parameters. They will be in the data field.

Example response:

```json
{
  "id": 15,
  "server_public_key": "server_public_key",
  "address": "10.8.0.16/24",
  "private_key": "private_key",
  "preshared_key": "preshared_key",
  "allowed_ips": "0.0.0.0/0, ::/0",
  "dns": "1.1.1.1",
  "persistent_keepalive": 0,
  "endpoint": "0.0.0.0:51820",
  "data": {
    "params1": "value1"
  }
}
```

### GET /clients/:id

Returns a specific client by his ID. The answer will be similar to the previous one. If the client is not found, a 404 error will be returned.

### DELETE /clients/:id

Deletes a specific one client. If the client is not found, a 404 error will be returned.

## Contribution

If you would like to contribute to the development, submit a pull request with your changes. We welcome any contributions that improve the service. You can also view the current project board here. You can also contribute by reporting bugs or suggesting new features. Please use the GitHub issues for that.

### TODO

- [x] Make a fully functional rest api wireguard server
- [ ] Test coverage
- [ ] Implementation of the ability to update clients
