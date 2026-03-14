//==============================================================================
//	R_ArpgPawnAnimProxy
//	AnimProxy class to be used with R_ArpgPawn
//==============================================================================
class R_ArpgPawnAnimProxy extends AnimationProxy;

function R_ArpgPawn GetArpgPawnOwner()
{
	return R_ArpgPawn(Owner);
}