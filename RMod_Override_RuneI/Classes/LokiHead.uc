//=============================================================================
// LokiHead.
//=============================================================================
class LokiHead expands ScriptPawn;

// Emit light

var() float MaxDeviation;
var float HeadTime;
var LokiEffect plaque;


function PreBeginPlay()
{
	// Background sprite/smoke effect
	plaque = Spawn(class'LokiEffect',,, Location);

	HeadTime=0;
	HomeBase = Location;

	Super.PreBeginPlay();
}

function Destroyed()
{
	if (plaque != None)
		plaque.Destroy();
	Super.Destroyed();
}

function PreSetMovement()
{
	bCanFly = true;
}

function Tick(float DeltaTime)
{
	local vector loc;
	local vector X,Y,Z;

	HeadTime += DeltaTime;

	GetAxes(Rotation, X,Y,Z);

	loc = HomeBase + (Y * Sin(HeadTime) * MaxDeviation) + (Z * Cos(HeadTime) * 2 * MaxDeviation);
	SetLocation(loc);

	Super.Tick(DeltaTime);
}


State Acquisition
{
ignores EnemyAcquired, SeePlayer, HearNoise;
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_NONE;
}

defaultproperties
{
     MaxDeviation=5.000000
     bFallAtStartup=False
     AttitudeToPlayer=ATTITUDE_Ignore
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     bDynamicLight=True
     DrawScale=5.000000
     CollisionRadius=67.000000
     CollisionHeight=100.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Skeletal=SkelModel'objects.Skull'
}
