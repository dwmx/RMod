
//==============================================================================
//	R_RBots_CanvasLibrary
//	Utility functions for Canvas
//==============================================================================
class R_RBots_CanvasLibrary extends Object abstract;

// Copy of Canvas.DrawBox3D, replacing ints with floats
static function DrawBox3D(Canvas C, Vector Center, Vector Extents, float R, float G, float B)
{
	local vector bX,bY,bZ;
	
	bX = vect(0,0,0); bX.X = Extents.X;
	bY = vect(0,0,0); bY.Y = Extents.Y;
	bZ = vect(0,0,0); bZ.Z = Extents.Z;

	// Top	
	C.DrawLine3D(Center+bZ+bX, Center+bZ+bY, R, G, B);
	C.DrawLine3D(Center+bZ+bY, Center+bZ-bX, R, G, B);
	C.DrawLine3D(Center+bZ-bX, Center+bZ-bY, R, G, B);
	C.DrawLine3D(Center+bZ-bY, Center+bZ+bX, R, G, B);
	
	// Bottom
	C.DrawLine3D(Center-bZ+bX, Center-bZ+bY, R, G, B);
	C.DrawLine3D(Center-bZ+bY, Center-bZ-bX, R, G, B);
	C.DrawLine3D(Center-bZ-bX, Center-bZ-bY, R, G, B);
	C.DrawLine3D(Center-bZ-bY, Center-bZ+bX, R, G, B);

	// Sides
	C.DrawLine3D(Center+bZ+bX, Center-bZ+bX, R, G, B);
	C.DrawLine3D(Center+bZ+bY, Center-bZ+bY, R, G, B);
	C.DrawLine3D(Center+bZ-bX, Center-bZ-bX, R, G, B);
	C.DrawLine3D(Center+bZ-bY, Center-bZ-bY, R, G, B);
}

// Copy of Canvas.DrawLine3D
static function DrawLine3D(Canvas C, Vector Start, Vector End, float R, float G, float B)
{
	C.DrawLine3D(Start, End, R, G, B);
}