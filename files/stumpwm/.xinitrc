# Needed when starting through sx
xhost +SI:localuser:$USER

xss-lock -- i3lock -c 000000 &

autorandr --change --match-edid

xmodmap -e "clear lock"
xmodmap -e "keysym Caps_Lock = Hyper_L"
xmodmap -e "remove Mod4 = Hyper_L"
xmodmap -e "add Mod3 = Hyper_L"

# Start stumpwm from git checkout
#exec sbcl --load start-stump

export PATH="$HOME/.emacs.d/guix-profile/bin:$PATH"
exec dbus-launch --exit-with-session emacs --maximized --fullscreen --no-splash
