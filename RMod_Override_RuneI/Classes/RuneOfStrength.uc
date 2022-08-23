//=============================================================================
// RuneOfStrength.
// Boost strength (berserk) to instantly bloodlust
//=============================================================================
class RuneOfStrength extends Runes;

function PickupFunction(Pawn Other)
{
	Other.BoostStrength(Other.MaxStrength);

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
	if (PlayerPawn(Other)!=None && !PlayerPawn(Other).bBloodLust)
		return true;
	return (Other.BodyPartMissing(BODYPART_LARM1) ||
			Other.BodyPartMissing(BODYPART_RARM1));
}

defaultproperties
{
     RunePower=10.000000
     SpheresClass=Class'RuneI.RuneSpheresBerserker'
     PickupMessage="You possess a Rune of Bloodlust"
     PickupSound=Sound'OtherSnd.Pickups.grab03'
     SoundRadius=21
     SoundVolume=130
     SoundPitch=88
     AmbientSound=Sound'WeaponsSnd.PowerUps.power03L'
     CollisionRadius=11.000000
     CollisionHeight=13.000000
     Skeletal=SkelModel'objects.Rune2'
}
