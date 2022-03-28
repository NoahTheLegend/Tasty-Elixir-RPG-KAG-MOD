
namespace SkillsKnight
{
    shared enum skills
    {
        SHIELDBLOCK,
    }
}

namespace SkillsArcher
{
    shared enum skills
    {
        CONCENTRATION,
    }
}

namespace SkillsRogue
{
    shared enum skills
    {
        SILENCE,
    }
}

namespace SkillsCommon
{
    shared enum skills
    {
        REASSURANCE,
    }
}

string getSkillIcon(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return "ShieldblockIcon.png";
        }
    }
    else if (pclass == "archer")
    {
        switch(ski)
        {
            case SkillsArcher::CONCENTRATION: return "ConcentrationIcon.png";
        }
    }
    else if (pclass == "rogue")
    {
        switch(ski)
        {
            case SkillsRogue::SILENCE: return "SilenceIcon.png";
        }

    }
    else if (pclass == "common")
    {
        switch(ski)
        {
            case SkillsCommon::REASSURANCE: return "ReassuranceIcon.png";
        }
    }
    return "No Icon";
}

string getSkillName(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return "Shield block";
        }
    }
    else if (pclass == "archer")
    {
        switch(ski)
        {
            case SkillsArcher::CONCENTRATION: return "Concentration";
        }
    }
    else if (pclass == "rogue")
    {
        switch(ski)
        {
            case SkillsRogue::SILENCE: return "Silence";
        }

    }
    else if (pclass == "common")
    {
        switch(ski)
        {
            case SkillsCommon::REASSURANCE: return "Reassurance";
        }
    }
    return "No Effect Name";
}

string getSkillDescription(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return "You gain additional +50%\nblockchance for 15 seconds.\n\nIf you get a succesful hit by anyone,\nthis effect disappears.";
        }
    }
    else if (pclass == "archer")
    {
        switch(ski)
        {
            case SkillsArcher::CONCENTRATION: return "You gain +2.0 additional damage for\n15 seconds. Also your next arrow will fly further.\n\nAny your attack removes effect.";
        }
    }
    else if (pclass == "rogue")
    {
        switch(ski)
        {
            case SkillsRogue::SILENCE: return "Your next attack will be a crit.\nIf you have less than 2 hearts, you also gain\n+0.75 agility for 5 seconds.\n\nLasts in 30 seconds.";
        }

    }
    else if (pclass == "common")
    {
        switch(ski)
        {
            case SkillsCommon::REASSURANCE: return "\nWhat a wonderful day!\nYour damage reduction will\nbe increased by 0.5 hearts\nfor 60 seconds.";
        }
    }
    return "No Description";
}

u16 getSkillCooldown(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return 45*30;
        }
    }
    else if (pclass == "archer")
    {
        switch(ski)
        {
            case SkillsArcher::CONCENTRATION: return 45*30;
        }
    }
    else if (pclass == "rogue")
    {
        switch(ski)
        {
            case SkillsRogue::SILENCE: return 45*30;
        }

    }
    else if (pclass == "common")
    {
        switch(ski)
        {
            case SkillsCommon::REASSURANCE: return 180*30;
        }
    }
    return 0;
}

u16 getSkillTime(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return 15*30;
        }
    }
    else if (pclass == "archer")
    {
        switch(ski)
        {
            case SkillsArcher::CONCENTRATION: return 15*30;
        }
    }
    else if (pclass == "rogue")
    {
        switch(ski)
        {
            case SkillsRogue::SILENCE: return 30*30;
        }

    }
    else if (pclass == "common")
    {
        switch(ski)
        {
            case SkillsCommon::REASSURANCE: return 60*30;
        }
    }
    return 0;
}

u16 getSkillMana(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return 25;
        }
    }
    else if (pclass == "archer")
    {
        switch(ski)
        {
            case SkillsArcher::CONCENTRATION: return 15;
        }
    }
    else if (pclass == "rogue")
    {
        switch(ski)
        {
            case SkillsRogue::SILENCE: return 15;
        }

    }
    else if (pclass == "common")
    {
        switch(ski)
        {
            case SkillsCommon::REASSURANCE: return 30;
        }
    }
    return 0;
}

u8 getSkillPosition(CBlob@ this, string name) // move to skills.as later
{
    for (int i = 0; i < 11; i++)
    {
        if (this.get_string("skill1") == name) return 1;
		else if (this.get_string("skill2") == name) return 2;
        else if (this.get_string("skill3") == name) return 3;
        else if (this.get_string("skill4") == name) return 4;
        else if (this.get_string("skill5") == name) return 5;
    }
	return 255;
}

void giveSkill(CBlob@ blob, u16 ski)
{
    CBitStream params;
    params.write_u16(ski);
    blob.SendCommand(blob.getCommandID("receive_skill"), params);
}

void takeSkill(CBlob@ blob, u16 ski)
{
    CBitStream params;
    params.write_u16(ski);
    blob.SendCommand(blob.getCommandID("take_skill"), params);
}

