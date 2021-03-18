//=============================================================================
// GlowBulb.
//=============================================================================
class GlowBulb expands BubbleSystem;

//#exec OBJ LOAD PACKAGE=plants FILE=..\meshes\plants.ums


function PreBeginPlay()
{
	// skip setdefaultpolygroups
}

defaultproperties
{
     ParticleTexture(0)=None
     ShapeVector=(X=8.000000,Y=8.000000,Z=0.000000)
     bConvergeX=True
     bConvergeY=True
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'plants.GlowPlant'
}
