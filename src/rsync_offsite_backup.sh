#!/bin/bash
set -eu -o pipefail
shopt -s failglob

readonly SELF="${0}"
readonly PID=$$
readonly _PREFIX='rsync:'
readonly _VERSION='2022.02'

_error() { echo "ERROR: ${*}" >&2; }
_out() { echo "${*}"; }

#
# Defaults
#
DRY_RUN_FLAG=0
LIST_ONLY_FLAG=0

CONFIG_FILE=""
DEFAULT_INFO="progress2"
JOB_NAME="${_PREFIX}${PID}"
RSYNC_OPTIONS=(
  #--8-bit-output           # leave high-bit chars unescaped in output
  #--acls                   # preserve ACLs (implies --perms)
  #--address=ADDRESS        # bind address for outgoing socket to daemon
  #--append                 # append data onto shorter files
  #--append-verify          # --append w/old data in file checksum
  #--archive                # archive mode; equals: '--devices --group --links --owner --perms --recursive --specials --times'
  #--atimes                 # preserve access (use) times
  #--backup                 # make backups (see --suffix & --backup-dir)
  #--backup-dir=DIR         # make backups into hierarchy based in DIR
  #--block-size=SIZE        # force a fixed checksum block-size
  #--blocking-io            # use blocking I/O for the remote shell
  #--bwlimit=RATE           # limit socket I/O bandwidth
  #--checksum               # skip based on checksum, not mod-time & size
  #--checksum-choice=STR    # choose the checksum algorithm
  #--checksum-seed=NUM      # set block/file checksum seed (advanced)
  #--chmod=CHMOD            # affect file and/or directory permissions
  #--chown=USER:GROUP       # simple username/groupname mapping
  #--compare-dest=DIR       # also compare destination files relative to DIR
  --compress                # compress file data during the transfer
  #--compress-choice=STR    # choose the compression algorithm
  #--compress-level=NUM     # explicitly set compression level
  #--contimeout=SECONDS     # set daemon connection timeout in seconds
  #--copy-as=USER[:GROUP]   # specify user & optional group for the copy
  #--copy-dest=DIR          # ... and include copies of unchanged files
  #--copy-dirlinks          # transform symlink to dir into referent dir
  #--copy-links             # transform symlink into referent file/dir
  #--copy-unsafe-links      # only "unsafe" symlinks are transformed
  #--crtimes                # preserve create times (newness)
  #--cvs-exclude            # auto-ignore files in the same way CVS does
  #--debug=FLAGS            # fine-grained debug verbosity
  #--delay-updates          # put all updated files into place at end
  --delete                  # delete extraneous files from dest dirs
  #--delete-after           # receiver deletes after transfer, not during
  #--delete-before          # receiver deletes before xfer, not during
  #--delete-delay           # find deletions during, delete after
  #--delete-during          # receiver deletes during the transfer
  --delete-excluded         # also delete excluded files from dest dirs
  #--delete-missing-args    # delete missing source args from destination
  --devices                 # preserve device files (super-user only)
  #--dirs                   # transfer directories without recursing
  #--early-input=FILE       # use FILE for daemon's early exec input
  #--executability          # preserve executability
  #--existing               # skip creating new files on receiver
  #--fake-super             # store/recover privileged attrs using xattrs
  #--files-from=FILE        # read list of source-file names from FILE
  #--filter=RULE            # add a file-filtering RULE
  #--force                  # force deletion of dirs even if not empty
  #--from0                  # all *-from/filter files are delimited by 0s
  #--fuzzy                  # find similar file for basis if no dest file
  #--group                  # preserve group
  #--groupmap=STRING        # custom groupname mapping
  #--hard-links             # preserve hard links
  --human-readable          # output numbers in a human-readable format
  #--iconv=CONVERT_SPEC     # request charset conversion of filenames
  #--ignore-errors          # delete even if there are I/O errors
  #--ignore-existing        # skip updating files that exist on receiver
  #--ignore-missing-args    # ignore missing source args without error
  #--ignore-times           # don't skip files that match size and time
  #--include-from=FILE      # read include patterns from FILE
  #--include=PATTERN        # don't exclude files matching PATTERN
  #--inplace                # update destination files in-place
  #--keep-dirlinks          # treat symlinked dir on receiver as dir
  #--link-dest=DIR          # hardlink to files in DIR when unchanged
  --links                   # copy symlinks as symlinks
  #--list-only              # list the files instead of copying them
  #--log-file-format=FMT    # log updates using the specified FMT
  #--log-file=FILE          # log what we're doing to the specified FILE
  #--max-alloc=SIZE         # change a limit relating to memory alloc
  #--max-delete=NUM         # don't delete more than NUM files
  #--max-size=SIZE          # don't transfer any file larger than SIZE
  #--min-size=SIZE          # don't transfer any file smaller than SIZE
  #--mkpath                 # create the destination's path component
  #--modify-window=NUM      # set the accuracy for mod-time comparisons
  #--munge-links            # munge symlinks to make them safe & unusable
  #--no-OPTION              # turn off an implied OPTION (e.g. --no-D)
  #--no-implied-dirs        # don't send implied dirs with --relative
  #--no-motd                # suppress daemon-mode MOTD
  #--numeric-ids            # don't map uid/gid values by user/group name
  #--omit-dir-times         # omit directories from --times
  #--omit-link-times        # omit symlinks from --times
  #--one-file-system        # don't cross filesystem boundaries
  #--only-write-batch=FILE  # like --write-batch but w/o updating dest
  #--open-noatime           # avoid changing the atime on opened files
  #--out-format=FORMAT      # output updates using the specified FORMAT
  #--outbuf=N|L|B           # set out buffering to None, Line, or Block
  #--owner                  # preserve owner (super-user only)
  #--partial                # keep partially transferred files
  #--partial-dir=DIR        # put a partially transferred file into DIR
  #--password-file=FILE     # read daemon-access password from FILE
  --perms                   # preserve permissions
  #--port=PORT              # specify double-colon alternate port number
  #--preallocate            # allocate dest files before writing them
  #--progress               # show progress during transfer
  #--protect-args           # no space-splitting; wildcard chars only
  #--protocol=NUM           # force an older protocol version to be used
  #--prune-empty-dirs       # prune empty directory chains from file-list
  #--quiet                  # suppress non-error messages
  #--read-batch=FILE        # read a batched update from FILE
  --recursive               # recurse into directories
  #--relative               # use relative path names
  #--remote-option=OPT      # send OPTION to the remote side only
  #--remove-source-files    # sender removes synchronized files (non-dir)
  #--rsync-path=PROGRAM     # specify the rsync to run on remote machine
  #--safe-links             # ignore symlinks that point outside the tree
  #--size-only              # skip files that match in size
  #--skip-compress=LIST     # skip compressing files with suffix in LIST
  #--sockopts=OPTIONS       # specify custom TCP options
  #--sparse                 # turn sequences of nulls into sparse blocks
  --specials                # preserve special files
  --stats                   # give some file-transfer stats
  #--stderr=e|a|c           # change stderr output mode (default: errors)
  #--stop-after=MINS        # Stop rsync after MINS minutes have elapsed
  #--stop-at=y-m-dTh:m      # Stop rsync at the specified point in time
  #--suffix=SUFFIX          # backup suffix (default ~ w/o --backup-dir)
  #--super                  # receiver attempts super-user activities
  #--temp-dir=DIR           # create temporary files in directory DIR
  #--timeout=SECONDS        # set I/O timeout in seconds
  --times                   # preserve modification times
  #--update                 # skip files that are newer on the receiver
  #--usermap=STRING         # custom username mapping
  #--verbose                # increase verbosity
  #--whole-file             # copy files whole (w/o delta-xfer algorithm)
  #--write-batch=FILE       # write a batched update to FILE
  #--write-devices          # write to devices as files (implies --inplace)
  #--xattrs                 # preserve extended attributes
)

