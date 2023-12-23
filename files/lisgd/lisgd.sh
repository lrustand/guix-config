#!/usr/bin/env bash
lisgd -d /dev/input/by-path/pci-0000:00:15.0-platform-i2c_designware.0-event \
      -g "1,RL,R,*,P,xdotool key Super_L+n" \
      -g "1,LR,L,*,P,xdotool key Super_L+p" \
      -g "2,RL,*,*,R,xdotool key Super_L+n" \
      -g "2,LR,*,*,R,xdotool key Super_L+p" \
      -g "1,DU,B,*,P,xdotool key Hyper_L+m" \
      -g "1,UD,B,*,P,xdotool key Hyper_L+M" \
      -g "1,UD,T,*,P,SHOW_MENU" \
      -g "1,DLUR,TR,*,P,xdotool key Super_L+f" \
