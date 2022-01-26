#!/bin/bash

#;#############################################################################
#; Script Name  : ls-sstm.sh
#; Description  : a tool to list the min and max dates of records in a
#;                  directory of Cassandra SSTables. This is useful for
#;                  manually dropping old TWCS SSTables that don't have
#;                  a default TTL set.
#:
#; Args         : sstables_dir_path
#;                  the path to a Cassandra table directory with SSTables
#;
#; Author       : Loki Coyote
#; Email        : lokkju@gmail.com
#; License      : MIT
###############################################################################

shopt -s nullglob

CASSANDRA_HOME=${CASSANDRA_HOME:-/usr/local/cassandra}
PATH=$PATH:$CASSANDRA_HOME/tools/bin
hash env_parallel.bash 2>/dev/null || { echo >&2 "I require GNU parallel but it's not installed.  Aborting."; exit 1; }
hash sstablemetadata 2>/dev/null || { echo >&2 "I require sstablemetadata but it's not installed.  Try setting the CASSANDRA_HOME environment variable. Aborting."; exit 1; }


usage() {
    cat <<EOM
    Usage:
    $(basename $0) <cassandra table sstables directory path>

EOM
    exit 0
}

error() {
    printf "\nError: %s\n" "$1"
    exit 1
}
sstm_short () {
    f=$1
    meta=$(sstablemetadata $f 2>&1| grep -v WARN)
    max_date=$(date --date=@$(echo "$meta" | grep "Maximum time" | cut -d" "  -f3| cut -c 1-10) '+%Y-%m-%d')
    min_date=$(date --date=@$(echo "$meta" | grep "Minimum time" | cut -d" "  -f3| cut -c 1-10) '+%Y-%m-%d')
    droppable=$(echo "$meta" | grep droppable | awk '{print $4'})
    ls_data=$(ls -lh --time-style="+%Y-%m-%d" $f)
    fsize=$(echo "$ls_data" | awk '{print $5}')
    fmod=$(echo "$ls_data" | awk '{print $6}')
    printf "%10s %10s %9.2f %8s %10s %-s\n" $max_date $min_date $droppable $fsize $fmod $f
}

[ -z $1 ] && { usage; }
[[ ! -d $1 ]] && { usage; }

data_dir=$(realpath ${1})
echo "Attempting to read SSTables from $data_dir"
files=($data_dir/*Data.db)
file_num=0
for file in "${files[@]}"; do
    if [[ $file == *Data.db  ]]; then
        ((file_num++))
    fi
done
if [[ $file_num == 0 ]]; then
  error "Could not locate any SSTables in $data_dir"
fi

echo "Scanning $file_num SSTables"
. `which env_parallel.bash`
env_parset pout --will-cite --progress --eta --bar "sstm_short {}" ::: "${files[@]}"

printf "%10s %10s %9s %8s %10s %-s\n" "Max Date" "Min Date" "Droppable" "Size" "Modified" "Filename"
printf '%s\n' "${pout[@]}" | sort
