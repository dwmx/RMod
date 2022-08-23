//=============================================================================
// Baracuda.
//=============================================================================
class Baracuda expands ScriptPawn;


/* Description:
	Swims around and eats things.
	uses collision joint to sense collisions.  Swims away quickly upon touch.

   ANIMS:
	Death
	Turn
	Flop

   TODO:
*/

var(Sounds) sound	SwimSound;
var float AirTime;


// FUNCTIONS ------------------------------------------------------------------

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

function SpeechTimer()
{
	IgnoreEnemy=None;
}

function Texture PainSkin(int BodyPart)
{
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
		PlaySound(SwimSound, SLOT_Interact, 0.33, false,, 0.95 + (FRand() * 0.1));
	}
}


function ZoneChange( ZoneInfo NewZone )
{
	Super.ZoneChange(NewZone);
	if (!NewZone.bWaterZone)
	{
		AmbientSound = None;
		if (Physics != PHYS_Falling)
		{
			MoveTimer = -1;
			SetPhysics(PHYS_Falling);
		}
	}
	else if (AmbientSound == None)
	{
		AmbientSound=Default.AmbientSound;
	}
}

function Landed(vector HitNormal, actor HitActor)
{
	local rotator newRotation;

	Super.Landed(HitNormal, HitActor);

	SetPhysics(PHYS_None);
	SetTimer(0.2 + FRand(), false);
	newRotation = Rotation;
	newRotation.Pitch = 0;
	newRotation.Roll = 16384;
	SetRotation(newRotation);
	GotoState('Flopping');
}


// ANIMATIONS -----------------------------------------------------------------
function PlayWaiting(optional float tween)			{	LoopAnim('swim', 1.0, 0.1);	}
function PlayMoving(optional float tween)			{	LoopAnim('swim', 1.0, 0.1);	}
function PlayInAir(optional float tween)			{	LoopAnim('swim', 1.0, 0.1);	}
function PlayDeath(name DamageType)					{	PlayAnim('death',1.0, 0.1);	}


// STATES ---------------------------------------------------------------------

// Fleeing state is used to back off, circle around, for another charge
State Fleeing
{
ignores HitWall;

Begin:
	SpeechTime = RandRange(3,10);	// When this timer expires, return to attack
	IgnoreEnemy=Enemy;
	Enemy=None;
	GotoState('Roaming');
}


state Fighting
{
ignores SeePlayer, HearNoise;

	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}


Begin:
	// Damage check

	GotoState('Fleeing');
}


State Flopping
{
	ignores Touch, Bump, SeePlayer, HearNoise, EnemyAcquired;

	function Landed(vector HitNormal, actor HitActor)
	{
		local rotator newRotation;

		SetPhysics(PHYS_None);
		SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
		newRotation = Rotation;
		newRotation.Pitch = 0;
		newRotation.Roll = 16384;
		SetRotation(newRotation);
	}
		
	function Timer()
	{
		AirTime += 1;
		if (AirTime > 25 + 20 * FRand())
		{
			Died(self, 'Suffocated', Location);
		}
		else
		{
			SetPhysics(PHYS_Falling);
			Velocity = 200 * VRand();
			Velocity.Z = 60 + 160 * FRand();
			DesiredRotation.Pitch = Rand(8192) - 4096;
			DesiredRotation.Yaw = Rand(65535);
		}		
	}

	function AnimEnd()
	{
		PlayAnim('Swim', 0.1 * FRand());
	}

	function BeginState()
	{
		SetPhysics(PHYS_Falling);
	}
}

defaultproperties
{
     FightOrFlight=0.700000
     FightOrDefend=1.000000
     HighOrLow=1.000000
     bRoamHome=True
     bGlider=True
     bBurnable=False
     GroundSpeed=0.000000
     WaterSpeed=300.000000
     AccelRate=400.000000
     JumpZ=0.000000
     WalkingSpeed=300.000000
     ClassID=16
     Health=50
     HitSound1=Sound'CreaturesSnd.Fish.fish07'
     HitSound2=Sound'CreaturesSnd.Fish.fish07'
     HitSound3=Sound'CreaturesSnd.Fish.fish07'
     Die=Sound'CreaturesSnd.Fish.fish08'
     Die2=Sound'CreaturesSnd.Fish.fish08'
     Die3=Sound'CreaturesSnd.Fish.fish08'
     SoundRadius=20
     SoundVolume=115
     SoundPitch=54
     AmbientSound=Sound'CreaturesSnd.Fish.fish01L'
     TransientSoundRadius=800.000000
     CollisionRadius=65.000000
     CollisionHeight=15.000000
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     Mass=50.000000
     Buoyancy=50.000000
     RotationRate=(Yaw=22768)
     Skeletal=SkelModel'creatures.Baracuda'
}
