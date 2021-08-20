#!/bin/bash

SIZE_TYPE="GiB"
SIZE_TYPE_OPTIONS=(KB KiB MB MiB GB GiB TB TiB)
MAX_SIZE=2
CUT_SIZE=1
while getopts d:m:c:t: flag; do
  # shellcheck disable=SC2220
  case "${flag}" in
  d) DIRECTORY=${OPTARG} ;;
  m) MAX_SIZE=${OPTARG} ;;
  c) CUT_SIZE=${OPTARG} ;;
  t) SIZE_TYPE=${OPTARG} ;;
  esac
done

type_exists=$(echo "${SIZE_TYPE_OPTIONS[@]}" | grep -o $SIZE_TYPE | wc -w)

if [ "$type_exists" -eq "2" ]; then
  echo "Size Type [$SIZE_TYPE] Not Valid - Valid Types: ${SIZE_TYPE_OPTIONS[*]}"
  exit
fi
if [ -z ${DIRECTORY+x} ]; then
  echo "No Directory specified!"
  exit
else echo "Directory: $DIRECTORY"; fi

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

MAX_SIZE_BYTES=$(dehumanise $MAX_SIZE$SIZE_TYPE)
CUT_SIZE_BYTES=$(dehumanise $CUT_SIZE$SIZE_TYPE)
echo "MaxSize: $MAX_SIZE $SIZE_TYPE ($MAX_SIZE_BYTES Bytes)"
echo "Cutsize: $CUT_SIZE $SIZE_TYPE ($CUT_SIZE_BYTES Bytes)"

# Check Size of BACKUP_DIR
CURRENT_SIZE_BYTES=$(du -bs "$DIRECTORY" | cut -f1)
echo "Current Size $DIRECTORY: $CURRENT_SIZE_BYTES Bytes"
if [ $CURRENT_SIZE_BYTES -gt $MAX_SIZE_BYTES ]; then
  echo "Maximum Size $MAX_SIZE exceeded"
else
  echo "Maximum size not yet reached"
fi
