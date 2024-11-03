# A hardened-by-default postgres service config.
#
# Use the following in a host machine's config to setup a list of 
# databases/users:
#
# ```nix
# services.postgresql = let users = ["pobcoin"]; in {
#   ensureDatabases = users;
#   ensureUsers = map (u: { name = u; ensureDBOwnership = true; }) users;
# };
# ```

{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16_jit;
    identMap = ''
       # ArbitraryMapName systemUser DBUser
       superuser_map      root      postgres
       superuser_map      postgres  postgres
       # Let other names login as themselves
       superuser_map      /^(.*)$   \1
    '';
    authentication = pkgs.lib.mkDefault ''
      # TYPE   DATABASE   USER   ADDRESS          METHOD    OPT_IDENT_MAP

      # "local" is for Unix domain socket connections only
      local    sameuser   all                     peer      map=superuser_map

      # IPv4 local connections:
      # host     sameuser   all    127.0.0.1/32     md5

      # IPv4 connections from a specific subnet:
      # host     all        all    192.168.68.0.22  peer      map=superuser_map

      # IPv6 local connections:
      # host     all        all    ::1/128          md5       map=superuser_map
    '';
  };
}
