//==============================================================================
//	R_ArpgPawnAnimProxy
//	AnimProxy class to be used with R_ArpgPawn
//==============================================================================
class R_ArpgPawnAnimProxy extends AnimationProxy;

function AnimEnd()
{
	local R_ArpgPawn LocalPawn;

	LocalPawn = R_ArpgPawn(Owner);
	if(LocalPawn != None)
	{
		LocalPawn.AnimProxyAnimEnd();
	}
}