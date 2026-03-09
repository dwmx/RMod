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
var private R_ArpgObserverCollision_Sphere Spheres[64];
var private int SphereCount;

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

//------------------------------------------------------------------------------
// TODO: Move this to a subclass in the debug package, this shouldnt be in core
static function DrawSphere3D(
	Canvas C,
	Vector WorldOrigin, float Radius,
	int NumSegments, int NumSlices,
	Vector VectorColor)
{
	local float Theta0, Theta1;
	local float Phi0, Phi1;
	local Vector P0, P1, P2;
	local int i, j;

	NumSegments = Clamp(NumSegments, 3, 24);
	NumSlices = Clamp(NumSlices, 3, 24);

	for(i = 0; i < NumSegments; ++i)
	{
		Theta0 = Pi * float(i) / float(NumSegments) - Pi * 0.5;
		Theta1 = Pi * float(i+1) / float(NumSegments) - Pi * 0.5;

		for(j = 0; j < NumSlices; ++j)
		{
			Phi0 = 2.0 * Pi * float(j) / float(NumSlices);
			Phi1 = 2.0 * Pi * float(j+1) / float(NumSlices);

			P0.X = Cos(Theta0) * Cos(Phi0);
			P0.Y = Cos(Theta0) * Sin(Phi0);
			P0.Z = Sin(Theta0);

			P1.X = Cos(Theta1) * Cos(Phi0);
			P1.Y = Cos(Theta1) * Sin(Phi0);
			P1.Z = Sin(Theta1);

			P2.X = Cos(Theta0) * Cos(Phi1);
			P2.Y = Cos(Theta0) * Sin(Phi1);
			P2.Z = Sin(Theta0);

			P0 = WorldOrigin + P0 * Radius;
			P1 = WorldOrigin + P1 * Radius;
			P2 = WorldOrigin + P2 * Radius;

			// vertical line
			C.DrawLine3D(P0, P1, VectorColor.X, VectorColor.Y, VectorColor.Z);

			// horizontal ring line
			C.DrawLine3D(P0, P2, VectorColor.X, VectorColor.Y, VectorColor.Z);
		}
	}
}

function DrawCollisions(Canvas C)
{
	local int i;
	
	if(C == None)
	{
		return;
	}

	for(i = 0; i < SphereCount; ++i)
	{
		DrawSphere3D(
			C,
			Spheres[i].Origin,
			Spheres[i].Radius,
			3,
			5,
			Vect(1,1,0));
	}
}