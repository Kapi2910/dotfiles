#!/bin/sh

front_app=(
  label.font="JetBrainsMono Nerd Font Mono:Regular:12.0"
  icon.font="sketchybar-app-font:Regular:22.0"
  icon.background.drawing=on
  display=active
  script="$PLUGIN_DIR/front_app.sh"
  click_script="open -a 'Mission Control'"
)
sketchybar --add item front_app left         \
           --set front_app "${front_app[@]}" \
           --subscribe front_app front_app_switched

