//=============================================================================
// RuneOfHealth.
// Increases maximum health
//=============================================================================
class RuneOfHealth extends Runes;

function PickupFunction(Pawn Other)
{
	local int i;

	Other.MaxHealth += RunePower;
	Other.MaxHealth = Clamp(Other.MaxHealth, 0, 200);
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

	Destroy();
}

function bool PawnWantsRune(Pawn Other)
{// return whether the pawn should currently want this rune
	return (Other.MaxHealth < 200 ||
			Other.Health < Other.MaxHealth ||
			Other.BodyPartMissing(BODYPART_LARM1) ||
			Other.BodyPartMissing(BODYPART_RARM1));
}

defaultproperties
{
     RunePower=20.000000
     SpheresClass=Class'RuneI.RuneSpheresHealth'
     PickupMessage="You picked up a Rune of Health"
     PickupSound=Sound'OtherSnd.Pickups.pickup12'
     SoundRadius=21
     SoundVolume=126
     SoundPitch=83
     AmbientSound=Sound'WeaponsSnd.PowerUps.power66L'
     CollisionRadius=11.000000
     CollisionHeight=11.000000
     Skeletal=SkelModel'objects.Rune3'
}
