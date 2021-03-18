//=============================================================================
// Table.
//=============================================================================
class Table expands DecorationRune;

// INSTANCE VARIABLES ---------------------------------------------------------

//var float TableStrength;

// FUNCTIONS ------------------------------------------------------------------

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_WOOD;
}

/*

function BreakTable()
{
	SkelMesh = 1;
	SetRotation(Rotation + Rot(5680, 0, 0));
	SetLocation(Location - Vect(0, 0, 34));
}

function DisableCollision()
{
	SetCollision(false, false, false);
	bCollideWorld = false;
	bJointsBlock = false;
}

function EnableCollision()
{
	SetCollision(true, true, true);
	bCollideWorld = true;
	bJointsBlock = true;
}

// STATES ---------------------------------------------------------------------
auto state SolidTable
{
	function BeginState()
	{
		TableStrength = 60.0;
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		local Table t;
		local actor A;

		TableStrength -= Damage;

		if(TableStrength < 0)
		{
			DisableCollision();
			t = spawn(class'Table',,,, Rotation+Rot(0, 32768, 0));
			t.DisableCollision();
			BreakTable();
			t.BreakTable();
			EnableCollision();
			t.EnableCollision();
			GotoState('BrokenTable');
			t.GotoState('BrokenTable');

			foreach BasedActors(class'actor', A)
			{
				slog("throwing "$A.name);
				A.SetPhysics(PHYS_Falling);
				A.Velocity += VRand()*30;
			}
		}
	}

	function Attach(actor other)
	{
		if (Other.Mass > 200)
			JointDamaged(TableStrength, Pawn(other), Location, vect(0,0,0), 'crushed', 1);
		else if (Other.Mass > 50)
			JointDamaged(Abs(other.Velocity.Z)*other.mass/1000, Pawn(other), Location, vect(0,0,0), 'crushed', 1);
	}
}

state BrokenTable
{
}
*/

defaultproperties
{
     DrawType=DT_SkeletalMesh
     LODCurve=LOD_CURVE_CONSERVATIVE
     CollisionRadius=105.000000
     CollisionHeight=23.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bJointsBlock=True
     Skeletal=SkelModel'objects.Table'
}
