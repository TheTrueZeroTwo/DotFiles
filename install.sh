#!/bin/bash


function fail() {
    echo -e "Error occured. Exiting installation."
    exit 1
}

#New distro setup script


#dotfiles install
#distro=1

#find what distro is being used
if [ -e "/usr/bin/apt-get" ] ; then # Apt-based distros (Debian, Ubuntu, etc.)
    distro=apt
elif [ -e "/usr/bin/pacman" ] ; then # Arch Linux
    distro=pacman
elif [ -e "/usr/bin/yum" ] ; then # RPM-based distros
    distro=yum
elif [ -e "/usr/local/bin/brew" ] ; then # homebrew
    distro=brew
fi



#downlaod dotfiles
cd /home/$USER/
wget -P ~/.bash_aliases https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main/.bash_aliases || fail

echo "if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi
if [ -f ~/.pentesting_aliases ]; then
    source ~/.pentesting_aliases
fi" | tee -a ~/.bashrc ~/.zshrc




#done setting up dotfiles
echo -e "Done setting up dotfiles"
echo -e ""
echo -e "Starting to install programs"




#source alias
#  source $TERMTYPE

#download package list
wget -P ~/Downloads/packages_to_be_installed.txt https://raw.githubusercontent.com/TheTrueZeroTwo/DotFiles/main/packages_to_be_installed.txt /home/$USER/Downloads/packages_to_be_installed.txt

#update system
echo -e "updating system"
source ~/.bash_aliases
sudo pacu

#install aditional packages
for i in 'cat /home/$USER/Downloads/packages_to_be_installed.txt'; do "sudo paci $1"; done


#done installing packages
echo -e "installing zsh and powerlevel10k"
#install zsh and powerlevel10k


#downlaod zsh fonts
mkdir -p ~/.local/share/fonts
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
wget -P ~/.local/share/fonts "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"

#setup zsh
sudo paci zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" < <(echo exit) || fail
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || fail
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || fail
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || fail
sed -i 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#g' /home/$USER/.zshrc



read -p "Do you wish to install for root user as well? [y/n]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo rm ~root/.zshrc || fail
    sudo ln -s ~/.zshrc ~root/.zshrc || fail
    echo -e "Root setup ready."
fi

#done install packages
echo -e "Done installing packages"
echo -e ""
echo -e "Setting up Home dir"


#set up Home dir
mkdir -p /home/$USER/github
mkdir -p /home/$USER/projects

#DONE!
echo -e "Done setting up"
echo -e ""
echo -e "Remember to start a new terminal to setup powerlevel10k"
