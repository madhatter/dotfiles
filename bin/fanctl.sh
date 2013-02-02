#! /bin/bash

#
# Controls the fan speed for MacBook Pro
# It's best to background this script from rc.local
#

applesmc_path="/sys/devices/platform/applesmc.768"

# enable manual fan setting
echo 1 > ${applesmc_path}/fan1_manual

function set_fans()
{
    echo "$1" > ${applesmc_path}/fan1_output
}

function get_temp()
{
    local temp_no=7 # thermo number, closest to CPU
    local temp=$(cat ${applesmc_path}/temp${temp_no}_input)

    echo $((temp/1000))
}

function rpm_from_temp()
{
    local speed_min=2000 #$(cat ${applesmc_path}/fan1_min)
    local speed_max=6500 #$(cat ${applesmc_path}/fan1_max)
    local speed=$(($((200 * $1)) - 10000))

    if [[ $speed -lt $speed_min ]]; then
        speed=$speed_min
    elif [[ $speed -gt $speed_max ]]; then
        speed=$speed_max
    fi

    echo $speed
}

TT=$(get_temp)
ff=$(rpm_from_temp $TT)
while [ 1 ]
do
    T=$(get_temp)
    f=$(rpm_from_temp $T)
    
    set_fans $f
    printf '%s (%s) status: [ %i (%+i) C | %i (%+i) rpm ]\n' \
        "$0" "$(date)" $T $(($T-$TT)) $f $(($f-$ff))
    
    TT=$T
    ff=$f
    sleep 5
done
