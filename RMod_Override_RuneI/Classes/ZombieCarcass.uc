//=============================================================================
// ZombieCarcass.
//=============================================================================
class ZombieCarcass extends RuneCarcass;

function PlayStabRemove()
{
	PlayAnim('ReactToPullout', 1.0, 0.1);
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_EARTH;
}

//============================================================
//
// SpawnBodyGibs
//
//============================================================

function SpawnBodyGibs(vector momentum)
{
	local int i, NumSourceGroups;
	local debris Gib;
	local vector loc;
	local float scale;
	local int GibCount;

	GibCount = 10;

	// Find appropriate size of chunks
	scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (GibCount*500);
	scale = scale ** 0.3333333;

	for (NumSourceGroups=1; NumSourceGroups<16; NumSourceGroups++)
	{
		if (SkelGroupSkins[NumSourceGroups] == None)
			break;
	}

	for (i = 0; i < GibCount; i++)
	{
		loc = VRand();
		loc.X *= CollisionRadius;
		loc.Y *= CollisionRadius;
		loc.Z *= CollisionHeight;
		loc += Location;

		Gib = spawn(class'DebrisStone',,, loc,);
		if (Gib != None)
		{
			Gib.SetSize(scale);
			Gib.SetMomentum(Momentum);
			if (FRand()<0.3)
				Gib.SetTexture(SkelGroupSkins[i%NumSourceGroups]);
		}
	}
}

defaultproperties
{
     AnimSequence=DTH_ALL_death1_AN0N
     DrawScale=1.250000
     PrePivot=(Z=40.000000)
     CollisionRadius=25.000000
     CollisionHeight=10.000000
     SkelMesh=11
     Skeletal=SkelModel'Players.Ragnar'
}
