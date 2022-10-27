# Wireguard tunnels for multi exit points

[Russin version](README.ru.md)

### Description

Using wireguard for tunneling the proxy packets via remote OpenWRT devices.

#### Scheme

![Scheme of the network](scheme.png)

#### Files

| File                  | Description                                |
|-----------------------|--------------------------------------------|
| create_tunnel.sh      | Create db files for the tunnel             |
| start_tunnel.sh       | Start tunnel interface                     |
| stop_tunnel.sh        | Stop tunnel interface                      |
| show_tunnel.sh        | Show system related info for the tunnel    |
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

1. `<ID>` unique id of the tunnel -- just an arbitrary number
1. `<IP>` local IP address of the tunnel
1. `<IP remote>` remote IP address of the tunnel (on the OpenWRT)
1. `<UDP>` free UDP port for the tunnel that wiregard will listen
1. `<table ID>` free unique routing table id for the tunnel (*ip route show table `<table ID>`*)
1. `<rule ID>` free unique rule id for the tunnel (*ip rule show pref `<table ID>`*)

> `<IP>` and `<IP remote>` have to be in the same /31 subnet

Example

```bash
./create_tunnel_files.sh 1 10.10.0.0 10.10.0.1 3001 1001 1001
./create_tunnel_files.sh 2 10.10.0.2 10.10.0.3 3001 1001 1001
```

##### Start tunnel

```bash
./start_tunnel.sh <ID | wg interface | IP local | IP remote | all>
```

> `<parameter>` can be set more then once, separated by space
> `all` leads to the fact that everyone available tunnels in ./db will be affected

Example

```bash
./start_tunnel.sh 1
./start_tunnel.sh 1 2
./start_tunnel.sh wg00001
./start_tunnel.sh wg00001 wg00002
./start_tunnel.sh 10.10.0.0
./start_tunnel.sh 10.10.0.1
./start_tunnel.sh 10.10.0.2
./start_tunnel.sh 10.10.0.0 10.10.0.2
./start_tunnel.sh wg00001 10.10.0.0
./start_tunnel.sh all
```

> such approach is correct for all next commands

##### Stop tunnel

```bash
./stop_tunnel.sh <ID | wg interface | IP local | IP remote>
```

##### Show tunnel related info in system

```bash
./show_tunnel.sh <ID | wg interface | IP local | IP remote>
```

##### Get tunnels statistics in a table form

```bash
./getstat_tunnel.sh <ID | wg interface | IP local | IP remote>
```

##### Print shell commands for creating tunnel on a OpenWRT 

```bash
./wrt_create_tunnel.sh <ID | wg interface | IP local | IP remote>
```

##### Print shell commands for destroing tunnel on a OpenWRT 

```bash
./wrt_destroy_tunnel.sh <ID | wg interface | IP local | IP remote>
```

#### 3Proxy example config related to tunnels

```conf
proxy -e10.10.0.0   -i172.16.96.3 -p34001
proxy -e10.10.0.2   -i172.16.96.3 -p34002
```

172.16.96.3 is a public IP address of the server
