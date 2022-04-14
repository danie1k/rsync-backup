bats:
	@./test/bats/bin/bats test/

bats-cov:
	@docker run -it --rm --workdir /github/workspace -v "$PWD":/github/workspace kcov/kcov:latest kcov --include-path src/ codecov/ ./test/bats/bin/bats test/

shellcheck:
	@find . -maxdepth 2 -name .git -type d -prune -o -type f \( -name \*.sh -or -name \*.bats -or -name \*.bash \) -print0 | xargs -0 -r -n1 shellcheck --enable=all --severity=warning --color=always
