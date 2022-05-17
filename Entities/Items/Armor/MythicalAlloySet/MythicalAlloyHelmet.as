void onInit(CBlob@ this)
{
    this.addCommandID("equip");
    this.addCommandID("unequip");

    this.Tag("armor");

    this.set_f32("damagereduction", (XORRandom(20)+1)/10);
    this.set_f32("manaregtime", 3*30);
    this.set_u16("maxmana", 100);
    this.set_u16("manareg", 45);
    this.set_f32("vampirism", 0.1); // 10%
}

void onInit(CSprite@ this)
{
    this.ScaleBy(0.45f, 0.45f);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.getName() != "knight") return;

    if (!caller.get_bool("hashelmet"))
    {
        CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$mythicalalloy_helmet$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
    }
    else
    {
        CBitStream params;
	    caller.CreateGenericButton("$mythicalalloy_helmet$", Vec2f(0, 0), this, this.getCommandID("unequip"), getTranslatedString("Unequip helmet first!"), params);
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

            caller.set_bool("hashelmet", true);
	        caller.set_string("helmetname", "mythicalalloy_helmet");

	        caller.set_f32("damagereduction", caller.get_f32("damagereduction") + this.get_f32("damagereduction"));
            if (player !is null && player.isMyPlayer()) caller.set_f32("manaregtime", caller.get_f32("manaregtime") - 3*30);
            caller.set_u16("maxmana", caller.get_u16("maxmana") + 100);
            caller.set_u16("manareg", caller.get_u16("manareg") + 45);
            caller.set_f32("vampirism", caller.get_f32("vampirism") + 0.1);

            //set variables to save XORRandom()ly defined stats
            caller.set_f32("mythhelmetdamagereduction", this.get_f32("damagereduction"));
        }
    }
    else if (cmd==this.getCommandID("unequip")) {}
}