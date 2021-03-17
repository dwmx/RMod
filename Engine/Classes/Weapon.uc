//=============================================================================
// Parent class of all weapons.
//=============================================================================
class Weapon extends Inventory
	abstract
	native;
//	nativereplication;

#exec Texture Import File=Textures\Weapon.pcx Name=S_Weapon Mips=Off Flags=2

/*
   SOUND slot usage:
	SLOT_None				
	SLOT_Misc				HitXXXX
	SLOT_Pain				
	SLOT_Interact			DropSound
	SLOT_Ambient			AmbientSound
	SLOT_Talk				ThroughAir
	SLOT_Interface			Sheath,UnSheath
*/

// ----- STRUCTURES -----------------------------------------------------------

struct SwipeHit
{
	var Actor Actor;
	var int LowMask;
	var int HighMask;
};

// ----- VARIABLES ------------------------------------------------------------

var() enum EMeleeType
{
	MELEE_SWORD,
	MELEE_HAMMER,
	MELEE_AXE,
	MELEE_NON_STOW
} MeleeType;

var() bool bWeaponStay;				// Copy of weapon stays after being picked up
var() bool bCrouchTwoHands;			// Should use the two-handed anims when crouching	
var() bool bPoweredUp;
var bool bCanBePoweredUp;
var bool bPlayedDropSound;
var bool bClientPoweredUp;			// PowerUp effect active locally
var int HitMatterSoundCount;

var() byte StowMesh;
var() int Damage;
var() name DamageType;
var() name ThrownDamageType;
var() Texture BloodTexture;
var() int Rating;				// Higher rating means a better weapon
var() float WeaponSweepExtent;	// Extent of sweep lines
var() int SweepJoint1;
var() int SweepJoint2;
var() float ExtendedLength;
var() int RunePowerRequired;	// Power needed to powerup the weapon
var() float RunePowerDuration;	// Duration of the powerup (weapon-specific... some weapons are not time-based)
var() localized string PowerupMessage;
var() byte StabMesh;
var int TimerCount;				// Used for powerup pulsing
var() vector SweepVector;		// vector defining weapon direction in holders joint coords (usually (0,1,0))

var int FrameOfAttackAnim;	// TEST: for frame-rate independent attacks
var vector gB1,gE1,gB2,gE2;

var Actor StabbedActor;	// Actor that was stabbed by the weapon

var Actor LastThrower;	//RUNE: Last actor to throw this weapon...

var(Sounds) Sound	ThroughAir[3];
var(Sounds) Sound	ThroughAirBerserk[3];
var(Sounds) Sound	HitFlesh[3];
var(Sounds) Sound	HitWood[3];
var(Sounds) Sound	HitStone[3];
var(Sounds) Sound	HitMetal[3];
var(Sounds) Sound	HitDirt[3];
var(Sounds) Sound	HitShield;
var(Sounds) Sound	HitWeapon;
var(Sounds) Sound	HitBreakableWood;
var(Sounds) Sound	HitBreakableStone;
var(Sounds) Sound	SheathSound; 
var(Sounds) Sound	UnsheathSound;
var(Sounds) Sound	ThrownSoundLOOP;
var(Sounds)	Sound	PowerUpSound;
var(Sounds) Sound	PoweredUpSoundLOOP;
var(Sounds) Sound	PoweredUpEndingSound;
var(Sounds) Sound	PoweredUpEndSound;

var(Sounds) float	PitchDeviation;		// Vary pitch of sounds by +/- this percentage

var() Texture PowerupIcon;
var() Texture PowerupIconAnim;

var vector lastpos1, lastpos2;	// testing sweep

var int NumThroughAirSounds;
var int NumThroughAirBerserkSounds;
var int NumFleshSounds;
var int NumWoodSounds;
var int NumStoneSounds;
var int NumMetalSounds;
var int NumEarthSounds;

const HitCount = 16;
var SwipeHit SwipeHits[16];

// For the weapon swipe effect
var WeaponSwipe Swipe;
var() class<WeaponSwipe> SwipeClass;
var() class<WeaponSwipe> PoweredUpSwipeClass;

// Viking specific information (utilized to determine which animations should
// be used for Ragnar and the enemy vikings using this weapon)
var(Anims) name A_Idle;
var(Anims) name A_TurnLeft;
var(Anims) name A_TurnRight;
var(Anims) name A_Forward;
var(Anims) name A_Backward;
var(Anims) name A_Forward45Right;
var(Anims) name A_Forward45Left;
var(Anims) name A_Backward45Right;
var(Anims) name A_Backward45Left;
var(Anims) name A_StrafeRight;
var(Anims) name A_StrafeLeft;
var(Anims) name A_Jump;
var(Anims) name A_ForwardAttack; // This anim is only played on the legs while attacking

var(Anims) name A_AttackA;	// attack moving forward
var(Anims) name A_AttackAReturn;
var(Anims) name A_AttackB;	// attack moving forward combo
var(Anims) name A_AttackBReturn;	
var(Anims) name A_AttackC;	// attack moving forward combo #2
var(Anims) name A_AttackCReturn;
var(Anims) name A_AttackD;	// attack moving forward combo #3
var(Anims) name A_AttackDReturn;

var(Anims) name A_AttackStandA;
var(Anims) name A_AttackStandAReturn;
var(Anims) name A_AttackStandB;
var(Anims) name A_AttackStandBReturn;	

var(Anims) name A_AttackBackupA;
var(Anims) name A_AttackBackupAReturn;
var(Anims) name A_AttackBackupB;
var(Anims) name A_AttackBackupBReturn;

var(Anims) name A_AttackStrafeRight;
var(Anims) name A_AttackStrafeLeft;
var(Anims) name A_JumpAttack;
var(Anims) name A_Throw;

var(Anims) name A_Powerup;

var(Anims) name A_Defend;
var(Anims) name A_DefendIdle;

var(Anims) name A_PainFront;
var(Anims) name A_PainBack;
var(Anims) name A_PainLeft;
var(Anims) name A_PainRight;

var(Anims) name A_PickupGroundLeft;
var(Anims) name A_PickupHighLeft;

var(Anims) name A_Taunt;

var(Anims) name A_PumpTrigger;
var(Anims) name A_LeverTrigger;

// more to come....

replication
{
	reliable if (Role==ROLE_Authority)
		bPoweredUp;

	// Function the server can call on the client
//	unreliable if( Role==ROLE_Authority && bPoweredUp)
//		ClientWeaponFire;
}

