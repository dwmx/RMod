//=============================================================================
// Mutator.
// called by the IsRelevant() function of DeathMatchPlus
// by adding new mutators, you can change actors in the level without requiring
// a new game class.  Multiple mutators can be linked together. 
//=============================================================================
class Mutator expands Info
	native;

var Mutator NextMutator;
var Mutator NextDamageMutator;
var Mutator NextHUDMutator;

var bool bHUDMutator;


var class<Weapon> DefaultWeapon;
var class<Shield> DefaultShield;

event PreBeginPlay()
{
	//Don't call Actor PreBeginPlay()
}

simulated event PostRender( canvas Canvas );

function ModifyPlayer(Pawn Other)
{	// called by GameInfo.RestartPlayer()
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

function ScoreKill(Pawn Killer, Pawn Other)
{	// called by GameInfo.ScoreKill()
	if ( NextMutator != None )
		NextMutator.ScoreKill(Killer, Other);
}

function bool AllowWeaponDrop()
{	// called by GameInfo.AllowWeaponDrop()
	if ( NextMutator != None )
		return NextMutator.AllowWeaponDrop();
	return true;
}

function bool AllowShieldDrop()
{	// called by GameInfo.AllowShieldDrop()
	if ( NextMutator != None )
		return NextMutator.AllowShieldDrop();
	return true;
}

// return what should replace the default weapon
// mutators further down the list override earlier mutators
function Class<Weapon> MutatedDefaultWeapon()
{
	local Class<Weapon> W;

	if ( NextMutator != None )
	{
		W = NextMutator.MutatedDefaultWeapon();
		if ( W == Level.Game.DefaultWeapon )
			W = MyDefaultWeapon();
	}
	else
		W = MyDefaultWeapon();
	return W;
}

function Class<Weapon> MyDefaultWeapon()
{
	if ( DefaultWeapon != None )
		return DefaultWeapon;
	else
		return Level.Game.DefaultWeapon;
}

function Class<Shield> MutatedDefaultShield()
{
	local Class<Shield> S;

	if( NextMutator != None )
	{
		S = NextMutator.MutatedDefaultShield();
		if (S == Level.Game.DefaultShield)
			S = MyDefaultShield();
	}
	else
		S = MyDefaultShield();
	return S;
}

function Class<Shield> MyDefaultShield()
{
	if (DefaultShield != None)
		return DefaultShield;
	else
		return Level.Game.DefaultShield;
}

function AddMutator(Mutator M)
{
	if ( NextMutator == None )
		NextMutator = M;
	else
		NextMutator.AddMutator(M);
}

/* ReplaceWith()
Call this function to replace an actor Other with an actor of aClass.
*/
function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
		return false;
	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Inventory') )
	{
		if ( Inventory(Other).MyMarker != None )
		{
			Inventory(Other).MyMarker.markedItem = Inventory(A);
			if ( Inventory(A) != None )
			{
				Inventory(A).MyMarker = Inventory(Other).MyMarker;
				A.SetLocation(A.Location 
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Inventory(Other).MyMarker = None;
		}
		else if ( A.IsA('Inventory') )
		{
			Inventory(A).Respawntime = 0.0;
		}
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return true;
	}
	return false;
}

/* ReplaceWithAndReturn()
Call this function to replace an actor Other with an actor of aClass.
*/
function actor ReplaceWithAndReturn(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
		return None;
	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Inventory') )
	{
		if ( Inventory(Other).MyMarker != None )
		{
			Inventory(Other).MyMarker.markedItem = Inventory(A);
			if ( Inventory(A) != None )
			{
				Inventory(A).MyMarker = Inventory(Other).MyMarker;
				A.SetLocation(A.Location 
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Inventory(Other).MyMarker = None;
		}
		else if ( A.IsA('Inventory') )
		{
			Inventory(A).Respawntime = 0.0;
		}
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
	}
	return A;
}

/* Force game to always keep this actor, even if other mutators want to get rid of it
*/
function bool AlwaysKeep(Actor Other)
{
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local bool bResult;

	// allow mutators to remove actors
	bResult = CheckReplacement(Other, bSuperRelevant);

	if ( bResult && (NextMutator != None) )
		bResult = NextMutator.IsRelevant(Other, bSuperRelevant);

	return bResult;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	return true;
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

function MutatorJointDamaged( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType, out int joint)
{
	if ( NextDamageMutator != None )
		NextDamageMutator.MutatorJointDamaged( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType, joint );
}

// Registers the current mutator on the client to receive PostRender calls.
simulated function RegisterHUDMutator()
{
	local HUD MyHud;

	if ((Level.NetMode == NM_Client) || (Level.NetMode == NM_Standalone))
		foreach AllActors(class'HUD', MyHud)
		{
			NextHUDMutator = MyHud.HUDMutator;
			MyHud.HUDMutator = Self;
			bHUDMutator = True;
		}	
}

defaultproperties
{
}
