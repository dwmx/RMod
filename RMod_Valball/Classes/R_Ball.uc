class R_Ball extends R_RigidBall;

simulated event Spawned()
{
	local int i;
	
	Super.Spawned();
	
	//for(i = 0; i < 16; ++i)
	//{
	//	SkelGroupSkins[i] = Texture'RMod_ValBall.R_Ball_Base_Color';
	//}
	
	// Spawn client-side effects
	if(Role < ROLE_Authority)
	{
		Spawn(class'RMod.R_ShadowActor', Self);
		Spawn(class'RMod_ValBall.R_BallEffects', Self);
	}
}

event event bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local Vector ContactNormal;
	local Vector Impulse;
	
	//if(EventInstigator != None)
	//{
	//	ContactNormal = Normal(Location - EventInstigator.Location);
	//	Impulse = -1.0 * (ContactNormal * (ContactNormal Dot Velocity));
	//	Impulse += ContactNormal * 1024.0;
	//	
	//	ApplyImpulse(Impulse);
	//}
	ApplyImpulse(Momentum);
}

function EMatterType MatterForJoint(int JointID)
{
    return MATTER_WOOD;
}

simulated function ContactSurface(Vector ContactNormal, Actor ContactActor)
{
	local Vector VelocityCoincident;
	local Vector ContactLocation;
	local Rotator ContactRotation;
	local ParticleSystem ContactEffect;
	local float t;
	
	if(ContactNormalCount == 0)
	{
		VelocityCoincident = ContactNormal * (ContactNormal Dot Velocity);
		if((VelocityCoincident Dot ContactNormal) < 0.0
		&& VSize(VelocityCoincident) >= 256.0)
		{
			t = VSize(VelocityCoincident) / 1024.0;
				t = t * t;
				t = FMin(t, 1.0);
			
			PlaySound(
				Sound'WeaponsSnd.ImpEarth.impactearth07',,
				(1.0 - t) * 0.25 + t * 1.0);
			
			ContactLocation = Location + (-1.0 * ContactNormal * CollisionRadius);
			ContactRotation = Rotator(ContactNormal);
			ContactEffect = Spawn(class'RuneI.GroundDust',,,ContactLocation, ContactRotation);
			if(ContactEffect != None)
			{
				ContactEffect.ScaleMin = ((1.0 - t) * 0.4 + t * 0.8);
				ContactEffect.ScaleMax = ((1.0 - t) * 0.6 + t * 1.2);
				ContactEffect.VelocityMin =
					((1.0 - t) * Vect(-1.0, -1.0, 2.0) +
					(t * Vect(-2.0, -2.0, 4.0)));
				ContactEffect.VelocityMax =
					((1.0 - t) * Vect(-3.0, -3.0, 4.0) +
					(t * Vect(-6.0, -6.0, 8.0)));
			}
		}
	}
	
	Super.ContactSurface(ContactNormal, ContactActor);
}

event Bump(Actor Other)
{
	local Vector CumulativeVelocity;
	local float t;
	local float DamageDealt;
	
	if(Pawn(Other) != None)
	{
		CumulativeVelocity = Other.Velocity - Velocity;
		if(VSize(CumulativeVelocity) > 768.0)
		{
			t = VSize(CumulativeVelocity) / 2048.0;
			if(t <= 1.0 && t >= 0.0)
			{
				DamageDealt = (1.0 - t) * 10.0 + t * 100.0;
			}
			else
			{
				// Make player explode at high velocity
				DamageDealt = 10000.0;
			}
			Other.JointDamaged(DamageDealt, None, Vect(0.0, 0.0, 0.0), CumulativeVelocity * Mass, 'Blunt', 0);
		}
	}
}

defaultproperties
{
     Restitution=0.600000
     DrawScale=0.600000
     CollisionRadius=18.000000
     CollisionHeight=18.000000
     Mass=100.000000
     Skeletal=SkelModel'RMod_ValBall.R_Ball'
}