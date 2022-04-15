set -e
/bin/chmod a+x test/bin/*
exec kcov --include-path src/ codecov/ ./test/bats/bin/bats test/
