# XInit
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap


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

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi


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


# TeXLive
export TEXINPUTS=".:/usr/share/texmf-dist/tex/latex//:"


# CUDA
export LD_LIBRARY_PATH="/usr/local/cuda/lib64"
export LIBVA_DRIVER_NAME=vdpau
export LD_PRELOAD=/usr/lib/libstdc++.so.6
export PATH=/opt/cuda/bin:$PATH


# VMWare Services
sudo systemctl enable vmware-networks.service  vmware-usbarbitrator.service &
sudo systemctl start vmware-networks.service  vmware-usbarbitrator.service &


# Touchpad Settings
xinput set-prop "MSFT0001:00 06CB:CE78 Touchpad" 310 1
xinput set-prop "MSFT0001:00 06CB:CE78 Touchpad" 281 1
xinput set-prop "MSFT0001:00 06CB:CE78 Touchpad" 292 0.4


# Xsetroot Bar
while true; do
    # Battery
    battery=$(cat /sys/class/power_supply/BAT0/capacity)
    battery_status=$(cat /sys/class/power_supply/BAT0/status)
    if [[ "$battery_status" == "Not charging" || "$battery_status" == "Charging" || "$battery_status" == "Full" ]]; then
        is_charging=$(echo /C)
    else
        is_charging=$(echo )
    fi

    # Volume
    volume=$( amixer get Master | tail -1 | awk '{print $4}')

    # CPU & GPU
    cpu_memory_free=$(free -h | grep 'Mem' | awk '{print $7}' | sed 's/Gi//' | awk '{printf "%.1fGB\n", $1 * 1.073741824}')
    gpu_memory_free=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | awk '{sum += $1} END {printf "%.1fGB\n", sum/1024}')

    gpu_use=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1"%"}')
    cpu_use=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.0f%%", 100 - $1}')

    cpu_temp=$(sensors | grep 'Tctl:' | awk '{print $2}' | grep -o '[0-9.]*' | awk -F. '{print $1}')
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)

    # Network
    wlan0=$(ifconfig wlan0 | grep "inet" | awk '{print $2}' | awk 'NR==1')
    eno1=$(ifconfig eno1 | grep "inet" | awk '{print $2}' | awk 'NR==1')
    eth0=$(ifconfig enp6s0f4u2c4i2 | grep "inet" | awk '{print $2}' | awk 'NR==1')
    enp6s0f4u2c4i2=$(ifconfig enp6s0f4u2c4i2 | grep "inet" | awk '{print $2}' | awk 'NR==1')

    net=$(echo N/A)
    [ $wlan0 ] && net=$(echo wlan0)
    [ $eno1 ] && net=$(echo eno1)
    [ $eth0 ] && net=$(echo eth0)
    [ $wlan0 ] && [ $eth0 ] && net=$(echo wlan0/eth0)
    [ $wlan0 ] && [ $eno1 ] && net=$(echo wlan0/eno1)
    [ $eno1 ] && [ $enp6s0f4u2c4i2 ] && net=$(echo eno1/eth0)
    [ $wlan0 ] && [ $enp6s0f4u2c4i2 ] && [ $eno1 ] && net=$(echo wlan0/eno1/eth0 )

    # Date
    week_jp=$(LC_TIME=ja_JP.UTF-8 date '+%A' | awk '{print substr($0, 1, 1)}')

    xsetroot -name " BAT[$battery%$is_charging] NET[$net] CPU[$cpu_use/$cpu_memory_free/$cpu_temp°C] GPU[$gpu_use/$gpu_memory_free/$gpu_temp°C] | $(date +"%F")($week_jp) $(date +"%H:%M") "

    amixer set -c 1 Master 0   # Keep Quiet

    sleep 1s
done &


# Auto-Start
picom --config ~/.config/picom/picom.conf &
wmname LG3D &
clash &
fcitx-autostart &
fcitx &
xrandr --output HDMI-0 --primary --mode 1920x1080 --rate 75 &
xrandr --output DP-4 --mode 2560x1600 --rate 165 &
redshift -P -O 5500K -b 0.3 & 
bluetoothctl power on &
dunst &
xmodmap ~/.Xmodmap & 
#blueman-manager &


exec dwm
