//=============================================================================
// DecorationWeapon.
//=============================================================================
class DecorationWeapon extends DecorationRune;

/*
	Decoration Weapons are intented to be purely used as placing weapons in locations
	where the player will never be able to access.


	To use, set the SkelMesh to the desired mesh for the object
*/

defaultproperties
{
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'weapons.BattleAxe'
}
