void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

    this.set_f32("damagereduction", 0.5);
    this.set_f32("manaregtime", 2*30);
    this.set_u16("maxmana", 35);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.70f, 0.70f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "knight") return;

    if (!caller.get_bool("hashelmet"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$chromium_helmet$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$chromium_helmet$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip helmet first!"), params);
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
	        caller.set_string("helmetname", "chromium_helmet");

	        caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.5);
            if (player !is null && player.isMyPlayer()) caller.set_f32("manaregtime", caller.get_f32("manaregtime") - 2*30);
            caller.set_u16("maxmana", caller.get_u16("maxmana") + 35);
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}