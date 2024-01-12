# Needed when starting through sx
xhost +SI:localuser:$USER

xss-lock -- i3lock -c 000000 &

autorandr --change

xmodmap ~/.Xmodmap

# Start stumpwm from git checkout
exec sbcl --load start-stump
