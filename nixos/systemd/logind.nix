{ ... }:

{
     services.logind.extraConfig = /* ini */ ''
        IdleActionSec=30s
        HoldoffTimeoutSec=3s
        RuntimeDirectorySize=2G
        RuntimeDirectoryInodesMax=2M
	 '';
}
