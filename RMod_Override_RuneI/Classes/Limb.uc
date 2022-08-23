//=============================================================================
// Limb.
//=============================================================================
class Limb expands DecorationRune;


//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_FLESH;
}

state WaitingToRemove
{
	function BeginState()
	{
		LifeSpan=RandRange(15,20);
	}

	function Destroyed()
	{
		if (LifeSpan < 1)
			bDestroyable=false;
		Super.Destroyed();
	}
}

defaultproperties
{
     bBurnable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     Mass=10.000000
}
