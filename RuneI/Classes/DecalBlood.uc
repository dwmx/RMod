//=============================================================================
// DecalBlood.
//=============================================================================
class DecalBlood expands Decal;

var bool bAttached, bStartedLife, bImportant;
var float TimePassed;
var float GrowForTime;

simulated function PostBeginPlay()
{
	if (class'GameInfo'.Default.bLowGore || (Level.bDropDetail && (FRand() < 0.35)) )
	{	// Can destroy this here because it's not replicated to client
		Destroy();
		return;
	}

	if(Owner != None)
		DrawScale = Owner.DrawScale * 0.4;

	Super.PostBeginPlay();
	SetTimer(1.0, false);
}

simulated function Timer()
{
	// Check for nearby players, if none then destroy self

	if ( !bAttached )
	{
		Destroy();
		return;
	}

	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
		if ( Level.bDropDetail )
			SetTimer(5.0 + 2 * FRand(), false);
		else
			SetTimer(18.0 + 5 * FRand(), false);
		return;
	}
	if ( Level.bDropDetail && (MultiDecalLevel < 6) )
	{
		if ( (Level.TimeSeconds - LastRenderedTime > 0.35)
			|| (!bImportant && (FRand() < 0.2)) )
			Destroy();
		else
		{
			SetTimer(1.0, true);
			return;
		}
	}
	else if ( Level.TimeSeconds - LastRenderedTime < 1 )
	{
		SetTimer(5.0, true);
		return;
	}
	Destroy();
}

defaultproperties
{
     bAttached=True
     GrowForTime=4.000000
     bBloodyDecal=True
     Style=STY_Modulated
     Texture=Texture'BloodFX.blood02_b'
}
