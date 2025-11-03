#!/bin/bash

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}

log "Starting Backup Rotation Script"
BACKUP_ROTATION_SIZE_TYPE="${BACKUP_ROTATION_SIZE_TYPE:=GiB}"
BACKUP_ROTATION_SIZE_TYPE_OPTIONS=(MB MiB GB GiB TB TiB)
DIRECTORY="/etc/backup"
ENCRYPTED_DIRECTORY="/etc/encrypted"
UNENCRYPTED_DIRECTORY="/etc/unencrypted"

BACKUP_ROTATION_MAX_SIZE="${BACKUP_ROTATION_MAX_SIZE:=2}"
BACKUP_ROTATION_CUT_SIZE="${BACKUP_ROTATION_CUT_SIZE:=1}"
BACKUP_MAX_DATE="${BACKUP_MAX_DATE:=21}" # Default to 21 days

while getopts m:c:t: flag; do
  case "${flag}" in
    m) BACKUP_ROTATION_MAX_SIZE=${OPTARG} ;;
    c) BACKUP_ROTATION_CUT_SIZE=${OPTARG} ;;
    t) BACKUP_ROTATION_SIZE_TYPE=${OPTARG} ;;
    d) BACKUP_MAX_DATE=${OPTARG} ;;

  esac
done

type_exists=$(echo "${BACKUP_ROTATION_SIZE_TYPE_OPTIONS[@]}" | grep -o "$BACKUP_ROTATION_SIZE_TYPE" | wc -w)

if [ "$type_exists" -ne "1" ]; then
  log "Size Type [$BACKUP_ROTATION_SIZE_TYPE] Not Valid - Valid Types: ${BACKUP_ROTATION_SIZE_TYPE_OPTIONS[*]}"
  exit 1
fi

if [ "$BACKUP_ROTATION_CUT_SIZE" -gt "$BACKUP_ROTATION_MAX_SIZE" ]; then
  log "Cutsize [$BACKUP_ROTATION_CUT_SIZE] cannot be bigger than Maxsize [$BACKUP_ROTATION_MAX_SIZE]!"
  exit 1
fi

convert_bytes_to_unit() {
  local bytes="$1"
  local unit="$2"
  case "$unit" in
    KiB|kib|Ki|ki) echo $((bytes / 1024)) ;;
    MiB|mib|Mi|mi) echo $((bytes / 1024 / 1024)) ;;
    GiB|gib|Gi|gi) echo $((bytes / 1024 / 1024 / 1024)) ;;
    TiB|tib|Ti|ti) echo $((bytes / 1024 / 1024 / 1024 / 1024)) ;;
    KB|kb)         echo $((bytes / 1000)) ;;
    MB|mb)         echo $((bytes / 1000 / 1000)) ;;
    GB|gb)         echo $((bytes / 1000 / 1000 / 1000)) ;;
    TB|tb)         echo $((bytes / 1000 / 1000 / 1000 / 1000)) ;;
    *)             echo "$bytes" ;;
  esac
}

auto_human_readable() {
  local bytes="$1"
  if [ "$bytes" -ge $((1024**3)) ]; then
    echo "$((bytes / 1024 / 1024 / 1024)) GiB"
  elif [ "$bytes" -ge $((1024**2)) ]; then
    echo "$((bytes / 1024 / 1024)) MiB"
  elif [ "$bytes" -ge 1024 ]; then
    echo "$((bytes / 1024)) KiB"
  else
    echo "$bytes Bytes"
  fi
}

