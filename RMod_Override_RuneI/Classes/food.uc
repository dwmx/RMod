//=============================================================================
// Food.
//=============================================================================
class Food extends Pickup
	abstract;


var() int Nutrition;
var() class<actor> JunkActor;

var(Sounds) sound UseSound; // The sound that is played when the item is immediately picked up

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(3);
}

function PickupFunction(Pawn Other)
{
	local int i;
	local int adjNutrition;

	adjNutrition = Nutrition;

	switch(Level.Game.Difficulty)
	{
	case 0: // Easy mode, more health
		adjNutrition *= 1.5;
		break;
	case 2: // Hard mode, less health
		adjNutrition *= 0.75;
		break;
	}

	Other.Health += adjNutrition;
	if (Other.Health > Other.MaxHealth)
		Other.Health = Other.MaxHealth;

	// Cure eater of any ailments
	if(Other.Fatness != 128)
		Other.DesiredFatness = 128;
	if(Other.ScaleGlow != 1.0)
		Other.ScaleGlow = 1.0;
	if(Other.BodyPartMissing(BODYPART_LARM1))
		Other.RestoreBodyPart(BODYPART_LARM1);
	if(Other.BodyPartMissing(BODYPART_RARM1))
		Other.RestoreBodyPart(BODYPART_RARM1);

	// Restore health of bodyparts (must be after restoring limbs)
	for (i=0; i<NUM_BODYPARTS; i++)
		Other.BodyPartHealth[i] = Other.Default.BodyPartHealth[i];

	// Fire the event on the food item
	if(Other.bIsPawn)
		FireEvent(Event);

	Destroy();
}

function InventorySpecial1()
{ // Special1 - Eat/drink the food/mead
	local Pawn P;
	local int joint;
	local actor junk;

	if(Owner == None)
		return;

	P = Pawn(Owner);

	joint = P.JointNamed(P.WeaponJoint);
	if(joint != 0)
	{
		P.DetachActorFromJoint(joint);

		if(JunkActor != None)
		{
			junk = Spawn(JunkActor, P,, Location);
			if(junk != None)
				P.AttachActorToJoint(junk, joint);
		}
	}

	SetOwner(P); // Has to reset owner, as it is set to None by DetachActorFromJoint

	if ( PickupMessageClass == None )
		P.ClientMessage(PickupMessage, 'Pickup');
	else
		P.ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );
	PlaySound(PickupSound,,2.0);	
	PickupFunction(P);
}

/*
function InventorySpecial2()
{ // Drop the refuse (bone or empty stein)
	local Pawn P;
	local actor junk;

	if(Owner == None)
		return;
		
	P = Pawn(Owner);
	junk = P.DetachActorFromJoint(P.JointNamed(P.WeaponJoint));

	if(junk != None)
	{	
		junk.Velocity = DropVelocity(P);
		junk.SetPhysics(PHYS_Falling);
		junk.bCollideWorld = true;
	}

	if (!bDeleteMe)
		Destroy();
}
*/

defaultproperties
{
     Nutrition=5
     RespawnTime=30.000000
     RespawnSound=Sound'OtherSnd.Respawns.respawn01'
     PickupMessageClass=Class'RuneI.PickupMessage'
}
