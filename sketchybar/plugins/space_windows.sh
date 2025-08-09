#!/usr/bin/env bash
 
echo AEROSPACE_PREV_WORKSPACE: $AEROSPACE_PREV_WORKSPACE, \
 AEROSPACE_FOCUSED_WORKSPACE: $AEROSPACE_FOCUSED_WORKSPACE \
 SELECTED: $SELECTED \
 BG2: $BG2 \
 INFO: $INFO \
 SENDER: $SENDER \
 NAME: $NAME \
  >> ~/aaaa

source "$CONFIG_DIR/colors.sh"

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKESPACE=$(aerospace list-workspaces --monitor focused --empty)

reload_workspace_icon() {
  # echo reload_workspace_icon "$@" >> ~/aaaa
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --animate sin 10 --set space.$@
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Update all monitor space displays
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
    
    # Update the combined space item for this monitor
    if [ -n "$workspaces" ]; then
      sketchybar --set spaces_monitor_$monitor icon="$display_string" \
                       display=$monitor \
                       background.border_color=$GREY
    fi
  done
fi
