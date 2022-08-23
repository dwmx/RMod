//=============================================================================
// FireRadius.
//=============================================================================
class FireRadius expands Effects;

var float TimePassed;
const StartRadius = 22.0;
const EndRadius=125.0;
const EffectTime=0.75;

simulated function Spawned()
{
	TimePassed=0.0;
	ScaleGlow = EffectTime * 2;

	DoRadiusEffect();
}

function DoRadiusEffect()
{
	local actor A;
	local int i;
	local bool bCollisionJoints;

	foreach RadiusActors(class'actor', A, EndRadius * 2, Location)
	{
		if (A == self || A==Owner || A.Owner==Owner)
				continue;

		if (A.bHidden)
			continue;

		if (ScriptPawn(A) != None && ScriptPawn(A).bIsBoss)
			continue;

		if (!FastTrace(Location, A.Location))
			continue;

		if (A.IsA('Pawn'))
		{
			// Set on fire
			Pawn(A).PowerupBlaze(Pawn(Owner));

			// Do some damage
			A.JointDamaged(10, Pawn(Owner), A.Location, Normal(A.Location-Owner.Location)*50, 'fire', 0);
//			A.AddVelocity((Normal(A.Location-Owner.Location)+vect(0,0,1))*300);
		}
		else if (A.IsA('Decoration') || A.IsA('Inventory'))
		{
			// Set all collision joints on fire
			for (i=0; i<A.NumJoints(); i++)
			{
				if ((A.JointFlags[i] & JOINT_FLAG_COLLISION)!=0)
				{
					bCollisionJoints = true;
					A.SetOnFire(Pawn(Owner), i);
				}
			}
			if (!bCollisionJoints)
				A.SetOnFire(Pawn(Owner), 1);
		}
	}
}

simulated function Tick(float DeltaTime)
{
	local float newRadius;

	TimePassed += DeltaTime;
	newRadius = StartRadius + (EndRadius-StartRadius) * (TimePassed/EffectTime);
	DrawScale = newRadius/StartRadius;
	
	// Fade the blast radius out
	ScaleGlow -= DeltaTime * 2;
	if(ScaleGlow <= 0)
		Destroy();
//	SetCollisionSize(newRadius, CollisionHeight);
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_VerticalSprite
     Style=STY_Translucent
     Texture=FireTexture'RuneFX2.FireRing'
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     bCollideActors=True
}