function check_prerequisites() {
  local required_commands=(dasel jq rsync screen)

  for command_name in "${required_commands[@]}"; do
    # shellcheck disable=SC2248
    if ! which ${command_name} 1>/dev/null 2>&1; then
      _error "${command_name} is not available or not in your PATH." \
             "Please install ${command_name} and try again."
      exit 1
    fi
  done
}


function print_usage() {
  _out "Usage: ${SELF} [OPTIONS]"
  _out
  _out "Options:"
  _out "  -c FILE     Path to config file for this job"
  _out "  -d          Dry run"
  _out "  -l          Show list of the currently running jobs and exit"
  _out "  -n NAME     Custom name of the job"
  _out "  -h          Shows this help"
  _out
  _out "Version ${_VERSION}"
}


return 0  # FIXME: Remove


[ $# -eq 0 ] && usage && exit 1

while getopts ":c:dhln:" opt
do
  case "${opt}" in
    c)
      readonly CONFIG_FILE="${OPTARG}"
      ;;
    d)
      readonly DRY_RUN_FLAG=1
      ;;
    l)
      readonly LIST_ONLY_FLAG=1
      ;;
    n)
      readonly JOB_NAME="${_PREFIX}${OPTARG}"
      ;;
    h|*)
      usage
      exit 1
      ;;
  esac
