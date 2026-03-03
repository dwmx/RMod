//==============================================================================
//	R_ArpgEntityTagContainer
//	Contains a set of tags traceable to a source UID
//	This is meant to be owned by an ArpgEntity
//==============================================================================
class R_ArpgEntityTagContainer extends R_ArpgObject;

struct R_ArpgTraceableTag
{
	var Name Tag;
	var int SourceUID;
	var bool bValid;
};
var private R_ArpgTraceableTag Tags[32];

function InitializeArpgObject()
{
	local int i;
	for(i = 0; i < ArrayCount(Tags); ++i)
	{
		Tags[i].bValid = false;
	}
}

function AddTag(Name Tag, int SourceUID)
{
	local int i;

	// Ensure the tag is not already contained
	for(i = 0; i < ArrayCount(Tags); ++i)
	{
		if(!Tags[i].bValid)
		{
			continue;
		}

		if(Tags[i].SourceUID == SourceUID && Tags[i].Tag == Tag)
		{
			return;
		}
	}

	for(i = 0; i < ArrayCount(Tags); ++i)
	{
		if(!Tags[i].bValid)
		{
			Tags[i].Tag = Tag;
			Tags[i].SourceUID = SourceUID;
			Tags[i].bValid = true;
			return;
		}
	}
}

function bool HasTag(Name Tag)
{
	local int i;

	for(i = 0; i < ArrayCount(Tags); ++i)
	{
		if(!Tags[i].bValid)
		{
			continue;
		}
		if(Tags[i].Tag == Tag)
		{
			return true;
		}
	}
	return false;
}

function RemoveAllForSource(int SourceUID)
{
	local int i;

	for(i = 0; i < ArrayCount(Tags); ++i)
	{
		if(Tags[i].bValid && Tags[i].SourceUID == SourceUID)
		{
			Tags[i].bValid = false;
		}
	}
}

function GetUniqueTags(out Name OutTags[32], out int OutTagCount)
{
	local Name UniqueTags[ArrayCount(Tags)];
	local int UniqueTagCount;
	local bool bSkip;
	local int i, j;

	UniqueTagCount = 0;
	for(i = 0; i < ArrayCount(Tags); ++i)
	{
		if(!Tags[i].bValid)
		{
			continue;
		}

		bSkip = false;
		for(j = 0; j < UniqueTagCount; ++j)
		{
			if(UniqueTags[j] == Tags[i].Tag)
			{
				bSkip = true;
				break;
			}
		}
		if(bSkip)
		{
			continue;
		}

		UniqueTags[UniqueTagCount] = Tags[i].Tag;
		++UniqueTagCount;
	}

	OutTagCount = 0;
	for(i = 0; i < UniqueTagCount && i < ArrayCount(OutTags); ++i)
	{
		OutTags[i] = UniqueTags[i];
		++OutTagCount;
	}
}