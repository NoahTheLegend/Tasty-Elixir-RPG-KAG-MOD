void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");
    //move these vars to code bodies. My bad.
    this.set_f32("velocity", -0.4);
    this.set_f32("dodgechance", 25.0);
    this.set_f32("damagereduction", 0.75);
    this.set_f32("gravityresist", 6.0);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.325f, 0.325f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "archer" && caller.getName() != "rogue") return;

    if (!caller.get_bool("hasboots"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$dragon_boots$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$dragon_boots$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip boots first!"), params);
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
	        caller.set_string("bootsname", "dragon_boots");

	        caller.set_f32("velocity", caller.get_f32("velocity") - this.get_f32("velocity"));
            caller.set_f32("dodgechance", caller.get_f32("dodgechance") + this.get_f32("dodgechance"));
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + this.get_f32("damagereduction"));
            caller.set_f32("gravityresist", caller.get_f32("gravityresist") + this.get_f32("gravityresist"));
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}