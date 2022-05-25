namespace Effects
{
    shared enum effs
    {
        PLACEHOLDER,
        POTIONBUFF,
        POISON,
        BLEED,
        REGEN,
        SHIELDBLOCK,
        CONCENTRATION,
        SILENCE,
        REASSURANCE,
		FURY,
		ENDURANCE,
		INNERRAGE,
		POWERCORE,
		FIRERING,
		MASSSTRENGTH,
		SWORDSMASTERY
    }
}

string getEffectIcon(u16 eff)
{
    switch(eff)
    {
        case Effects::POTIONBUFF: return "PotionIcon.png";
        case Effects::POISON: return "PoisonedIcon.png";
        case Effects::BLEED: return "BleedingIcon.png";
        case Effects::REGEN: return "RegenIcon.png";
        case Effects::SHIELDBLOCK: return "ShieldblockEffectIcon.png";
        case Effects::CONCENTRATION: return "ConcentrationEffectIcon.png";
        case Effects::SILENCE: return "SilenceEffectIcon.png";
        case Effects::REASSURANCE: return "ReassuranceEffectIcon.png";
		case Effects::FURY: return "FuryEffectIcon.png";
		case Effects::ENDURANCE: return "EnduranceEffectIcon.png";
		case Effects::INNERRAGE: return "InnerrageEffectIcon.png";
		case Effects::POWERCORE: return "PowercoreEffectIcon.png";
		case Effects::FIRERING: return "FireringEffectIcon.png";
		case Effects::MASSSTRENGTH: return "MassstrengtEffecthIcon.png";
		case Effects::SWORDSMASTERY: return "SwordsmasteryEffectIcon.png";
    }
    return "No Icon";
}

string getEffectName(u16 eff)
{
    switch(eff)
    {
        case Effects::POTIONBUFF: return "POTION EFFECT";
        case Effects::POISON: return "POISONED";
        case Effects::BLEED: return "BLEED";
        case Effects::REGEN: return "REGEN INCREASE";
        case Effects::SHIELDBLOCK: return "SKILL: SHIELD BLOCK";
        case Effects::CONCENTRATION: return "SKILL: CONCENTRATION";
        case Effects::SILENCE: return "SKILL: SILENCE";
        case Effects::REASSURANCE: return "SKILL: REASSURANCE";
		case Effects::FURY: return "SKILL: FURY";
		case Effects::ENDURANCE: return "SKILL: ENDURANCE";
		case Effects::INNERRAGE: return "SKILL: INNER RAGE";
		case Effects::POWERCORE: return "SKILL: POWER CORE";
		case Effects::FIRERING: return "SKILL: FIRE RING";
		case Effects::MASSSTRENGTH: return "SKILL: MASS STRENGTH";
		case Effects::SWORDSMASTERY: return "SKILL: SWORDS MASTERY";
    }
    return "No Effect";
}

string getEffectDescription(u16 eff)
{
    switch(eff)
    {
        case Effects::POTIONBUFF: return "You are under a potion effect,\nwait until it lasts,\nor use some medkit!";
        case Effects::POISON: return "You are poisoned and can't\nregenerate health!\nYou need to do something!";
        case Effects::BLEED: return "You are bleeding!\nUse something to stop\nblood unceremoniously\leaving you!";
        case Effects::REGEN: return "Your regenerating\nstrength is increased.";
        case Effects::SHIELDBLOCK: return "Your combat stance\nis enpowered!";
        case Effects::CONCENTRATION: return "You are in harmony\nwith environment!";
        case Effects::SILENCE: return "Ready to stab!";
        case Effects::REASSURANCE: return "Optimism as a solution.";
		case Effects::FURY: return "You gain extra damage when being hit!";
		case Effects::ENDURANCE: return "You regenerate more health\nwhen you have few HP.";
		case Effects::INNERRAGE: return "You gain extra buffs\nwhen you have few HP.";
		case Effects::POWERCORE: return "You gain immunity to\ndamage, and after\nthat +1.0 of agility.";
		case Effects::FIRERING: return "Fire ring is warming\nyou externally!";
		case Effects::MASSSTRENGTH: return "Your damage is buffed.";
		case Effects::SWORDSMASTERY: return "You gain extra bonuses\nwhen holding two swords!";
    }
    return "No Description";
}

bool getEffectType(string name) // string because entry is splitted string, without parseInt() 
{
	u8 idx = parseFloat(name);
    if (idx == 1) return true;
    else if (idx == 2 || idx == 3) return true;
    else if (idx > 3 && idx < 15) return false;

    return true;
}

bool hasEffect(CBlob@ blob, u16 eff)
{
    return blob.hasTag(getEffectName(eff));
}

void giveEffect(CBlob@ blob, u16 eff)
{
    CBitStream params;
    params.write_u16(eff);
	params.write_u32(1800+XORRandom(900));
    blob.SendCommand(blob.getCommandID("receive_effect"), params);
}

void SetToSlot(CBlob@ this, string name, string buff, u16 time, u8 idx)
{
	this.set_u16("timer"+idx, time);
	this.set_string("eff"+idx, name);
	this.Sync("eff"+idx, true); // for onRender
	this.set_string("buffs"+idx, buff);
	this.Sync("buffs"+idx, true);
}

void SetToFreeSlot(CBlob@ this, string name, string buff, u16 time)
{
	if (this.get_string("eff1") == "")
		SetToSlot(this, name, buff, time, 1);
	else if (this.get_string("eff2") == "") 
		SetToSlot(this, name, buff, time, 2);
	else if (this.get_string("eff3") == "")
		SetToSlot(this, name, buff, time, 3);
	else if (this.get_string("eff4") == "")
		SetToSlot(this, name, buff, time, 4);
	else if (this.get_string("eff5") == "")
		SetToSlot(this, name, buff, time, 5);
	else if (this.get_string("eff6") == "")
		SetToSlot(this, name, buff, time, 6);
	else if (this.get_string("eff7") == "") 
		SetToSlot(this, name, buff, time, 7);
	else if (this.get_string("eff8") == "")
		SetToSlot(this, name, buff, time, 8);
	else if (this.get_string("eff9") == "")
		SetToSlot(this, name, buff, time, 9);
	else if (this.get_string("eff10") == "")
		SetToSlot(this, name, buff, time, 10);
}