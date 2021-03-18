class ZTargetDecal expands Decal;

var vector OldOwnerLocation;
//var FadeShadow FadeShadow;

function AttachToSurface()
{
}
/*
function Destroyed()
{
	Super.Destroyed();

	if ( FadeShadow != None )
		FadeShadow.Destroy();
}
*/
function Timer()
{
	DetachDecal();
	OldOwnerLocation = vect(0,0,0);
}
			
event Update(Actor L)
{
	local Actor HitActor;
	local Vector HitNormal,HitLocation, ShadowStart, ShadowDir;

	if ( !Level.bHighDetailMode )
		return;

	SetTimer(0.25, false);
	if ( OldOwnerLocation == Owner.Location )
		return;

	OldOwnerLocation = Owner.Location;

	DetachDecal();

	if ( Owner.Style == STY_Translucent )
		return;

	ShadowDir = vect(0.1,0.1,0);

	ShadowStart = Owner.Location + Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0,0,300), ShadowStart, false);

	if ( HitActor == None )
		return;

	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	AttachDecal(10, ShadowDir);
}

defaultproperties
{
     MultiDecalLevel=3
     Style=STY_Translucent
     Texture=Texture'RuneFX2.Target'
}
