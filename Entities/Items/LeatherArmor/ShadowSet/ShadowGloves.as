void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");
    
    this.Tag("armor");
    //move these vars to code bodies. My bad.
    this.set_f32("damagereduction", 0.75);
    this.set_f32("damagebuff", 1.5);
    this.set_f32("critchance", 25.0);
    this.set_f32("attackspeed", 0.5);
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.475f, 0.475f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "archer" && caller.getName() != "rogue") return;

    if (!caller.get_bool("hasgloves"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$shadow_gloves$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$shadow_gloves$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip gloves first!"), params);
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

            caller.set_bool("hasgloves", true);
	        caller.set_string("glovesname", "shadow_gloves");

            caller.set_f32("damagereduction", caller.get_f32("damagereduction") + 0.75);
            if (player !is null && player.isMyPlayer()) caller.set_f32("damagebuff", caller.get_f32("damagebuff") + 1.5);
            caller.set_f32("critchance", caller.get_f32("critchance") + 25.0);
            caller.set_f32("attackspeed", caller.get_f32("attackspeed") + 0.5);

            CBitStream params;
		    params.write_f32(this.get_f32("attackspeed"));
		    params.write_bool(true);
		    caller.SendCommand(caller.getCommandID("doattackspeedchange"), params);
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}