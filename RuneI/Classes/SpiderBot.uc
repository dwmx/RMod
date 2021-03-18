//=============================================================================
// SpiderBot.
//=============================================================================
class SpiderBot expands ScriptPawn;

/*
// TODO:

- Finish SteamerBot!
- If the player is too far, retract the blades and follow


// ANIMATION FUNCTIONS

XSI LOAD betty_antic
XSI LOAD betty_antic_spin
XSI LOAD betty_attack
XSI LOAD betty_attack_ready
XSI LOAD bomber_antic
XSI LOAD bomber_attack
XSI LOAD idleA
XSI LOAD steamer_antic
XSI LOAD steamer_attack
XSI LOAD steamer_return
XSI LOAD walkA
*/

// Betty Vars
var() float BounceZ;
var() float HorizontalThrust;
var() float BettyRange;
var() int BettyDamage;
var vector Direction;
var vector HomeLocation;
var(Sounds) Sound	SpinSoundLOOP;
var(Sounds) Sound	BounceSound;

// Bomber Vars
var int BombCount;
var ParticleSystem BombFire;
var(Sounds) Sound	LaunchFireSound;

var(Sounds) Sound	LaunchSpin;
var(Sounds) Sound	BurnOut;

// Generic sounds
var(Sounds) Sound	HitFlesh;
var(Sounds) Sound	HitWood;
var(Sounds) Sound	HitStone;
var(Sounds) Sound	HitMetal;
var(Sounds) Sound	HitDirt;
var(Sounds) Sound	HitShield;
var(Sounds) Sound	HitWeapon;
var(Sounds) Sound	HitBreakableWood;
var(Sounds) Sound	HitBreakableStone;

var(Sounds) float	PitchDeviation;		// Vary pitch of sounds by +/- this percentage

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_WEAPON;
}

//============================================================
//
// PainSkin
//
//============================================================
function Texture PainSkin(int BodyPart)
{
	return None;
}

//============================================================
//
// Died
// 
// TODO:  Spawn out metal spiderbot gibs
//============================================================

function Died(pawn Killer, name damageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
	Spawn(class'SpiderBotExplosion',,, Location);
	Destroy();
}

//------------------------------------------------
//
// Animation Functions
//
//------------------------------------------------
function PlayWaiting(optional float tween)
{
	LoopAnim('idleA', 1.0, tween);
}
function PlayMoving(optional float tween)
{
	LoopAnim('walkA', 1.0, tween);	
}
function PlayTurning(optional float tween)
{
	PlayAnim('walkA', 1.0, tween);
}

// Tween functions
function TweenToWaiting(float time)
{
	TweenAnim ('idleA', time);
}
function TweenToMoving(float time)
{
	TweenAnim ('walkA', time);
}

//=============================================================================
//
// SpawnHitEffect
//
// Spawns an effect based upon what was struck
//=============================================================================

