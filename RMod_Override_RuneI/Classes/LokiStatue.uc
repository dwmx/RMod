//=============================================================================
// LokiStatue.
//=============================================================================
class LokiStatue extends Statue;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SkelGroupSkins[1] = texture'creatures.lokiloki_headstone';
	SkelGroupSkins[2] = texture'creatures.lokiloki_snakestone';
	SkelGroupSkins[3] = texture'creatures.lokiloki_snakestone';
	SkelGroupSkins[4] = texture'creatures.lokiloki_snakestone';
	SkelGroupSkins[5] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[6] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[7] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[8] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[9] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[10] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[11] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[12] = texture'creatures.lokiloki_bodystone';
	SkelGroupSkins[13] = texture'creatures.lokiloki_headstone';
	SkelGroupSkins[14] = texture'creatures.lokiloki_headstone';
}

defaultproperties
{
     bDestroyable=False
     bStatic=True
     DrawScale=3.000000
     LODDistMax=3500.000000
     LODPercentMax=1.000000
     LODCurve=LOD_CURVE_NORMAL
     CollisionRadius=17.000000
     CollisionHeight=72.500000
     Skeletal=SkelModel'creatures.Loki'
}
