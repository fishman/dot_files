#!/bin/bash
[ -f /tmp/theme ] && read theme < /tmp/theme || theme=$([ $(gsettings get org.gnome.desktop.interface color-scheme) = "'default'" ] && echo "light" || echo "dark")

WOB_PATH="$XDG_RUNTIME_DIR/wob.sock"
BAR_ID=''
while getopts 'w:b:' flag; do
  case "${flag}" in
    w) WOB_PATH="${OPTARG}" ;;
    b) BAR_ID="${OPTARG}" ;;
    *) printf "$@"
        exit 1 ;;
  esac
done

is_waybar_ServerExist=`ps -ef|grep -m 1 waybar|grep -v "grep"|wc -l`
if [ "$is_waybar_ServerExist" = "0" ]; then
  echo "waybar_server not found" > /dev/null 2>&1
  exit;
elif [ "$is_waybar_ServerExist" = "1" ]; then
  killall waybar
fi

SDIR="$HOME/.config/waybar"
for i in /sys/class/hwmon/hwmon*/temp*_input; do 
    if [ "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*}))" = "coretemp: Package id 0" ]; then
        export HWMON_PATH="$i"
    fi
done
sed -i "/hwmon-path/c\ \ \ \ \"hwmon-path\": \"$HWMON_PATH\"," $SDIR/config

# replace socket for wob
sed 's@\$WOBSOCK@'"$WOB_PATH"'@g' $SDIR/config > /tmp/wb_conf

#waybar -c "$SDIR"/config1 -s "$SDIR"/style1.css &
waybar -c /tmp/wb_conf -s "$SDIR"/"$theme".css -b "$BAR_ID" &
