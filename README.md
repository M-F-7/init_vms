need to add opencode, nvim, tmux (multiple terminal window), superfile (file manager), branchlet (git branches manager), pkgtop & taproom (interactive packets manager(LINUX & MACOS), stormy(weather info (maybe useful to be integrated), smassh(monkey type), jrnl(journal), navi (mini-man)


✨ edex-ui ✨
DL le bon format https://github.com/gitsquared/edex-ui/releases

sudo add-apt-repository universe                  
sudo apt install libfuse2t64

#depend de l' OS (ici pour Debian (>= 13) and Ubuntu (>= 24.04):
#more info https://github.com/AppImage/AppImageKit/wiki/FUSE
./eDEX-UI.AppImage --appimage-extract 
sudo chown root:root squashfs-root/chrome-sandbox
sudo chmod 4755 squashfs-root/chrome-sandbox

mv squashfs-root ~/
./squashfs-root/AppRun


npm et cargo

npm -v
Sur Linux :
sudo apt update
sudo apt install nodejs npm
Mieux pour avoir une version récente : utiliser nvm :
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshrc
nvm install --lts
2. cargo
cargo est fourni avec rustup (gestionnaire officiel Rust).
Installe-le avec :
curl https://sh.rustup.rs -sSf | sh
source ~/.cargo/env
Puis vérifie :
rustc -V
cargo -V
