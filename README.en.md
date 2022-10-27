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

##### Create files for wireguard tunnel
```
./create_tunnel.sh <ID> <IP local> <IP remote> <UDP port> <Route table ID> <Rule ID>
```

The command creates files for the tunnel in `./db` directory

##### Start tunnel

```
./start_tunnel.sh <ID | wg interface | IP local | IP remote>
```

##### Stop tunnel

```
./stop_tunnel.sh <ID | wg interface | IP local | IP remote>
```

