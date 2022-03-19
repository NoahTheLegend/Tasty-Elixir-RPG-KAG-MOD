void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

	this.set_f32("velocity", -0.1);
    this.set_f32("blockchance", 2.0);
    this.set_f32("damagereduction", 0.1);
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
	    caller.CreateGenericButton("$iron_boots$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$iron_boots$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip"), params);
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
	        caller.set_string("bootsname", "iron_boots");

	        caller.set_f32("velocity", caller.get_f32("velocity") - 0.1);
            caller.set_f32("blockchance", caller.get_f32("blockchance") + 2.0);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.1);
        }
    }
    else if (cmd==this.getCommandID("unequip"))
    {
        u16 callerid = params.read_u16();
        CBlob@ caller = getBlobByNetworkID(callerid);

        if (caller !is null)
        {
            if (caller.get_bool("hasboots"))
            {
                if (isServer())
                {
                    server_CreateBlob(caller.get_string("bootsname"), caller.getTeamNum(), caller.getPosition());
                }
            }

            caller.set_bool("hasboots", false);
	        caller.set_string("bootsname", "");
            
	        caller.set_f32("velocity", caller.get_f32("velocity") + 0.1);
            caller.set_f32("blockchance", caller.get_f32("blockchance") - 2.0);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") - 0.1);
        }
    }
}