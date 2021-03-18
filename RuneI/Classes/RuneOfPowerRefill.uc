//=============================================================================
// RuneOfPowerRefill.
// Gives an amount of rune power
//=============================================================================
class RuneOfPowerRefill extends Runes;

function PickupFunction(Pawn Other)
{
	Other.RunePower += RunePower;
	if (Other.RunePower > Other.MaxPower)
		Other.RunePower = Other.MaxPower;

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
	return (Other.RunePower < Other.MaxPower ||
			Other.BodyPartMissing(BODYPART_LARM1) ||
			Other.BodyPartMissing(BODYPART_RARM1));
}

defaultproperties
{
     RunePower=25.000000
     SpheresClass=Class'RuneI.RuneSpheresPower2'
     PickupMessage="You found a Rune of Lesser Power"
     PickupSound=Sound'OtherSnd.Pickups.pickup11'
     SoundRadius=21
     SoundVolume=110
     SoundPitch=88
     AmbientSound=Sound'WeaponsSnd.PowerUps.power63L'
     CollisionRadius=11.000000
     CollisionHeight=10.000000
     Skeletal=SkelModel'objects.Rune5'
}
