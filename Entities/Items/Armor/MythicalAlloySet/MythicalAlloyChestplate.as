void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

	this.set_f32("velocity", 0.15+(XORRandom(3)*0.1));
    this.set_f32("blockchance", XORRandom(20)+15);
    this.set_f32("damagereduction", 1.5+(XORRandom(6)*0.1));
    this.set_f32("hpregtime", 5*30);

    this.set_string("mythset", "");

    if (this.get_f32("damagereduction") < 1.65) this.set_string("mythset", "mythset1");
    else if (this.get_f32("damagereduction") >= 1.65
    && this.get_f32("damagereduction") < 1.85) this.set_string("mythset", "mythset2");
    else this.set_string("mythset", "mythset3");

    this.set_f32("bashchance", 15.0);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.475f, 0.475f);
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
	    caller.CreateGenericButton("$mythicalalloy_chestplate$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$mythicalalloy_chestplate$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip chestplate first!"), params);
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
	        caller.set_string("armorname", "mythicalalloy_chestplate");

            caller.set_string("mythset", this.get_string("mythset"));

	        caller.set_f32("velocity", caller.get_f32("velocity") - this.get_f32("velocity"));
            caller.set_f32("blockchance", caller.get_f32("blockchance") + this.get_f32("blockchance"));
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + this.get_f32("damagereduction"));
            if (player !is null && player.isMyPlayer()) caller.set_f32("hpregtime", caller.get_f32("hpregtime") - 5*30);
            caller.set_f32("bashchance", caller.get_f32("bashchance") + 15.0);

            CPlayer@ player = caller.getPlayer();
            if (player is null) return;
            //set variables to save XORRandom()ly defined stats
            player.set_f32("mythchestplatevelocity", this.get_f32("velocity"));
            player.set_f32("mythchestplateblockchance", this.get_f32("blockchance"));
            player.set_f32("mythchestplatedamagereduction", this.get_f32("damagereduction"));
            player.set_f32("mythchestplatebashchance", this.get_f32("bashchance"));
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}