function SpawnHitEffect(vector HitLoc, vector HitNorm, Actor HitActor)
{	
	local int i,j;
	local EMatterType matter;
	local vector traceEnd, traceStart;
	local float traceDist;
	local rotator rot;

	if(HitActor == None)
		return;

	// Determine what kind of matter was hit
	if(HitActor.IsA('LevelInfo'))
	{
		matter = HitActor.MatterTrace(HitLoc, Location, 20);
	}
	else
	{
		matter = HitActor.MatterForJoint(0);
	}

	PlayHitMatterSound(matter);

	// Create effects
	switch(matter)
	{
		case MATTER_FLESH:
			if(HitActor.IsA('Sark') || HitActor.IsA('SarkRagnar'))
				Spawn(class'SarkBloodMist',,, HitLoc, rotator(HitNorm)); // Sark blood
			else
				Spawn(class'BloodMist',,, HitLoc, rotator(HitNorm));

			break;
		case MATTER_WOOD:
			break;
		case MATTER_STONE:
			Spawn(class'HitStone',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_METAL:
			break;
		case MATTER_EARTH:
			Spawn(class'GroundDust',,, HitLoc, rotator(HitNorm));
			break;
		case MATTER_BREAKABLEWOOD:
			break;
		case MATTER_BREAKABLESTONE:
			break;
		case MATTER_WEAPON:
			break;
		case MATTER_SHIELD:
			break;
		case MATTER_ICE:
			break;
		case MATTER_WATER:
			break;
		case MATTER_SNOW:
			break;
	}
}

//============================================================
//
// PlayHitMatterSound
//
//============================================================

function PlayHitMatterSound(EMatterType matter)
{
	switch(matter)
	{
		case MATTER_FLESH:
			PlaySound(HitFlesh, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_WOOD:
			PlaySound(HitWood, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_STONE:
			PlaySound(HitStone, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_METAL:
			PlaySound(HitMetal, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_EARTH:
			PlaySound(HitDirt, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_BREAKABLEWOOD:
			PlaySound(HitBreakableWood, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_BREAKABLESTONE:
			PlaySound(HitBreakableStone, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_WEAPON:
			PlaySound(HitWeapon, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_SHIELD:
			PlaySound(HitShield, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_ICE:
		case MATTER_WATER:
			break;
	}

	MakeNoise(1.0);
}

//============================================================
//
// Fighting
//
//============================================================

state Fighting
{
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function ChooseBotType()
	{
		local float f;
		
		f = FRand();

		if(f < 0.5)
		{ // Betty Bot
			NextState = 'BettyAttack';
			SkelMesh = 0;
		}
		else
		{ // Bomber Bot
			NextState = 'BomberAttack';
			SkelMesh = 1;
		}
/* NOTE:  For now, Steamer bot does nothing until we further design it		
		else
		{ // Steamer Bot
			NextState = 'SteamerAttack';
			SkelMesh = 2;
		}
*/		
	}
	
begin:
	ChooseBotType();
	GotoState(NextState);
}

// ===== BETTY BOT =====

//============================================================
//
// BettyAttack
//
//============================================================

state BettyAttack
{	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function BeginState()
	{
		Acceleration = vect(0, 0, 0);
		Velocity = vect(0, 0, 0);
	}
	
begin:
	PlayAnim('betty_antic', 1.0, 0.1);
	FinishAnim();
	
	PlayAnim('betty_attack', 1.0, 0.2);
	FinishAnim();
	GotoState('Bouncing');
}

//============================================================
//
// Bouncing
//
//============================================================

state Bouncing
{	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	//--------------------------------------------------------
	//
	// BeginState
	//
	//--------------------------------------------------------

	function BeginState()
	{	
		AmbientSound = SpinSoundLOOP;
		HomeLocation = Location;	
		bBounce = true;
		ThrustUp();
	}		

	//--------------------------------------------------------
	//
	// EndState
	//
	//--------------------------------------------------------

	function EndState()
	{	// Stop looping sound
		AmbientSound = None;
	}

	//--------------------------------------------------------
	//
	// ThrustUp
	//
	//--------------------------------------------------------
		
	function ThrustUp()
	{
		local float speed;
		local vector dist;
		
		SetPhysics(PHYS_Falling);
		Velocity.Z = BounceZ + FRand() * (BounceZ * 0.25);

		// Bounce the BettyBot towards its target, or if
		// the bot doesn't have a target, return it to waiting
		speed = FRand() * HorizontalThrust;

		if(Enemy == None)
		{
			GotoState('ReturnToWaiting');
		}
		else
		{
			dist = Enemy.Location - Location;
			
			// If the enemy is too far away, return the bot to 
			// Charging
			if(VSize(dist) > BettyRange)
			{
				GotoState('ReturnToWaiting');
			}
			
			dist.Z = 0;
			dist = Normal(dist);
			
			Velocity.X = dist.X * speed;
			Velocity.Y = dist.Y * speed;
		}
	}

	//--------------------------------------------------------
	//
	// Landed
	//
	//--------------------------------------------------------

	function Landed(vector HitNormal, actor HitActor)
	{
		HitWall(HitNormal, HitActor);
	}

	//--------------------------------------------------------
	//
	// HitWall
	//
	//--------------------------------------------------------
	
	function HitWall(vector HitNormal, actor HitWall)
	{	
		PlaySound(BounceSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);

		if(HitNormal.Z > 0.5)
		{
			ThrustUp();
		}
		else
		{
			Velocity = HitNormal * 100;
			SetPhysics(PHYS_Falling);
		}

		if(HitWall != None && !HitWall.IsA('SpiderBot'))
		{
			HitWall.JointDamaged(BettyDamage, self, Location, Velocity * 0.5, 'bluntsever', 0);
			SpawnHitEffect(Location, HitNormal, HitWall);			
		}
	}

	//--------------------------------------------------------
	//
	// PickDirection
	//
	//--------------------------------------------------------

	function PickDirection()
	{
		local vector X, Y, Z;
		
		GetAxes(Rotation, X, Y, Z);
		
		Direction = Location - (X * 10) - (Y * 10);
	}
	
begin:

spin:
	PickDirection();
	TurnTo(Direction);
	Goto('begin');
}

//============================================================
//
// ReturnToWaiting
//
//============================================================

state ReturnToWaiting
{
begin:
	PlayWaiting(0.1);
	SetPhysics(PHYS_Falling);
	GotoState('Waiting');
}

// ===== BOMBER BOT =====

//============================================================
//
// BomberAttack
//
//============================================================

state BomberAttack
{		
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	//--------------------------------------------------------
	//
	// BeginState
	//
	//--------------------------------------------------------

	function BeginState()
	{
		Acceleration = vect(0, 0, 0);
		Velocity = vect(0, 0, 0);
	}

	//--------------------------------------------------------
	//
	// LaunchBomb
	//
	//--------------------------------------------------------
	
	function LaunchBomb()
	{
		local int traj;
		local vector adjust;
		local actor bomb;
		
		bomb = Spawn(class'SpiderBomb', self,, Location, Rotation);
		bomb.SetPhysics(PHYS_Falling);
		bomb.bCollideWorld = true;
		
		if(Enemy != None)
		{ // Throw bombs directly at enemy
			traj = (45 + Rand(25)) * 65536 / 360;
			adjust = VRand() * 10; // Random adjustment to compensate for perfect accuracy
			bomb.Velocity = CalcArcVelocity(traj, Location, Enemy.Location + adjust);
		}
		else
		{ // No enemy, so randomly emit bombs		
			bomb.Velocity.Z = 250 + FRand() * 250;
			bomb.Velocity.X = (FRand() - 0.5) * 250;
			bomb.Velocity.Y = (FRand() - 0.5) * 250;
		}
	}

	function CatchFire()
	{
		BombFire = Spawn(class'fire',,, Location,);		
		AttachActorToJoint(BombFire, JointNamed('offset'));
	}	
	
	function ExplodeBot()
	{
		// Set up the fire to remove itself
		BombFire.bSystemOneShot = true;
		BombFire.bOneShot = true;
		
		Died(None, '', Location);
	}
	
begin:
	PlaySound(LaunchSpin, SLOT_Interface,,,, 1.0 + FRand()*0.2-0.1);

	PlayAnim('bomber_antic', 1.0, 0.1);
	FinishAnim();
	PlayAnim('bomber_attack', 1.0, 0.1);
	FinishAnim();
	
	BombCount = 6 + Rand(6);

	while(BombCount-- > 0)
	{
		if ((BombCount & 1)==0)
			PlaySound(LaunchFireSound, SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
		else
			PlaySound(LaunchFireSound, SLOT_Misc,,,, 1.0 + FRand()*0.2-0.1);

		LaunchBomb();
		Sleep(0.2);
	}
	
	Sleep(0.3);
	CatchFire();
	PlaySound(BurnOut, SLOT_Interface,,,, 1.0 + FRand()*0.2-0.1);
	Sleep(4.0);
	ExplodeBot();
}


// ===== STEAMER BOT =====

//============================================================
//
// SteamerAttack
//
//============================================================

state SteamerAttack
{	
	function AmbientSoundTimer()
	{
		PlayAmbientFightSound();
	}

	function BeginState()
	{
		Acceleration = vect(0, 0, 0);
		Velocity = vect(0, 0, 0);
	}
	
begin:	
	PlayAnim('steamer_antic', 1.0, 0.1);
	FinishAnim();
	PlayAnim('steamer_attack', 1.0, 0.1);
	FinishAnim();
	Sleep(3.0);
	PlayAnim('steamer_return', 1.0, 0.1);
	FinishAnim();
	GotoState('Waiting');
}

defaultproperties
{
     BounceZ=260.000000
     HorizontalThrust=140.000000
     BettyRange=800.000000
     BettyDamage=8
     SpinSoundLOOP=Sound'CreaturesSnd.SpiderBot.spiderspin01L'
     BounceSound=Sound'CreaturesSnd.SpiderBot.spiderbounce01'
     LaunchFireSound=Sound'CreaturesSnd.SpiderBot.spiderlaunch01'
     LaunchSpin=Sound'CreaturesSnd.SpiderBot.spidergear02'
     BurnOut=Sound'CreaturesSnd.SpiderBot.spiderburn01'
     HitFlesh=Sound'WeaponsSnd.ImpFlesh.impfleshsword07'
     HitWood=Sound'WeaponsSnd.ImpWood.impactwood15'
     HitStone=Sound'WeaponsSnd.ImpStone.impactstone07'
     HitMetal=Sound'WeaponsSnd.ImpMetal.impactmetal17'
     HitDirt=Sound'WeaponsSnd.ImpEarth.impactearth03'
     HitShield=Sound'WeaponsSnd.Shields.shield03'
     HitWeapon=Sound'WeaponsSnd.Swords.sword03'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     PitchDeviation=0.090000
     FightOrFlight=1.000000
     FightOrDefend=1.000000
     ShadowScale=0.750000
     bCanStrafe=True
     bAlignToFloor=True
     MeleeRange=160.000000
     GroundSpeed=160.000000
     JumpZ=290.000000
     MaxStepHeight=10.000000
     ClassID=13
     SightRadius=1500.000000
     PeripheralVision=-1.000000
     Health=50
     Intelligence=BRAINS_REPTILE
     Die=Sound'OtherSnd.Explosions.explosion12'
     SoundRadius=50
     TransientSoundRadius=1200.000000
     CollisionRadius=18.000000
     CollisionHeight=8.000000
     Mass=30.000000
     RotationRate=(Pitch=0,Yaw=150000,Roll=0)
     Skeletal=SkelModel'creatures.SpiderBot'
}
