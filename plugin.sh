#!/bin/bash
this_dir=dev
isDebug=false
# isDebug=true

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors
source "$HOME/.config/sketchybar/addone/${this_dir}/config.sh" # Loads all defined variables

###
function GetLength() {
  local input_string="$1"
  local ascii_string="$(echo "$input_string" | gsed -e 's/[^\x00-\x7f]/XX/g')"
  local ascii_string="$(echo "$ascii_string" | gsed -e 's/XXXX/XXX/g')"
  echo ${#ascii_string}
}

###
function ShortenString() {
  local string="$1"
  local max_length="$2"

  if [ $(GetLength "$string") -gt $max_length ]
  then
    while [ $(GetLength "$string") -gt $((max_length - 2)) ]
    do
        string=${string%?}
    done
    string="${string}..."
  fi

  echo $string
}

###
function GetRatioTo800px() {
    local cover="$1"
    W=$( sips -g pixelWidth  $cover | awk '/pixelWidth/{print $2}' )
    H=$( sips -g pixelHeight $cover | awk '/pixelHeight/{print $2}' )
    [ $W -gt $H ] && long=$W longside="w" || long=$H longside="h"
    ratio=$( echo "scale=4; 800/$long" | bc )
    echo $ratio
}


###
FadeIn () {
    popup on
    sketchybar --animate tanh 20 --set popup_dummy popup.background.color=$POPUP_BACKGROUND_COLOR\
               --animate tanh 20 --set slider background.color=$POPUP_BACKGROUND_COLOR
    sleep 0.3
    sketchybar --set music.title  drawing=on\
               --set music.artist drawing=on\
               --set music.album  drawing=on\
               --set music.cover  drawing=on\
               --set slider      padding_left=-455
    sleep 0.4
    sketchybar --animate tanh 25 --set slider background.color=$TRANSPARENT
}

###
FadeOut () {
    $isDebug && exit
    sleep $KEEP_SHOWING_TIME
    sketchybar --animate tanh 20 --set slider background.color=$POPUP_BACKGROUND_COLOR
    sleep 0.4
    sketchybar --set music.title  drawing=off  \
               --set music.artist drawing=off \
               --set music.album  drawing=off \
               --set music.cover  drawing=off   \
               --set slider      padding_left=0
    sleep 0.4
    sketchybar --animate tanh 20 --set popup_dummy popup.background.color=$TRANSPARENT\
               --animate tanh 20 --set slider background.color=$TRANSPARENT
    sleep 0.7
    popup off

    exit 0
}
###
FadeIn2 () {
    # track_value=$(sketchybar --query music.title | jq -r ".label.value")
    # if [ "$track_value" = "\"$CONNECTING_MSG\"" ] || [ "$track_value" = "" ] ; then
    #     echo " FadeIn(): Abort FadeIn due to not playing"
    #     exit
    # fi
    sketchybar --set music.cover icon.drawing=on
    popup on
    sketchybar --animate tanh 20 --set popup_dummy popup.background.color=$POPUP_BACKGROUND_COLOR
    sleep 0.1
    sketchybar --set music.cover background.color=$POPUP_BACKGROUND_COLOR
    sketchybar --set music.cover background.image.drawing=on

    PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state')
    [ $PLAYER_STATE = "playing" ] && sketchybar --set music.cover icon.drawing=off

    sketchybar --animate tanh 25 --set music.title  label.color=$LABEL_COLOR \
               --animate tanh 25 --set music.artist label.color=$LABEL_COLOR \
               --animate tanh 25 --set music.album  label.color=$LABEL_COLOR \
               --animate tanh 25 --set music.cover   icon.color=$WHITE\
               --animate tanh 25 --set music.cover  icon.background.color=0x8a3a3a3a\
               --animate tanh 25 --set music.cover  background.color=$TRANSPARENT
}

###
FadeOut2 () {
    $isDebug && exit
    sleep $KEEP_SHOWING_TIME
    sketchybar --animate tanh 25 --set music.title  label.color=$TRANSPARENT \
               --animate tanh 25 --set music.artist label.color=$TRANSPARENT \
               --animate tanh 25 --set music.album  label.color=$TRANSPARENT \
               --animate tanh 25 --set music.cover  icon.color=$TRANSPARENT\
               --animate tanh 25 --set music.cover  icon.background.color=$TRANSPARENT\
               --animate tanh 25 --set music.cover  background.color=$POPUP_BACKGROUND_COLOR

    sleep 0.4
    sketchybar --set music.cover icon.drawing=on
    sketchybar --set music.cover background.image.drawing=off
    sketchybar --set music.cover background.color=$TRANSPARENT
    sketchybar --animate tanh 20 --set popup_dummy popup.background.color=$TRANSPARENT
    sleep 0.7
    popup off

    PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state')
    [ $PLAYER_STATE = "playing" ] && sketchybar --set music.cover icon.drawing=off

    exit 0
}

###
SlideIn() {
    popup on
    sketchybar --animate tanh 20 --set slider width=455
    sleep 0.3
    sketchybar --set music.title  drawing=on   \
               --set music.artist drawing=on   \
               --set music.album  drawing=on   \
               --set music.cover  drawing=on   \
               --set slider      padding_left=-455
    sleep 0.2
    sketchybar --animate tanh 25 --set slider background.color=$TRANSPARENT
}

###
SlideOut() {
    $isDebug && exit
    sleep $KEEP_SHOWING_TIME
    sketchybar --animate tanh 25 --set slider background.color=$POPUP_BACKGROUND_COLOR
    sleep 0.2
    sketchybar --set music.title  drawing=off   \
               --set music.artist drawing=off   \
               --set music.album  drawing=off   \
               --set music.cover  drawing=off   \
               --set slider      padding_left=0
    sleep 0.2
    sketchybar --animate tanh 20 --set slider width=0
    sleep 0.7
    popup off
    exit 0
}

###
PlaypauseOrActivate () {
    PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state')

    if [ $PLAYER_STATE = "stopped" ] ; then
        echo " PlaypauseOrActivate(): open Music.app"
        open /System/Applications/Music.app
    else
        echo " PlaypauseOrActivate(): playpause"
        osascript -e 'tell application "Music" to playpause'
    fi
}

###
popup () {
    sketchybar --set popup_dummy popup.drawing=$1
}

###
mouse_clicked () {
    echo " mouse_clicked(): $NAME"
    case "$NAME" in
        "music")
            PlaypauseOrActivate
            ;;
        *) exit
            ;;
    esac
}

