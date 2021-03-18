//=============================================================================
// Cuttle.
//=============================================================================
class Cuttle expands ScriptPawn;



/* Description:
	Ambient creature which can be interested in the player, but will not attack.  It eats
	dealie fish when it can and squirts ink when threatened.  Upon death, it releases it's
	ink and sinks.	Movement is a side-stepping hover, always facing it's target.
	
   TODO:
   	make killing a dealie actually make it hidden, move to school, sleep, and restart
   		(to avoid the nasty thrashing from actually destroying/respawning)
	ink squirt
   	get interested in ragnar for a while
	make user settable vars for parameters
*/


var actor prey;			// Prey he is about to eat
var vector targetloc;	// target location for FreeRoaming
var bool bDigesting;	// Whether unable to hunt currently
var float ThrustDist;
var bool bAttacking;

var string debugstring;


function CheckForEnemies()
{
}

function Texture PainSkin(int BodyPart)
{
}

function PreSetMovement()
{
	bCanJump = false;
	bCanWalk = false;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	ThrustDist = 200;
	bAttacking = false;
	HomeBase = Location;
}

function ZoneChange(ZoneInfo newZone)
{
	if (!newZone.bWaterZone)
	{
		SetPhysics(PHYS_Falling);
		GotoState('OutOfWater');
	}
	else
	{
		SetPhysics(PHYS_Swimming);
	}
}

function bool PickEnemy()
{
	local int count, pick;
	local DealieFish A;

	Enemy = None;
	
	// Pick a randomly distributed fish	
	foreach VisibleActors(class'DealieFish', A)
	{
		if (A.Health > 0)
			count++;
	}
	pick = FRand() * count;
	foreach VisibleActors(class'DealieFish', A)
	{
		if (A.Health > 0)
		{
			if (--pick <= 0)
			{
				Enemy = A;
				break;
			}
		}
	}
	return(Enemy!=None);
}

// Choose a side-step destination closer to target than we are now
function SideStepDestination(vector targetpos)
{	
	local vector ToTarget, ToSide, ToHeight;
	
	ToTarget = targetpos - Location;
	if (ToTarget.Z > 0)
		ToHeight = vect(0,0,1);
	else
		ToHeight = vect(0,0,-1);
	ToTarget.Z = 0;
	ToTarget = Normal(ToTarget);
	ToSide = ToTarget cross vect(0,0,1);
	if (FRand() < 0.5)
		ToSide *= -1;
	Destination = Location +
		ToTarget*RandRange(50, 100) +
		ToSide*RandRange(25,50) +
		ToHeight*RandRange(40,50) +
		vect(0,0,1)*RandRange(-10,10);
}



//============================================================
// Animation functions
//============================================================

function PlayDeath(name DamageType)	          { PlayAnim  ('death', 1.0, 0.1);     }


//============================================================
// States
//============================================================

auto state Idle
{
	function BeginState()
	{
		ZoneChange(Region.Zone);
	}
	
Begin:
	LoopAnim('swim', 1.0, 0.1);
CanSee:
	if (PlayerCanSeeMe())
		GotoState('FreeRoaming');
	Sleep(1);
	Goto('CanSee');
}


state FreeRoaming
{
	ignores Bump, SeePlayer;

	function BeginState()
	{
		RotationRate.Yaw = 3000;
		bDigesting = true;
		SetTimer(RandRange(2, 15), false);	// Start Digesting
		Enable('SeePlayer');
	}

	function Timer()
	{
		bDigesting = false;
		PickTargetLocation();
	}
		
	function PickTargetLocation()
	{
		// Try to find an enemy
		if (!bDigesting && PickEnemy())
			GotoState('CuttleHunting', 'PickDest');

		targetloc = Location + Velocity*2 + VRand()*RandRange(100,500);

		// Make sure target location is in water
		
	}

	function Touch(actor Other)
	{
		if (DealieFish(Other) == None)
		{	// Run away if not a dealie
			Destination = Location + (Location - Other.Location) * 3 + VRand()*2;
			GotoState('Flee');
		}
	}

	function PickDestination()
	{
		// If target is reached, pick a new target
		if (VSize(targetloc - Location) < 100)
		{
			GotoState('FreeRoaming', 'PickTarget');
		}
		else if (!pointReachable(targetloc))
		{
			targetloc = HomeBase;
			SideStepDestination(targetloc);
		}
		else
		{
			SideStepDestination(targetloc);
		}
	}

Begin:
	SetPhysics(PHYS_Swimming);
PickTarget:
	PickTargetLocation();
PickWayPoint:
	PickDestination();
Swim:
	MoveTo(Destination);
	if (FRand()<0.3)
		Sleep(RandRange(0.1,1.0));
	Goto('PickWaypoint');
}


// Flee to destination, then resume FreeRoaming
state Flee
{
	ignores HearNoise, SeePlayer, Bump, Touch;
	
Begin:
	LoopAnim('Swim', 1.0, 0.1);
	MoveTo(Destination);
	Sleep(1);
	GotoState('FreeRoaming');
}


