//==============================================================================
//	R_MapData_Hildir
//	Dynamic map data for DM-Hildir
//==============================================================================
class R_MapData_Hildir extends R_DynamicMapData;

function BuildNavMesh()
{
	NavMesh.PushVertex(Vect(-986.295593,944.919617,-230.899994));
	NavMesh.PushVertex(Vect(-238.727325,944.919617,-230.899994));
	NavMesh.PushVertex(Vect(-238.727325,1703.094360,-230.899994));
	NavMesh.PushVertex(Vect(-986.295593,1703.094360,-230.899994));

	NavMesh.PushTriangle(0, 1, 2);
	NavMesh.PushTriangle(0, 2, 3);
}