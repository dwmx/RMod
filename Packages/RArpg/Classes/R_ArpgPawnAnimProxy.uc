//==============================================================================
//	R_ArpgPawnAnimProxy
//	AnimProxy class to be used with R_ArpgPawn
//==============================================================================
class R_ArpgPawnAnimProxy extends AnimationProxy;

function R_ArpgPawn GetArpgPawnOwner()
{
	return R_ArpgPawn(Owner);
}

function AnimEnd()
{
	local R_ArpgPawn LocalPawn;

	LocalPawn = GetArpgPawnOwner();
	if(LocalPawn != None)
	{
		LocalPawn.AnimProxyAnimEnd();
	}
}

function FrameNotify(int FramePassed)
{
	local R_ArpgPawn LocalPawn;

	LocalPawn = GetArpgPawnOwner();
	if(LocalPawn != None)
	{
		LocalPawn.AnimProxyFrameNotify(FramePassed);
	}
}