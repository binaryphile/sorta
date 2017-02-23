Change Log
==========

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning], with the minor exception that v10 is considered
v0 in semver parlance.

[Unreleased]
------------

### Added

- dependency on [nano].bash added

### Changed

- the old `retx` suite of functions has been replaced with a single
  `ret` function, wrapping the "_ret" call from the [nano] library

- added direct-return options for `keys_of`, `values_of` and the `intox`
  suite of functions

### Deprecated

- the old "retx" functions

### Fixed

[v10.11.10] - 2017-02-23
------------------------

### Added

-   `import.bash` brought into project, but not documented

### Changed

-   Clarified README with better examples

[v10.10.11] - ??
----------------

### Added

-   Second release

  [Keep a Changelog]: http://keepachangelog.com/
  [Semantic Versioning]: http://semver.org/
  [Unreleased]: https://github.com/binaryphile/sorta/compare/v10.11.10...v11.10
  [v10.11.10]: https://github.com/binaryphile/sorta/compare/v10.10.11...v10.11.10
  [v10.10.11]: https://github.com/binaryphile/sorta/compare/v10.10.10...v10.10.11
  [nano]: https://github.com/binaryphile/nano
