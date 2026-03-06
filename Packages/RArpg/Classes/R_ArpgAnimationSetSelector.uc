//==============================================================================
//	R_ArpgAnimationSetSelector
//	Static class meant for mapping a Tag to an AnimationSet
//==============================================================================
class R_ArpgAnimationSetSelector extends R_ArpgObject abstract;

static function Class<R_ArpgAnimationSet> GetDefaultAnimationSetClass()
{
	return None;
}

static function Class<R_ArpgAnimationSet> GetAnimationSetClassFromTag(R_ArpgTag Tag)
{
	return None;
}