//=============================================================================
// SonicBlastHighlight.
//=============================================================================
class SonicBlastHighLight expands Effects;

const TimeStep = 0.1;

var float Time;
var int TexStage;

simulated function Spawned()
{
	Time = 0;
	TexStage = 0;
}

simulated function Tick(float DeltaTime)
{
	local float newRadius;
	local vector loc;
	local rotator rot;

	DrawScale += DeltaTime * DrawScale * 2;
		
	rot = Rotation;
	rot.Roll += 50000 * DeltaTime / (DrawScale * 0.25);
	SetRotation(rot);
	
	Time += DeltaTime;
	while(Time >= TimeStep)
	{
		Time -= TimeStep;
		TexStage++;
		if(TexStage >= 7)
		{
			Destroy();
			return;
		}
	}
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_VerticalSprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.sonic3'
     ScaleGlow=0.700000
}
