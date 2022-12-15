#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

# merge in defaults and keymaps

if [ -f $sysresources ]; then

    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then

    	xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

DIR=${HOME}/.dwm
 
if [ -f "${DIR}"/dwmrc ]; then
 
/bin/sh "${DIR}"/dwmrc &
 
else
 
while true; do
 
BAT=$(cat /sys/class/power_supply/BAT0/capacity)
VOL=$( amixer get Master | tail -1 | awk '{print $4}' )
MemAva=$(free -h | grep 'Mem' | awk '{print $7}')
CPUUs=$(top -bn 1 -i -c | grep '%Cpu(s)' | awk '{print $2}')

xsetroot -name " VOL$VOL BAT[$BAT%] CPU[$CPUUs%] MEM[$MemAva] | $(date +"%F") $(date +"%H:%M") "
sleep 1s 
 
done &
 
fi

#imwheel &
#clash &
/home/kana/Software/Clash\ for\ Windows-0.20.2-x64-linux/cfw &
fcitx-autostart &
fcitx &
#xrandr --output HDMI-0 --mode 1920x1080 --rate 74.99 &                                                                                      (base) 19:33:15
xrandr --output DP-4 --mode 2560x1600 --rate 165 &
redshift -P -O 5000K -b 0.4 &

exec dwm
