Change Log
==========

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning], with the minor exception that v10 is considered
v0 in semver parlance.

[v11.10.12] - 2017-04-10
------------------------

### Added

-   bash 4.4 compatibility

### Changed

-   `all-shpecs` script echoes command before output instead of all at
    top

### Fixed

-   `all-shpecs` script invokes bash directly

[v11.10.11] - 2017-04-08
------------------------

### Added

-   Compatibility with Bash 4.3.11 (Ubuntu precise default, for Travis
    CI)

### Changed

-   prefer (()) to [let]

-   update license to 2017

[v11.10.10] - 2017-02-28
------------------------

### Added

-   dependency on [nano].bash added

-   ability to write libraries which allow importing of named functions
    with `import.bash`, and documentation

### Changed

-   the old `retx` suite of functions has been replaced with a single
    `ret` function, wrapping the `ret` call from the [nano] library

### Deprecated

-   the old `retx` functions

[v10.11.10] - 2017-02-23
------------------------

### Added

-   `import.bash` brought into project, but not documented

-   added changelog

### Changed

-   clarified README with better examples

[v10.10.11] - 2017-01-31
------------------------

### Added

-   second release

  [Keep a Changelog]: http://keepachangelog.com/
  [Semantic Versioning]: http://semver.org/
  [v11.10.12]: https://github.com/binaryphile/sorta/compare/v11.10.11...v11.10.12
  [v11.10.11]: https://github.com/binaryphile/sorta/compare/v11.10.10...v11.10.11
  [let]: http://wiki.bash-hackers.org/commands/builtin/let
  [v11.10.10]: https://github.com/binaryphile/sorta/compare/v10.11.10...v11.10.10
  [nano]: https://github.com/binaryphile/nano
  [v10.11.10]: https://github.com/binaryphile/sorta/compare/v10.10.11...v10.11.10
  [v10.10.11]: https://github.com/binaryphile/sorta/compare/v10.10.10...v10.10.11
