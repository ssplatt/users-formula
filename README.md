# users-formula
This formula manages user settings and dotfiles.

Providing user specific configurations:

Under the options stanza within pillar a section called configs can be utilized to provide user specific configs
through the users formula. In the event that no data source is specified we look in salt://users/files/{{ username }}/{{ config }}.
This allows us to provide empty dictionaries to provide a config with the username it was defined under.

Note that content can be specified within the pillar definition if no source is defined, just use the same definition style as
we use for vimrc below.

The following stanza shows an example definition with two configurations (bashrc, tmux.conf):

```
users:
  enabled: True
  directory:
    users:
      'myuser':
        uid: 10100
        gid: 10100
        fullname: "The User"
        configs:
          bashrc: {}
          tmux.conf:
            source: "http://raw.githubusercontent.com/MyUser/dotfiles/master/tmux.conf"
            skip_verify: True
          vimrc:
            contents: "set ruler"
```

Install and setup brew:
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install vagrant with brew:
```
brew install cask
brew cask install vagrant
```

Install test-kitchen:
```
sudo gem install test-kitchen
sudo gem install kitchen-vagrant
sudo gem install kitchen-salt
```

Run a converge on the default configuration:
```
kitchen converge default
```

## Applying directory users to a system

In order to add users from the directory to a system, the users to be added
must be specified under the pillar `users.system`. See pillar-custom.sls for
examples of adding directory users and removing users from a system. When
defining users, it is useful to understand the following behaviors:

- Entries added under `users.system.users` are provided the following default values:
  + `state: absent`
  + `purge: true` (only default when `state` == `absent`)
  + `force: true` (only default when `state` == `absent`)
- Entries added under `users.directory.users` are provided the following default values:
  + `home: /home/{{ username }}``
  + `authorized_key_file: authorized_keys`
- Entries added under `users.system.group` are provided the following default values:
  + `state: absent`
- Entries added under `users.system.aliases` are provided the following default values:
  + `state: absent`
- Parameters added to each entry under `users.system.users` will be passed as arguments
 directly to [`salt.states.user`](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.user.html),
 with the exception of the following keys, which will be consumed by the formula instead:
  + `state`
- The same rule applies to entries under `users.system.groups` and `users.system.aliases`
- Parameters added to each entry under `users.directory.users` will be passed as
 arguments directly to [`salt.states.user`](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.user.html)
 *only when `state` == `present`*. The following keys will not be passed as
 arguments, and will be consumed by the formula instead:
  + `configs`
  + `authorized_key_file`
  + `authorized_keys`
  + `google_2fa`
- Like `users.directory.users`, parameters added to each entry under `users.directory.groups`
 will be passed as arguments directly to [`salt.states.group`](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.group.html)
 *only when `state` == `present`*. No keys are consumed by the formula.