done


#
# Get/show current jobs
#
screen -wipe 1>/dev/null 2>&1 || true
readonly ACTIVE_SCREEN_SESSIONS="$(screen -list | grep 'Detached' | grep "${_PREFIX}" | awk '{print $1}')"

# shellcheck disable=SC2248,SC2250
if [ $LIST_ONLY_FLAG -eq 1 ]
then
  if [ -z "${ACTIVE_SCREEN_SESSIONS}" ]
  then
    echo 'No active rsync jobs'
    exit 0
  fi

  _printf_line='                                            '
  _reattach_cmd="rsync -r <job_name>"
  echo "┌────────────────────────────────────────────────────────────────────────────┐"
  echo "│                      CURRENTLY ACTIVE RSYNC SESSIONS                       │"
  echo "├────────────────────────────────────────────────────────────────────────────┤"
  printf "│ To attach to the session run: %s%s │\n" "${_reattach_cmd}" "${_printf_line:${#_reattach_cmd}}"
  echo "└────────────────────────────────────────────────────────────────────────────┘"

  # shellcheck disable=SC2068
  for job_name in ${ACTIVE_SCREEN_SESSIONS[@]}
  do
    echo "${job_name}"
  done
  exit 0
fi


#
# Read config
#
if [[ ! -r "${CONFIG_FILE}" ]]
then
  echo "ERROR: Given config file path is invalid: '${CONFIG_FILE}'" >&2
  exit 1
fi

if which envsubst 1>/dev/null 2>&1
then
  readonly _CONF="$(envsubst < "${CONFIG_FILE}")"
else
  readonly _CONF="$(cat "${CONFIG_FILE}")"
fi

readonly SSH_KEY="$(echo "${_CONF}" | dasel --null -c '.ssh.key' -p yaml 2>/dev/null)"
readonly SSH_HOST="$(echo "${_CONF}" | dasel --null -c '.ssh.host' -p yaml 2>/dev/null)"
readonly SSH_PORT="$(echo "${_CONF}" | dasel --null -c '.ssh.port' -p yaml 2>/dev/null)"
readonly SSH_USER="$(echo "${_CONF}" | dasel --null -c '.ssh.user' -p yaml 2>/dev/null)"

readonly PATH_SOURCE="$(echo "${_CONF}" | dasel --null -c '.path.source' -p yaml 2>/dev/null)"
readonly PATH_REMOTE="$(echo "${_CONF}" | dasel --null -c '.path.remote' -p yaml 2>/dev/null)"

