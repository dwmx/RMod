//==============================================================================
//	R_MapData_Champions8on8ER
//	Dynamic map data for AR-8on8-ChampionsER
//==============================================================================
class R_MapData_Champions8on8ER extends R_DynamicMapData;

function BuildNavMesh()
{
    NavMesh.PushVertex(Vect(576.000000,-64.000031,-896.000000));
    NavMesh.PushVertex(Vect(832.000000,-64.000031,-896.000000));
    NavMesh.PushVertex(Vect(576.000000,512.000000,-896.000000));
    NavMesh.PushVertex(Vect(832.000000,512.000000,-896.000000));
    NavMesh.PushVertex(Vect(64.000000,-64.000031,-896.000000));
    NavMesh.PushVertex(Vect(-231.202454,344.384552,-896.000000));
    NavMesh.PushVertex(Vect(576.000000,768.000000,-896.000000));
    NavMesh.PushVertex(Vect(-254.650879,768.000000,-896.000000));
    NavMesh.PushVertex(Vect(576.000000,-320.000000,-896.000000));
    NavMesh.PushVertex(Vect(64.000000,-320.000000,-896.000000));
    NavMesh.PushVertex(Vect(-704.000000,180.330048,-896.000000));
    NavMesh.PushVertex(Vect(-89.999939,-370.000000,-896.000000));
    NavMesh.PushVertex(Vect(64.000000,-654.899780,-896.000000));
    NavMesh.PushVertex(Vect(-704.000000,-320.000000,-896.000000));
    NavMesh.PushVertex(Vect(-671.749146,-449.003113,-896.000000));
    NavMesh.PushTriangleAsVertices(0, 1, 3);
    NavMesh.PushTriangleAsVertices(0, 3, 2);
    NavMesh.PushTriangleAsVertices(0, 2, 5);
    NavMesh.PushTriangleAsVertices(0, 5, 4);
    NavMesh.PushTriangleAsVertices(5, 2, 6);
    NavMesh.PushTriangleAsVertices(5, 6, 7);
    NavMesh.PushTriangleAsVertices(0, 4, 9);
    NavMesh.PushTriangleAsVertices(0, 9, 8);
    NavMesh.PushTriangleAsVertices(9, 4, 10);
    NavMesh.PushTriangleAsVertices(9, 10, 11);
    NavMesh.PushTriangleAsVertices(9, 11, 12);
    NavMesh.PushTriangleAsVertices(11, 10, 13);
    NavMesh.PushTriangleAsVertices(11, 13, 14);
    NavMesh.PushTriangleAsVertices(4, 5, 10);
}