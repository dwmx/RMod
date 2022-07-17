////////////////////////////////////////////////////////////////////////////////
//	R_BallEffect_Swipe
//	Client-side swipe effect for the Ball in ValBall
class R_BallEffect_Swipe extends WeaponSwipe;

simulated function SwipeSystemTick(float DeltaTime)
{	
	local vector NewBase, NewOffset;

	if(Owner == None || Owner.Owner == None)
	{
		IsLoaded = false;
		return;
	}

	// System LifeSpan
	if(SystemLifeSpan > 0)
	{ // Only calculate LifeSpan if the particle has a lifespan
		SystemLifeSpan -= DeltaTime;
		if(SystemLifeSpan <= 0.0)
		{
			Destroy();
		}

		// If a SwipeSystem has a lifespan, that means that the system
		// will be removed soon and is only still valid so that any remaining
		// particles can be rendered
		return;
	}

	// Compute the new base/offset locations
	NewBase = Vect(0.0, 0.0, 1.0) * Owner.Owner.CollisionHeight + Owner.Owner.Location;
	NewOffset = Vect(0.0, 0.0, -1.0) * Owner.Owner.CollisionHeight + Owner.Owner.Location;

	CreateSwipeParticle(DeltaTime, OldBaseLocation, OldOffsetLocation, NewBase, NewOffset);

	// Set the old locations to the new locations
	OldBaseLocation = NewBase;
	OldOffsetLocation = NewOffset;
}

defaultproperties
{
     ParticleTexture(0)=Texture'RuneFX.swipe_yellow'
     SwipeSpeed=2.000000
}
