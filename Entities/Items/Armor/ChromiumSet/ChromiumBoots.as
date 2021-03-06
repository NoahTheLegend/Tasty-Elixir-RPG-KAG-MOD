void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

	this.set_f32("velocity", 0.15);
    this.set_f32("blockchance", 5.0);
    this.set_f32("damagereduction", 0.35);
    this.set_f32("attackspeed", 0.2);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.80f, 0.80f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "knight") return;

    if (!caller.get_bool("hasboots"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$chromium_boots$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$chromium_boots$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip boots first!"), params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd==this.getCommandID("equip"))
    {
        u16 callerid = params.read_u16();
        CBlob@ caller = getBlobByNetworkID(callerid);

        if (caller !is null)
        {
            if (caller.getCarriedBlob() !is null) caller.getCarriedBlob().server_Die();

            caller.set_bool("hasboots", true);
	        caller.set_string("bootsname", "chromium_boots");

	        caller.set_f32("velocity", caller.get_f32("velocity") - 0.15);
            caller.set_f32("blockchance", caller.get_f32("blockchance") + 5.0);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.35);
            caller.set_f32("attackspeed", caller.get_f32("attackspeed") + 0.15);

            CBitStream params;
		    params.write_f32(this.get_f32("attackspeed"));
		    params.write_bool(true);
		    caller.SendCommand(caller.getCommandID("doattackspeedchange"), params);
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}