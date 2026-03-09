//==============================================================================
//	R_ArpgObserver_Collision
//	Observer which holds collision information
//==============================================================================
class R_ArpgObserver_Collision extends R_ArpgObserver;

struct R_ArpgObserverCollision_Sphere
{
	var Vector Origin;
	var float Radius;
};
var R_ArpgObserverCollision_Sphere Spheres[64];
var int SphereCount;

function ClearCollisionSpheres()
{
	SphereCount = 0;
}

function AddCollisionSphere(Vector Origin, float Radius)
{
	SphereCount = Clamp(SphereCount, 0, ArrayCount(Spheres));
	if(SphereCount >= ArrayCount(Spheres))
	{
		return;
	}

	Spheres[SphereCount].Origin = Origin;
	Spheres[SphereCount].Radius = Radius;
	++SphereCount;
}