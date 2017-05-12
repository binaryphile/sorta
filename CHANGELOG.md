Change Log
==========

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning].

Latest Changes
==============

[Unreleased]
------------



[v1.0.4] - 2017-05-12
---------------------

### Changed

-   revert to normal versioning

[v1.0.2] - 2017-04-10
---------------------

### Added

-   bash 4.4 compatibility

### Changed

-   `all-shpecs` script echoes command before output instead of all at
    top

### Fixed

-   `all-shpecs` script invokes bash directly

Older Changes
=============

[v1.0.1] - 2017-04-08
---------------------

### Added

-   Compatibility with Bash 4.3.11 (Ubuntu precise default, for Travis
    CI)

### Changed

-   prefer (()) to [let]

-   update license to 2017

[v1.0.0] - 2017-02-28
---------------------

### Added

-   dependency on [nano].bash added

-   ability to write libraries which allow importing of named functions
    with `import.bash`, and documentation

### Changed

-   the old `retx` suite of functions has been replaced with a single
    `ret` function, wrapping the `ret` call from the [nano] library

### Deprecated

-   the old `retx` functions

[v0.3.0] - 2017-02-23
---------------------

### Added

-   `import.bash` brought into project, but not documented

-   added changelog

### Changed

-   clarified README with better examples

[v0.2.1] - 2017-01-31
---------------------

### Added

-   second release

  [Keep a Changelog]: http://keepachangelog.com/
  [Semantic Versioning]: http://semver.org/
  [Unreleased]: https://github.com/binaryphile/sorta/compare/v1.0.4...v1.0
  [v1.0.4]: https://github.com/binaryphile/sorta/compare/v1.0.2...v1.0.4
  [v1.0.2]: https://github.com/binaryphile/sorta/compare/v1.0.1...v1.0.2
  [v1.0.1]: https://github.com/binaryphile/sorta/compare/v1.0.0...v1.0.1
  [let]: http://wiki.bash-hackers.org/commands/builtin/let
  [v1.0.0]: https://github.com/binaryphile/sorta/compare/v0.3.0...v1.0.0
  [nano]: https://github.com/binaryphile/nano
  [v0.3.0]: https://github.com/binaryphile/sorta/compare/v0.2.1...v0.3.0
  [v0.2.1]: https://github.com/binaryphile/sorta/compare/v0.2.0...v0.2.1
