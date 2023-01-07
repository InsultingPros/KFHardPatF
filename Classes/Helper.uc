// Holds utilitary functions
// Author        : NikC-
// Home Repo     : https://github.com/InsultingPros/KFHardPatF
// License       : https://www.gnu.org/licenses/gpl-3.0.en.html
class Helper extends Info;

// Mutate help related stuff
static function TellAbout(string arg, PlayerController pc, KFHardPatF Mut)
{
    if (arg == "")
    {
        Mut.SendMessage(pc, "%rHard Pat Mutator%w:");
        Mut.SendMessage(pc, "%wAvailable commands - %bSTANDARD%w (%g0%w),%bXMAS%w (%g1%w),");
        Mut.SendMessage(pc, "%bCIRCUS%w (%g2%w),%bHALLOWEEN%w (%g3%w).");
        Mut.SendMessage(pc, "%bSTATUS%w, %bSAVE%w.");
    }

    else if (arg ~= "STATUS")
    {
        Mut.SendMessage(pc, "%wPrints all main settings that are currently used.");
    }

    else if (arg ~= "SAVE")
    {
        Mut.SendMessage(pc, "%gSAVE");
        Mut.SendMessage(pc, "%wSave all config variables.");
    }
}

// color codes for messages
static function string ParseFormattedLine(string input)
{
    ReplaceText(input, "%r", chr(27) $ chr(200) $ chr(1)   $chr(1));
    ReplaceText(input, "%g", chr(27) $ chr(1)   $ chr(200) $chr(1));
    ReplaceText(input, "%b", chr(27) $ chr(1)   $ chr(100) $chr(200));
    ReplaceText(input, "%w", chr(27) $ chr(200) $ chr(200) $chr(200));
    ReplaceText(input, "%y", chr(27) $ chr(200) $ chr(200) $chr(1));
    ReplaceText(input, "%p", chr(27) $ chr(200) $ chr(1)   $chr(200));
    return input;
}

// remove color codes
static function string StripFormattedString(string input)
{
    ReplaceText(input, "%r", "");
    ReplaceText(input, "%g", "");
    ReplaceText(input, "%b", "");
    ReplaceText(input, "%w", "");
    ReplaceText(input, "%y", "");
    ReplaceText(input, "%p", "");
    return input;
}

defaultproperties{}