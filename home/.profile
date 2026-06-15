export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
if [ -r /sys/devices/virtual/dmi/id/product_name ]; then
    export PRODUCT_NAME=$(cat /sys/devices/virtual/dmi/id/product_name)
else
    export PRODUCT_NAME="GENERIC"
fi
export LIBVIRT_DEFAULT_URI='qemu:///system'
# shanwaw wireless controller make look like a PS3 controller
export SDL_GAMECONTROLLERCONFIG="0300d859bc2000000055000010010000,PS3 Controller,platform:Linux,a:b0,b:b1,x:b3,y:b4,back:b10,start:b11,guide:b12,leftshoulder:b6,rightshoulder:b7,leftstick:b13,rightstick:b14,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b8,righttrigger:b9,dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,"

if [ -f ~/.xdpi ]; then 
    export XDPI=$(cat ~/.xdpi)
else
    export XDPI=96
fi

export WINIT_X11_SCALE_FACTOR=$(awk -v xdpi="$XDPI" 'BEGIN { printf "%.2f\n", xdpi/96 }')
export XCURSOR_THEME="Adwaita"
export XCURSOR_SIZE=24
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources && echo ".Xresources loaded">>~/.xinit.log
