//=============================================================================
// Chandelier.
//=============================================================================
class Chandelier expands DecorationRune;

function AddVelocity(vector NewVelocity)
{
}

defaultproperties
{
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=42.000000
     CollisionHeight=14.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.Chandelier'
}
