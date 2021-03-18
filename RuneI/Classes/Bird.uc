//=============================================================================
// Bird.
//=============================================================================
class Bird expands ScriptPawn;


var() float CircleRadius;

var	vector CircleCenter;
var float Angle;

// FUNCTIONS ------------------------------------------------------------------

function PreBeginPlay()
{
	Super.PreBeginPlay();
	CircleCenter = Location;
}

function PreSetMovement()
{
	bCanJump = false;
	bCanWalk = false;
	bCanSwim = false;
	bCanFly = true;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}

function CheckForEnemies()
{
}

function Texture PainSkin(int BodyPart)
{
	return None;
}

// ANIMATIONS -----------------------------------------------------------------
function PlayWaiting(optional float tween)			{	LoopAnim('idle', 1.0, 0.1);	}
function PlayMoving(optional float tween)			{	LoopAnim('fly', 1.0, 0.1);	}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{	// Force death
	return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}


// STATES ---------------------------------------------------------------------

State Fleeing
{
ignores SeePlayer, HearNoise, EnemyAcquired;

	function HitWall(vector HitNormal, actor Wall)
	{	// avoid cowering
		global.HitWall(HitNormal, Wall);
	}

	function PickDestination()
	{
		Destination = Location + VRand()*50;
	}

Move:
	PickDestination();
	MoveTo(Destination, MovementSpeed);
	Goto('Move');
}


state() Circle
{
	ignores seeplayer, hearnoise, enemynotvisible;

	singular function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone || NewZone.bPainZone)
		{
			SetLocation(OldLocation);
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			MoveTimer = -1.0;
		}
	}

begin:
	PlayMoving(0.1);

Move:
	Angle += 1.0484; //2*3.1415/6;
	Destination.X = CircleCenter.X - CircleRadius * Sin(Angle);
	Destination.Y = CircleCenter.Y + CircleRadius * Cos(Angle);
	Destination.Z = CircleCenter.Z + 30 * FRand() - 15;
	MoveTo(Destination, MovementSpeed);
	Goto('Move');
}


//------------------------------------------------------------
//
// STATE Dying
//
//------------------------------------------------------------
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed;

	function BeginState()
	{
		SetPhysics(PHYS_Falling);
		Super.BeginState();
	}

//	function Landed(vector HitNormal)
//	{
//	}
	function ReplaceWithCarcass()
	{
		SpawnBodyGibs(Velocity);
	}

PostDeath:
	// spawn blood spot
	Destroy();
}

//------------------------------------------------------------
//
// STATE LoneFlyer
//
// Used to script a bird flying on a particular path
//------------------------------------------------------------

state() LoneFlyer
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, PainTimer, Landed;

	function Trigger(actor other, pawn eventInstigator)
	{
		local InterpolationPoint i;

		if(Event != 'None')
			foreach AllActors(class 'InterpolationPoint', i, Event)
				if(i.Position == 0)
				{ // Found a matching path
					SetCollision(true, false, false);
					bCollideWorld = False;
					Target = i;
					SetPhysics(PHYS_Interpolating);
					PhysRate = 1.0;
					PhysAlpha = 0.0;
					bInterpolating = true;
					return;
				}
	}

begin:
	LoopAnim('fly', 1.0, 0.1);
}

defaultproperties
{
     CircleRadius=70.000000
     FightOrDefend=1.000000
     HighOrLow=1.000000
     bRoamHome=True
     bGlider=True
     GroundSpeed=0.000000
     WaterSpeed=5.000000
     AirSpeed=300.000000
     AccelRate=400.000000
     JumpZ=0.000000
     WalkingSpeed=300.000000
     ClassID=11
     Health=10
     CollisionRadius=25.000000
     CollisionHeight=12.000000
     bBlockActors=False
     bBlockPlayers=False
     Mass=50.000000
     Buoyancy=100.000000
     RotationRate=(Yaw=22768)
}
