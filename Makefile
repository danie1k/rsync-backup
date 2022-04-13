shellcheck:
	@find . -maxdepth 2 -name .git -type d -prune -o -type f -name \*.sh -print0 | xargs -0 -r -n1 shellcheck --enable=all --severity=warning --shell=bash --color=always
