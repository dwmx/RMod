//=============================================================================
// SonicBlast.
//=============================================================================
class SonicBlast expands Effects;

const TimeStep = 0.1;

var() texture BlastTex[4]; // In order from full --> faded out

var float Time;
var int TexStage;

simulated function Spawned()
{
	Time = 0;
	TexStage = 0;
	Texture = BlastTex[3];
}

simulated function ChangeBlastTexture()
{
	TexStage++;

	if(TexStage >= 7)
	{
		Destroy(); // Remove the sonic effect after a certain time
		return;
	}
	
	switch(TexStage)
	{
	case 0: case 6:
		Texture = BlastTex[3];
		break;
	case 1: case 5:
		Texture = BlastTex[2];
		break;
	case 2: case 4:
		Texture = BlastTex[1];
		break;
	case 3:
		Texture = BlastTex[0];
		break;
	default:
		Texture = BlastTex[3];
		break;
	}

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
		ChangeBlastTexture();
	}
}

defaultproperties
{
     BlastTex(0)=Texture'RuneFX.sonicmod'
     BlastTex(1)=Texture'RuneFX.sonicmodfade1'
     BlastTex(2)=Texture'RuneFX.sonicmodfade2'
     BlastTex(3)=Texture'RuneFX.sonicmodfade3'
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_VerticalSprite
     Style=STY_Modulated
     Texture=Texture'RuneFX.sonicmod'
     bUnlit=True
}
