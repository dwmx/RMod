//==============================================================================
//	R_UI_ArpgUIGameLib
//	Library functions to be used across any UI classes for Arpg game package
//==============================================================================
class R_UI_ArpgUIGameLib extends R_ArpgObject abstract;

static function final Color MakeColor3(byte R, byte G, byte B)
{
	local Color Result;
	Result.R = R;
	Result.G = G;
	Result.B = B;
	Result.A = 255;
	return Result;
}

static function Color GetItemRarityTypeDrawColor(Name ItemRarityType)
{
	switch(ItemRarityType)
	{
	case 'Normal':	return MakeColor3(255,255,255);
	case 'Magic':	return MakeColor3(100,100,255);
	case 'Rare':	return MakeColor3(193,255,100);
	case 'Unique':	return MakeColor3(197, 100,255);
	case 'Crafted':	return MakeColor3(252, 87, 10);
	}

	return MakeColor3(255,255,255);
}