class R_CreaturePlayer_Dwarf extends R_CreaturePlayer;

// RDwarf.scm is original dwarf model with anim project joint groups setup
#exec SKELETAL IMPORT NAME=RDwarf FILE=..\RCreatures\Models\RDwarf.scm
#exec SKELETAL ORIGIN NAME=RDwarf X=0 Y=0 Z=-4 Pitch=0 Yaw=-64 Roll=-64

defaultproperties
{
	Skeletal=SkelModel'RMod.RDwarf'
	SkelMesh=2
}