void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

	this.set_f32("velocity", 0.3);
    this.set_f32("damagereduction", 0.2);
    this.set_f32("manaregtime", 3*30);
    this.set_u16("maxmana", 10);
    this.set_u16("manareg", 10);
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
	    caller.CreateGenericButton("$golden_boots$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$golden_boots$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip boots first!"), params);
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
	        caller.set_string("bootsname", "golden_boots");

	        caller.set_f32("velocity", caller.get_f32("velocity") - 0.3);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.2);
            caller.set_f32("manaregtime", caller.get_f32("manaregtime") - 3*30);
            caller.set_u16("maxmana", caller.get_u16("maxmana") + 10);
            caller.set_u16("manareg", caller.get_u16("manareg") + 10);
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}