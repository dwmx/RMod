//==============================================================================
//	R_ArpgObserver_CollisionDebug
//	Collision observer with debug drawing capabilities
//	Attach to an ArpgPawn to view its collision-related visual data 
//==============================================================================
class R_ArpgObserver_CollisionDebug extends R_ArpgObserver_Collision;

function DrawCollisions(Canvas C, R_DBStringManager StringManager, R_ArpgDBMutator DBM)
{
	local int i;
	
	if(C == None)
	{
		return;
	}

	for(i = 0; i < SphereCount; ++i)
	{
		Class'RBase.R_ACanvasLibrary'.Static.DrawSphere3D(
			C,
			Spheres[i].Origin,
			Spheres[i].Radius,
			3,
			5,
			1.0, 1.0, 0.0);
	}
}