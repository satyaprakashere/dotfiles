# PostgreSQL Homebrew Installation Hints

This formula has created a default database cluster with:
  initdb --locale=C -E UTF-8 /opt/homebrew/var/postgresql@17

When uninstalling, some dead symlinks are left behind so you may want to run:
  brew cleanup --prune-prefix

postgresql@17 is keg-only, which means it was not symlinked into /opt/homebrew,
because this is an alternate version of another formula.

If you need to have postgresql@17 first in your PATH, run:
  fish_add_path /opt/homebrew/opt/postgresql@17/bin

For compilers to find postgresql@17 you may need to set:
  set -gx LDFLAGS "-L/opt/homebrew/opt/postgresql@17/lib"
  set -gx CPPFLAGS "-I/opt/homebrew/opt/postgresql@17/include"

To start postgresql@17 now and restart at login:
  brew services start postgresql@17
Or, if you don't want/need a background service you can just run:
  LC_ALL="C" /opt/homebrew/opt/postgresql@17/bin/postgres -D /opt/homebrew/var/postgresql@17
==> Summary
🍺  /opt/homebrew/Cellar/postgresql@17/17.6: 3,821 files, 72.0MB
==> Running `brew cleanup postgresql@17`...
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
==> No outdated dependents to upgrade!
==> Caveats
==> postgresql@17
This formula has created a default database cluster with:
  initdb --locale=C -E UTF-8 /opt/homebrew/var/postgresql@17

When uninstalling, some dead symlinks are left behind so you may want to run:
  brew cleanup --prune-prefix

postgresql@17 is keg-only, which means it was not symlinked into /opt/homebrew,
because this is an alternate version of another formula.

If you need to have postgresql@17 first in your PATH, run:
  fish_add_path /opt/homebrew/opt/postgresql@17/bin

For compilers to find postgresql@17 you may need to set:
  set -gx LDFLAGS "-L/opt/homebrew/opt/postgresql@17/lib"
  set -gx CPPFLAGS "-I/opt/homebrew/opt/postgresql@17/include"

To start postgresql@17 now and restart at login:
  brew services start postgresql@17
Or, if you don't want/need a background service you can just run:
  LC_ALL="C" /opt/homebrew/opt/postgresql@17/bin/postgres -D /opt/homebrew/var/postgresql@17
