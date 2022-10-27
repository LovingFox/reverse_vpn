# Wireguard tunnels for multi exit points

[Russin version](README.ru.md)

### Description

Using wireguard for tunneling the proxy packets via remote OpenWRT devices.

#### Scheme

![Scheme of the network](scheme.png)

#### Files

| File                  | Description                                |
|-----------------------|--------------------------------------------|
| create_tunnel.sh      | Create db files for a tunnel               |
| start_tunnel.sh       | Start tunnel interface                     |
| stop_tunnel.sh        | Stop tunnel interface                      |
| show_tunnel.sh        | Show tunnel related info                   |
| getstat_tunnel.sh     | Get status of the tunnel                   |
| wrt_create_tunnel.sh  | Shell commands to start tunnel on OpenWRT  |
| wrt_destroy_tunnel.sh | Shell commands to stop tunnel on OpenWRT   |
| source.sh             | Common bash functions and vars             |

### Usage

#### Wireguard scripts

##### Create files for wireguard tunnel

```bash
./create_tunnel.sh <ID> <IP> <IP remote> <UDP> <table ID> <rule ID>
```

The command creates files for the tunnel in `./db` directory

1. `<ID>` unique id of the tunnel. Just an arbitrary number.
1. `<IP>` local IP address of the tunnel
1. `<IP remote>` remote IP address of the tunnel (on the OpenWRT)

> `<IP>` and `<IP remote>` have to be in the same /31 subnet

1. `<UDP>` listening UDP port for the tunnel
1. `<table ID>` routing table id for the tunnel (ip route show table `<table ID>`)
1. `<rule ID>` rule id for the tunnel (ip rule show pref `<table ID>`)

Example

```bash
./create_tunnel_files.sh 1 10.10.0.0 10.10.0.2 3001 1001 1001
```

##### Start tunnel

```bash
./start_tunnel.sh <ID | wg interface | IP local | IP remote>
```

##### Stop tunnel

```bash
./stop_tunnel.sh <ID | wg interface | IP local | IP remote>
```

#### 3Proxy example
