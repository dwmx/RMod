//=============================================================================
// WaterloggedShield.
//=============================================================================
class WaterloggedShield expands Shield;



//-----------------------------------------------------------------------------
//
// DestroyEffect
//
// Used when shield is destroyed
//-----------------------------------------------------------------------------
function DestroyEffect()
{
	local int i, numchunks, NumSourceGroups;
	local debris d;
	local debriscloud c;
	local vector loc;
	local float scale;

	// Spawn cloud
	c = Spawn(class'DebrisCloud');
	if(c != None)
		c.SetRadius(Max(CollisionRadius,CollisionHeight));

	// Spawn debris
	numchunks = Clamp(Mass/10, 2, 15);

	// Find appropriate size of chunks
	scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (numchunks*500);
	scale = scale ** 0.3333333;
	for (NumSourceGroups=1; NumSourceGroups<16; NumSourceGroups++)
	{
		if (SkelGroupSkins[NumSourceGroups] == None)
			break;
	}

	for (i=0; i<numchunks; i++)
	{
		loc = Location;
		loc.X += (FRand()*2-1)*CollisionRadius;
		loc.Y += (FRand()*2-1)*CollisionRadius;
		loc.Z += (FRand()*2-1)*CollisionHeight;
		d = Spawn(class'debriswood',,,loc);
		if(d != None)
		{
			d.SetSize(scale);
			d.SetTexture(SkelGroupSkins[i%NumSourceGroups]);
		}
	}
}


//=============================================================================
//
// Sound Functions
//
//=============================================================================
function PlayHitSound(name DamageType)
{
}

defaultproperties
{
     Health=30
     DestroyedSound=Sound'WeaponsSnd.Shields.xtroy01'
     PickupMessage="You got a Waterlogged Shield"
     RespawnSound=Sound'OtherSnd.Respawns.respawn01'
     DropSound=Sound'WeaponsSnd.Shields.xdrop01'
     PickupMessageClass=Class'RuneI.PickupMessage'
     LODCurve=LOD_CURVE_ULTRA_CONSERVATIVE
     CollisionRadius=13.000000
     CollisionHeight=3.000000
     bCollideWorld=True
     Mass=50.000000
     Skeletal=SkelModel'weapons.VikingShield'
}
