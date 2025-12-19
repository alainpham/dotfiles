export PRODUCT_NAME=$(cat /sys/devices/virtual/dmi/id/product_name)
export LIBVIRT_DEFAULT_URI='qemu:///system'
export SDL_GAMECONTROLLERCONFIG="0300d859bc2000000055000010010000,ShanWanWireless,a:b0,b:b1,back:b10,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,guide:b12,leftshoulder:b6,leftstick:b13,lefttrigger:a5,leftx:a0,lefty:a1,rightshoulder:b7,rightstick:b14,righttrigger:a4,rightx:a2,righty:a3,start:b11,x:b3,y:b4"


[ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ] && command -v startx && startx
