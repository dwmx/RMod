//=============================================================================
// Jellyfish.
//=============================================================================
class Jellyfish expands ScriptPawn;


/* Description:
	Stays close to home roaming up and drifting down.  Sink upon death.
	
   TODO:
*/

var bool bDrifting;
var vector HomeBase;
var() float MaxZDeviation;		// Maximum deviation on the Z axis allowed
var() float MinMoveZ;			// Minimum upward thrust amount
var() float MaxMoveZ;			// Maximum upward thrust amount
var bool glowingUp;				// glow is increasing

var(Sounds) sound	ThrustSound;


function PreSetMovement()
{
	bCanWalk = false;
	bCanJump = false;
	bCanFly = false;
	bCanSwim = false;
	MinHitWall = -0.6;
}


function CheckForEnemies()
{
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	HomeBase = Location;
	Destination = Location;
}

function Texture PainSkin(int BodyPart)
{
}

function ZoneChange(ZoneInfo newZone)
{
	if (!newZone.bWaterZone)
	{
		AmbientSound = None;
		SetPhysics(PHYS_Falling);
		GotoState('OutOfWater');
	}
	else
	{
		if (AmbientSound == None)
			AmbientSound=Default.AmbientSound;

		if (Physics != PHYS_Swimming)
			SetPhysics(PHYS_Swimming);
	}
}


function bool JointDamaged( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType, int joint)
{
	local bool bAlreadyDead;

	bAlreadyDead = (Health <= 0);

	momentum = momentum/Mass;
	AddVelocity( momentum ); 
	Health -= Damage;
	if ( Health < -20 )
	{
		//Spawn(class'Bloodspurt');
		Destroy();
	}
	else if ( !bAlreadyDead && (Health <= 0) )
	{
		GotoState('Dead');
	}
	return true;
}

// Rate is in range [0..1]
function VaryGlow(float rate)
{
	if (glowingUp)
	{
		ScaleGlow += rate;
		if (ScaleGlow>0.7)
			glowingUp = false;
	}
	else
	{
		ScaleGlow -= rate;
		if (ScaleGlow<0.2)
			glowingUp = true;
	}
}

//=============================================================================
//
// FootStep Notify
// 
//=============================================================================
function FootStep()
{
	local EMatterType matter;
	local vector end;
	local sound snd;
	local int i;

	if(bFootsteps && Region.Zone.bWaterZone)
	{
		PlaySound(ThrustSound, SLOT_Interact, 0.33, false,, 0.95 + (FRand() * 0.1));
	}
}


//============================================================
// Animation functions
//============================================================
function PlayDeath(name DamageType)	          { PlayAnim  ('death', 1.0, 0.1);     }



//============================================================
// States
//============================================================

auto State Swimming
{
	ignores Bump, SeePlayer, HearNoise;
	
	function PickDestination()
	{
		local vector deviation, correction;
		local float correctionamount;
		
		deviation = Location - HomeBase;
		if (deviation.Z > MaxZDeviation-MaxMoveZ)
			bDrifting = true;
		else if (deviation.Z < -MaxZDeviation)
			bDrifting = false;
		else if (bDrifting)
			bDrifting = false;
		else if (deviation.Z <= 0)
			bDrifting = false;
		else
			bDrifting = FRand() < 0.4;
			
		if (!bDrifting)
		{
			correction = HomeBase - Location;
			correctionamount = FRand() * 0.2;
			Destination = Location + VRand() + correction*correctionamount;
			Destination.Z += RandRange(MinMoveZ, MaxMoveZ);
		}
	}
	
	function HitWall(vector HitNormal, actor HitWall)
	{
		Destination = Location + (HitNormal * 100);
		Buoyancy = Mass;
		SetTimer(0, false);
		GotoState('Flee');
	}

	function Touch(actor Other)
	{	// Sting and move
		Disable('Touch');
		Other.JointDamaged(2, self, location, vect(0,0,0), 'stung', 0);
		Destination = Location + (Location - Other.Location) * 4;
		Buoyancy = Mass;
		SetTimer(0, false);
		GotoState('Flee');
	}
	
	function BeginState()
	{
		ZoneChange(Region.Zone);
	}

	function Timer()
	{
		local vector tohome;

		VaryGlow(0.05);
		if (bDrifting)
		{
			// Check if reached destination
			tohome = HomeBase - Location;
			if (Abs(tohome.Z) > MaxZDeviation)
			{
//				SetTimer(0, false);
				GotoState('swimming', 'swim');
			}
		}
	}
	
Begin:
	SetTimer(0.1, true);
	if (Physics!=PHYS_Swimming)
		SetPhysics(PHYS_Swimming);
	Enable('Touch');
	Enable('HitWall');
Swim:
	PickDestination();
	if (bDrifting)
	{
		Buoyancy = Mass * 0.95;		// accel.z is -950 * .05
		PlayAnim('drift_tran', 1.0, 1.0);
	}
	else
	{
		Buoyancy = Mass;
		PlayAnim('walk', 1.0, 0.1);
		MoveTo(Destination);
		FinishAnim();
		Sleep(0.5);
		GotoState('Swimming');
	}
}


