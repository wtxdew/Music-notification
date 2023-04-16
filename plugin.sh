#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

function get_length() {
  local input_string="$1"
  local ascii_string="$(echo "$input_string" | gsed -e 's/[^\x00-\x7f]/XX/g')"
  echo ${#ascii_string}
}

function shorten_string() {
  local string="$1"
  local max_length="$2"

  if [ $(get_length "$string") -gt $max_length ]
  then
    while [ $(get_length "$string") -gt $((max_length - 2)) ]
    do
        string=${string%?}
    done
    string="${string}..."
  fi

  echo $string
}

function get_ratio_to_800px() {
    local cover="$1"
    W=$( sips -g pixelWidth  $cover | awk '/pixelWidth/{print $2}' )
    H=$( sips -g pixelHeight $cover | awk '/pixelHeight/{print $2}' )
    [ $W -gt $H ] && long=$W longside="w" || long=$H longside="h"
    ratio=$( echo "scale=4; 800/$long" | bc )
    echo $ratio
}

update ()
{
    # connecting_msg is dependent on the language of system
    connecting_msg="正在連線⋯"
    echo "@Debug: music.sh::update()"
    RUNNING=$(osascript -e 'application "Music" is running')
    if ! $RUNNING ; then
        echo " update(): Music.app is not running"
        close
        exit
    fi

    PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state')
    echo "PLAYER_STATE: $PLAYER_STATE"
    if [ "$PLAYER_STATE" = "stopped" ]; then
        return
    elif [ "$PLAYER_STATE" = "playing" ]; then
        PLAYING=true
    elif [ "$PLAYER_STATE" = "paused" ]; then
        PLAYING=false
    else
        echo " update(): Unknown player state: $PLAYER_STATE"
        exit
    fi

    TRACK=$(osascript -e 'tell application "Music" to get name of current track')
    ARTIST=$(osascript -e 'tell application "Music" to get artist of current track')
    ALBUM=$(osascript -e 'tell application "Music" to get album of current track')

    if [ "$TRACK" = "$connecting_msg" ]; then
        echo " update(): Connecting to iTunes... retrying in 1 second"
        sleep 1
        update
        exit
    fi

    # if track length is greater than 23, truncate it
    TRACK=$(shorten_string "$TRACK" 24)
    ARTIST=$(shorten_string "$ARTIST" 31)
    ALBUM=$(shorten_string "$ALBUM" 31)

    echo "==========================="
    echo "RUNNING:      $RUNNING"
    echo "PLAYER_STATE: $PLAYER_STATE"
    echo "PLAYING:      $PLAYING"
    echo "TRACK:        $TRACK"
    echo "ARTIST:       $ARTIST"
    echo "ALBUM:        $ALBUM"
    echo ""

    args=()
    osascript "$HOME/.config/sketchybar/addone/music/get_artwork.scpt"
    COVER="/tmp/cover.jpg"
    ratio=$( get_ratio_to_800px $COVER )
    scale=$( echo "scale=4; $ratio*0.2" | bc )

    args+=( --set music.cover background.image=$COVER )
    args+=( --set music.cover background.image.scale=$scale)

    if [ "$ARTIST" == "" ]; then
        args+=( --set music.title   label="$TRACK"  drawing=on \
                --set music.artist  label="$ALBUM"  drawing=on \
                --set music.album   label="Podcast" drawing=on )
    else
        args+=(--set music.title   label="$TRACK"   drawing=on \
               --set music.artist  label="$ARTIST"  drawing=on \
               --set music.album   label="$ALBUM"   drawing=on )
    fi

    # Show popup when state change
    args+=( --set music drawing=on )

    if ! $PLAYING ; then
        args+=( --set music.cover icon.drawing=on                  \
                                  icon.background.color=0x8a3a3a3a )
    else
        args+=( --set music.cover icon.drawing=off                 \
                                  icon.background.color=0x00ffffff )
    fi

    sketchybar "${args[@]}"
    setup
    popup on
    reset
}

setup() {
    sketchybar --animate tanh 20 \
                --set music \
                            popup.background.border_color=$POPUP_BORDER_COLOR \
                            popup.background.color=$POPUP_BACKGROUND_COLOR    \
                --set music.title  label.color=$LABEL_COLOR \
                --set music.artist label.color=$LABEL_COLOR \
                --set music.album  label.color=$LABEL_COLOR
}

reset () {
    sleep 3
    sketchybar --animate tanh 20 --set music\
                        popup.background.color=0x00000000\
                        popup.background.border_color=0x00000000\
        --set music.title  label.color=0x00000000\
        --set music.artist label.color=0x00000000\
        --set music.album  label.color=0x00000000

    sleep 0.2
    popup off
}

playpause ()
{
    echo "@Debug: music.sh::playpause()"
    osascript -e 'tell application "Music" to playpause'
}

close ()
{
    echo "@Debug: music.sh::close()"
    sketchybar  --set music.title drawing=off \
                --set music.artist drawing=off \
                --set music drawing=off popup.drawing=off
    exit 0
}

mouse_clicked () {
    echo "@Debug: music.sh::mouse_clicked()"
    case "$NAME" in
        "music.cover") 
            playpause
            ;;
        *) exit
            ;;
    esac
}

popup () {
    sketchybar --set music popup.drawing=$1
}


echo "==========================="
echo "$(date)"
echo "Start plugins/music.sh [SENDER: $SENDER] [NAME: $NAME]"
echo "$INFO" | jq 
case "$SENDER" in
    "mouse.clicked")
        echo "@Debug: music.sh::mouse_clicked()"
        mouse_clicked
        ;;
    "mouse.entered")
        echo "@Debug: music.sh::mouse_entered()"
        setup
        popup on
        sleep 10
        reset
        ;;
    "mouse.exited"|"mouse.exited.global")
        echo "@Debug: music.sh::mouse_exited()"
        reset
        ;;
    *)
        echo "@Debug: music.sh::DEFAULT()"
        update
        ;;
esac
