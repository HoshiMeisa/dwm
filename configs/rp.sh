rm ~/dwm/configs/xinitrc
rm ~/dwm/configs/alacritty.yml
rm ~/dwm/configs/starship.toml
rm -rf ~/dwm/configs/fish/
rm -rf ~/dwm/configs/ranger/


cp ~/.xinitrc ~/dwm/configs/xinitrc
cp ~/.config/alacritty/alacritty.yml ~/dwm/configs/alacritty.yml
cp ~/.config/starship.toml ~/dwm/configs/starship.toml
cp -r ~/.config/fish/ ~/dwm/configs/fish/ 
cp -r ~/.config/ranger/ ~/dwm/configs/ranger/

