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
        REASSURANCE
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
    }
    return "No Description";
}

bool getEffectType(string name) // string because entry is splitted string, without parseInt() 
{
    if (name == "1") return true;
    else if (name == "2") return true;
    else if (name == "3") return true;
    else if (name == "4") return false;
    else if (name == "5") return false;
    else if (name == "6") return false;
    else if (name == "7") return false;
    else if (name == "8") return false;

    return false;
}

bool hasEffect(CBlob@ blob, u16 eff)
{
    return blob.hasTag(getEffectName(eff));
}

void giveEffect(CBlob@ blob, u16 eff)
{
    CBitStream params;
    params.write_u16(eff);
    blob.SendCommand(blob.getCommandID("receive_effect"), params);
}

void SetToFreeSlot(CBlob@ this, string name, string buff, u16 time)
{
	if (this.get_string("eff1") == "")
	{
		this.set_u16("timer1", time);
		this.set_string("eff1", name);
		this.Sync("eff1", true); // for onRender
		this.set_string("buffs1", buff);
		this.Sync("buffs1", true);
	} 
	else if (this.get_string("eff2") == "") 
	{
		this.set_u16("timer2", time);
		this.set_string("eff2", name);
		this.Sync("eff2", true);
		this.set_string("buffs2", buff);
		this.Sync("buffs2", true);
	}
	else if (this.get_string("eff3") == "")
	{
		this.set_u16("timer3", time);
		this.set_string("eff3", name);
		this.Sync("eff3", true);
		this.set_string("buffs3", buff);
		this.Sync("buffs3", true);
	}
	else if (this.get_string("eff4") == "")
	{
		this.set_u16("timer4", time);
		this.set_string("eff4", name);
		this.Sync("eff4", true);
		this.set_string("buffs4", buff);
		this.Sync("buffs4", true);
	}
	else if (this.get_string("eff5") == "")
	{
		this.set_u16("timer5", time);
		this.set_string("eff5", name);
		this.Sync("eff5", true);
		this.set_string("buffs5", buff);
		this.Sync("buffs5", true);
	}
	else if (this.get_string("eff6") == "")
	{
		this.set_u16("timer6", time);
		this.set_string("eff6", name);
		this.Sync("eff6", true);
		this.set_string("buffs6", buff);
		this.Sync("buffs6", true);
	} 
	else if (this.get_string("eff7") == "") 
	{
		this.set_u16("timer7", time);
		this.set_string("eff7", name);
		this.Sync("eff7", true);
		this.set_string("buffs7", buff);
		this.Sync("buffs7", true);
	}
	else if (this.get_string("eff8") == "")
	{
		this.set_u16("timer8", time);
		this.set_string("eff8", name);
		this.Sync("eff8", true);
		this.set_string("buffs8", buff);
		this.Sync("buffs8", true);
	}
	else if (this.get_string("eff9") == "")
	{
		this.set_u16("timer9", time);
		this.set_string("eff9", name);
		this.Sync("eff9", true);
		this.set_string("buffs9", buff);
		this.Sync("buffs9", true);
	}
	else if (this.get_string("eff10") == "")
	{
		this.set_u16("timer10", time);
		this.set_string("eff10", name);
		this.Sync("eff10", true);
		this.set_string("buffs10", buff);
		this.Sync("buff10", true);
	}
}