
namespace SkillsKnight
{
    shared enum skills
    {
        SHIELDBLOCK,
        FURY,
        MASSBASH,
        ENDURANCE,
        INNERRAGE,
        POWERCORE,
        FIERYBREATH,
        FIRERING,
        MASSSTRENGTH,
        METEORSUMMON,
        FLAMINGESSENCE,
        SWORDSMASTERY,
        PARRY,
        PENETRATINGHIT,
        SWORDTHROW,
        SWORDSPIN,
        FLUMINANTHITS,
        MANAFLAME,
        PROCLAMATION,
        QUAKE,
        HYPERWAVES
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

    if (hasAnimation(this.getName(), idx))
    {
	    this.set_bool("animplaying", true);
	    this.set_string("animname", this.get_string("skill"+idx));
	    this.set_u32("begintime", getGameTime());
    }
}

bool hasAnimation(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return true;
            case SkillsKnight::FURY: return false;
            case SkillsKnight::MASSBASH: return true;
            case SkillsKnight::ENDURANCE: return false;
            case SkillsKnight::INNERRAGE: return false;
            case SkillsKnight::POWERCORE: return true;
            case SkillsKnight::FIERYBREATH: return true;
            case SkillsKnight::FIRERING: return false;
            case SkillsKnight::MASSSTRENGTH: return true;
            case SkillsKnight::METEORSUMMON: return false;
            case SkillsKnight::FLAMINGESSENCE: return false;
            case SkillsKnight::SWORDSMASTERY: return false;
            case SkillsKnight::PARRY: return false;
            case SkillsKnight::PENETRATINGHIT: return false; 
            case SkillsKnight::SWORDTHROW: return false;
            case SkillsKnight::SWORDSPIN: return false;
            case SkillsKnight::FLUMINANTHITS: return false;
            case SkillsKnight::MANAFLAME: return false;
            case SkillsKnight::PROCLAMATION: return true;
            case SkillsKnight::QUAKE: return true;
            case SkillsKnight::HYPERWAVES: return false;
        }
    }
    else if (pclass == "archer")
    {
        switch(ski)
        {
            case SkillsArcher::CONCENTRATION: return true;
        }
    }
    else if (pclass == "rogue")
    {
        switch(ski)
        {
            case SkillsRogue::SILENCE: return false;
        }

    }
    else if (pclass == "common")
    {
        switch(ski)
        {
            case SkillsCommon::REASSURANCE: return true;
        }
    }
    return false;
}

