//=============================================================================
// Odin.
//=============================================================================
class Odin expands ScriptPawn;

// Emit light

var() float MaxDeviation;
var float HeadTime;
var OdinEffect plaque;
var bool bFadingIn, bFadingOut;
var() float CrowRadius;				// Crows grab this for circling

function PreBeginPlay()
{
	// Background sprite/smoke effect
	plaque = Spawn(class'OdinEffect',self,,Location);
	AttachActorToJoint(plaque, JointNamed('base'));
	HeadTime=0;
	HomeBase = Location;
	
	// Move to defaults
	Style = STY_AlphaBlend;
	AlphaScale = 0;
	bFadingIn = true;

	Super.PreBeginPlay();
}

function Destroyed()
{
	if (plaque != None)
		plaque.Destroy();
	Super.Destroyed();
}

function Texture PainSkin(int BodyPart)
{
}

function PreSetMovement()
{
	bCanFly = true;
}

function Tick(float DeltaTime)
{
	UpdateOdinLocation(DeltaTime);
	UpdateOdinAlpha(DeltaTime);
	Super.Tick(DeltaTime);
}

function UpdateOdinLocation(float DeltaTime)
{
	local vector loc;
	local vector X,Y,Z;

	HeadTime += DeltaTime;

	GetAxes(Rotation, X,Y,Z);

	loc = HomeBase + (Y * Sin(HeadTime) * MaxDeviation) + (Z * Cos(HeadTime) * 2 * MaxDeviation);
	SetLocation(loc);
}

function UpdateOdinAlpha(float DeltaTime)
{
	if (bFadingIn)
	{
		AlphaScale += DeltaTime * 0.3;
		if(AlphaScale >= 1.0)
		{
			AlphaScale = 1.0;
			bFadingIn = false;
			Style = STY_Normal;
		}
	}
	else if (bFadingOut)
	{
		AlphaScale -= DeltaTime * 0.3;
		if(AlphaScale <= 0)
		{
			AlphaScale = 0;
			Destroy();
		}
	}
}

State Acquisition
{
ignores EnemyAcquired, SeePlayer, HearNoise;
}

/*
auto state Appear
{
	function BeginState()
	{
		Style = STY_AlphaBlend;
		AlphaScale = 0;
	}

	function Tick(float DeltaTime)
	{
		UpdateOdinLocation(DeltaTime);
		
		AlphaScale += DeltaTime * 0.3;
		if(AlphaScale >= 0.75)
		{
			AlphaScale = 0.75;
			GotoState('');
		}
		Super.Tick(DeltaTime);
	}
}

state Disappear
{
	function BeginState()
	{
		Style = STY_AlphaBlend;
	}

	function Tick(float DeltaTime)
	{
		UpdateOdinLocation(DeltaTime);
		
		AlphaScale -= DeltaTime * 0.3;
		if(AlphaScale <= 0)
		{
			AlphaScale = 0;
			Destroy();
		}
		Super.Tick(DeltaTime);
	}
}
*/

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

//============================================================
//
// Died
// 
// Used as a convenient way to remove the Odin Head
//============================================================

function Died(pawn Killer, name DamageType, vector HitLocation)
{
	bFadingOut=true;
	Style = STY_AlphaBlend;
}

//============================================================
//
// WeaponActivate
//
// This notify is used to spawn the Odin Eye Blast
//============================================================

function WeaponActivate()
{
	local actor blast;
	local int jointIndex;
	
	jointIndex = JointNamed('eyeEfx');
	blast = Spawn(class'OdinEyeBlast', self,, GetJointPos(jointIndex));
	AttachActorToJoint(blast, jointIndex);
}

defaultproperties
{
     MaxDeviation=5.000000
     bFallAtStartup=False
     ClassID=15
     AttitudeToPlayer=ATTITUDE_Ignore
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     bDynamicLight=True
     DrawScale=5.000000
     CollisionRadius=60.000000
     CollisionHeight=93.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Skeletal=SkelModel'creatures.OdinHead'
}
