this_dir=dev
source "$HOME/.config/sketchybar/addone/${this_dir}/config.sh" # Loads all defined variables
music_event="com.apple.Music.playerInfo"
goto_music_page="osascript -e 'tell application \"Music\" to (reveal current track) activate'"
playpause="osascript -e 'tell application \"Music\" to playpause'"
music_plugin="$HOME/.config/sketchybar/addone/${this_dir}/plugin.sh"

music=(
    width=186
    drawing=off
    script="$music_plugin"
    click_script="$playpause"
    icon=􀑪
    icon.y_offset=2
    icon.padding_left=0
    icon.padding_right=0
    icon.color=$notch_icon_color
    icon.font="$FONT:Regular:22.0"
    label.drawing=off
    background.height=50
    background.y_offset=9
    background.padding_left=0
    background.padding_right=0
    background.corner_radius=8
    background.color=$notch_bg_color
    popup.height=120
    popup.y_offset=3
    popup.align=center
    popup.horizontal=on
    popup.background.border_width=0
    popup.background.corner_radius=5
)

cover=(
    script="$music_plugin"
    label.drawing=off
    icon="􀊄"
    icon.drawing=off
    icon.color=$cover_icon_color_df
    icon.font="$FONT:Regular:50.0"
    icon.align=center
    icon.width=160
    icon.background.height=160
    icon.background.color=$cover_icon_bg_color_df
    icon.padding_right=0
    icon.padding_left=0
    updates=on
    background.corner_radius=0
    background.padding_left=5
    background.padding_right=10
    background.image.scale=$PRE_SCALE
    background.image.drawing=on
    background.drawing=on
)

info=(
    width=0
    drawing=off
    icon.drawing=off
    label.color=$TRANSPARENT
    label.padding_left=0
    label.padding_right=0
    label.width=550
    background.padding_left=0
    background.padding_right=0
)

title=(
    click_script="$goto_music_page"
    label.font="$FONT:Heavy:25"
    y_offset=30
)

artist=(
    label.font="$FONT:Regular:20"
    y_offset=-13
    click_script="$goto_music_page"
)

album=(
    width=280
    label.font="$FONT:Regular:20"
    y_offset=-40
    click_script="$goto_music_page"
)

# cover_icon=(
#     width=50
#     background.height=50
#     background.y_offset=9
#     background.padding_left=-10
#     background.padding_right=-20
#     background.corner_radius=8
#     background.color=$notch_bg_color
#     background.drawing=on
# )
# cover_img=(
#     width=50
#     background.height=50
#     background.y_offset=9
#     background.padding_left=80
#     background.padding_right=0
#     background.corner_radius=8
#     background.image=/tmp/cover.jpg
#     background.image.scale=0.04
#     background.image.drawing=on
#     background.drawing=on
# )
mini_bg=(
    width=50
    drawing=off
    background.drawing=on
    background.height=50
    background.y_offset=9
    background.padding_left=0
    background.padding_right=78
    background.corner_radius=8
    # background.color=0xaa00ff00
    background.color=$BLACK
)

mini_cover=(
    width=50
    y_offset=3
    drawing=off
    background.drawing=on
    background.height=50
    background.y_offset=9
    background.padding_left=0
    background.padding_right=23
    background.corner_radius=8
    background.color=$TRANSPARENT
    # background.color=0xaaff0000
    # background.image=/tmp/cover.jpg
    background.image.scale=0.035
    background.image.drawing=on
)

mini_wave=(
    drawing=off
    width=50
    icon="􀙫"
    icon.drawing=on
    icon.y_offset=2
    icon.width=50
    icon.align=center
    icon.padding_left=0
    icon.padding_right=0
    icon.color=$notch_icon_color
    icon.font="$FONT:Regular:22.0"
    label.drawing=off
    background.drawing=on
    background.height=50
    background.y_offset=9
    background.padding_left=78
    background.padding_right=0
    background.corner_radius=8
    background.color=$BLACK
)


sketchybar  --add   item            music           center      \
            --add   item            music.cover     popup.music \
            --add   item            music.title     popup.music \
            --add   item            music.artist    popup.music \
            --add   item            music.album     popup.music \
            --set   music           "${music[@]}"               \
            --set   music.cover     "${cover[@]}"               \
            --set   music.title     "${info[@]}" "${title[@]}"  \
            --set   music.artist    "${info[@]}" "${artist[@]}" \
            --set   music.album     "${info[@]}" "${album[@]}"

sketchybar  --add   item            mini_bg         q  \
            --add   item            mini_cover      q  \
            --add   item            mini_wave       e  \
            --set   mini_bg         "${mini_bg[@]}"    \
            --set   mini_cover      "${mini_cover[@]}" \
            --set   mini_wave       "${mini_wave[@]}"

sketchybar  --add   event           music_change     $music_event    \
            --add   event           music_launched                   \
            --subscribe music       mouse.entered       mouse.exited \
                                    mouse.exited.global              \
            --subscribe music.cover mouse.clicked                    \
            --subscribe music.cover music_change
           # --subscribe music.cover  music_launched
           


