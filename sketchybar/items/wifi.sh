
#!/bin/bash

wifi=(
  icon=􀐫
  icon.font="$FONT:Black:12.0"
  icon.padding_right=0
  label.align=right
  padding_left=15
  update_freq=30
  script="$PLUGIN_DIR/wifi.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item wifi right       \
           --set wifi "${wifi[@]}" \
           --subscribe wifi  system_woke
