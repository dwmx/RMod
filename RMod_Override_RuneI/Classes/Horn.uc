//=============================================================================
// Horn.
//=============================================================================
class Horn expands Instrument;

var(Sounds) Sound BlowHorn;


//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_METAL;
}

//============================================================
//
// PlayInstrument
//
//============================================================
function PlayInstrument(actor Musician)
{
	Super.PlayInstrument(Musician);
	PlaySound(BlowHorn, SLOT_Misc,,,, FRand()*0.5 + 0.8);
}

defaultproperties
{
     BlowHorn=Sound'MusicalSnd.ME.mehorns01'
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=100.000000
     CollisionHeight=58.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.Horn'
}
