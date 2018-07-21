if ! lsmod | grep tuxedo_keyboard ; then
	echo "ERROR: kernel module 'tuxedo_keyboard' not loaded. Can't run"
	exit 1
fi

RED="0xff0000"
HRED="0xbb2211"
BLACK="0x000000"

K_LEFT="/sys/devices/platform/tuxedo_keyboard/color_left"
K_CENTER="/sys/devices/platform/tuxedo_keyboard/color_center"
K_RIGHT="/sys/devices/platform/tuxedo_keyboard/color_right"
K_BRIGHT="/sys/devices/platform/tuxedo_keyboard/brightness"
K_MODE="/sys/devices/platform/tuxedo_keyboard/mode"

SLEEP=0.3

declare -A OLD
OLD=(["left"]=$(cat $K_LEFT)
     ["center"]=$(cat $K_CENTER)
     ["right"]=$(cat $K_RIGHT)
     ["bright"]=$(cat $K_BRIGHT)
     ["mode"]=$(cat $K_MODE)
)

declare -A states
states=(["200"]="left_on"
	["020"]="center_on"
	["002"]="right_on"
	["120"]="lh_center_on"
	["012"]="ch_right_on"
	["021"]="rh_center_on"
	["210"]="ch_left_on"
	["100"]="lh_on"
)

function restore_old_status {
	echo "0x${OLD["left"]}"   > $K_LEFT
	echo "0x${OLD["center"]}" > $K_CENTER
	echo "0x${OLD["right"]}"  > $K_RIGHT
	echo ${OLD["bright"]} > $K_BRIGHT
	echo ${OLD["mode"]}   > $K_MODE
}
function left_on {
	echo "$RED"   > $K_LEFT
	echo "$BLACK" > $K_CENTER
	echo "$BLACK" > $K_RIGHT
}
function center_on {
	echo "$BLACK" > $K_LEFT
	echo "$RED"   > $K_CENTER
	echo "$BLACK" > $K_RIGHT
}
function right_on {
	echo "$BLACK" > $K_LEFT
	echo "$BLACK" > $K_CENTER
	echo "$RED"   > $K_RIGHT
}
function lh_center_on {
	echo "$HRED"  > $K_LEFT
	echo "$RED"   > $K_CENTER
	echo "$BLACK" > $K_RIGHT
}
function ch_right_on {
	echo "$BLACK" > $K_LEFT
	echo "$HRED"  > $K_CENTER
	echo "$RED"   > $K_RIGHT
}
function rh_center_on {
	echo "$BLACK" > $K_LEFT
	echo "$RED"   > $K_CENTER
	echo "$HRED"  > $K_RIGHT
}
function ch_left_on {
	echo "$RED"   > $K_LEFT
	echo "$HRED"  > $K_CENTER
	echo "$BLACK" > $K_RIGHT
}
function all_color {
	local color=$1
	echo "$color" > $K_LEFT
	echo "$color" > $K_CENTER
	echo "$color" > $K_RIGHT
}
function lh_on {
	echo "$HRED"  > $K_LEFT
	echo "$BLACK" > $K_CENTER
	echo "$BLACK" > $K_RIGHT
}
function all_black {
	all_color $BLACK
}
function pause {
	sleep $SLEEP
}
function dec2hex {
	printf '%02x' $1
}
function random_hex {
	local parts=${1-2}
	dec2hex $(( RANDOM % $parts * 255 / $((parts-1)) ))
}
function random_color {
	local parts=${1-2}
	local r=$(random_hex $parts)
	local g=$(random_hex $parts)
	local b=$(random_hex $parts)
	echo "0x$r$g$b"
}

function go_sequence {
	LOOPS=20
	SLEEP=0.3
	sequence=( 200 020 002 020 )
	while [ $LOOPS -gt 0 ]; do
		for i in "${sequence[@]}"; do
			${states[$i]}
			pause
		done
		LOOPS=$((LOOPS-1))
	done
	left_on
	pause
	all_black
	sleep 1
	restore_old_status
}

function go_smooth_sequence {
	LOOPS=15
	SLEEP=0.2
        sequence=( 200 120 012 002 021 210 )
	while [ $LOOPS -gt 0 ]; do
		for i in "${sequence[@]}"; do
			${states[$i]}
			pause

			[[ "x$i" == "x200" ]] && sleep 0.2
			[[ "x$i" == "x002" ]] && sleep 0.15
		done
		LOOPS=$((LOOPS-1))
	done
	lh_on
	pause
	all_black
	sleep 1
	restore_old_status
}

function go_rainbow {
	LOOPS=50
	SLEEP=0.2
	while [ $LOOPS -gt 0 ]; do
		L_COLOR=$(random_color)
		C_COLOR=$(random_color)
		R_COLOR=$(random_color)
		# echo $L_COLOR $C_COLOR $R_COLOR
		echo "$L_COLOR" > $K_LEFT
		echo "$C_COLOR" > $K_CENTER
		echo "$R_COLOR" > $K_RIGHT
		pause
		LOOPS=$((LOOPS-1))
	done
	all_black
	sleep 1
	restore_old_status
}

function go_reset {
	echo 0x00FF00 > $K_LEFT
	echo 0x00FF00 > $K_CENTER
	echo 0x00FF00 > $K_RIGHT
	echo 125 > $K_BRIGHT
	echo 0 > $K_MODE
}

case "${1}" in
	simple_scan)
		go_sequence
		;;
	scan)
		go_smooth_sequence
		;;
	rainbow)
		go_rainbow
		;;
	reset)
		go_reset
		;;
	*)
		echo "Usage: ${0} {scan|simple_scan|rainbow|reset}"
		exit 1
		;;
esac

