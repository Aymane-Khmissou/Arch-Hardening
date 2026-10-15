# Arch Linux Hardening Script

A Bash script that automates basic security hardening on an Arch Linux system.

> **Warning:** this script changes your SSH configuration and firewall rules.
> Test it in a virtual machine first and make sure your SSH key is set up
> before running it on a remote server. Use at your own risk.

## What it does

The script runs the following steps in order:

1. **System update**: runs `pacman -Syu` to update and upgrade all packages.
2. **User permissions**
   - Lists all accounts with UID 0.
   - Sets `/etc/passwd` to `644` and `/etc/shadow` to `600`.
3. **Telnet and SSH**
   - Stops and disables `telnet.socket`.
   - Edits `/etc/ssh/sshd_config`:
     - `Port 2222`
     - `PasswordAuthentication no`
     - `PubkeyAuthentication yes`
   - Restarts the SSH service.
4. **Firewall (UFW)**
   - Installs UFW.
   - Denies all incoming and allows all outgoing traffic by default.
   - Allows `2222/tcp` (SSH), `80/tcp` (HTTP) and `443/tcp` (HTTPS).
   - Enables UFW at boot and starts it now.
5. **Kernel and network hardening (sysctl)**: writes `/etc/sysctl.d/99-security.conf` with:
   - IP spoofing protection (`rp_filter`)
   - ICMP redirects disabled (accept and send)
   - SYN flood protection (`tcp_syncookies`)
   - ICMP broadcasts ignored

## Requirements

- Arch Linux
- Root privileges
- An SSH public key in `~/.ssh/authorized_keys` (password login is disabled)

## Usage

```bash
git clone https://github.com/USERNAME/REPO_NAME.git
cd REPO_NAME
chmod +x Hardening.sh
sudo ./Hardening.sh
```

After the script finishes, open a **new** terminal and confirm you can still log in:

```bash
ssh -p 2222 user@your-server
```

Keep your original session open until this works.

## Files modified

| File | Change |
|------|--------|
| `/etc/passwd` | Permissions set to `644` |
| `/etc/shadow` | Permissions set to `600` |
| `/etc/ssh/sshd_config` | Port, password and key authentication settings |
| `/etc/sysctl.d/99-security.conf` | Created with kernel and network rules |

## Notes

- Disabling password authentication without a working SSH key will lock you out of the server.
- The script edits only `/etc/ssh/sshd_config`. Settings defined in `/etc/ssh/sshd_config.d/*.conf` may take precedence over them.
- Ports 80 and 443 are opened by default. Remove those lines from the script if the machine does not run a web server.
- The script does not create a backup of the files it modifies.

## Disclaimer

This script provides baseline hardening only and is not a complete security solution.
It is provided as is, without warranty of any kind.
