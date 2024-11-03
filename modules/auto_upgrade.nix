# Auto-upgrade (flake)

{ pkgs, self, ... }:
{
  # Enable auto-upgrading, every Saturday @ 10am PT
  system.autoUpgrade = {
    enable = true;
    # you should set `flake` in the calling module, as it's apparently an
    # anti-pattern to pass args into imported modules.
    # https://discourse.nixos.org/t/passing-parameters-into-import/34082/4
    # flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "Sat *-*-* 10:00:00 America/Los_Angeles";
    randomizedDelaySec = "20min";
  };
}