//=============================================================================
//
// PostBeginPlay
//
//=============================================================================
function PostBeginPlay()
{
	local int i;

	SetWeaponStay();

	NumThroughAirSounds = 0;
	NumThroughAirBerserkSounds = 0;
	NumFleshSounds = 0;
	NumWoodSounds = 0;
	NumStoneSounds = 0;
	NumMetalSounds = 0;
	NumEarthSounds = 0;
	for(i = 0; i < 3; i++)
	{
		if(ThroughAir[i] != None)
			NumThroughAirSounds++;
		if(ThroughAirBerserk[i] != None)
			NumThroughAirBerserkSounds++;
		if(HitFlesh[i] != None)
			NumFleshSounds++;
		if(HitWood[i] != None)
			NumWoodSounds++;
		if(HitStone[i] != None)
			NumStoneSounds++;
		if(HitMetal[i] != None)
			NumMetalSounds++;
		if(HitDirt[i] != None)
			NumEarthSounds++;
	}

	Super.PostBeginPlay();
}

function bool SplashJump()
{
	return false;
}

simulated function PreRender( canvas Canvas );
simulated function PostRender( canvas Canvas );

function ClientWeaponEvent(name EventType);


//=============================================================================
//
// CalculateDamage
//
// Calculates damage amount, based on strength modifier.
// Override with logic for rune powers
//=============================================================================

function int CalculateDamage(actor Victim)
{
	local int newDamage;

	newDamage = Damage;

	if(Owner != None && Pawn(Owner) != None)
		newDamage *= Pawn(Owner).PawnDamageModifier(self);

	// Don't hurt players/shield in neutral zones
	if((Owner.Region.Zone.bNeutralZone || Victim.Region.Zone.bNeutralZone) && (Victim.IsA('Pawn') || Victim.IsA('Shield')))
		newDamage = 0;
	else if(Victim.Owner != None && Victim.Owner.Region.Zone.bNeutralZone)
		newDamage = 0; // Shield could be sticking out of the neutral zone, but the owner is inside

	// [RMod]
	// Commented out so that GameInfo can handle friendly fire
	//if (Level.Game.bTeamGame
	//&& Pawn(Victim) != None
	//&& Pawn(Owner) != None
	//&& Pawn(Victim).PlayerReplicationInfo != None
	//&& Pawn(Owner).PlayerReplicationInfo != None
	//&& Pawn(Victim).PlayerReplicationInfo.Team != 255 
	//&& Pawn(Victim).PlayerReplicationInfo.Team == Pawn(Owner).PlayerReplicationInfo.Team)
	//	newDamage = 0; // Don't hurt the victim if on the same team

//	if (Owner != None && Pawn(Owner) != None)
//		newDamage += Pawn(Owner).Strength * 0.25;

	return newDamage;
}

//=============================================================================
// Powerup functions to override
//=============================================================================
function PowerupInit()
{
//	DesiredColorAdjust.X = 191;
//	DesiredFatness=170;
	SwipeClass = PoweredUpSwipeClass;
	SpawnPowerupEffect();
}

function PowerupEndingPulseOn()
{
	DesiredFatness=170;
	DesiredColorAdjust.X = 191;
	PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
	DesiredFatness=128;
	DesiredColorAdjust.X = 0;
}

function PowerupEnded()
{
	DesiredColorAdjust.X = 0;
	DesiredFatness=128;
	SwipeClass = Default.SwipeClass;
	RemovePowerupEffect();
}

simulated function SpawnPowerupEffect()		{}
simulated function RemovePowerupEffect()	{}

// called on clients when bPoweredUp changes
simulated event PowerupStatusChanged()
{
	if (bPoweredUp && !bClientPoweredUp)
	{
		bClientPoweredUp = true;
		SpawnPowerupEffect();
	}
	else if (!bPoweredUp && bClientPoweredUp)
	{
		bClientPoweredUp = false;
		RemovePowerupEffect();
	}
}


//=============================================================================
//
// Powerup
//
// This function is called when the weapon is initially powered up
//=============================================================================
function PowerUp()
{
	bPoweredUp = true;
	SetTimer(RunePowerDuration, false);
	TimerCount = 7;
	PlaySound(PowerUpSound);
	AmbientSound = PoweredUpSoundLOOP;
	Pawn(Owner).ClientMessage(PowerupMessage, '');
	PowerupInit();
}

function PowerupEnd()
{
	bPoweredUp = false;
	SetTimer(0, false);
	PlaySound(PoweredUpEndSound);
	AmbientSound = None;
	PowerupEnded();
}

function Timer()
{
	TimerCount--;

	switch(TimerCount)
	{
	case 5: case 3: case 1:
		PowerupEndingPulseOn();
		SetTimer(0.5, false);
		break;
	case 6: case 4: case 2:	
		PowerupEndingPulseOff();
		SetTimer(0.5, false);
		break;
	case 0:
		PowerupEnd();
		break;
	}
}

function WeaponFire(int SwingCount); // Event called at some point during the swing for powerups (swingcount is zero-based)

// Used for lightning powerup, get rid of
function PowerUpNotify1();
function PowerUpNotify2();
function PoweredUpCallback1();
function PoweredUpCallback2();

function bool StickInWall( EMatterType matter)
{
	return false;
}

function SetWeaponStay()
{
	if (Level.Game != None)
		bWeaponStay = bWeaponStay || Level.Game.bCoopWeaponMode;
}

