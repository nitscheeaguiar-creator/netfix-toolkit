# NetFix Toolkit

A lightweight Linux network diagnostic tool written in Bash.

NetFix Toolkit helps identify basic network connectivity issues by checking the default gateway, DNS resolution, TCP connectivity, and HTTP responses.

The project is currently under development and is intended as a learning and portfolio project focused on Linux administration, networking, and troubleshooting.

## Features

- Default gateway connectivity check
- DNS resolution check
- TCP port connectivity check
- HTTP/HTTPS response check
- Support for domain names, IPv4 addresses, and URLs
- HTTP and HTTPS protocol detection
- Redirect handling
- Global installation as `netfix`
- Basic command-line usage and error handling

## Requirements

NetFix currently relies on the following Linux utilities:

- Bash
- `ip`
- `ping`
- `getent`
- `nc` (Netcat)
- `curl`

These utilities are commonly available on Linux distributions. Some may need to be installed separately.

## Installation

Clone or download this repository.

From the project directory, run:

```bash
chmod +x install.sh
./install.sh
```

The installer copies the diagnostic script to:

```text
/usr/local/bin/netfix
```

After installation, you can run NetFix from any directory.

## Usage

```bash
netfix <domain|IP|URL>
```

### Examples

Check a domain:

```bash
netfix example.com
```

Check an HTTPS URL:

```bash
netfix https://github.com
```

Check an HTTP URL:

```bash
netfix http://example.com
```

Check an IPv4 address:

```bash
netfix 192.168.0.1
```

Display help:

```bash
netfix --help
```

When a domain is provided without a protocol, NetFix assumes HTTPS.

When a plain IPv4 address is provided, NetFix currently checks reachability using ICMP ping.

## Example output

```text
Destino informado: example.com
Host identificado: example.com
Protocolo: https
Porta TCP: 443

Gateway identificado: 192.168.0.1
[OK] Gateway acessível
[OK] DNS resolveu example.com
[OK] TCP conectado a example.com:443
[OK] HTTP respondeu com status 200

[OK] Diagnóstico concluído: nenhuma falha encontrada
```

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Diagnostic completed without reported failures |
| `1` | One or more diagnostic checks failed |
| `2` | Invalid usage or unsupported input |

## Uninstallation

From the project directory:

```bash
./uninstall.sh
```

This removes the installed executable:

```text
/usr/local/bin/netfix
```

## Project structure

```text
netfix-toolkit/
├── scripts/
│   └── linux/
│       └── diagnose.sh
├── install.sh
├── uninstall.sh
├── .gitignore
└── README.md
```

## Roadmap

Planned improvements:

- More reliable gateway detection
- Layered network troubleshooting
- Improved IPv4 validation
- Clear handling of unsupported IPv6 targets
- Better reporting of dependent checks when DNS or gateway tests fail
- ShellCheck integration
- Automated tests with Bats
- Improved installation and dependency validation
- JSON output and latency measurements
- TLS certificate diagnostics
- Windows support using PowerShell

## Learning goals

This project is being developed to practice:

- Bash scripting
- Linux system administration
- Network troubleshooting
- DNS, TCP/IP, HTTP, and HTTPS
- Git and version control
- Software testing and documentation

## License

License to be defined.
