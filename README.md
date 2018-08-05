A collections of SlackBuild scripts for my slackware installations.


More info about

slackware:
* https://www.slackware.com


slackbuilds:
* https://www.slackbuilds.org
* https://www.slackwiki.com/Writing_A_SlackBuild_Script


Quoting E. Hameleers:
A SlackBuild script is essentially just a small shell script
  * extracts the source code tarball
  * prepares the source code for compilation (compile options)
  * compiles the object code
  * installs it to a temporary "staging" directory
  * performs other needed operations (install documentation, compress man pages,
    add package description, etc.)
  * uses makepkg (8) to make a Slackware package of the application
