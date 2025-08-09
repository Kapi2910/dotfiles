#!/bin/bash

#echo space.sh $'FOCUSED_WORKSPACE': $FOCUSED_WORKSPACE, $'SELECTED': $SELECTED, NAME: $NAME, SENDER: $SENDER  >> ~/aaaa

update() {
  source "$CONFIG_DIR/colors.sh"
  
  # Handle aerospace_workspace_change event
  if [ "$SENDER" = "aerospace_workspace_change" ]; then
    # Update all monitor displays
    for monitor in $(aerospace list-monitors | awk '{print $1}'); do
      workspaces=$(aerospace list-workspaces --monitor $monitor)
      focused_workspace=$(aerospace list-workspaces --focused)
      
      # Build the display string with highlighting
      display_string=""
      for ws in $workspaces; do
        if [ "$ws" = "$focused_workspace" ]; then
          # Highlight the focused workspace
          display_string="$display_string [$ws]"
        else
          display_string="$display_string $ws"
        fi
      done
      
      # Update the display for this monitor
      if [ -n "$workspaces" ]; then
        sketchybar --set spaces_monitor_$monitor icon="$display_string" \
                         background.border_color=$GREY
      fi
    done
  else
    # Handle other events (fallback)
    focused_workspace=$(aerospace list-workspaces --focused)
    focused_monitor=$(aerospace list-monitors --focused | awk '{print $1}')
    workspaces=$(aerospace list-workspaces --monitor $focused_monitor)
    
    display_string=""
    for ws in $workspaces; do
      if [ "$ws" = "$focused_workspace" ]; then
        display_string="$display_string [$ws]"
      else
        display_string="$display_string $ws"
      fi
    done
    
    sketchybar --set spaces_monitor_$focused_monitor icon="$display_string" \
                     background.border_color=$GREY
  fi
}

set_space_label() {
  sketchybar --set $NAME icon="$@"
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    # Right click - cycle through workspaces backwards
    focused_workspace=$(aerospace list-workspaces --focused)
    focused_monitor=$(aerospace list-monitors --focused | awk '{print $1}')
    workspaces=($(aerospace list-workspaces --monitor $focused_monitor))
    
    # Find current workspace index
    for i in "${!workspaces[@]}"; do
      if [ "${workspaces[$i]}" = "$focused_workspace" ]; then
        # Go to previous workspace (or last if at beginning)
        if [ $i -eq 0 ]; then
          prev_index=$((${#workspaces[@]} - 1))
        else
          prev_index=$((i - 1))
        fi
        aerospace workspace "${workspaces[$prev_index]}"
        break
      fi
    done
  else
    # Left click - cycle through workspaces forward
    focused_workspace=$(aerospace list-workspaces --focused)
    focused_monitor=$(aerospace list-monitors --focused | awk '{print $1}')
    workspaces=($(aerospace list-workspaces --monitor $focused_monitor))
    
    # Find current workspace index
    for i in "${!workspaces[@]}"; do
      if [ "${workspaces[$i]}" = "$focused_workspace" ]; then
        # Go to next workspace (or first if at end)
        if [ $i -eq $((${#workspaces[@]} - 1)) ]; then
          next_index=0
        else
          next_index=$((i + 1))
        fi
        aerospace workspace "${workspaces[$next_index]}"
        break
      fi
    done
  fi
}

# echo plugin_space.sh $SENDER >> ~/aaaa
case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
