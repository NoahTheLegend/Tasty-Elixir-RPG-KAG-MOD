void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

	this.set_f32("velocity", 0.15+(XORRandom(3)*0.1));
    this.set_f32("blockchance", XORRandom(20)+15);
    this.set_f32("damagereduction", 1.0+(XORRandom(7))*0.1);
    this.set_f32("gravityresist", 6.0);
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

    if (!caller.get_bool("hasboots"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$mythicalalloy_boots$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$mythicalalloy_boots$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip boots first!"), params);
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
	        caller.set_string("bootsname", "mythicalalloy_boots");

	        caller.set_f32("velocity", caller.get_f32("velocity") - this.get_f32("velocity"));
            caller.set_f32("blockchance", caller.get_f32("blockchance") + this.get_f32("blockchance"));
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + this.get_f32("damagereduction"));
            caller.set_f32("gravityresist", caller.get_f32("gravityresist") + 6.0);
        
            CPlayer@ player = caller.getPlayer();
            if (player is null) return;
            //set variables to save XORRandom()ly defined stats
            player.set_f32("mythbootsvelocity", this.get_f32("velocity"));
            player.set_f32("mythbootsblockchance", this.get_f32("blockchance"));
            player.set_f32("mythbootsdamagereduction", this.get_f32("damagereduction"));
            player.set_f32("mythbootsgravityresist", this.get_f32("gravityresist"));
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}