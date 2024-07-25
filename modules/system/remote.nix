# Common config for a remote system

{ pkgs, ... }:
{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  users.users.ben.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTaKuskeQD2NNZ7JP3H8LMzCsWRwmTf3WnN20GzZO+e snowful@linuxisgood" ];

  # Ignore the lid closing
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";
}
