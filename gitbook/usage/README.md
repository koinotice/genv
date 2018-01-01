# Usage

**Make sure you don't have any other containers exposing or local
services running on ports 80 or 443.**

## Traefik Port Overrides (optional)

If you must run _Traefik_ on different ports, export the following
environment variables with the ports of your choice:

```bash
export TRAEFIK_HTTP_PORT=8880
export TRAEFIK_HTTPS_PORT=8843
```

## Installation

### Upgrade Bash to 4.x

#### macOS, using [Homebrew](https://brew.sh)

1. `brew install bash`
2. Homebrew installs packages to `/usr/local/bin/`, so you’ll need to
   specify that path when looking for any Homebrew packages. In the
   following three commands, we’ll initiate a shell as the `root` user,
   append our desired shell’s path to a file of whitelisted system
   shells, and then change the system shell globally.

   ```bash
   sudo -s 
   echo /usr/local/bin/bash >> /etc/shells
   chsh -s /usr/local/bin/bash
   ```
   Now you can close and reopen your terminal. With
   just those few commands, you should be using with the latest version
   of your shell. You can double-check the version you’re using with the
   command `echo $BASH_VERSION`. Or, if you’ve installed Zsh, you can use
   the command `echo $ZSH_VERSION` to do the same.


### Get Harpoon

1. curl
   https://raw.githubusercontent.com/wheniwork/harpoon/master/install.sh
   | bash
2. _Optional:_ Load completion scripts by adding `which harpoon >
   /dev/null && . "$(harpoon initpath)"` to your profile (`~/.bashrc`,
   `~/.bash_profile`, `~/.zshrc`).

## Help

* `harpoon help [<task> | <service>]`

## Web UIs

* **Consul:** http://consul.harpoon
* **Traefik:** http://traefik.harpoon

## Removal

* Run `harpoon clean`
  * On MacOS, you'll be asked for your password

