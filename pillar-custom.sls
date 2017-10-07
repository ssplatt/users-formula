# vim: ft=yaml
# Custom Pillar Data for users

users:
  enabled: True
  directory:
    users:
      'myuser':
        uid: 10100
        gid: 10100
        fullname: "Joe Schmoe"
        password: "$6$rZWQF/Pr$7KljpCYfxwanIHmOESQIXC1qjRNnVIeAoNVrd0fNwVIX4/xc4ZQCi9kSKxOBl2eo2a3rlFlpX3EaRQHoxkwM80"
        gid_from_name: true
        authorized_keys:
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDP6jJjVkSm6QRYv43ih7K40aN9VKVySQj7kgmG6ejpwH8SrZHW6GZ0JL1Qf3hbKFsD3dsWmxxF+FIf6048awP6twYHeKLO+fBn+m5xk3oCiWHZRnIksMQrNLjjR7sP4a1qDuIanuzAmDY+kohsibQsq0uicgT/mQFia36dfBfSXNgs7YmwUd2nT/RNS9ZsJJrNPtWAFCTvHDX/oDO/pthOrKGDJu7ITrDAlIf8PKNS8UpwKZxzA5QCWAqbvwv1u8oCGTj9mHXkn/SuuTv9YkFpijR2wgWbROxE1PDkZCzg7cUZrf5ea2KuczuyioWA4n0O92TeMRi5NBCRGpHKWXhb vagrant
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHhkflL2tfSCAPYPKOJQNDnTOtH71YAfcWMmX7WT32M2UeQ+XfbmIJYyLiZjwpsPg0kcnZljHyjx8NgMrWAJxSDQSv5CmTLglqwEZ02o9YjIeEWIjw3g6To+M0vD0czSZ3qsDMzydh3U3eNdNP/puF1vJHe1ovLhwqEM4/TjlHiv7eoxbb8Vr9KxLhCsHKPbNdX6ZNgND9AxF0y4NjREJ/N4m7T+zYhif/8gbcNOepeAPcJzAt93rmX2oRSSnRH5t31N28iC5vZUtJInSEjQq+VLDZtll6CW/+5mBR/iHGdInNxRiTR2l6ePEgmO7M1nTQjb394jUXGtiCC7v8GqIp vagrant@custom-bento-debian-82
        google_2fa:
          secretkey: 4KSYHR4GKXH4TNQ4
        configs:
          bashrc:
            source: "salt://users/files/myuser/bashrc"
            skip_verify: True
          tmux.conf: {}
          vimrc:
            contents: "set ruler"
      no_configs_or_keys_or2fa:
        uid: 10101
        gid: 10101
        gid_from_name: true
        fullname: "Some person"
        password: "$6$rZWQF/Pr$7KljpCYfxwanIHmOESQIXC1qjRNnVIeAoNVrd0fNwVIX4/xc4ZQCi9kSKxOBl2eo2a3rlFlpX3EaRQHoxkwM80"
    groups:
      'testgroup':
        gid: 10000
      'anothertestgroup':
        gid: 10001
  system:
    users:
      no_configs_or_keys_or2fa:
        state: present
      myuser:
        state: present
      luser:
        state: absent
        purge: true
        force: true
      luser2:
        state: absent
        purge: true
        force: true
      dudewhoquit:
        state: absent
        purge: true
        force: true
      guywhogotfired:
        state: absent
        purge: true
        force: true
    groups:
      testgroup:
        state: present
      hackers:
        state: absent
      nsa:
        state: absent
    aliases:
      root:
        state: absent

pam:
  google2fa:
    enabled: true
