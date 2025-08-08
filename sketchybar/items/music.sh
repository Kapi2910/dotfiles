#!/bin/sh
# Add Spotify event listener
sketchybar -m --add event spotify_change "com.spotify.client.PlaybackStateChanged"

# Add music item
sketchybar -m --add item music left \
        --set music icon=" $($CONFIG_DIR/plugins/icon_map.sh "Spotify")" \
        --set music icon.font="sketchybar-app-font:Regular:16.0" \
        --set music icon.color=$GREEN \
        --set music icon.padding_left=5 \
        --set music icon.padding_right=8 \
        --set music script="~/.config/sketchybar/plugins/music.sh" \
        --set music background.color=$BACKGROUND_1 \
        --set music background.border_color=$BACKGROUND_2 \
        --set music update_freq=2 \
        --set music click_script="open -a Spotify" \
        --subscribe music spotify_change media_change
