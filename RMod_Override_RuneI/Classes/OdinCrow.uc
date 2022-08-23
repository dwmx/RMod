//=============================================================================
// OdinCrow.
//=============================================================================
class OdinCrow expands Crow;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1+FRand()*1, false);
}

function Timer()
{
	local Odin O;
	foreach AllActors(class'Odin', O)
	{
		if (O.CrowRadius != 0)
			CircleRadius = O.CrowRadius;
		break;
	}
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	if(GetStateName() != 'FadingOut')
		GotoState('FadingOut');
}

state FadingOut
{
	function BeginState()
	{
		Style = STY_AlphaBlend;
		AlphaScale = 1.0;
		Enable('Tick');
	}
	
	function Tick(float DeltaSeconds)
	{
		AlphaScale -= DeltaSeconds * 0.25;
		if(AlphaScale <= 0)
			Destroy();
	}
begin:
}

defaultproperties
{
     AcquireSound=None
     SoundPitch=64
     AmbientSound=Sound'MurmurSnd.Birds.bird17L'
}
