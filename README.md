need to add opencode, nvim, tmux (multiple terminal window), superfile (file manager), branchlet (git branches manager), taproom (interactive packets manager), stormy(weather info (maybe useful to be integrated), smassh(monkey type), jrnl(journal), navi (mini-man)

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
