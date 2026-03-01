//==============================================================================
//	R_ArpgTagLibrary
//	Functions for the R_ArpgTag data type
//==============================================================================
class R_ArpgTagLibrary extends R_ArpgObject abstract;

static function R_ArpgTag MakeTag(Name T0, optional Name T1, optional Name T2, optional Name T3)
{
	local R_ArpgTag Tag;
	Tag.T[0] = T0;
	Tag.T[1] = T1;
	Tag.T[2] = T2;
	Tag.T[3] = T3;
	return Tag;
}

static function String ToString(R_ArpgTag Tag)
{
	local int i;
	local String Result;

	Result = "";
	for(i = 0; i < ArrayCount(Tag.T); ++i)
	{
		Result = Result $ String(Tag.T[i]);
		if(i < ArrayCount(Tag.T) - 1)
		{
			if(Tag.T[i+1] != '')
			{
				Result = Result $ ".";
			}
			else
			{
				break;
			}
		}
	}

	return Result;
}

// Tags must match exactly
//    Query                  Target
// 'This.Tag'    matches    'This.Tag'
// 'This.Tag'   mismatches  'This.Tag.Too'
static function bool MatchExact(R_ArpgTag Query, R_ArpgTag Target)
{
	local int i;
	for(i = 0; i < ArrayCount(Query.T); ++i)
	{
		if(Query.T[i] != Target.T[i])
		{
			return false;
		}
	}
	return true;
}

// Query must contain the entire hierarchy of Target
//    Query                  Target
// 'This.Tag.Too' matches  'This.Tag'
// 'This.Tag'     matches  'This.Tag'
// 'This.Tag'   mismatches 'This.Tag.Too'
static function bool MatchHierarchy(R_ArpgTag Query, R_ArpgTag Target)
{
	local int i;
	for(i = 0; i < ArrayCount(Query.T); ++i)
	{
		if(Target.T[i] == '')
		{
			break;
		}
		if(Query.T[i] != Target.T[i])
		{
			return false;
		}
	}
	return true;
}