### 
mouse_entered() {
    RUNNING=$(osascript -e 'application "Music" is running')
    if ! $RUNNING ; then
        echo " mouse_entered(): Abort due to not running"
        exit
    fi
    # PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state')
    # if [ ! $PLAYER_STATE = "playing" ] ; then
    #     echo " mouse_entered(): Abort due to not playing"
    #     exit
    # fi

    SlideIn
}

###
function toggle_mini_bar () {
    args+=( --set mini_bg       drawing=$1)
    args+=( --set mini_cover    drawing=$1)
    args+=( --set mini_wave     drawing=$1)
    sketchybar "${args[@]}"
}

###
function Update () {
    # connecting_msg is dependent on the language of system
    echo " Update(): Start."
    RUNNING=$(osascript -e 'application "Music" is running')
    if ! $RUNNING ; then
        echo " Update(): Music.app Not Running - Exit"
        toggle_mini_bar off
        exit
    fi

    toggle_mini_bar on
    PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state')
    case "$PLAYER_STATE" in
        "stopped")
            echo " Update(): Player State: Stopped - Exit"
            exit
            ;;
        "playing")
            IS_PLAYING=true ;;
        "paused")
            IS_PLAYING=false ;;
        *)
            echo " Update(): Unknown player state: $PLAYER_STATE"
            exit ;;
    esac

    TRACK=$(osascript -e 'tell application "Music" to get name of current track')
    ARTIST=$(osascript -e 'tell application "Music" to get artist of current track')
    ALBUM=$(osascript -e 'tell application "Music" to get album of current track')

    if [ "$TRACK" = "$CONNECTING_MSG" ] || [ "$TRACK" = "" ] ; then
        echo " Update(): Connecting to iTunes... retrying in 1 second"
        sleep 1
        Update
        exit
    fi

    TRACK=$(ShortenString "$TRACK" 18)
    ARTIST=$(ShortenString "$ARTIST" 23)
    ALBUM=$(ShortenString "$ALBUM" 23)

    echo "---------------------------"
    echo "IS_PLAYING:   $IS_PLAYING"
    echo "TRACK:        $TRACK"
    echo "ARTIST:       $ARTIST"
    echo "ALBUM:        $ALBUM"
    echo ""

    args=()
    [ "$ARTIST" == "" ] && ARTIST="Podcast"
    args+=(--set music.title  label="$TRACK"  )
    args+=(--set music.artist label="$ARTIST" )
    args+=(--set music.album  label="$ALBUM"  )

    rm -f /tmp/cover.*
    COVER=""
    while [ -z "$COVER" ] ; do
        osascript "$HOME/.config/sketchybar/addone/${this_dir}/get_artwork.scpt"
        if [ -f "/tmp/cover.png" ]; then
            COVER="/tmp/cover.png" 
        elif [ -f "/tmp/cover.jpg" ]; then
            COVER="/tmp/cover.jpg"
        else
            echo " Update(): No cover found - retrying in 1 second"
            sleep 1
        fi
    done

    ratio=$(GetRatioTo800px $COVER)
    scale=$(echo "scale=4; $ratio*$PRE_SCALE" | bc)
    args+=( --set mini_cover  background.image=$COVER)
    args+=( --set music.cover background.image=$COVER )
    args+=( --set music.cover background.color=$TRANSPARENT)
    args+=( --set music.cover background.image.drawing=on)
    args+=( --set music.cover background.image.scale=$scale)

    if ! $IS_PLAYING ; then
        args+=( --set music         icon.color=${WHITE})
        args+=( --set mini_wave     icon.color=${WHITE})
        # args+=( --set music.cover   icon.drawing=on)
        # args+=( --set music.cover   icon.background.drawing=on)
    else
        args+=( --set music         icon.color=${notch_icon_color})
        args+=( --set mini_wave     icon.color=${notch_icon_color})
        # args+=( --set music.cover   icon.drawing=off)
        # args+=( --set music.cover   icon.background.drawing=off)
    fi

    sketchybar "${args[@]}"
    echo " Update(): Done"

    if  $IS_PLAYING ; then
        # FadeIn
        # FadeOut
        SlideIn
        SlideOut
    else
        SlideIn
    fi
}

