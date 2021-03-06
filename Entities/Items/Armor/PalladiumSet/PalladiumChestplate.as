void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

    this.set_f32("velocity", 0.4);
    this.set_f32("blockchance", 17.5);
    this.set_f32("damagereduction", 1.5);
    this.set_f32("hpregtime", 3*30);
    this.set_f32("bashchance", 5.0);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.85f, 0.85f);
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "knight") return;

    if (!caller.get_bool("hasarmor"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$palladium_chestplate$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$palladium_chestplate$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip chestplate first!"), params);
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

            caller.set_bool("hasarmor", true);
	        caller.set_string("armorname", "palladium_chestplate");

	        caller.set_f32("velocity", caller.get_f32("velocity") - 0.4);
            caller.set_f32("blockchance", caller.get_f32("blockchance") + 17.5);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 1.5);
            if (player !is null && player.isMyPlayer()) caller.set_f32("hpregtime", caller.get_f32("hpregtime") - 3*30);
            if (player !is null && player.isMyPlayer()) caller.set_f32("bashchance", caller.get_f32("bashchance") + 5.0);
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}