state Flee
{
	ignores Touch, Bump, SeePlayer, HearNoise;

	function HitWall(vector HitNormal, actor HitWall)
	{
		Destination = Location + (HitNormal * 100);
		GotoState('Flee', 'Move');
	}

	function Timer()
	{
		VaryGlow(0.2);
	}
	
Begin:
	SetTimer(0.1, true);
Move:
	MoveTo(Destination);
	GotoState('Swimming');
}


// If leaves water permanently, kill him
state OutOfWater
{
	function Landed(vector HitNormal, actor HitActor)
	{	// Landed on ground, kill him
		JointDamaged(Health+1, self, Location, vect(0,0,0), 'Suffocated', 0);
		SetTimer(0, false);
		GotoState('Dead');
	}
	
	function Timer()
	{	// Air exposure
		JointDamaged(Health+1, self, Location, vect(0,0,0), 'Suffocated', 0);
		GotoState('Dead');
	}
Begin:
	SetTimer(5, false);
}


State Dead
{
	ignores zonechange, footzonechange, headzonechange, falling, hitwall;

	function BeginState()
	{
		local rotator newrot;
		
		SkelGroupFlags[2] = SkelGroupFlags[2] | POLYFLAG_INVISIBLE;
		PlayAnim('Death', 1.0, 0.1);
		SetCollision(false,false,false);
		SetCollisionSize(CollisionRadius, 1);
		newrot = rot(0,0,0);
		newrot.Yaw = Rotation.Yaw;
		SetRotation(newrot);
		Buoyancy = 0.95 * Mass;
		Velocity.Z = FMax(0, Velocity.Z);
	}
	
	function Timer()
	{	// When lands on ground
		SetPhysics(PHYS_None);
		AnimRate = 0.0;
		RemoteRole = ROLE_DumbProxy;
	}
	
Begin:
	SetTimer(20, false);
}			
		

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Jellyfish:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" Destination:  "$Destination);
	Canvas.CurY -= 8;
	Canvas.DrawText(" MaxZDeviation:"$MaxZDeviation);
	Canvas.CurY -= 8;
	Canvas.DrawText(" bDrifting:    "$bDrifting);
	Canvas.CurY -= 8;

	Canvas.DrawLine3D(HomeBase, Location, 255, 0, 0);
}

defaultproperties
{
     MaxZDeviation=100.000000
     MinMoveZ=50.000000
     MaxMoveZ=75.000000
     bBurnable=False
     bCanStrafe=True
     GroundSpeed=0.000000
     ClassID=19
     SightRadius=1000.000000
     PeripheralVision=-1.000000
     BaseEyeHeight=18.000000
     bGibbable=False
     UnderWaterTime=-1.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     Intelligence=BRAINS_REPTILE
     HitSound1=Sound'CreaturesSnd.Fish.fish08'
     HitSound2=Sound'CreaturesSnd.Fish.fish08'
     HitSound3=Sound'CreaturesSnd.Fish.fish08'
     Die=Sound'CreaturesSnd.Fish.fish05'
     Die2=Sound'CreaturesSnd.Fish.fish05'
     Die3=Sound'CreaturesSnd.Fish.fish05'
     LookDegPerSec=0.000000
     bStasis=False
     Physics=PHYS_Swimming
     Style=STY_Translucent
     LODCurve=LOD_CURVE_NONE
     SoundRadius=21
     SoundVolume=152
     SoundPitch=30
     AmbientSound=Sound'CreaturesSnd.Fish.fish03L'
     TransientSoundRadius=800.000000
     CollisionRadius=18.000000
     CollisionHeight=18.000000
     bBlockActors=False
     bBlockPlayers=False
     bRotateToDesired=False
     Buoyancy=100.000000
     RotationRate=(Pitch=0,Roll=0)
     Skeletal=SkelModel'creatures.jellyfish'
}
