//=============================================================================
// StatueSnowbeast.
//=============================================================================
class StatueSnowbeast extends Statue;



function PostBeginPlay()
{
	Super.PostBeginPlay();

	SkelGroupSkins[1] = texture'statues.sb_armleg_stone';
	SkelGroupSkins[2] = texture'statues.sb_body_stone';
	SkelGroupSkins[3] = texture'statues.sb_armleg_stone';
	SkelGroupSkins[4] = texture'statues.sb_body_stone';
	SkelGroupSkins[5] = texture'statues.sb_body_stone';
	SkelGroupSkins[6] = texture'statues.sb_body_stone';
	SkelGroupSkins[7] = texture'statues.sb_body_stone';
	SkelGroupSkins[8] = texture'statues.sb_armleg_stone';
	SkelGroupSkins[9] = texture'statues.sb_body_stone';
	SkelGroupSkins[10] = texture'statues.sb_armleg_stone';
}

defaultproperties
{
     AnimSequence=howl
     DrawScale=5.000000
     CollisionRadius=355.000000
     CollisionHeight=325.000000
     bJointsBlock=True
     Skeletal=SkelModel'creatures.SnowBeast'
}
