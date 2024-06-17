#!/bin/bash

function fail() {
    echo -e "Error occurred. Exiting installation."
    exit 1
}

# List to store failed packages
failed_packages=()
failed_git_packages=()

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

# Download package lists
wget -P ~/Downloads https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main/packages_to_be_installed.txt || fail
wget -P ~/Downloads https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main/git_packages_to_install.txt || fail

# Source the git package functions
source ~/Downloads/git_packages_to_install.txt || fail

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
while read -r package; do
    # Skip comments and blank lines
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue

    case $distro in
        apt)
            sudo apt-get install -y $package || failed_packages+=($package)
            ;;
        pacman)
            sudo pacman -S --noconfirm $package || failed_packages+=($package)
            ;;
        yum)
            sudo yum install -y $package || failed_packages+=($package)
            ;;
        brew)
            brew install $package || failed_packages+=($package)
            ;;
        *)
            echo "Unsupported distribution" || failed_packages+=($package)
            ;;
    esac
done < /home/$USER/Downloads/packages_to_be_installed.txt

# Print failed packages
if [ ${#failed_packages[@]} -ne 0 ]; then
    echo -e "\nFailed to install the following packages:"
    for pkg in "${failed_packages[@]}"; do
        echo -e "- $pkg"
    done
fi

# Install packages from GitHub/GitLab
while read -r package; do
    # Skip comments and blank lines
    [[ "$package" =~ ^#.*$ ]] && continue
    [[ -z "$package" ]] && continue

    if declare -f "install_$package" > /dev/null; then
        "install_$package" || failed_git_packages+=("$package")
    else
        echo "No installation function defined for $package"
        failed_git_packages+=("$package")
    fi
done < /home/$USER/Downloads/git_packages_to_install.txt

# Print failed git packages
if [ ${#failed_git_packages[@]} -ne 0 ]; then
    echo -e "\nFailed to install the following Git packages:"
    for pkg in "${failed_git_packages[@]}"; do
        echo -e "- $pkg"
    done
fi

# Skip zsh setup if already installed
if command -v zsh &> /dev/null; then
    echo "zsh is already installed, skipping zsh setup"
else
    echo -e "Installing zsh and powerlevel10k"
    
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

    # Check if oh-my-zsh is already installed
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed, skipping installation"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" < <(echo exit) || fail
    fi

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || fail
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || fail
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || fail
    sed -i 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#g' /home/$USER/.zshrc || fail

    # Check if the required fonts are installed
    fonts_dir="$HOME/.local/share/fonts"
    meslo_regular="MesloLGS NF Regular.ttf"
    meslo_bold="MesloLGS NF Bold.ttf"
    meslo_italic="MesloLGS NF Italic.ttf"
    meslo_bold_italic="MesloLGS NF Bold Italic.ttf"

    missing_fonts=()

    for font in "$meslo_regular" "$meslo_bold" "$meslo_italic" "$meslo_bold_italic"; do
        if [ ! -f "$fonts_dir/$font" ]; then
            missing_fonts+=("$font")
        fi
    done

    if [ ${#missing_fonts[@]} -ne 0 ]; then
        echo "Downloading missing fonts for powerlevel10k"
        mkdir -p "$fonts_dir" || fail
        wget -P "$fonts_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" || fail
        wget -P "$fonts_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" || fail
        wget -P "$fonts_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" || fail
        wget -P "$fonts_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" || fail
    else
        echo "Required fonts for powerlevel10k are already installed"
    fi

    read -p "Do you wish to install for root user as well? [y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -e /root/.zshrc ]; then
            sudo rm /root/.zshrc || fail
        fi
        sudo ln -s ~/.zshrc /root/.zshrc || fail
        echo -e "Root setup ready."
    fi
fi

# Setting up Home directory
mkdir -p /home/$USER/github || fail
mkdir -p /home/$USER/projects || fail

# Set up SSH aliases
add_ssh_aliases=true
while $add_ssh_aliases; do
    read -p "Do you want to set up an SSH alias? [y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter alias name (e.g., myserver): " ssh_alias_name
        read -p "Enter SSH username: " ssh_username
        read -p "Enter SSH host (e.g., 192.168.1.1 or example.com): " ssh_host
        echo "alias $ssh_alias_name='ssh $ssh_username@$ssh_host'" | tee -a ~/.bash_aliases
    else
        add_ssh_aliases=false
    fi
done

# Change shell to zsh
echo -e "Changing default shell to zsh"
chsh -s $(which zsh) || fail

echo -e "Done setting up"
echo -e ""
echo -e "Remember to start a new terminal to setup powerlevel10k"
