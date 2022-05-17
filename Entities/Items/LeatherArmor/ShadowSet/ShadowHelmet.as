void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");
    //move these vars to code bodies. My bad.
    this.set_f32("damagereduction", 0.9);
    this.set_f32("manaregtime", 3*30);
    this.set_u16("maxmana", 100);
    this.set_u16("manareg", 50);
    this.set_f32("bashchance", 15.0);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.5f, 0.5f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "archer" && caller.getName() != "rogue") return;

    if (!caller.get_bool("hashelmet"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$shadow_helmet$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$shadow_helmet$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip helmet first!"), params);
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

            caller.set_bool("hashelmet", true);
	        caller.set_string("helmetname", "shadow_helmet");

	        caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.9);
            if (player !is null && player.isMyPlayer()) caller.set_f32("manaregtime", caller.get_f32("manaregtime") - 3*30);
            caller.set_u16("maxmana", caller.get_u16("maxmana") + 100);
            caller.set_u16("manareg", caller.get_u16("manareg") + 50);
            caller.set_f32("bashchance", caller.get_f32("bashchance") + 15.0);
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}