for var_name in SSH_KEY SSH_HOST SSH_PORT SSH_USER PATH_SOURCE PATH_REMOTE
do
  if [[ "${!var_name}" == '' ]]
  then
    echo "ERROR: Config file syntax is invalid." >&2
    exit 1
  fi
done


#
# Parse ssh connection parameters
#
RSYNC_OPTIONS+=(
  --rsh
  "ssh -p ${SSH_PORT} -i $(printf '%q' "${SSH_KEY}")"
)


#
# Parse info flags
#
readonly info_json="$(echo "${_CONF}" | dasel -c -p yaml -r yaml -w json '.rsync.info' 2>/dev/null || echo "[\"${DEFAULT_INFO}\"]")"

RSYNC_OPTIONS+=(
  --info                      # fine-grained informational verbosity
  "$(echo "${info_json}" | jq -r '. | join(",")' 2>/dev/null || echo "${DEFAULT_INFO}")"
)


#
# Dry run parameters
#
# shellcheck disable=SC2248,SC2250
if [ $DRY_RUN_FLAG -eq 1 ]
then
  RSYNC_OPTIONS+=(
    --itemize-changes         # output a change-summary for all updates
    --dry-run                 # perform a trial run with no changes made
  )
else
  RSYNC_OPTIONS+=()
fi


#
# Finally, tell rsync about paths to transfer
#
RSYNC_OPTIONS+=(
  "$(printf '%q' "${PATH_SOURCE}")"
  "${SSH_USER}@${SSH_HOST}:$(printf '%q' "${PATH_REMOTE}")"
)


#
# Print nice header
#
_printf_line='                                                            '
# shellcheck disable=SC2250
_dry_run="$([[ $DRY_RUN_FLAG -eq 1 ]] && echo 'yes' || echo 'no')"
_remote_target="${SSH_USER}@${SSH_HOST}:${PATH_REMOTE}"
echo "┌────────────────────────────────────────────────────────────────────────────┐"
echo "│                           STARTING RSYNC SESSION                           │"
echo "├────────────────────────────────────────────────────────────────────────────┤"
printf "│ Job name:      %s%s│\n" "${JOB_NAME}" "${_printf_line:${#JOB_NAME}}"
printf "│ Dry run:       %s%s│\n" "${_dry_run}" "${_printf_line:${#_dry_run}}"
printf "│ Local source:  %s%s│\n" "${PATH_SOURCE}" "${_printf_line:${#PATH_SOURCE}}"
printf "│ Remote target: %s%s│\n" "${_remote_target}" "${_printf_line:${#_remote_target}}"
echo "└────────────────────────────────────────────────────────────────────────────┘"


#
# Dry run message
#
# shellcheck disable=SC2248,SC2250
if [ $DRY_RUN_FLAG -eq 1 ]
then
  echo $'\nThe following command will be executed:\n'

  echo "${RSYNC_OPTIONS[0]}"
  for (( i=1; i<${#RSYNC_OPTIONS[@]}; i++ ))
  do
    echo -n "  ${RSYNC_OPTIONS[$i]}"

    if {
      [[ "${RSYNC_OPTIONS[$i]}" == --rsh ]] \
      || [[ "${RSYNC_OPTIONS[$i]}" == --exclude* ]] \
      || [[ "${RSYNC_OPTIONS[$i]}" == --info ]]
    }
    then
      echo " '${RSYNC_OPTIONS[(( i + 1 ))]}'"
      (( i = i + 1 ))
    else
      echo
    fi
  done

  read -rsp $'\nPress any key to continue...\n' -n1 _
fi


#
# Execute rsync
#
echo -n 'Starting rsync... '
screen -dmU -S "${JOB_NAME}" -t "${JOB_NAME}" "$(which --skip-alias --skip-functions rsync)" "${RSYNC_OPTIONS[@]}"
echo 'Done.'