string getSkillIcon(string pclass, u16 ski)
{
    if (pclass == "knight")
    {
        switch(ski)
        {
            case SkillsKnight::SHIELDBLOCK: return "ShieldblockIcon.png";
            case SkillsKnight::FURY: return "FuryIcon.png";
            case SkillsKnight::MASSBASH: return "MassbashIcon.png";
            case SkillsKnight::ENDURANCE: return "EnduranceIcon.png";
            case SkillsKnight::INNERRAGE: return "InnerrageIcon.png";
            case SkillsKnight::POWERCORE: return "PowercoreIcon.png";
            case SkillsKnight::FIERYBREATH: return "FierybreathIcon.png";
            case SkillsKnight::FIRERING: return "FireringIcon.png";
            case SkillsKnight::MASSSTRENGTH: return "MassstrengthIcon.png";
            case SkillsKnight::METEORSUMMON: return "MeteorsummonIcon.png";
            case SkillsKnight::FLAMINGESSENCE: return "FlamingessenceIcon.png";
            case SkillsKnight::SWORDSMASTERY: return "SwordsmasteryIcon.png";
            case SkillsKnight::PARRY: return "ParryIcon.png";
            case SkillsKnight::PENETRATINGHIT: return "PenetratinghitIcon.png";
            case SkillsKnight::SWORDTHROW: return "SwordthrowIcon.png";
            case SkillsKnight::SWORDSPIN: return "SwordspinIcon.png";
            case SkillsKnight::FLUMINANTHITS: return "FulminanthitsIcon.png";
            case SkillsKnight::MANAFLAME: return "ManaflameIcon.png";
            case SkillsKnight::PROCLAMATION: return "ProclamationIcon.png";
            case SkillsKnight::QUAKE: return "QuakeIcon.png";
            case SkillsKnight::HYPERWAVES: return "HyperwavesIcon.png";
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
            case SkillsKnight::FURY: return "Fury";
            case SkillsKnight::MASSBASH: return "Mass bash";
            case SkillsKnight::ENDURANCE: return "Endurance";
            case SkillsKnight::INNERRAGE: return "Inner rage";
            case SkillsKnight::POWERCORE: return "Power core";
            case SkillsKnight::FIERYBREATH: return "Fiery breath";
            case SkillsKnight::FIRERING: return "Fire ring";
            case SkillsKnight::MASSSTRENGTH: return "Mass strength";
            case SkillsKnight::METEORSUMMON: return "Meteor summon";
            case SkillsKnight::FLAMINGESSENCE: return "Flaming essence";
            case SkillsKnight::SWORDSMASTERY: return "Swords mastery";
            case SkillsKnight::PARRY: return "Parry";
            case SkillsKnight::PENETRATINGHIT: return "Penetrating hit";
            case SkillsKnight::SWORDTHROW: return "Sword throw";
            case SkillsKnight::SWORDSPIN: return "Sword spin";
            case SkillsKnight::FLUMINANTHITS: return "Fluminant hits";
            case SkillsKnight::MANAFLAME: return "Mana flame";
            case SkillsKnight::PROCLAMATION: return "Proclamation";
            case SkillsKnight::QUAKE: return "Quake";
            case SkillsKnight::HYPERWAVES: return "Hyper waves";
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
            case SkillsKnight::SHIELDBLOCK: return "Active:\nYou gain additional\n+25% of block chance for 15 seconds";
            case SkillsKnight::FURY: return "Passive:\nWhenever you are being hit, you receive\n+0.1 of additional damage.\nMax stacks: 5";
            case SkillsKnight::MASSBASH: return "Active:\nStuns all enemies in 6 blocks radius for 2 seconds";
            case SkillsKnight::ENDURANCE: return "Passive:\nIf your health is lower,\nthan 3 HP, you gain +0.5 of\nhealth regen";
            case SkillsKnight::INNERRAGE: return "Passive:\nIf your health is lower,\nthan 3 HP, you gain +15% of crit\n+0.5 of attack speed,\nand you burst an explosion";
            case SkillsKnight::POWERCORE: return "Active:\nYou become immune to damage for\n10 seconds and gain -1.0 of agility.\nAfter that time lasts,\nyou gain +1.0 agility for 10 seconds";
            case SkillsKnight::FIERYBREATH: return "Active:\nYou set on fire all enemies in\n8 block radius";
            case SkillsKnight::FIRERING: return "Active:\nSummons a magic ring, that hits\nand sets on fire nearby enemies";
            case SkillsKnight::MASSSTRENGTH: return "Active:\nPlayers except you in 10 blocks\nradius gain +1.5 of additional\ndamage. You heal 3 HP yourself";
            case SkillsKnight::METEORSUMMON: return "Active:\nSummons a magic meteor on a\nchosen enemy. It bashes enemy for\n5 seconds and deals damage, equal\nto yours additional damage*4";
            case SkillsKnight::FLAMINGESSENCE: return "Passive:\nAny of your melee attack sets\non fire the enemy you hit.";
            case SkillsKnight::SWORDSMASTERY: return "Passive:\nYou gain extra 1.0 of additional damage,\nwhen wearing double swords";
            case SkillsKnight::PARRY: return "Passive:\nWith a chance, equal to your block chance,\nyou can revert gain damage to the enemy";
            case SkillsKnight::PENETRATINGHIT: return "Active:\nYou attack in a large zone before you.";
            case SkillsKnight::SWORDTHROW: return "Active:\nYou throw a sword, that deals damage,\nequal to yours additional damage*2";
            case SkillsKnight::SWORDSPIN: return "Active:\nYou hit all enemies standing nearby";
            case SkillsKnight::FLUMINANTHITS: return "Active\nYou stab several times in a short time";
            case SkillsKnight::MANAFLAME: return "Active\nSummons a magic flame, that hits nearby\nenemies and restore you 5% of mana for each";
            case SkillsKnight::PROCLAMATION: return "Passive:\nYou summon several knights\nthat fight with you";
            case SkillsKnight::QUAKE: return "Active:\nYou hit ground and it pushes all nearby enemies to up.\nAlso stuns them for 5 seconds";
            case SkillsKnight::HYPERWAVES: return "Active:\nYou cast 2 sound waves, that move\nfrom you, damage and push all enemies\nin opposite way.";
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
            case SkillsKnight::FURY: return 0;
            case SkillsKnight::MASSBASH: return 25*30;
            case SkillsKnight::ENDURANCE: return 0;
            case SkillsKnight::INNERRAGE: return 0;
            case SkillsKnight::POWERCORE: return 60*30;
            case SkillsKnight::FIERYBREATH: return 35*30;
            case SkillsKnight::FIRERING: return 40*30;
            case SkillsKnight::MASSSTRENGTH: return 40*30;
            case SkillsKnight::METEORSUMMON: return 20*30;
            case SkillsKnight::FLAMINGESSENCE: return 0;
            case SkillsKnight::SWORDSMASTERY: return 0;
            case SkillsKnight::PARRY: return 0;
            case SkillsKnight::PENETRATINGHIT: return 15*30;
            case SkillsKnight::SWORDTHROW: return 20*30;
            case SkillsKnight::SWORDSPIN: return 30*30;
            case SkillsKnight::FLUMINANTHITS: return 45*30;
            case SkillsKnight::MANAFLAME: return 45*30;
            case SkillsKnight::PROCLAMATION: return 120*30;
            case SkillsKnight::QUAKE: return 30*30;
            case SkillsKnight::HYPERWAVES: return 45*30;
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
            case SkillsKnight::FURY: return 15*30; // 1 of 5 effects time
            case SkillsKnight::MASSBASH: return 2*30; // bash time
            case SkillsKnight::ENDURANCE: return 0; // no time
            case SkillsKnight::INNERRAGE: return 0; // no time
            case SkillsKnight::POWERCORE: return 10*30; // time of immunity & agility
            case SkillsKnight::FIERYBREATH: return 7.5*30; // time to set enemies on fire
            case SkillsKnight::FIRERING: return 15*30; // time of ring life
            case SkillsKnight::MASSSTRENGTH: return 15*30; // time of strength thats applied to allies
            case SkillsKnight::METEORSUMMON: return 5*30; // bash time
            case SkillsKnight::FLAMINGESSENCE: return 0; // no time
            case SkillsKnight::SWORDSMASTERY: return 0; // no time
            case SkillsKnight::PARRY: return 0; // no time
            case SkillsKnight::PENETRATINGHIT: return 0; // no time
            case SkillsKnight::SWORDTHROW: return 0; // no time
            case SkillsKnight::SWORDSPIN: return 0; // no time
            case SkillsKnight::FLUMINANTHITS: return 0; // no time
            case SkillsKnight::MANAFLAME: return 0; // no time
            case SkillsKnight::PROCLAMATION: return 45*30; // time of allies' life 
            case SkillsKnight::QUAKE: return 5*30; // bash time
            case SkillsKnight::HYPERWAVES: return 3*30; // time of waves' life
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
            case SkillsKnight::FURY: return 0;
            case SkillsKnight::MASSBASH: return 20;
            case SkillsKnight::ENDURANCE: return 0;
            case SkillsKnight::INNERRAGE: return 0;
            case SkillsKnight::POWERCORE: return 40;
            case SkillsKnight::FIERYBREATH: return 25;
            case SkillsKnight::FIRERING: return 30;
            case SkillsKnight::MASSSTRENGTH: return 30;
            case SkillsKnight::METEORSUMMON: return 30;
            case SkillsKnight::FLAMINGESSENCE: return 0;
            case SkillsKnight::SWORDSMASTERY: return 0;
            case SkillsKnight::PARRY: return 0;
            case SkillsKnight::PENETRATINGHIT: return 15;
            case SkillsKnight::SWORDTHROW: return 20;
            case SkillsKnight::SWORDSPIN: return 25;
            case SkillsKnight::FLUMINANTHITS: return 40;
            case SkillsKnight::MANAFLAME: return 30;
            case SkillsKnight::PROCLAMATION: return 50;
            case SkillsKnight::QUAKE: return 20;
            case SkillsKnight::HYPERWAVES: return 35;
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

void giveSkill(CBlob@ blob, string type, u16 ski)
{
    if (type != "knight" && type != "archer" && type != "rogue" && type != "common") return;
    CBitStream params;
    params.write_string(type);
    params.write_u16(ski);
    blob.SendCommand(blob.getCommandID("receive_skill"), params);
}

void takeSkill(CBlob@ blob, u16 pos)
{
    CBitStream params;
    params.write_u8(pos);
    blob.SendCommand(blob.getCommandID("take_skill"), params);
}