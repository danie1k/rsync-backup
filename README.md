[![Lint](https://github.com/danie1k/rsync-backup/actions/workflows/lint.yml/badge.svg)](https://github.com/danie1k/rsync-backup/actions/workflows/lint.yml)
[![Test](https://github.com/danie1k/rsync-backup/actions/workflows/test.yml/badge.svg)](https://github.com/danie1k/rsync-backup/actions/workflows/test.yml)
[![MIT License](https://img.shields.io/github/license/danie1k/rsync-backup)](https://github.com/danie1k/rsync-backup/blob/master/LICENSE)

# rsync-backup
A simple bash script wrapper for the rsync command


## Requirements

- `bash` (or any other bash-compatible shell; `sh`, `dash`, etc. are not supported)
- `dasel` (https://github.com/TomWright/dasel)
- `jq` (https://github.com/stedolan/jq)
- `rsync`
- `screen`
- `envsubst` (optional, a part of `gettext` package)


## Usage

```shell
$ ./rsync_offsite_backup.sh [OPTIONS]
```

### Options

| Argument    | Description                                         |
|-------------|-----------------------------------------------------|
| `-c string` | Path to config file for this job                    |
| `-d`        | Dry run                                             |
| `-l`        | Show list of the currently running jobs and exit    |
| `-n string` | Custom name of the job                              |
| `-h`        | Shows help                                          |


## Use case scenarios

### Starting new rsync job

```shell
$ ./rsync_offsite_backup.sh -c path/to/config.yml [-d] [-n]
```

### Getting list of currently active jobs

```shell
$ ./rsync_offsite_backup.sh -l
```

### Attaching to the screen of the active job

```shell
$ ./rsync_offsite_backup.sh -r
```


## License

[MIT](./LICENSE)
