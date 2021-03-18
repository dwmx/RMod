//=============================================================================
// WorldDecal.
//=============================================================================
class WorldDecal expands Decal;

simulated event PostBeginPlay()
{
	local vector X, Y, Z;
	DrawType = DT_None;
	
	GetAxes(Rotation, X, Y, Z);

	AttachDecal(100, Z);		
}

defaultproperties
{
     bHighDetail=False
     bDirectional=True
     DrawType=DT_VerticalSprite
     Style=STY_Modulated
}
