namespace Effects
{
    shared enum effs
    {
        PLACEHOLDER,
        POTIONBUFF,
        POISON,
        BLEED,
        REGEN,
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
    }
    return "No Effect";
}

string getEffectDescription(u16 eff)
{
    switch(eff)
    {
        case Effects::POTIONBUFF: return "You are under a potion effect,\nwait until it lasts,\nor use some medkit!";
        case Effects::POISON: return "You are poisoned!\nYou need to do something!";
        case Effects::BLEED: return "You are bleeding!\nUse something to stop\nblood unceremoniously\leaving you!";
        case Effects::REGEN: return "Your regenerating\nstrength is increased.";
    }
    return "No Description";
}

bool getEffectType(string name) 
{
    if (name == "potion") return true;
    else if (name == "poison") return true;
    else if (name == "bleed") return true;
    else if (name == "regen") return false;

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
