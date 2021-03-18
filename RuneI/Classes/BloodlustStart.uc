//=============================================================================
// BloodlustStart.
//=============================================================================
class BloodlustStart expands Effects;

var float time;

simulated function PreBeginPlay()
{
	Enable('Tick');
	DesiredColorAdjust.X = 102;	
	ScaleGlow = 0.75;
	DrawScale = 0.5;
	time = 0.75;
}

simulated function Tick(float DeltaSeconds)
{
	local vector newLoc;
	
	DrawScale += DeltaSeconds * 7;	
	ScaleGlow = time;
	
	SetLocation(Owner.Location);
	SetRotation(Owner.Rotation + rot(16384, 0, 0));
	
	time -= DeltaSeconds;
		
	if(time <= 0)
		Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_VerticalSprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.ripple2'
}
