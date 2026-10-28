#!/system/bin/sh
# Vigilante de audio. Lo lanza la propia app (por ADB en loopback o Shizuku) al abrirse y se apaga solo.
#  - Mientras CarAlign captura (marca "active" renovada cada segundo), silencia a las apps que estan sonando
#    (cualquier app con un reproductor de medios activo, no solo Tidal) y a las apps de musica conocidas.
#  - Restaura todo al instante si la app se detiene, se cae o deja de renovar la marca (>6 s).
#  - Termina cuando no hay captura ni la app esta abierta ("app_alive" sin renovar >6 s durante ~3 s).
APP=${CARALIGN_APP:-dev.angelflower.caralign}
# La app y el vigilante se pasan archivos por DOS carpetas: Android/media/<app> (funciona en Android 11+, donde el
# usuario shell no puede entrar en Android/data) y Android/data/<app>/files (la de siempre). Se escribe en las dos y
# se lee la mas reciente.
D1=/sdcard/Android/media/$APP
D2=/sdcard/Android/data/$APP/files
mkdir -p "$D1" 2>/dev/null
# edad en segundos del archivo mas reciente entre las dos carpetas; 9999 si no existe en ninguna
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
# apps de musica que se silencian de antemano al empezar la captura (evita un eco al iniciar la reproduccion)
KNOWN="com.aspiro.tidal com.spotify.music com.google.android.apps.youtube.music deezer.android.app com.amazon.mp3"
# nunca se silencian aunque suenen
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

# uid de apps con un reproductor de medios activo (MEDIA/GAME/UNKNOWN son los usos que captura CarAlign)
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

# paquetes de un uid (algunas versiones de Android no tienen "list packages --uid": respaldo con -U)
uid_pkgs() {
    r=$(cmd package list packages --uid "$1" 2>/dev/null | sed -n 's/^package:\([^ ]*\).*/\1/p')
    [ -z "$r" ] && r=$(pm list packages -U 2>/dev/null | sed -n "s/^package:\([^ ]*\) uid:$1\$/\1/p")
    echo "$r"
}

# silencia a las apps que suenan y deja en "players" cuantas son (la app lo usa para detectar capturas bloqueadas)
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
