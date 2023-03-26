//=============================================================================
// UTerminal.StaticUtilities
// Utility functions used throughout the UTerminal package
//=============================================================================
class StaticUtilities extends Object abstract;

// Special string characters
static function String CRLF()
{
    return Chr(10) $ Chr(13);
}

static function String TAB()
{
    return Chr(9);
}

// String tokenizer
static function String GetTokenUsingDelimiter(out String s, String Delimiter)
{
    local int i,length;
    local int delimlength;
    local string tok;

    delimlength = Len(Delimiter);
    if( instr(s,Delimiter) != -1 )
    {
        length = Len(s);
        for (i=0; i<length; i++)
        {
            if (Mid(s, i, delimlength) == Delimiter)
            {
                tok = left(s, i);
                s = right(s, length-i-delimlength);
                break;
            }
        }
    }
    else
    {
        if (tok=="")
        {
            tok = s;
            s = "";
        }
    }

    return tok;
}