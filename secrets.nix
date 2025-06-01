let
    # Users
    matthew_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB";

    # Systems
    nixvm_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDyt/aumMQY4wl24o48rnQC8ur2a6WW/2EjmDOLrGwM";
in

{
    "secrets/nixvm-smb-creds.age".publicKeys = [ matthew_pubkey nixvm_pubkey ];
}
