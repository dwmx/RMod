//=============================================================================
// DanglerLight.
//=============================================================================
class DanglerLight expands SpawnableLight;

// Load RUNE Player package
//#exec OBJ LOAD PACKAGE=RuneFX FILE=..\textures\RuneFX.utx

defaultproperties
{
     bHidden=False
     Style=STY_Translucent
     Texture=Texture'RuneFX.Deely1'
     Skin=Texture'RuneFX.Deely1'
     DrawScale=0.500000
     LightEffect=LE_NonIncidence
     LightBrightness=220
     LightSaturation=102
     LightRadius=14
     LightCone=179
}
