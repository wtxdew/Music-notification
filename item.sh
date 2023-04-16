music_event="com.apple.Music.playerInfo"
popup_script="osascript -e 'tell application \"Music\" to activate'"
title_script="osascript -e 'tell application \"Music\" to (reveal current track) activate'"
music_plugin="$HOME/.config/sketchybar/addone/music/plugin.sh"

music=(
    script="$music_plugin"
    click_script="$popup_script"
    popup.horizontal=on
    popup.align=center
    popup.height=120
    icon=􀑪
    icon.font="$FONT:Regular:22.0"
    label.drawing=off
    drawing=off
    popup.y_offset=3
    popup.background.border_width=0
    popup.background.corner_radius=5
    width=186
    background.height=50
    background.y_offset=9
    background.corner_radius=8
    background.color=0xff000000
    icon.padding_left=0
    icon.padding_right=0
    label.padding_left=0
    label.padding_right=0
    background.padding_left=1
    background.padding_right=0
    icon.y_offset=2
    icon.color=0xffffffff
)

cover=(
    script="$music_plugin"
    label.drawing=off
    icon="􀊄"
    icon.drawing=off
    icon.color=0xffffffff
    icon.font="$FONT:Regular:50.0"
    icon.align=center
    icon.width=160
    icon.background.height=160
    icon.background.color=0x00000000
    icon.padding_right=0
    icon.padding_left=0
    updates=on
    background.corner_radius=0
    background.padding_left=5
    background.padding_right=10
    background.image.scale=0.20
    background.image.drawing=on
    background.drawing=on
)

title=(
    icon.drawing=off
    background.padding_left=0
    background.padding_right=0
    label.font="$FONT:Heavy:25"
    y_offset=30
    width=0
    click_script="$title_script"
)

artist=(
    icon.drawing=off
    background.padding_left=0
    background.padding_right=0
    label.font="$FONT:Regular:20"
    y_offset=-13
    width=0
    click_script="$title_script"
)

album=(
    icon.drawing=off
    background.padding_left=0
    background.padding_right=10
    label.font="$FONT:Regular:20"
    y_offset=-40
    width=280
    click_script="$title_script"
)

sketchybar  --add   item            music           center      \
            --add   item            music.cover     popup.music \
            --add   item            music.title     popup.music \
            --add   item            music.artist    popup.music \
            --add   item            music.album     popup.music \
            --set   music           "${music[@]}"               \
            --set   music.cover     "${cover[@]}"               \
            --set   music.title     "${title[@]}"               \
            --set   music.artist    "${artist[@]}"              \
            --set   music.album     "${album[@]}"

sketchybar  --add   event           music_change     $music_event    \
            --add   event           music_launched                   \
            --subscribe music       mouse.entered       mouse.exited \
                                    mouse.exited.global              \
            --subscribe music.cover mouse.clicked                    \
            --subscribe music.cover music_change
           # --subscribe music.cover  music_launched

