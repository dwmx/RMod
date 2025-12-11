//==============================================================================
// R_ProjectileTracer
// Particle system effect which draws a tracer path behind a projectile
//
// Note:
// This particle system is NOT replicated, and is not meant to be
// These get spawned locally by an owning projectile and display effects
// locally only
//
// Because it's entirely local, non of the functions should be simulated
//==============================================================================
class R_ProjectileTracer extends ParticleSystem;

var Class<R_AUtilities> UtilitiesClass;
var float RibbonThickness;
var float RibbonSpeed;

var Vector SavedParticleBegin;
var Vector SavedParticleEnd;

var bool bInitialParticle;

event PostBeginPlay()
{
    local int i;
    
    if(Owner == None)
    {
        UtilitiesClass.Static.RModWarn(
            "Projectile tracer spawned without an owner, destroying");
        Destroy();
        return;
    }
    
    Super.PostBeginPlay();
    
    Owner.Attach(Self);
    
    for(i = 0; i < ParticleCount; ++i)
    {
        ParticleArray[i].Valid = false;
    }
    
    bInitialParticle = true;
}

event Tick(float DeltaSeconds)
{
    local Vector EffectLocation;
    local Vector NewParticleBegin, NewParticleEnd;
    local Vector RX, RY, RZ;
    
    if(Owner == None)
    {
        return;
    }
    
    GetAxes(Owner.Rotation, RX, RY, RZ);
    EffectLocation = GetEffectLocation();
    
    // Spawn new particle and update saved location
    NewParticleBegin = EffectLocation + RY * RibbonThickness * 1.0;
    NewParticleEnd = EffectLocation + RY * RibbonThickness * -1.0;
    
    if(bInitialParticle)
    {
        SavedParticleBegin = NewParticleBegin;
        SavedParticleEnd = NewParticleEnd;
        bInitialParticle = false;
    }
    
    CreateRibbonParticle(
        DeltaSeconds,
        SavedParticleBegin, SavedParticleEnd,
        NewParticleBegin, NewParticleEnd);
    
    SavedParticleBegin = NewParticleBegin;
    SavedParticleEnd = NewParticleEnd;
    
    // Update system
    UpdateRibbonParticles(DeltaSeconds);
}

function Vector GetEffectLocation()
{
    local Vector Result;
    local R_AProjectile ProjectileOwner;
    local Vector EffectBaseOffset;
    
    if(Owner == None)
    {
        Result.X = 0.0;
        Result.Y = 0.0;
        Result.Z = 0.0;
        return Result;
    }
    
    ProjectileOwner = R_AProjectile(Owner);
    if(ProjectileOwner != None)
    {
        EffectBaseOffset = ProjectileOwner.GetProjectileEffectBaseOffset();
        EffectBaseOffset = EffectBaseOffset >> ProjectileOwner.Rotation;
    }
    
    return Owner.Location + EffectBaseOffset;
}

function CreateRibbonParticle(float DeltaSeconds, Vector Begin1, Vector End1, Vector Begin2, Vector End2)
{
    local int i, j;
    local float ParticleAlpha;
    
    for(i = 0; i < ParticleCount; ++i)
    {
        if(ParticleArray[i].Valid)
        {
            continue;
        }
        
        ParticleArray[i].Valid = true;
        ParticleArray[i].Style = Style;
        ParticleArray[i].TextureIndex = 0;
        
        ParticleAlpha = (float(AlphaStart) / 255.0) * 5.0;
        ParticleArray[i].Alpha.X = ParticleAlpha;
        ParticleArray[i].Alpha.Y = ParticleAlpha;
        ParticleArray[i].Alpha.Z = ParticleAlpha;
        
        // Create quad
        ParticleArray[i].Points[0] = End2;
        ParticleArray[i].Points[1] = End1;
        ParticleArray[i].Points[2] = Begin1;
        ParticleArray[i].Points[3] = Begin2;
        
        // Set UVs
        ParticleArray[i].U0 = FMax((DeltaSeconds * RibbonSpeed * -1.0), -0.99);
        ParticleArray[i].V0 = 0.0;
        ParticleArray[i].U1 = 0.0;
        ParticleArray[i].V1 = 0.99;
        
        // Set particle location to average of four points
        ParticleArray[i].Location = ParticleArray[i].Points[0];
        for(j = 1; j < 4; ++j)
        {
            ParticleArray[i].Location += ParticleArray[i].Points[j];
        }
        ParticleArray[i].Location /= 4;
        break;
    }
}

function UpdateRibbonParticles(float DeltaSeconds)
{
    local int i;
    
    for(i = 0; i < ParticleCount; ++i)
    {
        if(!ParticleArray[i].Valid)
        {
            continue;
        }
        
        // Update UVs
        ParticleArray[i].U0 += DeltaSeconds * RibbonSpeed;
        ParticleArray[i].U1 += DeltaSeconds * RibbonSpeed;
        
        ParticleArray[i].U1 = FMin(ParticleArray[i].U1, 0.99);
        
        // Invalidate particles when UVs collapse
        if(ParticleArray[i].U0 > 0.99)
        {
            ParticleArray[i].Valid = false;
        }
    }
}

defaultproperties
{
    RemoteRole=ROLE_None
    ParticleCount=64
    ParticleType=PART_Generic
    ParticleSpriteType=PSPRITE_QuadUV
    AlphaStart=255
    AlphaEnd=255
    Style=STY_Translucent
    UtilitiesClass=Class'RMod.R_AUtilities'
    RibbonThickness=4.0
    RibbonSpeed=3.0
    ParticleTexture(0)=Texture'RuneI.sb_horizramp'
}