SemVer2 3.4.x gem, following semver.org 2.0.0
======

[![Gem Version](https://badge.fury.io/rb/semver2.svg)](https://rubygems.org/gems/semver2)
[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/semver2/)
[![Build Status](http://badges.herokuapp.com/travis/haf/semver?label=build&branch=master)](https://travis-ci.org/haf/semver)

Sponsored by
[qvitoo – A.I. bookkeeping](https://qvitoo.com/?utm_source=github&utm_campaign=repos).

quickstart on the command line
------------------------------
install it

```shell
gem install semver2
```

use it

```shell
# Find the .semver file and print a formatted string from this.
semver                    # => v2.3.4

# Initialize the .semver file.
semver init

# Print the tag for the current .semver file.
semver tag                # => v0.0.0

semver inc minor          # => v0.1.0
semver pre 'alpha.45'     # => v0.1.0-alpha.45
semver meta 'md5.abc123'  # => v0.1.0-alpha.45+md5.abc123
semver format "%M.%m"     # => 0.1
git tag -a `semver tag`
say 'that was easy'
```

quickstart for ruby
-------------------

```ruby
require 'semver'
v = SemVer.find
v.major                     # => "0"
v.major += 1
v.major                     # => "1"
v.prerelease = 'alpha.46'
v.metadata = 'md5.abc123'
v.format "%M.%m.%p%s%d"     # => "1.1.0-alpha.46+md5.abc123"
v.to_s                      # => "v1.1.0-alpha.46+md5.abc123"
v.save
```
parsing in ruby
---------------

```ruby
 require 'semver'
 v = SemVer.parse 'v1.2.3-rc.56'
 v = SemVer.parse_rubygems '2.0.3.rc.2'
```

git integration
---------------

```shell
git config --global alias.semtag '!git tag -a $(semver tag) -m "tagging $(semver tag)"'
```

existing 'SemVer' class from other gem?
---------------------------------------
You can now do this:

```ruby
require 'xsemver'
v = XSemVer::SemVer.find
# ...
v.save
```

creds
-----
* [Franco Lazzarino](mailto:flazzarino@gmail.com)
* [Henrik Feldt](mailto:henrik@haf.se)
* [James Childress](mailto:james@childr.es)
