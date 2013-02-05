SemVer2 3.1.x gem, following semver.org 2.0.0-rc.1
======

quickstart on the command line
------------------------------
install it

    % gem install semver

use it

    % semver                    # => v2.3.4
    Find the .semver file and print a formatted string from this.

    % semver init
    Initialize the .semver file.

    % semver tag                # => v0.0.0
    Print the tag for the current .semver file.

    % semver inc minor          # => v0.1.0
    % semver special 'alpha.45' # => v0.1.0-alpha.45
    % semver format "%M.%m"     # => 0.1
    % git tag -a `semver tag`
    % say 'that was easy'

quickstart for ruby
-------------------

    require 'semver'
    v = SemVer.find
    v.major                     # => "0"
    v.major += 1
    v.major                     # => "1"
    v.special = 'alpha.46'
    v.format "%M.%m.%p%s"       # => "1.1.0-alpha.46"
    v.to_s                      # => "v1.1.0"
    v.save


git integration
---------------
    % git config --global alias.semtag '!git tag -a $(semver tag) -m "tagging $(semver tag)"'


existing 'SemVer' class from other gem?
---------------------------------------
You can now do this:

    require 'xsemver'
    v = XSemVer::SemVer.find
    # ...
    v.save

creds
-----
[Franco Lazzarino](mailto:flazzarino@gmail.com)
[Henrik Feldt](mailto:henrik@haf.se)
