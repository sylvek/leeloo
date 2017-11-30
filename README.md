# leeloo [![Gem Version](https://badge.fury.io/rb/leeloo.svg)](https://badge.fury.io/rb/leeloo)
collaborative password manager

![multi pass](https://media.giphy.com/media/dVneNbpJiD2AU/giphy.gif)

Leeloo known as the 5th element is a humble clone of [password-store](https://www.passwordstore.org/) _(and compatible with it)_ written in Ruby with ambition to offer a powerful collaborative password manager.

Leeloo is based on [GPG](https://gnupg.org/) and [Git](https://git-scm.com/). _(you have to get a private GPG key and Git installed before, [more details here](https://www.gnupg.org/gph/en/manual/c14.html))_

## How to install leeloo ?

```
$> sudo apt-get install ruby ruby-dev
$> sudo gem install leeloo
```

## How to use it ?

```
$> leeloo init
# will create your first keystore (stored in ~/.leeloo/private)

$> leeloo
# will display all your keystores
+----------------+----------------------------------------+
| Name           | Path                                   |
+----------------+----------------------------------------+
| private        | /Users/sylvek/.leeloo/private          |
+----------------+----------------------------------------+

$> leeloo add keystore password-store ~/.password-store
# will add password-store keystore
+----------------+----------------------------------------+
| Name           | Path                                   |
+----------------+----------------------------------------+
| private        | /Users/sylvek/.leeloo/private          |
| password-store | /Users/sylvek/.password-store          |
+----------------+----------------------------------------+

# please make symbolic link to secrets if you use leeloo with password-store
$> ll ~/.password-store
drwx------  35 sylvek  staff   1,2K  4 sep 20:38 Personal
drwxr-xr-x   3 sylvek  staff   102B  4 sep 23:04 keys
lrwxr-xr-x   1 sylvek  staff     8B  4 sep 20:38 secrets -> Personal

$> leeloo add secret my_secret
# will add a secret

$> leeloo add secret my_secret --generate 5
# will add a randomized secret

$> echo "my secret" | leeloo add secret my_secret --stdin
# will add a secret from STDIN

$> leeloo add secret my_secret --keystore password-store
# will add a secret to "password-store"

$> leeloo read secret my_secret
# display it

$> leeloo sync secret
# will (re)crypt all secrets with the new given keys (from keys directory)
```

## How to share a keystore ?

Each action is commited on Git. To share your keystore, [create a remote repository and share it](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes).

By default, a new created keystore comes with all registered public keys on your system. So each owner should read your "shared" secret. To manage this list, you could remove or add new public GPG keys. It allows to share secret with someone who don't know you yet.


## ZSH completion support !

To use zsh-completion with leeloo you just have to copy _leeloo file into $HOME/.oh-my-zsh/completions/_leeloo

![demo](leeloo.gif)
