# nix-setup

Welcome to my nixos setup. I included many Nixpkgs and its own config.

I decided to create a full reproductible enviorment for my nix system not only because i wanted a new challenge but also to help the community. It is not a super advanced setup but i'm doing my best adding features every time i can.

Currently I only support a hybrid config system. Every program has its own settings folder with, its settings, in different languages. I adapted it to my computers for now but i will leave soon a templates folder to help customizing it.

---

## Map

---

Down below i will leave a map with the structure of the repo (so far) and the contents inside every directory

---

`assets/` -> So far my prefered wallpaper

`ci/` -> A Ci file to check error before compiling

`lib/` -> Contains lib helpers

`modules/` -> The full life cycle of the packages

`systems/` -> Devices customization, currently only my laptop

`user/` -> A model of user

---

`flake.nix` -> The flake itself
`switch.sh` -> My own bash script to rebuild

---

# Resources

I took a lot of inspiration from snowfall lib convention but mainly from [Khaneliman](https://github.com/khaneliman/khanelinix/blob/main)
