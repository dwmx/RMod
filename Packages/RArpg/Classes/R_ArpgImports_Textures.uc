//==============================================================================
//  R_ArpgImports_Textures
//  RArpg Texture Imports
//==============================================================================
class R_ArpgImports_Textures extends R_ArpgObject abstract;

// PF_None           = 0x00000000  # No flags.
// PF_Invisible      = 0x00000001  # Poly is invisible.
// PF_Masked         = 0x00000002  # Poly should be drawn masked.
// PF_Translucent    = 0x00000004  # Poly is transparent.
// PF_NotSolid       = 0x00000008  # Poly is not solid, doesn't block.
// PF_Environment    = 0x00000010  # Poly should be drawn environment mapped.
// PF_Semisolid      = 0x00000020  # Poly is semi-solid = collision solid, Csg nonsolid.
// PF_Modulated      = 0x00000040  # Modulation transparency.
// PF_FakeBackdrop   = 0x00000080  # Poly looks exactly like backdrop.
// PF_TwoSided       = 0x00000100  # Poly is visible from both sides.
// PF_AutoUPan       = 0x00000200  # Automatically pans in U direction.
// PF_AutoVPan       = 0x00000400  # Automatically pans in V direction.
// PF_NoSmooth       = 0x00000800  # Don't smooth textures.
// PF_BigWavy        = 0x00001000  # Poly has a big wavy pattern in it.
// PF_SmallWavy      = 0x00002000  # Small wavy pattern (for water/enviro reflection).
// PF_Flat           = 0x00004000  # Flat surface.
// PF_LowShadowDetail= 0x00008000  # Low detail shadows.
// PF_NoMerge        = 0x00010000  # OVERRIDDEN Used for LOD BIAS.
// PF_CloudWavy      = 0x00020000  # Polygon appears wavy like clouds.
// PF_DirtyShadows   = 0x00040000  # Dirty shadows.
// PF_BrightCorners  = 0x00080000  # Brighten convex corners.
// PF_SpecialLit     = 0x00100000  # Only speciallit lights apply to this poly.
// PF_Gouraud        = 0x00200000  # Gouraud shaded.
// PF_Unlit          = 0x00400000  # Unlit.
// PF_HighShadowDetail=0x00800000  # High detail shadows.
// PF_Memorized      = 0x01000000  # Editor: Poly is remembered.
// PF_Selected       = 0x02000000  # Editor: Poly is selected.
// PF_Portal         = 0x04000000  # Portal between iZones.
// PF_Mirrored       = 0x08000000  # Reflective surface.

//------------------------------------------------------------------------------
// FLAGS = 2050 = PF_Masked | PF_NoSmooth
// Using PF_Masked for transparency on the UI
// Using PF_NoSmooth because without it, the small UI textures get blurred badly
//------------------------------------------------------------------------------

// Weapons
#EXEC TEXTURE IMPORT NAME=UIBroadSword FILE=..\RArpg\Textures\UI\UIBroadSword.pcx FLAGS=2050
#EXEC TEXTURE IMPORT NAME=UIWoodShield FILE=..\RArpg\Textures\WoodShield.pcx FLAGS=2050
#EXEC TEXTURE IMPORT NAME=UIBattleAxe FILE=..\RArpg\Textures\BattleAxe.pcx FLAGS=2050
#EXEC TEXTURE IMPORT NAME=UIBattleHammer FILE=..\RArpg\Textures\UI\UIBattleHammer.pcx FLAGS=2050
#EXEC TEXTURE IMPORT NAME=UIWorkSword FILE=..\RArpg\Textures\UI\UIWorkSword.pcx FLAGS=2050
#EXEC TEXTURE IMPORT NAME=UIBattleSword FILE=..\RArpg\Textures\UI\UIBattleSword.pcx FLAGS=2050
#EXEC TEXTURE IMPORT NAME=UILowCal FILE=..\RArpg\Textures\UI\UILowCal.pcx FLAGS=2050

// Heads
#EXEC TEXTURE IMPORT NAME=UISkullHead FILE=..\RArpg\Textures\UI\UISkullHead.pcx FLAGS=2050