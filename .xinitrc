userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap


# Fcitx4
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

# Fcitx5
#export GTK_IM_MODULE=fcitx5
#export QT_IM_MODULE=fcitx5
#export XMODIFIERS="@im=fcitx5"

# Java
export JAVA_HOME=/home/kana/Software/jre1.8.0_351
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export JAVA_HOME=/usr/lib/jvm/default
export PATH=$PATH:$JAVA_HOME/bin
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit

# TexLive
export TEXINPUTS=".:/usr/share/texmf-dist/tex/latex//:"

# CUDA
export LD_LIBRARY_PATH="/usr/local/cuda/lib64"

export LIBVA_DRIVER_NAME=vdpau

export LD_PRELOAD=/usr/lib/libstdc++.so.6
export PATH=/opt/cuda/bin:$PATH


# Merge in Defaults and Keymaps
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


# Start Some Nice Programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi
 
# Title Bar
while true; do
BAT=$(cat /sys/class/power_supply/BAT0/capacity)
VOL=$( amixer get Master | tail -1 | awk '{print $4}')
MemAva=$(free -h | grep 'Mem' | awk '{print $7}')
WEEK=$(LC_TIME=ja_JP.UTF-8 date '+%A' | awk '{print substr($0, 1, 1)}')

wlan0=$(ifconfig wlan0 | grep "inet" | awk '{print $2}' | awk 'NR==1')
eno1=$(ifconfig eno1 | grep "inet" | awk '{print $2}' | awk 'NR==1')
eth0=$(ifconfig enp6s0f4u2c4i2 | grep "inet" | awk '{print $2}' | awk 'NR==1')
enp6s0f4u2c4i2=$(ifconfig enp6s0f4u2c4i2 | grep "inet" | awk '{print $2}' | awk 'NR==1')
#clipb=$(xclip -selection clipboard | cut -c 1-9)



# 使用xclip命令获取剪贴板内容
clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)

# 将内容重新放回剪切板
echo -n "$clipboard_content" | xclip -selection clipboard

# 判断剪贴板是否有内容
if [ -z "$clipboard_content" ]; then
    # 如果剪贴板没有内容，就将字符串“No any”赋值给clip
    clipb="N/A"
else
    # 使用tr命令将换行符替换为空格，再使用cut命令处理并赋值给clip
    clipb=$(echo "$clipboard_content" | tr '\n' ' ' | cut -c 1-9)
fi


net=$(echo N/A)
[ $wlan0 ] && net=$(echo wlan0)
[ $eno1 ] && net=$(echo eno1)
[ $eth0 ] && net=$(echo eth0)
[ $wlan0 ] && [ $eth0 ] && net=$(echo wlan0/eth0)
[ $wlan0 ] && [ $eno1 ] && net=$(echo wlan0/eno1)
[ $eno1 ] && [ $enp6s0f4u2c4i2 ] && net=$(echo eno1/eth0)
[ $wlan0 ] && [ $enp6s0f4u2c4i2 ] && [ $eno1 ] && net=$(echo wlan0/eno1/eth0 )

status=$(cat /sys/class/power_supply/BAT0/status)

if [[ "$status" == "Not charging" || "$status" == "Charging" || "$status" == "Full" ]]; then
	BATC=$(echo [C]) 
else
	BATC=$(echo )
fi

xsetroot -name "   VOL$VOL   BAT[$BAT%]$BATC   MEA[$MemAva]   NET[$net]   CLB[$clipb]   |   $(date +"%F") ($WEEK)   $(date +"%H:%M")   "
amixer set -c 1 Master 0   # Keep Quiet
sleep 1s  
done &


# VMWare Services
sudo systemctl enable vmware-networks.service  vmware-usbarbitrator.service &
sudo systemctl start vmware-networks.service  vmware-usbarbitrator.service &

xinput set-prop "MSFT0001:00 06CB:CE78 Touchpad" 310 1
xinput set-prop "MSFT0001:00 06CB:CE78 Touchpad" 281 1
xinput set-prop "MSFT0001:00 06CB:CE78 Touchpad" 292 0.4


# Auto-Run SOftwares
#imwheel &
picom --config ~/.config/picom/picom.conf &
#picom -b &
wmname LG3D &
clash &
fcitx-autostart &
fcitx &
xrandr --output HDMI-0 --primary --mode 1920x1080 --rate 75 &
xrandr --output DP-4 --mode 2560x1600 --rate 165 &
redshift -P -O 5500K -b 0.4 & 
bluetoothctl power on &
dunst &
xmodmap ~/.Xmodmap & 
#blueman-manager &
#amixer set -c 1 Master 0 & 

xset s 0 &
xset -dpms &

exec dwm

