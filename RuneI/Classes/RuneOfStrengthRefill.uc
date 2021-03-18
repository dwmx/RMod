//=============================================================================
// RuneOfStrengthRefill.
// Boosts strength (berserk) by an amount
//=============================================================================
class RuneOfStrengthRefill extends Runes;

function PickupFunction(Pawn Other)
{
	Other.BoostStrength(RunePower);

	// Cure eater of any ailments
	if(Other.Fatness != 128)
		Other.DesiredFatness = 128;
	if(Other.ScaleGlow != 1.0)
		Other.ScaleGlow = 1.0;
	if(Other.BodyPartMissing(BODYPART_LARM1))
		Other.RestoreBodyPart(BODYPART_LARM1);
	if(Other.BodyPartMissing(BODYPART_RARM1))
		Other.RestoreBodyPart(BODYPART_RARM1);

	Destroy();
}

function bool PawnWantsRune(Pawn Other)
{// return whether the pawn should currently want this rune
	return Other.Strength < Other.MaxStrength;
}

defaultproperties
{
     RunePower=50.000000
     SpheresClass=Class'RuneI.RuneSpheresBerserker2'
     PickupMessage="You picked up a Rune of Strength"
     PickupSound=Sound'OtherSnd.Pickups.pickup09'
     SoundRadius=21
     SoundVolume=118
     SoundPitch=91
     AmbientSound=Sound'WeaponsSnd.PowerUps.power02L'
     CollisionRadius=11.000000
     CollisionHeight=11.500000
     Skeletal=SkelModel'objects.Rune4'
}
