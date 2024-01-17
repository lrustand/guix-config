# Needed when starting through sx
xhost +SI:localuser:$USER

xss-lock -- i3lock -c 000000 &

autorandr --change

xmodmap -e "clear lock"
xmodmap -e "keysym Caps_Lock = Hyper_L"
xmodmap -e "remove Mod4 = Hyper_L"
xmodmap -e "add Mod3 = Hyper_L"

# Start stumpwm from git checkout
exec sbcl --load start-stump
