# Needed when starting through sx
xhost +SI:localuser:$USER

autorandr --change

xmodmap ~/.Xmodmap

# Start stumpwm from git checkout
exec sbcl --load start-stump
