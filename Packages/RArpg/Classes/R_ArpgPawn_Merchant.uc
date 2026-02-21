class R_ArpgPawn_Merchant extends R_ArpgPawn;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	SkelGroupSkins[1] = Texture(DynamicLoadObject("AlricPS2.APS2_armleg", Class'Texture'));
	SkelGroupSkins[2] = Texture(DynamicLoadObject("AlricPS2.APS2_armleg", Class'Texture'));
	SkelGroupSkins[3] = Texture(DynamicLoadObject("AlricPS2.APS2_chest", Class'Texture'));
	SkelGroupSkins[4] = Texture(DynamicLoadObject("AlricPS2.APS2_head", Class'Texture'));
}

defaultproperties
{
	Skeletal=SkelModel'Players.Ragnar'
	SkelMesh=7
	DrawScale=1.5
	CollisionRadius=27.0
	CollisionHeight=63.0
	bShouldDrawHealth=false
	AnimationSetDefaultClass=Class'RArpg.R_ArpgAnimationSet_Ragnar_Default'
}