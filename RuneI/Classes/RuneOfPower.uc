//=============================================================================
// RuneOfPower.
// Increases maximum rune power
//=============================================================================
class RuneOfPower extends Runes;

function PickupFunction(Pawn Other)
{
/*
	local float percent;

	percent = float(Other.RunePower)/float(Other.MaxPower);
	Other.MaxPower += RunePower;
	Other.RunePower = percent * Other.MaxPower;
*/
	Other.MaxPower += RunePower;
	Other.MaxPower = Clamp(Other.MaxPower, 0, 200);
	Other.RunePower = Other.MaxPower; // Fill the player fully up

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
	return (Other.MaxPower < 200 ||
			Other.RunePower < Other.MaxPower ||
			Other.BodyPartMissing(BODYPART_LARM1) ||
			Other.BodyPartMissing(BODYPART_RARM1));
}

defaultproperties
{
     RunePower=20.000000
     SpheresClass=Class'RuneI.RuneSpheresPower'
     PickupMessage="You picked up a Rune of Power"
     PickupSound=Sound'OtherSnd.Pickups.pickup08'
     SoundRadius=21
     SoundVolume=101
     SoundPitch=83
     AmbientSound=Sound'WeaponsSnd.PowerUps.power69L'
     CollisionRadius=11.000000
     CollisionHeight=10.000000
     Skeletal=SkelModel'objects.Rune1'
}
