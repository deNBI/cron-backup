#!/bin/bash

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}

log "Starting Backup Rotation Script"
BACKUP_ROTATION_SIZE_TYPE="${BACKUP_ROTATION_SIZE_TYPE:=GiB}"
BACKUP_ROTATION_SIZE_TYPE_OPTIONS=(MB MiB GB GiB TB TiB)
DIRECTORY="/etc/backup"
BACKUP_ROTATION_MAX_SIZE="${BACKUP_ROTATION_MAX_SIZE:=2}"
BACKUP_ROTATION_CUT_SIZE="${BACKUP_ROTATION_CUT_SIZE:=1}"
while getopts m:c:t: flag; do
  # shellcheck disable=SC2220
  case "${flag}" in
  m) BACKUP_ROTATION_MAX_SIZE=${OPTARG} ;;
  c) BACKUP_ROTATION_CUT_SIZE=${OPTARG} ;;
  t) BACKUP_ROTATION_SIZE_TYPE=${OPTARG} ;;
  esac
done

type_exists=$(echo "${BACKUP_ROTATION_SIZE_TYPE_OPTIONS[@]}" | grep -o $BACKUP_ROTATION_SIZE_TYPE | wc -w)

if [ "$type_exists" -ne "1" ]; then
  log "Size Type [$BACKUP_ROTATION_SIZE_TYPE] Not Valid - Valid Types: ${BACKUP_ROTATION_SIZE_TYPE_OPTIONS[*]}"
  exit
fi

if [ "$BACKUP_ROTATION_CUT_SIZE" -gt "$BACKUP_ROTATION_MAX_SIZE" ]; then
  log "Cutsize [$BACKUP_ROTATION_CUT_SIZE] can not be bigger than Maxsize [$BACKUP_ROTATION_MAX_SIZE]!"
  exit
fi

dehumanise() {
  for v in "${@:-$(</dev/stdin)}"; do
    echo $v | awk \
      'BEGIN{IGNORECASE = 1}
       function printpower(n,b,p) {printf "%u\n", n*b^p; next}
       /[0-9]$/{print $1;next};
       /KiB?$/{printpower($1,  2, 10)};
       /MiB?$/{printpower($1,  2, 20)};
       /GiB?$/{printpower($1,  2, 30)};
       /TiB?$/{printpower($1,  2, 40)};
       /KB$/{    printpower($1, 10,  3)};
       /MB$/{    printpower($1, 10,  6)};
       /GB$/{    printpower($1, 10,  9)};
       /TB$/{    printpower($1, 10, 12)}'
  done
}

log "Backup Directory: $DIRECTORY"
BACKUP_ROTATION_MAX_SIZE_BYTES=$(dehumanise $BACKUP_ROTATION_MAX_SIZE$BACKUP_ROTATION_SIZE_TYPE)
BACKUP_ROTATION_CUT_SIZE_BYTES=$(dehumanise $BACKUP_ROTATION_CUT_SIZE$BACKUP_ROTATION_SIZE_TYPE)
log "MaxSize: $BACKUP_ROTATION_MAX_SIZE $BACKUP_ROTATION_SIZE_TYPE ($BACKUP_ROTATION_MAX_SIZE_BYTES Bytes)"
log "Cutsize: $BACKUP_ROTATION_CUT_SIZE $BACKUP_ROTATION_SIZE_TYPE ($BACKUP_ROTATION_CUT_SIZE_BYTES Bytes)"

# Check Size of BACKUP_ROTATION_DIR
CURRENT_SIZE_KBYTES=$(du -ks "$DIRECTORY" | cut -f1)
CURRENT_SIZE_BYTES=$((CURRENT_SIZE_KBYTES * 1024))
log "Current Size: $CURRENT_SIZE_BYTES Bytes"

if [ $CURRENT_SIZE_BYTES -gt $BACKUP_ROTATION_MAX_SIZE_BYTES ]; then
  log "Maximum Size $BACKUP_ROTATION_MAX_SIZE_BYTES exceeded - Current Size $CURRENT_SIZE_BYTES"

  while [ $CURRENT_SIZE_BYTES -gt $BACKUP_ROTATION_CUT_SIZE_BYTES ]; do
    log "Cut Size $BACKUP_ROTATION_CUT_SIZE_BYTES exceeded - Current Size $CURRENT_SIZE_BYTES"
    CURRENT_SIZE_KBYTES=$(du -ks "$DIRECTORY" | cut -f1)
    CURRENT_SIZE_BYTES=$((CURRENT_SIZE_KBYTES * 1024))
    log "Current Size: $CURRENT_SIZE_BYTES Bytes"
    oldest_file=$DIRECTORY/$(ls -t $DIRECTORY | tail -1)
    log "Delete oldest Backup: $oldest_file"
    rm $oldest_file
  done
  log "Current size lower than cut size"

else
  log "Maximum size not yet reached"
fi
