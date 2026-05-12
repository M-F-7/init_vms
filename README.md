## Packages and Tools installed by `init.sh`

Use the checklist below to track which tools are installed on your system after running `init.sh`.
Tick the boxes after you verify each tool (or run the script and check them).

### APT / system packages
- [ ] `debian-13.4.0-amd64-netinst.iso`

### APT / system packages
- [ ] curl
- [ ] tree
- [ ] nodejs
- [ ] npm
- [ ] python3-pip
- [ ] python3-pipx
- [ ] git
- [ ] ssh (openssh-client / openssh-server)
- [ ] docker.io
- [ ] code (Visual Studio Code)
- [ ] zsh
- [ ] make
- [ ] wget
- [ ] gpg
- [ ] libfuse2 (required by eDEX-UI/AppImage)

### Language/runtime installers / managers
- [ ] rustup / cargo (installed via rustup)
- [ ] Go (installed from tarball to /usr/local/go)

### Python / pipx packages
- [ ] smassh (pip)
- [ ] jrnl (pipx)

### npm / node tools
- [ ] branchlet (npm -g)

### Tools installed from source or other methods
- [ ] opencode (install script)
- [ ] neovim (build from source)
- [ ] tmux (build from source)
- [ ] superfile (install script)
- [ ] pkgtop (build/go)
- [ ] stormy (go build)
- [ ] eDEX-UI (AppImage / npm build)
- [ ] kind (download binary)
- [ ] kubectl (download binary)

### Post-install checks (commands used in the script)
- [ ] `curl -V`
- [ ] `tree --version`
- [ ] `npm -v`
- [ ] `cargo -V`
- [ ] `go version`
- [ ] `pip --version`
- [ ] `pipx --version`
- [ ] `git --version`
- [ ] `ssh -V`
- [ ] `docker --version`
- [ ] `code --version`
- [ ] `zsh --version`
- [ ] `make --version`
- [ ] `opencode --version`
- [ ] `nvim --version`
- [ ] `tmux -V`
- [ ] `superfile --version`
- [ ] `branchlet --version`
- [ ] `pkgtop -v`
- [ ] `stormy --version`
- [ ] `smassh --version`
- [ ] `jrnl --version`
- [ ] `kubectl version --client`
- [ ] `kind version`
