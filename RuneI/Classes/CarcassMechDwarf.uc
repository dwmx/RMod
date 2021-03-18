//=============================================================================
// CarcassMechDwarf.
//=============================================================================
class CarcassMechDwarf extends RuneCarcass;


function EMatterType MatterForJoint(int joint)
{
	return MATTER_METAL;
}

defaultproperties
{
     AnimSequence=Death
     PrePivot=(Z=10.000000)
     CollisionRadius=45.000000
     CollisionHeight=33.000000
     Skeletal=SkelModel'creatures.MechaDwarf'
}
