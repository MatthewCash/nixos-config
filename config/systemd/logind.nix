{ ... }:

{
     services.logind.extraConfig = ''
        IdleActionSec=30s
        HoldoffTimeoutSec=3s
	 '';
}
