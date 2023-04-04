{ pkgs
, ...
}:

{
  age.secrets.soren-libera-cert = {
    file = ../../../secrets/soren-libera-cert.age;
    owner = "soren";
  };
}
