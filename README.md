# SSH Backup Script

A Bash script to securely back up POSIX-compliant remote machines. This script connects to a target machine via SSH, creates a compressed archive of specified directories (excluding certain paths), and streams the backup to your local machine.

![](https://img.shields.io/badge/runs%20on-bash-blue) ![](https://img.shields.io/badge/written%20in-nano-orange) ![](https://img.shields.io/badge/powered%20by-procrastination-green)

## Features

- **Remote Backup**: Backs up remote machines over SSH without storing the archive on the remote machine.
- **Customizable Archive Root**: Specify the root directory to archive (default is `/`).
- **Exclusions**: Automatically excludes common unnecessary directories and files to optimize backup size.
- **Interactive Overwrite Protection**: Prompts before overwriting existing backup files.
- **Visual Progress**: Displays a progress bar using `pv` to monitor the backup process.
- **Automatic Naming**: Automatically names backups according to the date and remote.

## Prerequisites

- **Bash**:
  - Ensure you have [Bash](https://www.gnu.org/software/bash/manual/bash.html) available on your system.
- **SSH Access**:
  - [SSH](https://www.man7.org/linux/man-pages/man1/ssh.1.html) access to the target machine with necessary permissions.
- **Sudo Privileges**:
  - The user on the remote machine should have `sudo` privileges.
- **Pv Utility**:
  - [`pv`](https://man7.org/linux/man-pages/man1/pv.1.html) is needed for progress bar display.
- **NOPASSWD for tar (Optional)**:
  - For non-interactive execution, the remote user should have passwordless access to `tar` via [`visudo`](https://www.sudo.ws/docs/man/1.8.13/visudo.man/).

## Installation

1. **Download the Script**: Save the script to your local machine.
   #### Via HTTP
     ```bash
     #!/usr/bin/env bash
     
     curl -O https://raw.githubusercontent.com/DJStompZone/sshbackup/refs/heads/main/sshbak.sh
     ```
   #### Via Git
     ```bash
     #!/usr/bin/env bash
     
     git clone https://github.com/DJStompZone/sshbackup && cd sshbackup
     ```
3. **Make the Script Executable**:
   ```bash
   #!/usr/bin/env bash
     
   chmod +x sshbak.sh
   ```
4. **Move to a Directory in Your PATH** (optional):
   ```bash
   #!/usr/bin/env bash
     
   sudo mv sshbak.sh /usr/local/bin/sshbak
   ```

## Usage

```bash
#!/usr/bin/env bash
     
./sshbak <target_machine> [options]
```

- **`target_machine`**: Hostname, IP address, or SSH config host entry of the machine you want to back up.

### Options

- **`-d`, `--dir`**: Specify the archive root directory. Defaults to `/` if not specified.
- **`-h`, `--help`**: Display the help message and exit.

### Examples

- **Backup Entire Root Directory** (Default):
  ```bash
  #!/usr/bin/env bash
     
  ./sshbak remote_server
  ```
- **Backup a Specific Directory**:
  ```bash
  #!/usr/bin/env bash
     
  ./sshbak remote_server -d /home/steam
  ```
- **Display Help**:
  ```bash
  #!/usr/bin/env bash
     
  ./sshbak --help
  ```
- **?????**:
  ```bash
  #!/usr/bin/env bash
     
  ./sshbak --banner # Mysterious!
  ```

## Script Details

### Excluded Directories

The script excludes the following directories and files to optimize backup size and avoid unnecessary data:

- Version control directories (`.git`, `.svn`, etc.)
- System directories (`/proc`, `/sys`, `/dev`, `/snap`)
- Cache and temporary files (`*/.cache`, `*/__pycache__`, etc.)
- Development environments (`*/venv`, `*/.venv`, `*/node_modules`, `*/.rustup`, `*/miniconda3`, etc.)

### Backup Process

1. **Connection**: Establishes an SSH connection to the target machine.
2. **Archiving**: Uses `tar` to create a compressed archive (`.tar.gz`) of the specified directory.
3. **Exclusions**: Applies the exclusions during the archiving process.
4. **Streaming**: Streams the archive back to the local machine without storing it on the remote server.
5. **Progress Monitoring**: Displays a progress bar using `pv`.
6. **Saving**: Saves the backup file locally with the naming format: `<target_machine>.backup.<MM-DD-YY>.tar.gz`.

### Safety Checks

- **Existing Backup File**: If a backup file with the same name already exists, the script prompts the user before overwriting it.

## Troubleshooting

### Permission Denied Errors

- Ensure that the user has the necessary permissions to read the directories being archived.
- The script uses `sudo` on the remote machine. Verify that the SSH user has access to `sudo`.

### SSH Connection Issues

- Verify that you can manually SSH into the target machine without issues.
- Ensure that SSH keys are set up for passwordless authentication, or be prepared to enter the SSH password when prompted.

### `pv` Command Not Found

- Install `pv` using your package manager:
  ```bash
  sudo apt-get install pv     # Debian/Ubuntu
  sudo yum install pv         # CentOS/RHEL
  brew install pv             # macOS with Homebrew
  ```

## Security Considerations

- **SSH Keys**: Use SSH keys for authentication to enhance security.
- **Backup Storage**: Ensure that the backup files are stored securely, especially if they contain sensitive data.

## License

MIT License

## Contact

For questions or feedback, please open an issue or contact [DJ Stomp](https://discord.stomp.zone).
