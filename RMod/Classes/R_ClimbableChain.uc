//==============================================================================
//  R_ClimbableChain
//  Multiplayer compatible version of the ClimbableChain actor.
//  This actor should not be placed directly in level by level designers.
//  Instead, this actor is substituted in place of Rope
//  or ClimbableChain actors.
//==============================================================================
class R_ClimbableChain extends R_ClimbableBase;

defaultproperties
{
    ParticleTexture(0)=Texture'RuneFX.chain1'
}