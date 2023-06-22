{ ... }:

{
     services.logind.extraConfig = /* ini */ ''
        IdleActionSec=30s
        HoldoffTimeoutSec=3s
	 '';
}
