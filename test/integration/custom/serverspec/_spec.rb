require 'serverspec'

# Required by serverspec
set :backend, :exec

describe user('myuser') do
  it { should exist }
  it { should belong_to_group 'myuser' }
  it { should belong_to_primary_group 'myuser' }
  it { should have_uid 10100 }
  it { should have_home_directory '/home/myuser' }
  it { should have_login_shell '/bin/sh' }
  it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDP6jJjVkSm6QRYv43ih7K40aN9VKVySQj7kgmG6ejpwH8SrZHW6GZ0JL1Qf3hbKFsD3dsWmxxF+FIf6048awP6twYHeKLO+fBn+m5xk3oCiWHZRnIksMQrNLjjR7sP4a1qDuIanuzAmDY+kohsibQsq0uicgT/mQFia36dfBfSXNgs7YmwUd2nT/RNS9ZsJJrNPtWAFCTvHDX/oDO/pthOrKGDJu7ITrDAlIf8PKNS8UpwKZxzA5QCWAqbvwv1u8oCGTj9mHXkn/SuuTv9YkFpijR2wgWbROxE1PDkZCzg7cUZrf5ea2KuczuyioWA4n0O92TeMRi5NBCRGpHKWXhb vagrant' }
  it { should have_authorized_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHhkflL2tfSCAPYPKOJQNDnTOtH71YAfcWMmX7WT32M2UeQ+XfbmIJYyLiZjwpsPg0kcnZljHyjx8NgMrWAJxSDQSv5CmTLglqwEZ02o9YjIeEWIjw3g6To+M0vD0czSZ3qsDMzydh3U3eNdNP/puF1vJHe1ovLhwqEM4/TjlHiv7eoxbb8Vr9KxLhCsHKPbNdX6ZNgND9AxF0y4NjREJ/N4m7T+zYhif/8gbcNOepeAPcJzAt93rmX2oRSSnRH5t31N28iC5vZUtJInSEjQq+VLDZtll6CW/+5mBR/iHGdInNxRiTR2l6ePEgmO7M1nTQjb394jUXGtiCC7v8GqIp vagrant@custom-bento-debian-82' }
  its(:encrypted_password) { should match(/^\$6\$.{8}\$.{86}$/) }
  its(:minimum_days_between_password_change) { should eq 0 }
  its(:maximum_days_between_password_change) { should eq 99999 }
end

describe file('/home/myuser') do
  it { should exist }
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'myuser' }
  it { should be_grouped_into 'myuser' }
end

describe file('/home/myuser/.bashrc') do
  it { should exist }
  it { should be_mode 640 }
  it { should be_owned_by 'myuser' }
  it { should be_grouped_into 'myuser' }
  its(:sha256sum) { should eq '8ffa5935f6c3b6027791bc47e9ec3fd49e549f7ac0e9e016d988844376677696' }
end

describe file('/home/myuser/.tmux.conf') do
  it { should exist }
  it { should be_mode 640 }
  it { should be_owned_by 'myuser' }
  it { should be_grouped_into 'myuser' }
  its(:sha256sum) { should eq '5876678476452df9f6e7ab3b6f8c467cbf09ffe62f02e34d6fe0d8b6e4b1ae15' }
end

describe file('/home/myuser/.vimrc') do
  it { should exist }
  it { should be_mode 640 }
  it { should be_owned_by 'myuser' }
  it { should be_grouped_into 'myuser' }
  its(:sha256sum) { should eq '81409711a820e9ce39a0cd4f416bec1db05f429d1f19522d0e2dfb64ff8a5d6d' }
end

describe file('/home/myuser/.google_authenticator') do
  it { should exist }
  it { should be_mode 400 }
  it { should be_owned_by 'myuser' }
  it { should be_grouped_into 'myuser' }
  its(:content) { should match /^4KSYHR4GKXH4TNQ4/ }
  its(:content) { should match /^" RATE_LIMIT 3 30/ }
  its(:content) { should match /^" WINDOW_SIZE 17/ }
  its(:content) { should match /^" DISALLOW_REUSE/ }
  its(:content) { should match /^" TOTP_AUTH/ }
end

describe file('/home/no_configs_or_keys_or2fa') do
  it { should exist }
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'no_configs_or_keys_or2fa' }
  it { should be_grouped_into 'no_configs_or_keys_or2fa' }
end

describe file('/home/no_configs_or_keys_or2fa/.ssh/authorized_keys') do
  it { should_not exist }
end

describe file('/home/no_configs_or_keys_or2fa/.bashrc') do
  it { should exist }
  its(:sha256sum) { should_not eq '8ffa5935f6c3b6027791bc47e9ec3fd49e549f7ac0e9e016d988844376677696' }
end

describe file('/home/no_configs_or_keys_or2fa/.tmux.conf') do
  it { should_not exist }
end

describe file('/home/no_configs_or_keys_or2fa/.vimrc') do
  it { should_not exist }
end

describe file('/home/no_configs_or_keys_or2fa/.google_authenticator') do
  it { should_not exist }
end

describe group('testgroup') do
  it { should exist }
  it { should have_gid 10000 }
end

describe file('/etc/aliases') do
  its(:content) { should_not match /^root:/ }
end
