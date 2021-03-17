//=============================================================================
// WeaponSwipe.
//=============================================================================
class WeaponSwipe expands ParticleSystem
	abstract;

//==========================================================================
//
// SystemInit
//
//==========================================================================

simulated function SystemInit()
{
	local int i;

	if(Owner == None)
	{
		IsLoaded = false;
		return;
	}

	for(i = 0; i < ParticleCount; i++)
	{
		ParticleArray[i].Valid = false;
	}

	OldBaseLocation = Owner.GetJointPos(BaseJointIndex);
	OldOffsetLocation = Owner.GetJointPos(OffsetJointIndex);

	IsLoaded = true;
	HasValidCoords = false;
}

//==========================================================================
//
// SwipeSystemTick
//
//==========================================================================

simulated function SwipeSystemTick(float DeltaTime)
{	
	local vector NewBase, NewOffset;

	if(Owner == None)
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
	NewBase = Owner.GetJointPos(BaseJointIndex);
	NewOffset = Owner.GetJointPos(OffsetJointIndex);

	CreateSwipeParticle(DeltaTime, OldBaseLocation, OldOffsetLocation, NewBase, NewOffset);

	// Set the old locations to the new locations
	OldBaseLocation = NewBase;
	OldOffsetLocation = NewOffset;
}

//==========================================================================
//
// CreateSwipeParticle
//
//==========================================================================

function CreateSwipeParticle(float DeltaTime, vector B1, vector E1, vector B2, vector E2)
{
	local int i, j;
	local float alpha;

	// Spawn a new swipe particle
	for(i = 0; i < ParticleCount; i++)
	{
		if(ParticleArray[i].Valid)
		{
			continue;
		}

		ParticleArray[i].Valid = true;
		ParticleArray[i].Style = Style;
		ParticleArray[i].TextureIndex = 0;

		alpha = float(AlphaStart) / 255.0;
		ParticleArray[i].Alpha.X = alpha;
		ParticleArray[i].Alpha.Y = alpha;
		ParticleArray[i].Alpha.Z = alpha;

		// Set the 4 corner points for the particle (CW order)
		ParticleArray[i].Points[0] = E2;
		ParticleArray[i].Points[1] = E1;
		ParticleArray[i].Points[2] = B1;
		ParticleArray[i].Points[3] = B2;

		// Set the UV coordinates
		ParticleArray[i].U0 = -DeltaTime * SwipeSpeed;
		if(ParticleArray[i].U0 < -0.99)
			ParticleArray[i].U0 = -0.99;

		ParticleArray[i].V0 = 0;
		ParticleArray[i].U1 = 0;
		ParticleArray[i].V1 = 0.99;

		// Set the Location to the average of the 4 points
		ParticleArray[i].Location = ParticleArray[i].Points[0];
		for(j = 1; j < 4; j++)
		{
			ParticleArray[i].Location += ParticleArray[i].Points[j];
		}			
		ParticleArray[i].Location /= 4;
		break;
	}
}

//==========================================================================
//
// SwipeTick
//
//==========================================================================

simulated function SwipeTick(float DeltaTime)
{
	local int ix;

	for(ix = 0; ix < ParticleCount; ix++)
	{
		if(!ParticleArray[ix].Valid)
		{
			continue;
		}

		// Update the UV coordinates on the particle (all 4 pts)
		ParticleArray[ix].U0 += DeltaTime * SwipeSpeed;
		ParticleArray[ix].U1 += DeltaTime * SwipeSpeed;

		// Clamp the coordinates (just to be safe)
		if(ParticleArray[ix].U1 > 0.99)
		{
			ParticleArray[ix].U1 = 0.99;
		}
		if(ParticleArray[ix].U0 > 0.99)
		{ // Remove the particle if the all UV coordinates are beyond the right edge
			ParticleArray[ix].Valid = false;
		}
	}
}

simulated function Tick(float DeltaTime)
{
	SwipeSystemTick(DeltaTime);
	SwipeTick(DeltaTime);
}

defaultproperties
{
     ParticleCount=64
     ParticleType=PART_Generic
     ParticleSpriteType=PSPRITE_QuadUV
     AlphaStart=255
     AlphaEnd=255
     SwipeSpeed=7.000000
     bEventSystemInit=True
     bStasis=False
     bNet=False
     bNetSpecial=False
     Style=STY_Translucent
}
