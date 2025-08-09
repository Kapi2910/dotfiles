#!/bin/sh

# Left side separator
left_separator=(
  icon="-->"
  icon.font="$FONT:Regular:20.0"
  icon.color=$WHITE
  padding_right=8
  label.drawing=off
  # background.drawing=off
  y_offset=0
)

sketchybar --add item left_separator left \
           --set left_separator "${left_separator[@]}"
