#!/bin/bash

function fail() {
    echo -e "Error occurred. Exiting installation."
    exit 1
}

# Detecting the distribution
if [ -e "/usr/bin/apt-get" ]; then
    distro=apt
elif [ -e "/usr/bin/pacman" ]; then
    distro=pacman
elif [ -e "/usr/bin/yum" ]; then
    distro=yum
elif [ -e "/usr/local/bin/brew" ]; then
    distro=brew
fi

# Download and set up dotfiles
cd /home/$USER/ || fail
wget https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main/.bash_aliases || fail

echo "if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi
if [ -f ~/.pentesting_aliases ]; then
    source ~/.pentesting_aliases
fi" | tee -a ~/.bashrc ~/.zshrc

echo -e "Done setting up dotfiles"
echo -e ""
echo -e "Starting to install programs"

# Download package list
wget -P ~/Downloads https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main/packages_to_be_installed.txt || fail

# Update system
echo -e "Updating system"
source ~/.bash_aliases || fail

case $distro in
    apt)
        sudo apt-get update || fail
        ;;
    pacman)
        sudo pacman -Syu || fail
        ;;
    yum)
        sudo yum update || fail
        ;;
    brew)
        brew update || fail
        ;;
    *)
        echo "Unsupported distribution" || fail
        ;;
esac

# Install additional packages
for i in $(cat /home/$USER/Downloads/packages_to_be_installed.txt); do
    case $distro in
        apt)
            sudo apt-get install -y $i || fail
            ;;
        pacman)
            sudo pacman -S --noconfirm $i || fail
            ;;
        yum)
            sudo yum install -y $i || fail
            ;;
        brew)
            brew install $i || fail
            ;;
        *)
            echo "Unsupported distribution" || fail
            ;;
    esac
done

echo -e "Installing zsh and powerlevel10k"

# Download zsh fonts
mkdir -p ~/.local/share/fonts || fail
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" || fail
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" || fail
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" || fail
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" || fail

# Setup zsh
case $distro in
    apt)
        sudo apt-get install -y zsh || fail
        ;;
    pacman)
        sudo pacman -S --noconfirm zsh || fail
        ;;
    yum)
        sudo yum install -y zsh || fail
        ;;
    brew)
        brew install zsh || fail
        ;;
    *)
        echo "Unsupported distribution" || fail
        ;;
esac

chsh -s $(which zsh) || fail
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" < <(echo exit) || fail
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || fail
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || fail
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || fail
sed -i 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#g' /home/$USER/.zshrc || fail

read -p "Do you wish to install for root user as well? [y/n]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm ~root/.zshrc || fail
    sudo ln -s ~/.zshrc ~root/.zshrc || fail
    echo -e "Root setup ready."
fi

# Setting up Home directory
mkdir -p /home/$USER/github || fail
mkdir -p /home/$USER/projects || fail

# Set up SSH aliases
read -p "Do you want to set up SSH aliases? [y/n]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter alias name (e.g., myserver): " ssh_alias_name
    read -p "Enter SSH username: " ssh_username
    read -p "Enter SSH host (e.g., 192.168.1.1 or example.com): " ssh_host
    echo "alias $ssh_alias_name='ssh $ssh_username@$ssh_host'" | tee -a ~/.bash_aliases
fi

echo -e "Done setting up"
echo -e ""
echo -e "Remember to start a new terminal to setup powerlevel10k"
