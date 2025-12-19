export PRODUCT_NAME=$(cat /sys/devices/virtual/dmi/id/product_name)
export LIBVIRT_DEFAULT_URI='qemu:///system'
export SDL_GAMECONTROLLERCONFIG="0300d859bc2000000055000010010000,platform:Linux,a:b0,b:b1,x:b3,y:b4,back:b10,start:b11,guide:b12,leftshoulder:b6,rightshoulder:b7,leftstick:b13,rightstick:b14,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b8,righttrigger:b9,dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,"


[ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ] && command -v startx && startx
