#!/system/bin/sh
# Audio guard. Launched by the app itself (over loopback ADB or Shizuku) when it opens, and shuts itself down.
#  - While CarAlign captures (the "active" marker, renewed every second), it mutes the apps that are playing
#    (any app with an active media player, not just Tidal) and the known music apps.
#  - It restores everything instantly if the app stops, crashes or stops renewing the marker (>6 s).
#  - It exits when nothing is captured and the app is closed ("app_alive" not renewed for >6 s, for ~3 s).
APP=${CARALIGN_APP:-dev.angelflower.caralign}
# The app and the guard exchange files through TWO folders: Android/media/<app> (works on Android 11+, where the
# shell user cannot enter Android/data) and Android/data/<app>/files (the traditional one). Writes go to both and
# reads take the newest.
D1=/sdcard/Android/media/$APP
D2=/sdcard/Android/data/$APP/files
mkdir -p "$D1" 2>/dev/null
# age in seconds of the newest file across both folders; 9999 if it exists in neither
age() {
    t=$(date +%s); best=9999
    for d in "$D1" "$D2"; do
        m=$(stat -c %Y "$d/$1" 2>/dev/null) || continue
        a=$((t - m)); [ $a -lt $best ] && best=$a
    done
    echo $best
}
touch_all() { for d in "$D1" "$D2"; do touch "$d/$1" 2>/dev/null; done; }
write_all() { for d in "$D1" "$D2"; do echo "$2" > "$d/$1" 2>/dev/null; done; }
rm_all() { for d in "$D1" "$D2"; do rm -f "$d/$1" 2>/dev/null; done; }
# music apps muted in advance when capture starts (avoids an echo as playback begins)
KNOWN="com.aspiro.tidal com.spotify.music com.google.android.apps.youtube.music deezer.android.app com.amazon.mp3"
# never muted, even if they are playing
NEVER="android com.google.android.gms com.android.systemui com.android.phone com.android.server.telecom com.google.android.googlequicksearchbox com.google.android.apps.maps"

MUTED=""
muted=0
idle=0
restore_all() {
    for p in $MUTED $KNOWN; do appops set "$p" PLAY_AUDIO allow 2>/dev/null; done
    MUTED=""
    muted=0
}
trap 'restore_all; rm_all guard_alive; rm_all players; exit 0' TERM INT HUP

# uids of apps with an active media player (MEDIA/GAME/UNKNOWN are the usages CarAlign captures)
players() {
    dumpsys audio 2>/dev/null | grep AudioPlaybackConfiguration | grep 'state:started' \
        | grep -E 'usage=(USAGE_MEDIA|USAGE_GAME|USAGE_UNKNOWN|1|14|0)( |$)' | sed -n 's/.*u\/pid:\([0-9]*\)\/.*/\1/p' | sort -u
}

mute_pkg() {
    case " $MUTED " in *" $1 "*) return ;; esac
    case " $NEVER " in *" $1 "*) return ;; esac
    [ "$1" = "$APP" ] && return
    appops set "$1" PLAY_AUDIO deny 2>/dev/null
    MUTED="$MUTED $1"
}

# packages of a uid (some Android versions lack "list packages --uid": fall back to -U)
uid_pkgs() {
    r=$(cmd package list packages --uid "$1" 2>/dev/null | sed -n 's/^package:\([^ ]*\).*/\1/p')
    [ -z "$r" ] && r=$(pm list packages -U 2>/dev/null | sed -n "s/^package:\([^ ]*\) uid:$1\$/\1/p")
    echo "$r"
}

# mutes the apps that are playing and leaves their count in "players" (the app uses it to detect blocked captures)
scan_and_mute() {
    n=0
    for uid in $(players); do
        [ "$uid" -ge 10000 ] 2>/dev/null || continue
        for pkg in $(uid_pkgs "$uid"); do
            [ "$pkg" = "$APP" ] && continue
            case " $NEVER " in *" $pkg "*) continue ;; esac
            n=$((n + 1))
            mute_pkg "$pkg"
        done
    done
    write_all players $n
}

restore_all
while true; do
    touch_all guard_alive
    capturing=0; [ "$(age active)" -le 6 ] && [ -n "$(pidof $APP)" ] && capturing=1
    open=0; [ "$(age app_alive)" -le 6 ] && [ -n "$(pidof $APP)" ] && open=1
    if [ $capturing -eq 1 ]; then
        idle=0
        if [ $muted -eq 0 ]; then
            for p in $KNOWN; do mute_pkg "$p"; done
            muted=1
        fi
        scan_and_mute
    else
        if [ $muted -eq 1 ]; then restore_all; fi
        if [ $open -eq 1 ]; then idle=0; else idle=$((idle + 1)); fi
        if [ $idle -ge 3 ]; then restore_all; rm_all guard_alive; rm_all players; exit 0; fi
    fi
    sleep 1
done
