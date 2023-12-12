autorandr --change

# Make xmodmap service take effect
# TODO report this bug
herd restart xmodmap

# Start stumpwm from git checkout
exec sbcl --load start-stump
