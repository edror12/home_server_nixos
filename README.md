# Developer's Log

For the poor soul who has to go through this again.

## NixOS for the win

For a headless server, NixOS is a natural fit:
a setup that can be recreated from a few files or one.

### Assumptions

* Headless server
* Installation over SSH
* Ethernet connection available during installation
* Client can resolve `.local` hostnames over mDNS

## Create a headless installer ISO

This is a perfect way to avoid a messy setup of old monitor and peripherals.

Build the ISO:

```bash
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./iso.nix
```

The resulting ISO should appear under:

```bash
ls result/iso/*.iso
```

Write the ISO to a USB drive:

```bash
# Find the USB device
lsblk

# Then write the ISO to it.
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

### Boot into the ISO

Plug the USB drive into the server and connect Ethernet.
Boot the machine from the USB drive.

> This procedure assumes the firmware will select the USB installer automatically. Otherwise, configure the boot order beforehand.

```bash
# Wait until we get a response
ping nixos-installer.local

# Then ssh into it
ssh root@nixos-installer.local
```
> If mDNS is not working you can acquire the IP address from the router or by connecting
to a monitor (last resort).

Once you SSH into the installer, identify the disk you want to install the OS onto it, for our case it's `/dev/nvme0n1`, verify it's there with `lsblk`

```bash
# Partion it
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart root ext4 1GiB 100%

# Format it
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

# Mount it
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

Then we can generate the config
```bash
nixos-generate-config --root /mnt

# Creates:
# /mnt/etc/nixos/configuration.nix
# /mnt/etc/nixos/hardware-configuration.nix
```

Then edit it:

```bash
vi /mnt/etc/nixos/configuration.nix
```

Once your done with the config and you're happy with it go ahead and install it:
```bash
nixos-install
```

Rather than rebooting immediately and racing the firmware while removing the USB drive:
```bash
shutdown now
```

Once the server is completely off:

1. Remove the USB installer.
2. Power the server back on.
3. It should now boot from the NVMe.

## Connect to the installed system:
```bash
ssh root@nixos-server.local
```

Create a password for the user:
```bash
passwd username
```

Then you can ssh into the user
```bash
ssh username@nixos-server.local
```