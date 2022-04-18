exec find . -maxdepth 2 -name .git -type d -prune -o \
  -type f \( -name \*.sh -or -name \*.bats -or -name \*.bash \) -print0 \
  | xargs -0 -r -n1 \
    shellcheck --enable=all --severity=warning --color=never --format gcc
