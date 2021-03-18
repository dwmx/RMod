//=============================================================================
// DebrisFlesh.
//=============================================================================
class DebrisFlesh extends Debris;


var bool bWasInAir;


function PreBeginPlay()
{
	Super.PreBeginPlay();

	if(class'GameInfo'.Default.bLowGore)
	{
		Destroy();
	}
}

simulated function ZoneChange(ZoneInfo NewZone)
{
	local actor A;

	if (class'GameInfo'.Default.bLowGore )
	{
		return;
	}

	if (!NewZone.bWaterZone)
	{
		bWasInAir = True;
	}
	else
	{	// Entered water
		if (bWasInAir)
		{	// spawn a bloodUnderwater on surface
			RotationRate = rot(0,0,0);
			Spawn(class'BloodWaterSurface',,, Location, rot(16384,0,0));
		}
		else
		{
			A = Spawn(class'BloodUnderwater',,, Location, rotator(VRand()));
		}
	}
}


simulated function PlayLandSound()
{
	switch(Rand(6))
	{
		case 0:
			PlaySound(Sound'OtherSnd.Gibs.gib01');
			break;
		case 1:
			PlaySound(Sound'OtherSnd.Gibs.gib02');
			break;
		case 2:
			PlaySound(Sound'OtherSnd.Gibs.gib03');
			break;
		case 3:
			PlaySound(Sound'OtherSnd.Gibs.gib04');
			break;
		case 4:
			PlaySound(Sound'OtherSnd.Gibs.gib05');
			break;
		case 5:
			PlaySound(Sound'OtherSnd.Gibs.gib06');
			break;
	}
}

simulated function SpawnDebrisDecal(vector HitNormal)
{
	switch(Rand(5))
	{	// These are in order by size
		case 0:
			Spawn(class'DecalBlood',self,,Location, rotator(HitNormal));
			break;
		case 1:
			Spawn(class'DecalBlood2',self,,Location, rotator(HitNormal));
			break;
		case 2:
			Spawn(class'DecalBlood3',self,,Location, rotator(HitNormal));
			break;
		case 3:
			Spawn(class'DecalBlood4',self,,Location, rotator(HitNormal));
			break;
		case 4:
			Spawn(class'DecalBlood5',self,,Location, rotator(HitNormal));
			break;
	}
}

defaultproperties
{
     LandSound=Sound'OtherSnd.Gibs.gib01'
     Skeletal=SkelModel'objects.Chunks'
     SkelGroupSkins(1)=Texture'objects.Chunksflesh'
}
