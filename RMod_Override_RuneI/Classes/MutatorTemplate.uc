//=============================================================================
// MutatorTemplate
// empty mutator showing all possible overrides
//=============================================================================
class MutatorTemplate expands Mutator;


// Called before gameplay starts
function PreBeginPlay()
{
	Super.PreBeginPlay();
}

// Called each time an actor is spawned, returns relevancy
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	return true;
}

function bool AllowWeaponDrop()
{
	return Super.AllowWeaponDrop();
}

function bool AllowShieldDrop()
{
	return Super.AllowShieldDrop();
}


// Called each time there is a kill
function ScoreKill(Pawn Killer, Pawn Other)
{
	Super.ScoreKill(Killer, Other);
}

// Called after render
simulated event PostRender( canvas Canvas );


// Called by GameInfo.RestartPlayer()
function ModifyPlayer(Pawn Other)
{
	Super.ModifyPlayer(Other);
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	Super.Mutate(MutateString, Sender);
}

// Called for all damage
function MutatorJointDamaged( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType, out int joint)
{
	Super.MutatorJointDamaged(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType, joint);
}

defaultproperties
{
}
