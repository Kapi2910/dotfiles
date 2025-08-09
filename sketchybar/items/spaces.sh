#!/bin/sh

#SPACE_ICONS=("1" "2" "3" "4")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sketchybar --add event aerospace_workspace_change
#echo $(aerospace list-workspaces --monitor 1 --visible no --empty no) >> ~/aaaa

for m in $(aerospace list-monitors | awk '{print $1}'); do
    workspaces=$(aerospace list-workspaces --monitor $m)
    
    # Create a single combined space for this monitor
    space=(
      icon="$workspaces"
      icon.highlight_color=$RED
      icon.padding_left=10
      icon.padding_right=20
      icon.y_offset=1
      display=$m
      padding_left=2
      padding_right=2
      background.color=$BACKGROUND_1
      background.border_color=$BACKGROUND_2
      script="$PLUGIN_DIR/space.sh"
      y_offset=-1
    )

    sketchybar --add item spaces_monitor_$m left \
               --set spaces_monitor_$m "${space[@]}" \
               --subscribe spaces_monitor_$m mouse.clicked aerospace_workspace_change

    # Handle empty workspaces by hiding them
  for i in $(aerospace list-workspaces --monitor $m --empty); do
    # Empty workspaces are already excluded from the combined display
    # No action needed here for combined space approach
    continue
  done
  
done
