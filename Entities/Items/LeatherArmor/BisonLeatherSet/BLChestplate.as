void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");
    //move these vars to code bodies. My bad.
    this.set_f32("velocity", 0.1);
    this.set_f32("dodgechance", 7.0);
    this.set_f32("damagereduction", 0.75);
    this.set_f32("hpregtime", 2*30);
    this.set_f32("bashchance", 10.0);
}
void onInit(CSprite@ this)
{
    this.ScaleBy(0.75f, 0.75f);
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
	    caller.CreateGenericButton("$bl_chestplate$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$bl_chestplate$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip chestplate first!"), params);
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
	        caller.set_string("armorname", "bl_chestplate");

	        caller.set_f32("velocity", caller.get_f32("velocity") - 0.1);
            caller.set_f32("dodgechance", caller.get_f32("dodgechance") + 7.0);
            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.75);
            if (player !is null && player.isMyPlayer()) caller.set_f32("hpregtime", caller.get_f32("hpregtime") - 2*30);
            caller.set_f32("bashchance", caller.get_f32("bashchance") + 10.0);
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}