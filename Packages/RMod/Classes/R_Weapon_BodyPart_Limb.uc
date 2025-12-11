class R_Weapon_BodyPart_Limb extends R_AWeapon_BodyPart;

function ApplyBodyPartSubClass(Class<Actor> SubClass)
{
    local Class<LimbWeapon> LimbWeaponSubClass;
    local int i;
    
    LimbWeaponSubClass = Class<LimbWeapon>(SubClass);
    if(LimbWeaponSubClass == None)
    {
        return;
    }
    
    Self.SkelMesh = LimbWeaponSubClass.Default.SkelMesh;
    for(i = 0; i < 16; ++i)
        Self.SkelGroupSkins[i] = LimbWeaponSubClass.Default.SkelGroupSkins[i];
}