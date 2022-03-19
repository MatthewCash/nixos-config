{ ... }:

{
     services.logind.extraConfig = ''
        IdleActionSec=30s
        HandleLidSwitch=suspend
        HoldoffTimeoutSec=3s
	 '';
}
