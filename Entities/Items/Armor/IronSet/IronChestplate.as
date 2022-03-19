void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

    this.set_f32("velocity", -0.2);
    this.set_f32("blockchance", 10.0);
    this.set_f32("damagereduction", 0.25);
    this.set_f32("hpregtime", -1*30);
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
	    caller.CreateGenericButton("$iron_chestplate$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$iron_chestplate$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip"), params);
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

            caller.set_bool("hasarmor", true);
	        caller.set_string("armorname", "iron_chestplate");

	        caller.set_f32("velocity", caller.get_f32("velocity") - 0.2);
            caller.set_f32("blockchance", caller.get_f32("blockchance") + 10.0);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.25);
            caller.set_f32("hpregtime", caller.get_f32("hpregtime") - 1*30);
        }
    }
    else if (cmd==this.getCommandID("unequip"))
    {
        u16 callerid = params.read_u16();
        CBlob@ caller = getBlobByNetworkID(callerid);

        if (caller !is null)
        {
            if (caller.get_bool("hasarmor"))
            {
                if (isServer())
                {
                    server_CreateBlob(caller.get_string("armorname"), caller.getTeamNum(), caller.getPosition());
                }
            }

            caller.set_bool("hasarmor", false);
	        caller.set_string("armorname", "");
            
	        caller.set_f32("velocity", caller.get_f32("velocity") + 0.2);
            caller.set_f32("blockchance", caller.get_f32("blockchance") - 10.0);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") - 0.25);
            caller.set_f32("hpregtime", caller.get_f32("hpregtime") + 1*30);
        }
    }
}