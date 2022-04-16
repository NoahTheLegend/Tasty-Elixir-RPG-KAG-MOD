void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");
    
    this.Tag("armor");

    this.set_f32("damagereduction", (XORRandom(20)+1)/10);
    this.set_f32("critchance", XORRandom(20)+1);
    this.set_f32("damagebuff", (XORRandom(10)+11)/10);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.35f, 0.35f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "knight") return;

    if (!caller.get_bool("hasgloves"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$mythicalalloy_gloves$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$mythicalalloy_gloves$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip gloves first!"), params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd==this.getCommandID("equip"))
    {
        u16 callerid = params.read_u16();
        CBlob@ caller = getBlobByNetworkID(callerid);

        CPlayer@ player = caller.getPlayer();

        if (caller !is null)
        {
            if (caller.getCarriedBlob() !is null) caller.getCarriedBlob().server_Die();

            caller.set_bool("hasgloves", true);
	        caller.set_string("glovesname", "mythicalalloy_gloves");

            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + this.get_f32("damagereduction"));
            caller.set_f32("critchance", caller.get_f32("critchance") + this.get_f32("critchance"));
            if (player !is null && player.isMyPlayer()) caller.set_f32("damagebuff", caller.get_f32("damagebuff") + 0.15);
        
            //set variables to save XORRandom()ly defined stats
            caller.set_f32("mythglovesdamagereduction", this.get_f32("damagereduction"));
            caller.set_f32("mythglovescrithance", this.get_f32("critchance"));
            caller.set_f32("mythglovesdamagebuff", this.get_f32("damagebuff"));
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}