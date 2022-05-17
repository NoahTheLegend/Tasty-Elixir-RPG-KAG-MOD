
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

void ActivateSkill(CBlob@ this, u8 idx)
{
	CBitStream params;
	params.write_string(this.get_string("skilltype"+idx));
	params.write_u8(this.get_u8("skillpos"+idx)); // pos of skill in hotbar
	params.write_u16(this.get_u16("skillidx"+idx));
	this.SendCommand(this.getCommandID("activate_skill"), params);
	//printf("sent");
	this.set_u16("skillcd"+idx, getSkillCooldown(this.get_string("skilltype"+idx), this.get_u16("skillidx"+idx)));

	this.set_bool("animplaying", true);
	this.set_string("animname", this.get_string("skill"+idx));
	this.set_u32("begintime", getGameTime());
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
            case SkillsKnight::SHIELDBLOCK: return "\n\n\nYou gain additional +25%\nblockchance for 15 seconds.";
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
            case SkillsKnight::SHIELDBLOCK: return 30*30;
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

const u32 thebitch = "FrankStain".getHash();

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