//=============================================================================
// GlowPlant.
//=============================================================================
class GlowPlant extends Plants;

var actor sparks;
var() bool bNoSparks;

simulated function PreBeginPlay()
{
	if(!bNoSparks)
	{
		sparks = spawn(class'GlowplantSparks',self,,Location);
		sparks.RemoteRole = ROLE_None;
	}

//	AttachActorToJoint(sparks, 2);
}

function Destroyed()
{
	if (sparks!=None)
	{
//		DetachActorFromJoint(2);
		sparks.Destroy();
	}
	Super.Destroyed();
}

defaultproperties
{
     RotAngle=2000
     TouchFactor=0.050000
     HitFactor=0.250000
     BrushSound=Sound'OtherSnd.Bush.bush01'
     LODCurve=LOD_CURVE_CONSERVATIVE
     CollisionRadius=28.000000
     CollisionHeight=36.000000
     Skeletal=SkelModel'plants.GlowPlant'
}
