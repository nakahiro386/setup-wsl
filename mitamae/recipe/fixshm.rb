# Systemd units known to be problematic under WSL · arkane-systems/genie Wiki
# https://github.com/arkane-systems/genie/wiki/Systemd-units-known-to-be-problematic-under-WSL#systemd-sysusersservice

# WSL: snaps with private shared memory support enabled don't install
# https://randombytes.substack.com/p/wsl-snaps-with-private-shared-memory
file "/etc/systemd/system/fixshm.service" do
  action :create
  owner "root"
  group "root"
  mode "644"
  content <<-"EOH"
  [Unit]
Description=Fix the /dev/shm symlink to be a mount
DefaultDependencies=no
Before=sysinit.target
ConditionPathExists=/dev/shm
ConditionPathIsSymbolicLink=/dev/shm
ConditionPathIsMountPoint=/run/shm

[Service]
Type=oneshot
ExecStart=/usr/bin/rm /dev/shm
ExecStart=/usr/bin/mkdir /dev/shm
ExecStart=/bin/umount /run/shm
ExecStart=/usr/bin/rmdir /run/shm
ExecStart=/bin/mount -t tmpfs -o mode=1777,nosuid,nodev,strictatime tmpfs /dev/shm
ExecStart=/usr/bin/ln -s /dev/shm /run/shm

[Install]
WantedBy=sysinit.target
  EOH
  notifies :restart, "service[fixshm.service]", :immediately
end
service "fixshm.service" do
  action :enable
end

