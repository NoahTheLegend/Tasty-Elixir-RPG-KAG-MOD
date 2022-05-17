void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");
    //move these vars to code bodies. My bad.
    this.set_f32("velocity", -0.3-(XORRandom(3)*0.1));
    this.set_f32("dodgechance", 20.0+(XORRandom(10)*0.1));
    this.set_f32("damagereduction", 1.3+(XORRandom(10)*0.1));

    if (this.get_f32("damagereduction") < 1.45) this.set_string("mythset", "mythset1");
    else if (this.get_f32("damagereduction") >= 1.45
    && this.get_f32("damagereduction") < 1.75) this.set_string("mythset", "mythset2");
    else this.set_string("mythset", "mythset3");
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

    if (!caller.get_bool("hasarmor"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$dragon_chestplate$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$dragon_chestplate$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip chestplate first!"), params);
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
	        caller.set_string("armorname", "dragon_chestplate");

	        caller.set_f32("velocity", caller.get_f32("velocity") - this.get_f32("velocity"));
            caller.set_f32("dodgechance", caller.get_f32("dodgechance") + this.get_f32("dodgechance"));
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + this.get_f32("damagereduction"));

            CPlayer@ player = caller.getPlayer();
            if (player is null) return;
            player.set_f32("dragonchestplatevelocity", this.get_f32("velocity"));
            player.set_f32("dragonchestplatedodgechance", this.get_f32("dodgechance"));
            player.set_f32("dragonchestplatedamagereduction", this.get_f32("damagereduction"));

        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}