function bool HandlePickupQuery( inventory Item )
{
	local int OldAmmo;
	local Pawn P;

	if (Item.Class == Class)
	{
		P = Pawn(Owner);

		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if (Item.PickupMessageClass == None)
			P.ClientMessage(Item.PickupMessage, 'Pickup');
		else
			P.ReceiveLocalizedMessage( Item.PickupMessageClass, 0, None, None, item.Class );
		Item.PlaySound(Item.PickupSound);
		Item.SetRespawn();   
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

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
// PlayHitMatterSound
//
//============================================================
function PlayHitMatterSound(EMatterType matter)
{
	local int i;
	switch(matter)
	{
		case MATTER_FLESH:
			i = Rand(NumFleshSounds);
			PlaySound(HitFlesh[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_WOOD:
			i = Rand(NumWoodSounds);
			PlaySound(HitWood[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_STONE:
			i = Rand(NumStoneSounds);
			PlaySound(HitStone[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_METAL:
			i = Rand(NumMetalSounds);
			PlaySound(HitMetal[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_EARTH:
			i = Rand(NumEarthSounds);
			PlaySound(HitDirt[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
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

	if (Pawn(Owner) != None)
	{
		Pawn(Owner).MakeNoise(1.0);
	}
}

//=============================================================================
//
// Destroyed
//
//=============================================================================

function Destroyed()
{
	Super.Destroyed();
	if((Pawn(Owner)!=None) && (Pawn(Owner).Weapon == self))
	{
		Pawn(Owner).Weapon = None;
	}
}

//=============================================================================
//
// TravelPostAccept
//
//=============================================================================

event TravelPostAccept()
{
	local PlayerPawn P;
	local int joint;

	Super.TravelPostAccept();

	if(Pawn(Owner) == None)
	{
		return;
	}

	if(self == Pawn(Owner).Weapon)
	{
		joint = Owner.JointNamed(Pawn(Owner).WeaponJoint);
		Owner.AttachActorToJoint(self, joint);
		GotoState('Active');
		
		return;
	}

	if(Owner.IsA('PlayerPawn'))
	{ // Player-specific travel code
		P = PlayerPawn(Owner);

		if(self == P.StowSpot[0])
			joint = P.JointNamed('attatch_sword'); // Compensate for a spelling error...
		else if(self == P.StowSpot[1])
			joint = P.JointNamed('attach_hammer');
		else if(self == P.StowSpot[2])
			joint = P.JointNamed('attach_axe');
		else
			joint = 0;

		if(joint != 0)
			P.AttachActorToJoint(self, joint);
		else
			bHidden = true; // Hide inventory items that are NOT on a stowspot
	
		GotoState('Stow');
	}
}

//=============================================================================
//
// PlayThrowFrame
//
// Sets the frame with centered base for proper rotation
//=============================================================================
function PlayThrowFrame()
{
	PlayAnim('flying', 1.0, 0.0);
}

//=============================================================================
//
// PlayNormalFrame
//
//=============================================================================
function PlayNormalFrame()
{
	PlayAnim('baseframe', 1.0, 0.0);
}

//=============================================================================
//
// SuggestAttackStyle
//
// return delta to combat style
//=============================================================================

function float SuggestAttackStyle()
{
	return 0.0;
}

//=============================================================================
//
// SuggestDefendStyle
//
// return delta to defend style
//=============================================================================

function float SuggestDefenseStyle()
{
	return 0.0;
}

//=============================================================================
//
// RateSelf
//
// Returns a rating of the weapon
//=============================================================================

function float RateSelf(out int bUseAltMode)
{
	return 1.0;
}

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(1);
}

//=============================================================================
//
// SpawnCopy
//
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
// Also add Ammo to Other's inventory if it doesn't already exist
//
//=============================================================================

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local Weapon newWeapon;

	if( Level.Game.ShouldRespawn(self) )
	{
		Copy = spawn(Class,Other,,,rot(0,0,0));
		if (Copy == None)
			log(name@"cannot be spawned in spawncopy");
		Copy.Tag           = Tag;
		Copy.Event         = Event;
		if ( !bWeaponStay )
			GotoState('Sleeping');
	}
	else
		Copy = self;

	Copy.bTossedOut = true;
	Copy.RespawnTime = 0.0;
	Copy.GiveTo( Other );
	Copy.bHidden = false; // BecomeItem in Inventory automatically hides the item
	newWeapon = Weapon(Copy);
//	newWeapon.Instigator = Other;
//	newWeapon.SetSwitchPriority(Other);
//	if ( !Other.bNeverSwitchOnPickup )
//		newWeapon.WeaponSet(Other);
//	newWeapon.AmbientGlow = 0;
	return newWeapon;
}

//=============================================================================
//
// EnableSwipeTrail
//
//=============================================================================

function EnableSwipeTrail()
{
	if(SwipeClass != None)
	{
		Swipe = Spawn(SwipeClass, self,, Location,);
		if(Swipe != None)
		{
			Swipe.BaseJointIndex = SweepJoint1;
			Swipe.OffsetJointIndex = SweepJoint2;
			Swipe.SystemLifeSpan = -1;	
			Swipe.SetBase(self.Owner);
		}
	}
}

//=============================================================================
//
// DisableSwipeTrail
//
//=============================================================================

function DisableSwipeTrail()
{
	if(Swipe != None)
	{
		Swipe.SystemLifeSpan = 3.0;
		Swipe.SetBase(None);
		Swipe = None;
	}
}

//=============================================================================
//
// ZoneChange
//
// If the weapon enters a water zone, clear out the blood texture
//=============================================================================

function ZoneChange(ZoneInfo newZone)
{
	local int i;

	if(newZone.bWaterZone)
	{
		for (i=0; i<16; i++)
			SkelGroupSkins[i] = None; // Force the weapon to use the default skin
		SetDefaultPolygroups();
		if (bPoweredUp)
			PowerupEnd();
	}
}

//=============================================================================
//
// StabActor
//
// Stab the actor with a weapon, and attach the weapon
//
// NOTE:  Limit this to just swords?
//=============================================================================

function StabActor(Pawn Victim)
{
	if(Victim.StabJoint == '')
		return;

	Victim.AttachActorToJoint(self, Victim.JointNamed(Victim.StabJoint));
	Victim.PainSkin(BODYPART_TORSO); // Bloody the chest

//	SkelMesh = StabMesh;
	PlayAnim('skewer', 1.0, 0.0);
}

//=============================================================================
//
// RemoveStab
//
//=============================================================================

function RemoveStab(Carcass Victim, int JointIndex)
{
	local vector newLoc;
	local rotator newRot;

	PlayAnim('base', 1.0, 0.0);
//	SkelMesh = Default.SkelMesh;
	newLoc = Victim.GetJointPos(JointIndex) + vect(0, 0, 38); // Tweak me
	SetLocation(newLoc);
	newRot = rot(0, 0, 16384); // Tweak me
	newRot.Yaw = Victim.Rotation.Yaw + 16384;
	SetRotation(newRot);
	SetPhysics(PHYS_None);
	GotoState('Pickup');
}

//-----------------------------------------------------------------------------
//
// State Pickup
//
// Melee Weapon is sitting on the ground waiting to be picked up
//-----------------------------------------------------------------------------

auto state Pickup
{
	function BeginState()
	{
		bSweepable=false;
		BecomePickup();
		bCollideWorld = true;
		if (bTossedOut && bExpireWhenTossed)	// If not a placed item, expire after some time
			LifeSpan=ExpireTime;
	}
	
	function EndState()
	{
		bSweepable=Default.bSweepable;
		BecomeItem();
		bCollideWorld = false;
		LifeSpan=0;				// Disallow expire, since someone picked me up

		if(StabbedActor != None)
		{ // Animate the stabbed guy while removing the weapon
			StabbedActor.PlayStabRemove();
			StabbedActor = None;
		}
	}
	
	function Touch(Actor Other)
	{
		local inventory Copy;

		if(Other.IsA('Pawn'))
		{
			if(Pawn(Other).Health > 0 && Pawn(Other).CanPickUp(self))
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
				Copy = SpawnCopy(Pawn(Other));
				
				if(PickupMessageClass == None)
					Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
				else
					Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class);

				Copy.PlaySound (PickupSound);
				if ( Level.Game.Difficulty > 1 )
					Other.MakeNoise(0.1 * Level.Game.Difficulty);
				Pawn(Other).AcquireInventory(Copy);

				if(!Pawn(Other).IsInState('PlayerSwimming'))
					Copy.GotoState('Active');
			}
		}
	}
	
begin:
	AmbientGlow = 0;
	SkelMesh = Default.SkelMesh;

	if (Role==ROLE_Authority)
		bSimFall = false;	// Don't Replicate physics or simulate falling
}

//-----------------------------------------------------------------------------
//
// State BeingPickedUp
//
// Melee Weapon is about to be picked up by another actor
//
//-----------------------------------------------------------------------------
/*
state BeingPickedUp
{
	function BeginState()
	{
		Pawn(Owner).AcquireInventory(self);
		GotoState('Active');
	}
	
begin:
}
*/

//-----------------------------------------------------------------------------
//
// State Active
//
// Melee Weapon is Active and in the actor's hand, waiting to be used
//-----------------------------------------------------------------------------

state Active
{
	function BeginState()
	{
		SetPhysics(PHYS_None);
	}
	
	function EndState()
	{
	}

	function StartAttack()
	{	
		lastpos1 = GetJointPos(SweepJoint1);
		lastpos2 = GetJointPos(SweepJoint2);

		ClearSwipeArray();
	
		GotoState('Swinging');
	}

begin:
}

//-----------------------------------------------------------------------------
//
// State Stow
//
// Melee Weapon is non-active and stowed on the actor
//-----------------------------------------------------------------------------

state Stow
{
	function BeginState()
	{
		bSweepable = false;

		if (bPoweredUp)
			PowerupEnd();

		PlaySound(SheathSound, SLOT_Interface,,,, 1.0 + (FRand() * 0.2 - 0.1));
		SkelMesh = StowMesh;
		JointFlags[1] = JointFlags[1] & ~JOINT_FLAG_COLLISION;
	}
	
	function EndState()
	{
		bSweepable = Default.bSweepable;

		if(!Region.Zone.bWaterZone)
			PlaySound(UnsheathSound, SLOT_Interface,,,, 1.0 + (FRand() * 0.2 - 0.1));

		SkelMesh = Default.SkelMesh;
		JointFlags[1] = JointFlags[1] | JOINT_FLAG_COLLISION;
	}

begin:	
}

//-----------------------------------------------------------------------------
//
// State Throw
//
// Melee weapon was thrown
//
//-----------------------------------------------------------------------------

state Throw
{
	function BeginState()
	{
		local int i;
		local rotator wepRot;

		bSimFall = true;	// Replicate physics and simulate falling during throw

		if (bPoweredUp)
			PowerupEnd();

		ClearSwipeArray();
		
		SetPhysics(PHYS_Falling);
		SetCollision(true, false, false);
		bCollideWorld = true;
		bBounce = true;		
		bFixedRotationDir = true;
		bLookFocusPlayer = true;
		
		if(Owner != None)
		{
			wepRot.Yaw = Owner.Rotation.Yaw - 16384 + 32768;
			LastThrower = Owner;
		}

		wepRot.Pitch = 32768;
		wepRot.Roll = 0;
		SetRotation(wepRot);
		
		RotationRate.Pitch = 0;
		RotationRate.Yaw = 0;
		DesiredRotation.Roll = -32768; //Rotation.Roll - 2000;
		RotationRate.Roll = VSize(Velocity) * 2000 / Mass;
		PlayThrowFrame();

		AmbientSound = ThrownSoundLOOP;
		bPlayedDropSound=false;
		HitMatterSoundCount=0;
	}

	function ZoneChange(ZoneInfo newZone)
	{
		global.ZoneChange(newZone);
		if(newZone.bWaterZone)
		{
			GotoState('drop');
		}
	}

	function EndState()
	{
		bBounce = false;
		SetCollision(false, false, false);
		bCollideWorld = false;
		bBounce = false;		
		bFixedRotationDir = false;
		SetOwner(None);

		DisableSwipeTrail();
		AmbientSound = None;
						
		PlayNormalFrame();
	}

	function bool CanBeUsed(Actor Other)
	{ // Cannot be used while in the thrown state, meaning it cannot be picked up
		return(false);
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		HitWall(HitNormal, HitActor);
	}

	function HitWall(vector HitNormal, actor HitWall)
	{
		local float speed;
		local int DamageAmount;
		local EMatterType matter;
		local bool bNoStickInWall;

		AmbientSound = None;

		// Damage movers or polyobjects
		if ( (Role == ROLE_Authority) && ( (Mover(HitWall) != None) || (PolyObj(HitWall) != None) ))
		{
			bNoStickInWall=true;
			if(SwipeArrayCheck(HitWall, 0, 0))
			{
				DamageAmount = CalculateDamage(HitWall);
				if (DamageAmount != 0)
					HitWall.JointDamaged(DamageAmount, instigator, Location, Velocity*0.5, ThrownDamageType, 0);
			}
		}
		speed = VSize(velocity);

		if (HitNormal.Z > 0.8)
		{	// Hit floor
			if (!bPlayedDropSound && !Region.Zone.bWaterZone)
			{	// Play twice
				bPlayedDropSound=true;
				PlaySound(DropSound, SLOT_Interact);
				if (Instigator != None)
					MakeNoise(1.0);
			}
		}
		else if (speed > 300)
		{	// Hit wall fast
			if (HitMatterSoundCount<3)
			{
				HitMatterSoundCount++;
				matter = MatterTrace(Location-HitNormal*30, Location, 20);
				PlayHitMatterSound(matter);
			}

			if (!bNoStickInWall && StickInWall(matter))
			{	// Stick in wall
				bBounce = false;
				bFixedRotationDir = false;
				SetPhysics(PHYS_None);
				GotoState('Pickup');
				SetOwner(None);
				if ( (Role == ROLE_Authority) && ( (Mover(HitWall) != None) || (PolyObj(HitWall) != None) ))
				{	// Stick in mover
					SetBase(HitWall);
				}
				return;
			}
		}

		if(AnimSequence != 'skewer')
			GotoState('Settling');

		return;

/* 
		if((HitNormal.Z > 0.8) && (speed < 60))
		{
			if(DesiredRotation.Roll ~= Rotation.Roll
				&& DesiredRotation.Pitch ~= Rotation.Pitch)
			{
				SetPhysics(PHYS_None);
				bBounce = false;
				bFixedRotationDir = false;

				GotoState('Pickup');
			}
			else
			{
				DesiredRotation.Roll = 0;
				DesiredRotation.Pitch = 0;
				RotationRate.Roll = 40000;
				RotationRate.Pitch = 40000;
				bRotateToDesired = true;
				bFixedRotationDir = false;

				Velocity.Z = 60;
				SetPhysics(PHYS_Falling);
			}
		}
		else
		{			
			SetPhysics(PHYS_Falling);
			RotationRate.Yaw = VSize(Velocity) * 2000 / Mass;
			RotationRate.Pitch = VSize(Velocity) * 2000 / Mass;
			Velocity = 0.4 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
			DesiredRotation = rotator(HitNormal);
		}
		SetOwner(None);	// Allow pickup now that it's just waiting to come to rest
*/
	}

	//=========================================================================
	//
	// Touch
	// 
	// Touched an actor, does a simple check to see which joints the weapon struck
	//=========================================================================
	function Touch(Actor Other)
	{
		local int hitjoint;
		local vector HitLoc;
		local int DamageAmount;
		local int LowMask, HighMask;
		local actor HitActor;
		local PlayerPawn P;
		local vector VectOther;
		local float dp;

		if (Other == Owner)
			return;
		if (Owner == None)
			return;	// Already hit wall, no more damage after that
		if (Other.IsA('Inventory') && Other.GetStateName() == 'Pickup' && !Other.IsA('Lizard'))
			return;

		AmbientSound = None;

		HitActor = Other;

		if(Other.IsA('PlayerPawn') && Other.AnimProxy != None) 
		{
			P = PlayerPawn(Other);
			// Determine the direction the player is attempting to move
			VectOther = Normal((self.Location - Other.Location) * vect(1, 1, 0));
			dp = vector(P.Rotation) dot VectOther;

			if(dp > 0)
			{
				if(P.Shield != None && P.AnimProxy.GetStateName() == 'Defending')
				{
					HitActor = P.Shield;
				}
				else if(P.Weapon != None && P.AnimProxy.GetStateName() == 'Attacking')
				{
					HitActor = P.Weapon;
				}
			}
		}

		DamageAmount = CalculateDamage(HitActor);

		if(SwipeArrayCheck(HitActor, 0, 0))
		{
			if(HitActor.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Velocity*Mass, ThrownDamageType, 0))
			{	// Hit something solid, bounce
			}

			SpawnHitEffect(HitLoc, Normal(Location - HitActor.Location), 0, 0, HitActor);
			SetPhysics(PHYS_Falling);
			RotationRate.Yaw = VSize(Velocity) * 2000 / Mass;
			RotationRate.Pitch = VSize(Velocity) * 2000 / Mass;
			Velocity = -0.1 * Velocity;
		}
		
/* Pre-shield blocking/weapon blocking of thrown weapons
		if (Other.Skeletal != None)
		{
			hitjoint = Other.ClosestJointTo(Location);
			HitLoc = Other.GetJointPos(hitjoint);
		}
		else
		{
			hitjoint = 0;
			HitLoc = Other.Location;
		}
		if(SwipeArrayCheck(Other, 0, 0))
		{
			DamageAmount = CalculateDamage(Other);
			if (DamageAmount != 0)
			{
				if (Other.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Velocity*Mass, ThrownDamageType, hitjoint))
				{	// Hit something solid, bounce
				}

				if (hitjoint<32)
				{
					LowMask = 1 << hitjoint;
					HighMask = 0;
				}
				else
				{
					LowMask = 0;
					HighMask = 1 << (hitjoint - 32);
				}
				SpawnHitEffect(HitLoc, Normal(Location-Other.Location), LowMask, HighMask, Other);

				SetPhysics(PHYS_Falling);
				RotationRate.Yaw = VSize(Velocity) * 2000 / Mass;
				RotationRate.Pitch = VSize(Velocity) * 2000 / Mass;
				Velocity = -0.1 * Velocity;
			}
		}
*/
	}

begin:
}

//-----------------------------------------------------------------------------
//
// State Drop
//
// Melee weapon was dropped
//-----------------------------------------------------------------------------

state Drop
{
	function BeginState()
	{		
		if (bPoweredUp)
			PowerupEnd();
		SetPhysics(PHYS_Falling);
		SetCollision(true, false, false);
		SetOwner(None);
		bCollideWorld = true;
		bBounce = true;
		bFixedRotationDir = true;
		DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;		
		RotationRate.Yaw = 60000 / Mass;
		DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;		
		RotationRate.Pitch = 60000 / Mass;
		bPlayedDropSound = false;
		HitMatterSoundCount=0;
		DisableSwipeTrail();
	}
	
	function EndState()
	{
		bBounce = false;
		SetCollision(false, false, false);
		bCollideWorld = false;
		bBounce = false;
		bFixedRotationDir = false;
	}
	
	function Landed(vector HitNormal, actor HitActor)
	{
		HitWall(HitNormal, HitActor);
	}
	
	function HitWall(vector HitNormal, actor HitWall)
	{
		local float speed;

		speed = VSize(velocity);

		if (!bPlayedDropSound && !Region.Zone.bWaterZone)
		{
			bPlayedDropSound=true;
			PlaySound(DropSound, SLOT_Interact);
			if (Instigator != None)
				MakeNoise(1.0);
		}

		if(AnimSequence != 'skewer')
			GotoState('Settling');

		return;
/*
		if((HitNormal.Z > 0.8) && (speed < 60))
		{
			if(DesiredRotation.Roll ~= Rotation.Roll
				&& DesiredRotation.Pitch ~= Rotation.Pitch)
			{
				SetPhysics(PHYS_None);
				bBounce = false;
				bFixedRotationDir = false;

				GotoState('Pickup');
			}
			else
			{
				DesiredRotation.Roll = 0;
				DesiredRotation.Pitch = 16384;
				RotationRate.Roll = 40000;
				RotationRate.Pitch = 40000;
				bRotateToDesired = true;
				bFixedRotationDir = false;

				Velocity.Z = 60;
				SetPhysics(PHYS_Falling);
			}
		}
		else
		{			
			SetPhysics(PHYS_Falling);
			RotationRate.Yaw = VSize(Velocity) * 2000 / Mass;
			RotationRate.Pitch = VSize(Velocity) * 2000 / Mass;
			
			Velocity = 0.55 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
			DesiredRotation = rotator(HitNormal);
		}
*/
	}

	function Touch(Actor Other)
	{
		local inventory Copy;

		if(Other.IsA('Pawn'))
		{
			if(Pawn(Other).Health > 0 && Pawn(Other).CanPickUp(self))
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
				Copy = SpawnCopy(Pawn(Other));

				if(PickupMessageClass == None)
					Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
				else
					Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class);
				
				Copy.PlaySound (PickupSound);
				if ( Level.Game.Difficulty > 1 )
					Other.MakeNoise(0.1 * Level.Game.Difficulty);
				Pawn(Other).AcquireInventory(Copy);

				if(!Pawn(Other).IsInState('PlayerSwimming'))
					Copy.GotoState('Active');
			}
		}
	}

begin:
}


//-----------------------------------------------------------------------------
//
// State Settling
//
// Weapon has hit ground, settle into rest position/orientation
//-----------------------------------------------------------------------------
state Settling
{
	function BeginState()
	{
		SetCollision(true, false, false);
		bCollideWorld = true;

		SetOwner(None);	// Allow pickup now that it's just waiting to come to rest
		bFixedRotationDir = false;
		bRotateToDesired = true;

		if (FRand() < 0.5)
			DesiredRotation.Pitch = 49152;
		else
			DesiredRotation.Pitch = 16384;
		DesiredRotation.Yaw = Rotation.Yaw;
		DesiredRotation.Roll = 16384 + FRand()*32768;
		RotationRate.Pitch = 40000;
		RotationRate.Yaw = 0;
		RotationRate.Roll = 40000;
		SetPhysics(PHYS_Falling);
		bBounce = true;
	}
	
	function EndState()
	{
		SetCollision(false, false, false);
		bCollideWorld = false;
		bBounce = false;
		bFixedRotationDir = false;
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		HitWall(HitNormal, HitActor);
	}

	//============================================================================
	//
	// CanBeUsed (from Pickup)
	//
	//============================================================================
	function bool CanBeUsed(Actor Other)
	{
		if(Other.IsA('PlayerPawn') && Other.AnimProxy != None)
		{
			if(Other.AnimProxy.WantsToPickup(self))
			{
				return(true);
			}
		}
		return(false);
	}

	function HitWall(vector HitNormal, actor HitWall)
	{
		local float speed;
		local EMatterType matter;

		speed = VSize(velocity);

		// Play hit or drop sound
		if (HitNormal.Z > 0.8)
		{	// Hit floor
			if (!bPlayedDropSound && !Region.Zone.bWaterZone)
			{	// Play twice
				bPlayedDropSound=true;
				PlaySound(DropSound, SLOT_Interact);
				if (Instigator != None)
					MakeNoise(1.0);
			}
		}
		else if (speed > 300)
		{	// Hit wall fast
			if (HitMatterSoundCount<3)
			{
				HitMatterSoundCount++;
				matter = MatterTrace(Location-HitNormal*30, Location, 20);
				PlayHitMatterSound(matter);
			}
		}

		if((HitNormal.Z > 0.8) && (speed < 60))
		{
			if(DesiredRotation.Roll ~= Rotation.Roll
				&& DesiredRotation.Pitch ~= Rotation.Pitch)
			{
				SetPhysics(PHYS_None);
				bBounce = false;
				bFixedRotationDir = false;

				GotoState('Pickup');
			}
			else
			{
				SetPhysics(PHYS_Falling);
				Velocity.Z = 60;
			}
		}
		else
		{
			SetPhysics(PHYS_Falling);
			Velocity = 0.55 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
		}
	}

	function Touch(Actor Other)
	{
		local inventory Copy;

		if(Other.IsA('Pawn'))
		{
			if(Pawn(Other).Health > 0 && Pawn(Other).CanPickUp(self))
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
				Copy = SpawnCopy(Pawn(Other));

				if(PickupMessageClass == None)
					Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
				else
					Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class);

				Copy.PlaySound (PickupSound);
				if ( Level.Game.Difficulty > 1 )
					Other.MakeNoise(0.1 * Level.Game.Difficulty);
				Pawn(Other).AcquireInventory(Copy);

				if(!Pawn(Other).IsInState('PlayerSwimming'))
					Copy.GotoState('Active');
			}
		}
	}

}

//=============================================================================
//
// StartAttack
//
//=============================================================================

function StartAttack()
{
}

//=============================================================================
//
// FinishAttack
//
//=============================================================================

function FinishAttack()
{
}

//=============================================================================
//
// DropFrom
//
//=============================================================================

function DropFrom(vector StartLocation)
{
	bCollideWorld = true;

	if(!SetLocation(StartLocation))
	{
		return;
	}
		
	SetPhysics(PHYS_Falling);
	BecomePickup();
	SetCollision(true, false, false);
	SetOwner(None);
	AmbientSound = None;
	
	GotoState('Drop');
}

simulated function TweenToStill();

simulated function bool ClientFire( float Value )
{
	return true;
}

simulated function bool ClientAltFire( float Value )
{
	return true;
}

function ForceFire();
function ForceAltFire();

//=============================================================================
//
// ClearSwipeArray
//
//=============================================================================
function ClearSwipeArray()
{
	local int i;
	for(i = 0; i < HitCount; i++)
	{
		SwipeHits[i].Actor = None;
		SwipeHits[i].LowMask = 0;
		SwipeHits[i].HighMask = 0;
	}
}

//=============================================================================
//
// SwipeArrayCheck
//
// This maintains an array of actors (and joints within those actors)
// that are struck by the swipe.  Duplicates are not allowed.
// 
// The original intention for this was to not allow a given joint to be hit
// more than once, but to allow multiple joints within an actor to be hit.
// However, for gameplay purposes, this now ignores the joints and only
// allows each Actor to be struck once, regardless of the number of joints
// struck in the swipe.
//=============================================================================

function bool SwipeArrayCheck(Actor A, int LowMask, int HighMask)
{
	local int i;
	local Pawn P;

	// Check if this actor is valid to be struck
	if(A == Owner || A.Owner == Owner || A == self)
	{
		return(false);
	}

	if (!A.bSweepable)
		return false;

	// Check this actor against the SwipeHit array
	for(i = 0; i < HitCount; i++)
	{
		if(SwipeHits[i].Actor == A)
		{ // Found this actor in the list
			return(false);
		}
	}
	
	// The actor/joint combo wasn't in the list, so add it
	for(i = 0; i < HitCount; i++)
	{
		if(SwipeHits[i].Actor == None)
		{
			SwipeHits[i].Actor = A;
			SwipeHits[i].LowMask = LowMask;
			SwipeHits[i].HighMask = HighMask;

			if(A.Owner != None && !A.IsA('Weapon'))
			{ // Also add this actor's owner to the list (for shields...weapons owners are NOT added to the list)
				SwipeArrayCheck(A.Owner, 0, 0);
			}

			if(A.IsA('Pawn'))
			{ // Struck flesh before a weapon/shield, so add both to the swipe array list so that those aren't hit this swipe
				P = Pawn(A);

				if(P.Weapon != None)
				{
					SwipeArrayCheck(P.Weapon, 0, 0);
				}
				if(P.Shield != None)
				{
					SwipeArrayCheck(P.Shield, 0, 0);
				}
			}

			return(true);
		}		
	}
	
//	SLog("WARNING:  SwipeCheck actor count exceeded.");
	
	return(false);	
}

//=============================================================================
//
// [RMod]
// CheckRouteAllPawnHitsToPawnShield
//
// Returns true if all Pawn hits should be rerouted to its shield, if there is
// one.
//=============================================================================
function bool CheckRouteAllPawnHitsToPawnShield()
{
	// TODO: Implement as game option
	return true;
}

//=============================================================================
//
// DoWeaponSwipe
//
// Returns true if the swipe can continue, false if the swipe should stop
//=============================================================================

function bool DoWeaponSwipe(Actor A, int LowMask, int HighMask, vector HitLoc, vector HitNorm, vector Momentum)
{
	local int j;
	local int DamageAmount;
	local bool rtn;

	rtn = true; // default to allowing the swipe to continue

	if(Owner != None && Pawn(Owner) != None && !Pawn(Owner).AllowWeaponToHitActor(self, A))
	{
		return(true);
	}


	//if(A.CheckDefending())
	//{
	//	return(true);
	//}

	// [RMod]
	// Commented out friendly fire blocking code so that GameInfo can handle team hits
	//if (Level.Game.bTeamGame
	//&& Pawn(A) != None
	//&& Pawn(Owner) != None
	//&& Pawn(A).PlayerReplicationInfo != None
	//&& Pawn(Owner).PlayerReplicationInfo != None
	//&& Pawn(A).PlayerReplicationInfo.Team != 255
	//&& Pawn(A).PlayerReplicationInfo.Team == Pawn(Owner).PlayerReplicationInfo.Team)
	//{	// Don't hit teammates
	//	return true;
	//}

	// [RMod]
	// Commented out shield friendly fire code so that GameInfo can handle team shield hits
	//if(A.IsA('Shield')
	//&& Level.Game.bTeamGame
	//&& Pawn(A.Owner)!=None
	//&& Pawn(Owner)!=None
	//&& Pawn(A.Owner).PlayerReplicationInfo != None
	//&& Pawn(Owner).PlayerReplicationInfo != None
	//&& Pawn(A.Owner).PlayerReplicationInfo.Team != 255
	//&& Pawn(A.Owner).PlayerReplicationInfo.Team == Pawn(Owner).PlayerReplicationInfo.Team)
	//{	// Don't hit teammates shields
	//	return true;
	//}

	// [RMod]
	// Route all hits to shield, calc damage here
	if(CheckRouteAllPawnHitsToPawnShield())
	{
		if(Pawn(A) != None && Pawn(A).Shield != None)
		{
			DamageAmount = CalculateDamage(Pawn(A).Shield);
		}
		else
		{
			DamageAmount = CalculateDamage(A);
		}
	}
	// Original code
	else
	{
		DamageAmount = CalculateDamage(A);
	}

	if (DamageAmount == 0)
		return rtn;

	if (A.Skeletal != None)
	{
		if (LowMask==0 && HighMask==0)
		{
			// [RMod]
			// Route all hits to the Pawn's shield
			if(CheckRouteAllPawnHitsToPawnShield())
			{
				if(Pawn(A) != None && Pawn(A).Shield != None)
				{
					rtn = Pawn(A).Shield.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Momentum, DamageType, 0);
				}
				else
				{
					rtn = A.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Momentum, DamageType, 0);
				}
			}
			// Original code
			else
			{
				rtn = A.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Momentum, DamageType, 0);
			}
		}
		else
		{
			for (j=0; j<A.NumJoints(); j++)
			{
				if(((j < 32) && ((LowMask & (1 << j)) != 0))
					|| ((j >= 32) && (j < 64) && ((HighMask & (1 << (j - 32))) != 0)))
				{	
					// [RMod]
					// Route all hits to the Pawn's shield
					if(CheckRouteAllPawnHitsToPawnShield())
					{
						if(Pawn(A) != None && Pawn(A).Shield != None)
						{
							if(!Pawn(A).Shield.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Momentum, DamageType, 0))
							{
								return false;
							}
						}
						else
						{
							if(!A.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Momentum, DamageType, 0))
							{
								return false;
							}
						}
					}
					// Original code
					else
					{
						if(!A.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Momentum, DamageType, 0))
						{
							return false;
						}
					}
				}
			}
		}
	}
	else
	{ // Hit an actor that doesn't have a skeleton (probably the world)
//		Slog("Hit: "$A);
		if (A.IsA('PolyObj') ||
			A.IsA('Mover') ||
			A.IsA('ParticleSystem') ||
			(A.IsA('Trigger') && Trigger(A).TriggerType==TT_Damage) )
			rtn = A.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Momentum, DamageType, 0);
		else
			rtn = false;
	}

	return(rtn);
}

