let
    # Users
    matthew_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB";

    # Systems
    nixvm_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDyt/aumMQY4wl24o48rnQC8ur2a6WW/2EjmDOLrGwM";
    zenbook_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxam6FRzD1L0RhNNTeXZDnY90/1u2ts6QC1TQBEbLPW";
in

{
    "secrets/nixvm-smb-creds.age".publicKeys = [ matthew_pubkey nixvm_pubkey ];
    "secrets/wireguard/10.0.0.9/privkey.age".publicKeys = [ matthew_pubkey zenbook_pubkey ];
    "secrets/tailscale/zeta.age".publicKeys = [ matthew_pubkey zenbook_pubkey ];
}
