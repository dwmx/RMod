//=============================================================================
// Manowar.
//=============================================================================
class Manowar expands ScriptPawn;


/* Description:
	Drifts around, staying close to homebase.  When an enemy encroaches on his MeleeRange, he
	electrifies the water.
	
*/


var() float RoamRadius;			// Distance allowed to travel from home
var() float PulseRadius;		// Radius for detection and pulse damage
var() float RefireDelay;		// Delay between firing
var bool poweringup;

var(Sounds) Sound	ChargeupSound;
var(Sounds) Sound	PulseSound;


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

	HomeBase = Location;	// don't wander too far from home
}

function CheckForEnemies()
{
}

function Texture PainSkin(int BodyPart)
{
	return None;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{	// Force gib death
	Super.Died(Killer, 'gibbed', HitLocation);
}

//============================================================
// Animation functions
//============================================================

function PlayDeath(name DamageType)	          { PlayAnim  ('death', 1.0, 0.1);     }

function PlayWaiting(optional float tween)
{
	LoopAnim('swim', 1.0);
}


//============================================================
// States
//============================================================

auto State Swimming
{
	ignores Bump, Touch, HearNoise;
	
	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Mom, name DamageType, int joint)
	{
		if (DamageType=='thrownweaponblunt'||DamageType=='thrownweaponsever'||DamageType=='thrownweaponbluntsever')
			GotoState('pulse');

		return Super.JointDamaged(Damage, EventInstigator, HitLoc, Mom, DamageType, joint);
	}

	function PickDestination()
	{
		// Pick a destination near home
		Destination = HomeBase + VRand()*RoamRadius;
		Destination.Z = Location.Z;
	}

	function SeePlayer(actor Seen)
	{
		Enemy = Pawn(Seen);
		
		// Don't attack unless at surface
		if (HeadRegion.Zone.bWaterZone)
			return;
			
		//TODO: Need to move this if he can attack non-players
		if((Enemy.Region.Zone.bWaterZone || Enemy.FootRegion.Zone.bWaterZone)
			&& VSize(Enemy.Location-Location) < PulseRadius)
		{
			GotoState('pulse');
		}
	}

	function BeginState()
	{
		if (!Region.Zone.bWaterZone)
			SetPhysics(PHYS_FALLING);
		LoopAnim('swim', 1.0, 0.1);
	}
	
Begin:
Move:
	// Drift until something threatening comes near
	PickDestination();
//	Spawn(class'Ripple');
	MoveTo(Destination);
	Goto('Move');
}


State Pulse
{
	ignores Bump, SeePlayer, Touch, HearNoise;
	
	function Timer()
	{
		// Toggle texture of brain (or whole thing)
		if (SkelGroupSkins[1] == texture'manowarmowbright')
			SkelGroupSkins[1] = texture'manowarmowdim';
		else
			SkelGroupSkins[1] = texture'manowarmowbright';
		
		
		if (poweringup)
		{
			ScaleGlow+=0.1;
		}
		else
		{
			ScaleGlow-=0.2;
		}
	}

	function HurtWaterRadius( float DamageAmount, float DamageRadius, name DamageType, float Momentum, vector HitLocation )
	{
		local pawn Victim;
		local float damageScale, dist;
		local vector dir;
		
		foreach VisibleCollidingActors( class 'Pawn', Victim, DamageRadius, HitLocation )
		{
			if(Victim != self && Victim != Owner &&
				((Victim.Region.Zone.bWaterZone && Victim.Region.Zone == FootRegion.Zone)
				|| (Victim.FootRegion.Zone.bWaterZone && Victim.FootRegion.Zone == FootRegion.Zone)))
			{
				dir = Victim.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist; 
				damageScale = 1 - FMax(0,(dist - Victim.CollisionRadius)/DamageRadius);

				Victim.JointDamaged(damageScale * DamageAmount,
					Instigator,
					Victim.Location - 0.5 * (Victim.CollisionHeight + Victim.CollisionRadius) * dir,
					(damageScale * Momentum * dir),
					DamageType,
					0);

				Victim.AddVelocity(damageScale*Momentum*dir);
			} 
		}
	}

Begin:
Powerup:
	poweringup = true;
	PlaySound(ChargeupSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	SetTimer(0.05, true);
	Sleep(2);
	SetTimer(0, false);
Pulse:
	// Damage anything in the water within the damage radius
	Spawn(class'ManowarEffect',,, Location + vect(0, 0, 15));
	Spawn(class'ManowarEffect',,, Location - vect(0, 0, 10));
	PlaySound(PulseSound, SLOT_Interact,,,, 1.0 + FRand()*0.2-0.1);
	HurtWaterRadius(30, PulseRadius, 'stung', 1000, Location - vect(0, 0, 20)); // Guarantee to sting in the water

Powerdown:
	poweringup = false;
	SetTimer(0.05, true);
	Sleep(1);
	SetTimer(0, false);

	SkelGroupSkins[1] = texture'manowarmowdim';
	ScaleGlow = default.ScaleGlow;
	LoopAnim('Swim');
	Sleep(RefireDelay);
	GotoState('Swimming');
}


function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	Canvas.DrawText("Manowar:");
	Canvas.CurY -= 8;
	Canvas.DrawLine3D(HomeBase, Location, 255, 0, 0);
}

defaultproperties
{
     RoamRadius=100.000000
     PulseRadius=500.000000
     RefireDelay=3.000000
     bBurnable=False
     GroundSpeed=0.000000
     WaterSpeed=25.000000
     AccelRate=5.000000
     JumpZ=0.000000
     AirControl=0.000000
     ClassID=4
     PeripheralVision=-1.000000
     BaseEyeHeight=25.000000
     EyeHeight=25.000000
     Health=120
     Intelligence=BRAINS_REPTILE
     HitSound1=Sound'CreaturesSnd.Fish.fish01'
     HitSound2=Sound'CreaturesSnd.Fish.fish01'
     HitSound3=Sound'CreaturesSnd.Fish.fish01'
     Die=Sound'CreaturesSnd.Fish.fish08'
     Die2=Sound'CreaturesSnd.Fish.fish08'
     Die3=Sound'CreaturesSnd.Fish.fish08'
     LookDegPerSec=0.000000
     Style=STY_Translucent
     DrawScale=2.500000
     SoundRadius=30
     SoundVolume=190
     SoundPitch=77
     AmbientSound=Sound'CreaturesSnd.Dangler.danglerhum01L'
     TransientSoundRadius=800.000000
     CollisionRadius=32.000000
     CollisionHeight=36.000000
     Buoyancy=101.000000
     RotationRate=(Pitch=0,Yaw=5000,Roll=0)
     bNoSurfaceBob=True
     Skeletal=SkelModel'creatures.manowar'
}