//=============================================================================
//
// SpawnHitEffect
//
// Spawns an effect based upon what was struck
//=============================================================================

function SpawnHitEffect(vector HitLoc, vector HitNorm, int LowMask, int HighMask, Actor HitActor)
{	
}

//=============================================================================
//
// PlaySwipeSound
//
//=============================================================================

function PlaySwipeSound()
{
	// If the player is bloodlusting, then play the bloodlust through air sounds
	if(Owner != None && Owner.IsA('PlayerPawn') && PlayerPawn(Owner).bBloodLust && NumThroughAirBerserkSounds > 0)
		PlaySound(ThroughAirBerserk[Rand(NumThroughAirBerserkSounds)], SLOT_None,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
	else
		PlaySound(ThroughAir[Rand(NumThroughAirSounds)], SLOT_None,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
}

function StartDamageCheck();	//TEST

//-----------------------------------------------------------------------------
//
// Swinging State
//
//-----------------------------------------------------------------------------

state Swinging
{
	function BeginState()
	{
		PlaySwipeSound();
		FrameOfAttackAnim=0;
	}

	// Called each frame of animation
	function FrameNotify(int framepassed)
	{
		local vector NewPos1, NewPos2, WeaponVector;
		NewPos1 = GetJointPos(SweepJoint1);
		NewPos2 = GetJointPos(SweepJoint2);
		WeaponVector = SweepVector * (VSize(NewPos2-NewPos1) + ExtendedLength);

		FrameSweep(framepassed, WeaponVector, lastpos1, lastpos2);
	}

	event FrameSwept(vector B1, vector E1, vector B2, vector E2)
	{
		local int LowMask,HighMask;
		local vector HitLoc, HitNorm, NewPos1, NewPos2;
		local vector Momentum;
		local actor A;

		// Update the weapon swipes here
/*
		if(Swipe != None)
		{
			Swipe.CreateSwipeParticle(0.0, B1, E1, B2, E2);
		}
*/
		// Now sweep these frame-rate independent coordinates
		Momentum = (E2 - E1) * Mass;
		foreach SweepActors(class'actor', A,
			B1, E1, B2, E2, WeaponSweepExtent, HitLoc, HitNorm, LowMask, HighMask)
		{
			if(SwipeArrayCheck(A, LowMask, HighMask))
			{ // First time hitting this actor and/or joint
				if(!DoWeaponSwipe(A, LowMask, HighMask, HitLoc, HitNorm, Momentum))
				{ // Hit something that should stop the attack
				}

				// [RMod]
				// Route hit effects to the Pawn's shield
				if(CheckRouteAllPawnHitsToPawnShield())
				{
					if(Pawn(A) != None && Pawn(A).Shield != None)
					{
						SpawnHitEffect(HitLoc, HitNorm, LowMask, HighMask, Pawn(A).Shield);

						// Play sound so that all clients can hear the hit
						if(Owner != None && Owner.RemoteRole != ROLE_AutonomousProxy)
						{
							Pawn(A).Shield.PlayHitSound(DamageType);
						}
					}
					else
					{
						SpawnHitEffect(HitLoc, HitNorm, LowMask, HighMask, A);
					}
				}
				// Original code
				else
				{
					SpawnHitEffect(HitLoc, HitNorm, LowMask, HighMask, A);
				}
			}
		}

		gB1 = B1;
		gE1 = E1;
		gB2 = B2;
		gE2 = E2;
	}

	function StartAttack()
	{
	}

	function ClearSwipeArray()
	{
		global.ClearSwipeArray();
	}

	//=========================================================================
	//
	// FinishAttack
	// 
	//=========================================================================

	function FinishAttack()
	{
		Disable('Tick');
		GotoState('Active');
	}

	//=========================================================================
	//
	// Tick
	// 
	//=========================================================================
/*
	function Tick(float DeltaTime)
	{
		local int LowMask,HighMask;
		local vector HitLoc, HitNorm, NewPos1, NewPos2;
		local actor A;
		local vector Momentum;

		NewPos1 = GetJointPos(SweepJoint1);
		NewPos2 = GetJointPos(SweepJoint2);

		// Extend the weapon length if necessary
		if(ExtendedLength > 0)
		{			
			NewPos2 += Normal(NewPos2 - NewPos1) * ExtendedLength;
		}

		Momentum = (NewPos2 - lastPos2) * Mass;

		foreach SweepActors(class'actor', A,
			lastpos1, lastpos2, NewPos1, NewPos2, WeaponSweepExtent, HitLoc, HitNorm, LowMask, HighMask)
		{
			if(SwipeArrayCheck(A, LowMask, HighMask))
			{ // First time hitting this actor and/or joint
				if(!DoWeaponSwipe(A, LowMask, HighMask, HitLoc, HitNorm, Momentum))
				{ // Hit something that should stop the attack
				}
				SpawnHitEffect(HitLoc, HitNorm, LowMask, HighMask, A);
			}
		}

		lastpos1 = NewPos1;
		lastpos2 = NewPos2;
	}
*/
begin:
	Enable('Tick');		
}

//=============================================================================
//
// Debug
//
//=============================================================================

simulated function Debug(Canvas canvas, int mode)
{
	local vector pos1, pos2;

	Super.Debug(canvas, mode);

	Canvas.DrawText("MeleeWeapon:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  bRenderedLastFrame: " $bRenderedLastFrame);
	Canvas.CurY -= 8;
	Canvas.DrawText("  ExpireTime: " $ExpireTime);
	Canvas.CurY -= 8;
	
	Canvas.DrawText("LastThrower: " $LastThrower);
	Canvas.CurY -= 8;

	Canvas.DrawLine3D(gB1, gE1, 155, 155, 0);
	Canvas.DrawLine3D(gB2, gE2, 255, 255, 0);
/*
	if(GetStateName() == 'Swinging')
	{
		pos1 = GetJointPos(SweepJoint1);
		pos2 = GetJointPos(SweepJoint2);

		if(ExtendedLength > 0)
		{			
			pos2 += Normal(pos2 - pos1) * ExtendedLength;
		}

//		Canvas.DrawLine3D(GetJointPos(SweepJoint1), lastpos1, 0, 255, 0);
//		Canvas.DrawLine3D(GetJointPos(SweepJoint2), lastpos2, 0, 255, 0);
		Canvas.DrawTube(pos1, pos2, WeaponSweepExtent, WeaponSweepExtent, 0, 255, 0);
		Canvas.DrawTube(lastpos1, lastpos2, WeaponSweepExtent, WeaponSweepExtent, 0, 255, 0);
	}
*/
}

defaultproperties
{
     ThrownDamageType=ThrownWeaponBlunt
     WeaponSweepExtent=8.000000
     SweepJoint2=1
     ExtendedLength=10.000000
     RunePowerRequired=40
     RunePowerDuration=20.000000
     SweepVector=(Y=1.000000)
     PitchDeviation=0.090000
     Icon=Texture'Engine.S_Weapon'
     Texture=Texture'Engine.S_Weapon'
     LODDistMax=4000.000000
     LODCurve=LOD_CURVE_ULTRA_CONSERVATIVE
     SoundRadius=38
     CollisionHeight=10.000000
     Mass=10.000000
     Buoyancy=4.000000
}
