autorandr --change

xmodmap ~/.Xmodmap

# Start stumpwm from git checkout
exec sbcl --load start-stump