dehumanise() {
  for v in "${@:-$(</dev/stdin)}"; do
    echo "$v" | awk '
      BEGIN{IGNORECASE = 1}
      function printpower(n,b,p) {printf "%u\n", n*b^p; next}
      /[0-9]$/{print $1; next};
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

rotate_directory() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    log "Directory '$dir' does not exist - skipping."
    return
  fi

  log "Checking directory: $dir"

  BACKUP_ROTATION_MAX_SIZE_BYTES=$(dehumanise "$BACKUP_ROTATION_MAX_SIZE$BACKUP_ROTATION_SIZE_TYPE")
  BACKUP_ROTATION_CUT_SIZE_BYTES=$(dehumanise "$BACKUP_ROTATION_CUT_SIZE$BACKUP_ROTATION_SIZE_TYPE")

  log "MaxSize: $BACKUP_ROTATION_MAX_SIZE $BACKUP_ROTATION_SIZE_TYPE ($BACKUP_ROTATION_MAX_SIZE_BYTES Bytes)"
  log "Cutsize: $BACKUP_ROTATION_CUT_SIZE $BACKUP_ROTATION_SIZE_TYPE ($BACKUP_ROTATION_CUT_SIZE_BYTES Bytes)"
  FILES_BEFORE=$(find "$dir" -maxdepth 1 -type f  | wc -l)

  # Delete old files
  find "$dir" -maxdepth 1 -type f -mtime +"$BACKUP_MAX_DATE" -delete

  # Count files after deletion
  FILES_AFTER=$(find "$dir" -maxdepth 1 -type f  | wc -l)

  # Calculate the number of deleted files
  FILES_DELETED=$((FILES_BEFORE - FILES_AFTER))
  
  log "Deleted $FILES_DELETED files older than $BACKUP_MAX_DATE days."
  log "Kept $FILES_AFTER files newer than $BACKUP_MAX_DATE days."
  CURRENT_SIZE_KBYTES=$(du -ks "$dir" | cut -f1)
  CURRENT_SIZE_BYTES=$((CURRENT_SIZE_KBYTES * 1024))

  CURRENT_SIZE_HUMAN=$(auto_human_readable "$CURRENT_SIZE_BYTES")
  CURRENT_MAX_HUMAN=$(auto_human_readable "$BACKUP_ROTATION_MAX_SIZE_BYTES")
  CURRENT_CUT_HUMAN=$(auto_human_readable "$BACKUP_ROTATION_CUT_SIZE_BYTES")

  log "Current Size: $CURRENT_SIZE_BYTES Bytes ($CURRENT_SIZE_HUMAN) -- Max Size: $BACKUP_ROTATION_MAX_SIZE_BYTES Bytes ($CURRENT_MAX_HUMAN) -- Cut Size: $BACKUP_ROTATION_CUT_SIZE_BYTES Bytes ($CURRENT_CUT_HUMAN)"

  if [ "$CURRENT_SIZE_BYTES" -gt "$BACKUP_ROTATION_MAX_SIZE_BYTES" ]; then
    log "Maximum Size $BACKUP_ROTATION_MAX_SIZE_BYTES exceeded - Current Size $CURRENT_SIZE_BYTES"

    while [ "$CURRENT_SIZE_BYTES" -gt "$BACKUP_ROTATION_CUT_SIZE_BYTES" ]; do
      log "Cut Size $BACKUP_ROTATION_CUT_SIZE_BYTES exceeded - Current Size $CURRENT_SIZE_BYTES"

      oldest_file=$(find "$dir" -maxdepth 1 -type f -print0 | xargs -0 ls -t | tail -1)

      log "$oldest_file"
      log "Delete oldest Backup: $oldest_file"
      rm -f "$oldest_file"

      CURRENT_SIZE_KBYTES=$(du -ks "$dir" | cut -f1)
      CURRENT_SIZE_BYTES=$((CURRENT_SIZE_KBYTES * 1024))
      CURRENT_SIZE_HUMAN=$(auto_human_readable "$CURRENT_SIZE_BYTES")

      log "Current Size: $CURRENT_SIZE_BYTES Bytes ($CURRENT_SIZE_HUMAN)"
    done

    log "Current size [$CURRENT_SIZE_HUMAN] lower than cut size [$CURRENT_CUT_HUMAN]"
  else
    log "Maximum [$CURRENT_MAX_HUMAN] size not yet reached"
  fi
}

# Rotate directories
rotate_directory "$DIRECTORY"
rotate_directory "$ENCRYPTED_DIRECTORY"
rotate_directory "$UNENCRYPTED_DIRECTORY"
