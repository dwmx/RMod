//=============================================================================
// SkyZoneInfoOsc.
//=============================================================================
class SkyZoneInfoOsc extends SkyZoneInfo;

var float TimePassed;
//var float TimePassedZoom;
var rotator OriginalRotation;
//var float	OriginalDrawScale;

var() rotator MaxDeviation;
var() float SpeedScale;
//var() float ZoomSpeedScale;
//var() float ZoomMaxDeviation;


simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	OriginalRotation = Rotation;
//	OriginalDrawScale = DrawScale;
}

simulated function Tick(float DeltaTime)
{
	local rotator rot;

	Super.Tick(DeltaTime);

	TimePassed += DeltaTime*SpeedScale;

	rot = OriginalRotation;
	rot.Pitch += sin(TimePassed) * MaxDeviation.Pitch;
	rot.Yaw   += sin(TimePassed) * MaxDeviation.Yaw;
	rot.Roll  += sin(TimePassed) * MaxDeviation.Roll;

	SetRotation(rot);

//	TimePassedZoom += DeltaTime*ZoomSpeedScale;
//	DrawScale = OriginalDrawScale + sin(TimePassedZoom) * ZoomMaxDeviation;
}

defaultproperties
{
     MaxDeviation=(Pitch=2048,Roll=1024)
     SpeedScale=1.000000
     bStatic=False
}
