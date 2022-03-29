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
