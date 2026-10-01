{
  fileSystems."/srv/storage/syncthing" = {
    device = "/dev/disk/by-uuid/20891366-078d-4973-bd64-1cce466b0a51";
    fsType = "btrfs";
    options = [ "subvol=syncthing" "compress=zstd" "noatime" ];
  };
}
