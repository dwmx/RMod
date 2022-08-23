//=============================================================================
// StatueGoblin.
//=============================================================================
class StatueGoblin extends Statue;


function PostBeginPlay()
{
//	local int i;

	Super.PostBeginPlay();

	SkelGroupSkins[1] = texture'statues.gs_body';
	SkelGroupSkins[2] = texture'statues.gs_armleg';
	SkelGroupSkins[3] = texture'statues.gs_armleg';
	SkelGroupSkins[4] = texture'statues.gs_armleg';
	SkelGroupSkins[5] = texture'statues.gs_armleg';
	SkelGroupSkins[6] = texture'statues.gs_head';
	SkelGroupSkins[7] = texture'statues.gs_head';
	SkelGroupSkins[8] = texture'statues.gs_head';
	SkelGroupSkins[9] = texture'statues.gs_head';
	SkelGroupSkins[10] = texture'statues.gs_head';

//	for (i=0; i<16; i++)
//	{
//		SkelGroupSkins[i] = texture'statues.rock.rock20_d';
//	}
}

defaultproperties
{
     AnimSequence=swipe
     DrawScale=2.000000
     CollisionRadius=32.000000
     CollisionHeight=64.000000
     Skeletal=SkelModel'creatures.Goblin'
}