state CuttleHunting
{
	ignores Bump;
	
	function BeginState()
	{
		RotationRate.Yaw = default.RotationRate.Yaw;
		SetTimer(0.2, true);	// Search for nearby prey
	}

	function SeePlayer(actor seen)
	{
		// chance of following player
	}

	function PickDestination()
	{
		local vector ToEnemy;

		if (Enemy == None)
			GotoState('FreeRoaming');
		else if (Enemy.Health<=0)
			GotoState('FreeRoaming');
		else
		{
			ToEnemy = Enemy.Location - Location;
			SideStepDestination(Enemy.Location);
		}
	}
	
	function Touch(actor Other)
	{
		if (DealieFish(Other) == None)
		{	// Run away if not a dealie
			Destination = Location + (Location - Other.Location) * 5;
			bAttacking = false;
			SetPhysics(PHYS_Swimming);
			GotoState('Flee');
		}
		else if (bAttacking && (Other==Enemy))
		{	// Thrusting at this dealie
			Enemy.TakeDamage(Enemy.Health + 30, self, Enemy.Location, vect(0,0,0), 'eaten');
			Enemy = None;
		}
	}
	
	function Timer()
	{	// Check for any targets close enough for a thrust
		local DealieFish A;
		local vector ToEnemy;

		foreach RadiusActors(class'DealieFish', A, ThrustDist, Location)
		{
			if (A.Health > 0)
			{
				ToEnemy = A.Location - Location;
				if ((VSize(ToEnemy) < ThrustDist) && Abs(ToEnemy.Z)<50)
				{
					Enemy = A;
					SetTimer(0, false);
					GotoState('CuttleHunting', 'ThrustAttack');
					break;
				}
			}
		}
	}

Begin:
	SetPhysics(PHYS_Swimming);
PickDest:
	PickDestination();
Swim:
	if (Enemy!=None)
		StrafeFacing(Destination, Enemy);
	if (FRand()<0.3)
		Sleep(RandRange(0.1,1.0));
	Goto('PickDest');
ThrustAttack:
	Disable('SeePlayer');
	SetPhysics(PHYS_Falling);
	bAttacking = true;

	// Put fish to sleep	
	Enemy.bMovable = false;
	TurnToward(Enemy);
	
	// .5 second thrust move covering distance to 
	Destination = Enemy.Location;
	Velocity = (Destination - Location) * 2 * 2;
	Acceleration = Velocity / 0.5;
	PlayAnim('AttackA', 1.0, 0.1);
	Sleep(0.5);

	// If the fish survived, wake him up
	if (Enemy!=None)
	{
		Enemy.bMovable = true;
	}
	
	LoopAnim('Swim', 1.0, 0.1);
	SetPhysics(PHYS_Swimming);
	bAttacking = false;
	Enable('SeePlayer');

	GotoState('FreeRoaming');
}


State OutOfWater
{
	ignores Bump, Touch, SeePlayer, HearNoise;

Begin:
}


simulated function Debug(Canvas canvas, int mode)
{
	local vector ToEnemy;

	Super.Debug(canvas, mode);

	Canvas.DrawText("Cuttle:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" WaterSpeed: "$WaterSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText(" Destination: "$Destination);
	Canvas.CurY -= 8;
	Canvas.DrawText(" Enemy: "$Enemy);
	Canvas.CurY -= 8;
	Canvas.DrawText(" DebugString: "$DebugString);
	Canvas.CurY -= 8;
	Canvas.DrawText(" bAttacking: "$bAttacking);
	Canvas.CurY -= 8;
	Canvas.DrawText(" MoveTimer: "$MoveTimer);
	Canvas.CurY -= 8;

	if (Enemy!=None)
		ToEnemy = Enemy.Location - Location;
	else
		ToEnemy = targetloc - Location;
	
	Canvas.DrawText(" ToTarget: "$ToEnemy);
	Canvas.CurY -= 8;
	
	// If within range, thrust attack at the fish
	if (VSize(ToEnemy) < 200)
		Canvas.SetColor(255, 255, 255);
	else
		Canvas.SetColor(255, 0, 0);
	Canvas.DrawText(" In Range");
	Canvas.CurY -= 8;
	
	if (Abs(ToEnemy.Z)<40)
		Canvas.SetColor(255, 255, 255);
	else
		Canvas.SetColor(255, 0, 0);
	Canvas.DrawText(" Within Z");
	Canvas.CurY -= 8;

	Canvas.DrawLine3D(Location, Location+ToEnemy, 0,   0, 255);
	Canvas.DrawLine3D(Location, Destination,    255, 255, 255);
}

defaultproperties
{
     bBurnable=False
     bCanStrafe=True
     ClassID=17
     PeripheralVision=-1.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     HitSound1=Sound'CreaturesSnd.Fish.fish03'
     HitSound2=Sound'CreaturesSnd.Fish.fish03'
     HitSound3=Sound'CreaturesSnd.Fish.fish03'
     Die=Sound'CreaturesSnd.Fish.fish05'
     Die2=Sound'CreaturesSnd.Fish.fish05'
     Die3=Sound'CreaturesSnd.Fish.fish05'
     DrawScale=3.000000
     SoundRadius=20
     SoundVolume=90
     SoundPitch=121
     AmbientSound=Sound'EnvironmentalSnd.Bubbles.bubbleswater01L'
     TransientSoundRadius=800.000000
     CollisionRadius=30.000000
     CollisionHeight=9.000000
     bBlockActors=False
     bBlockPlayers=False
     Buoyancy=100.000000
     RotationRate=(Pitch=0,Yaw=30000,Roll=0)
     Skeletal=SkelModel'creatures.Cuttle'
}
