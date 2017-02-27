Change Log
==========

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning], with the minor exception that v10 is considered
v0 in semver parlance.

[Unreleased]
------------

### Added

-   dependency on [nano].bash added

-   ability to write libraries which allow importing of named functions
    with `import.bash`, and documentation

### Changed

-   the old `retx` suite of functions has been replaced with a single
    `ret` function, wrapping the "\_ret" call from the [nano] library

-   added direct-return options for `keys_of`, `values_of` and the
    `intox` suite of functions

-   README updated with instructions for running shpecs, basic
    contributing

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
  [Unreleased]: https://github.com/binaryphile/sorta/compare/v10.11.10...v11.10
  [nano]: https://github.com/binaryphile/nano
  [v10.11.10]: https://github.com/binaryphile/sorta/compare/v10.10.11...v10.11.10
  [v10.10.11]: https://github.com/binaryphile/sorta/compare/v10.10.10...v10.10.11
