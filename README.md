# leeloo [![Gem Version](https://badge.fury.io/rb/leeloo.svg)](https://badge.fury.io/rb/leeloo)
collaborative password manager

![multi pass](https://media.giphy.com/media/dVneNbpJiD2AU/giphy.gif)

Leeloo known as the 5th element is a humble clone of [password-store](https://www.passwordstore.org/) _(and compatible with it)_ written in Ruby with ambition to offer a powerful collaborative password manager.

Leeloo is based on [GPG](https://gnupg.org/) and [Git](https://git-scm.com/). _(you need a private GPG key ! - [more details here](https://www.gnupg.org/gph/en/manual/c14.html))_

## How to install leeloo ?

### On Linux

```
$> sudo apt install ruby ruby-dev ruby-gpgme
$> sudo gem install leeloo
```

### On Macos

```
$> brew tap sylvek/leeloo-brew
$> brew install leeloo
# on Intel
$> echo "pinentry-program /usr/local/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf
# on Apple M1
# ensure `/opt/homebrew/opt/ruby/bin` is set at the begining of your $PATH
# ruby3 is mandatory
$> echo "pinentry-program /opt/homebrew/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf
$> gem install leeloo
```

if some troubles with gpgme => `gem install gpgme -- --use-system-libraries`

## How to setup it ?

```
# if necessary, configure GIT
$> git config --global user.email "you@example.com"
$> git config --global user.name "Your Name"

# if necessary, create a private GPG key
$> gpg2 --gen-key
```

## How to use it ?

```
$> leeloo
# will create your first keystore (stored in ~/.leeloo/private)

$> leeloo keystore
# will display all your keystores
+-------+------------------------------+-------+
|Name   |Path                          |Default|
+-------+------------------------------+-------+
|private|/Users/sylvek/.leeloo/private |*      |
+-------+------------------------------+-------+

$> leeloo keystore add test ~/test
# will add test keystore
+-------+------------------------------+-------+
|Name   |Path                          |Default|
+-------+------------------------------+-------+
|private|/Users/sylvek/.leeloo/private |*      |
|test   |/Users/sylvek/test            |       |
+-------+------------------------------+-------+

$> leeloo keystore default test
# will change the default keystore
+-------+------------------------------+-------+
|Name   |Path                          |Default|
+-------+------------------------------+-------+
|private|/Users/sylvek/.leeloo/private |       |
|test   |/Users/sylvek/test            |*      |
+-------+------------------------------+-------+

$> leeloo key
# will display available keys and which are set to this keystore
+-------------------------+--------+
|Email                    |Selected|
+-------------------------+--------+
|user1@email.com          |        |
|user2@email.com          |        |
+-------------------------+--------+

(if nothing is displayed, have a look on your gpg's configuration)

$> leeloo key add user1@email.com
# will add user1@email.com to this keystore
+-------------------------+--------+
|Email                    |Selected|
+-------------------------+--------+
|user1@email.com          |*       |
|user2@email.com          |        |
+-------------------------+--------+

$> leeloo key sync
# will update all secrets to be readable by selected users

$> leeloo write my_secret
# will add a secret

$> leeloo write my_secret --generate 5
# will add a randomized secret

$> echo "my secret" | leeloo write my_secret --stdin
# will add a secret from STDIN

$> leeloo write my_secret --keystore test
# will add a secret to "test"

$> leeloo read my_secret
# display it

$> leeloo sync
# will synchronize keystore

$> leeloo translate < file.in > file.out
# will replace ${my_secret} by the current secret and will return file translated

$> leeloo share my_secret
# will generate an url with an access token allowing to retrieve the secret

$> leeloo token my_secret
# will generate an access token for accessing my_secret

$> leeloo server
# will launch a server instance allowing to retrieve a secret by a given access token
```

## How to share a keystore ?

Each action is commited in Git. To share your keystore, [create a remote repository and share it](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes).

By default, a new created keystore comes with *no registered public keys on your system*. So you have to explicitly add them by using `key add` function before writing new secrets.


## ZSH completion support !

_installed with brew on Macos_

To use zsh-completion with leeloo you just have to copy _leeloo file into $HOME/.oh-my-zsh/completions/_leeloo

![demo](leeloo.gif)
