//==============================================================================
//	R_ArpgPlayerCamera
//==============================================================================
class R_ArpgPlayerCamera extends Actor;

var private float OffsetDistance;
var private Vector OffsetDirection;

function PlayerCalcView(
	out Actor ViewActor,
	out Vector CameraLocation,
	out Rotator CameraRotation)
{
	local Vector BasisLocation;
	local Vector OffsetVector;

	if(Owner == None)
	{
		ViewActor = None;
		CameraLocation = Vect(0,0,0);
		CameraRotation = Rot(0,0,0);
		return;
	}

	BasisLocation = Owner.Location;
	OffsetVector = Normal(OffsetDirection) * OffsetDistance;

	CameraLocation = BasisLocation + OffsetVector;
	CameraRotation = Rotator(BasisLocation - CameraLocation);
	ViewActor = Owner;
}

defaultproperties
{
	RemoteRole=ROLE_None
	OffsetDistance=1024.0
	OffsetDirection=(X=1.0,Y=1.0,Z=2.0)
	DrawType=DT_Sprite
    Style=STY_Normal
	Texture=Texture'Engine.S_Camera'
	bHidden=true
}