echo "========== Music Indicator: $(date) =========="
echo "[addone/music] (SENDER: $SENDER) (NAME: $NAME)"
case "$SENDER" in
    "mouse.clicked")
        mouse_clicked
        ;;
    "mouse.entered")
        mouse_entered
        ;;
    "mouse.exited"|"mouse.exited.global")
        SlideOut
        ;;
    *)
        $isDebug && DebugFunc || Update
        ;;
esac
echo ""

sleep $ENTER_TIMEOUT
SlideOut

DebugFunc () {
    echo "@Debug: music.sh::DebugFunc()"
    # args+=( --set music.cover background.image=$COVER )
    # args+=( --set music.cover background.image.scale=$scale)
    TRACK="ABCDEFGHIJKLMN"
    # ARTIS="あいうえおかきくけこさしすせ" # 14 (41px)
    # ARTIS="11111111111111111111111111111111" # 32 (18px)
    # ARTIS="--------------------------------" # 32 (18px)
    # ARTIS="___________________________" # 27 (21px)
    # ARTIS="99999999999999999999999" # 23 (25px)
    # ARTIS="A                                                    V" # 52 (10px)
    # ARTIS="一二三ABCDEFあい   ESDFSう"
    # ALBUM="ABCDEFGHIJKLMNOPQRSTUV" # 22 (26px)= 572px
    ARTIS="ABCDEFGHIJKLMNOPQRSTUV" # 22 (26px)= 572px
    ALBUM="U.N.オーエンは彼女なのか?" # 22 (26px)= 572px
    args+=( --set music.title   label="$TRACK"   drawing=on \
        --set music.artist  label="$ARTIS"  drawing=on \
        --set music.album   label="$ALBUM"   drawing=on )

    args+=( --set music drawing=on )

    sketchybar "${args[@]}"
    FadeIn
}
