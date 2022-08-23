//=============================================================================
// DestroyRock.
//=============================================================================
class DestroyRock expands DecorationRune;

var int Health;



function ThrowDebris(int number)
{
	local int i;
	local Rocks rock;

	for (i=0; i<number; i++)
	{
		switch(Rand(2))
		{
		case 0:
			rock = spawn(class'rocksmall',,,,);
			break;
		case 1:
			rock = spawn(class'rockmedium',,,,);
			break;
		}
		rock.SetPhysics(PHYS_Falling);
		rock.Velocity = (VRand()+vect(0,0,2)) * RandRange(100,1000);
		rock.LifeSpan = 5.0;
	}
}

//================================================
//
// JointDamaged
//
// He is stunned by thrown objects
//================================================
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	if (DamageType == 'blunt')
	{
		Health -= Damage;
		if (Health <= 0)
		{
			ThrowDebris(7);
			Destroy();
		}
	}
	return false;
}

defaultproperties
{
     Health=50
     bStatic=False
     DrawType=DT_SkeletalMesh
     DrawScale=2.000000
     AmbientGlow=15
     CollisionRadius=42.000000
     CollisionHeight=45.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Mass=400.000000
     SkelMesh=2
     Skeletal=SkelModel'objects.Rocks'
}
