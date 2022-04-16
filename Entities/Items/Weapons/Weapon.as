void onInit(CBlob@ this)
{
    this.addCommandID("equip");

    this.Tag("weapon");
    this.Tag("customstats"); // for unequip stat syncing

    CSprite@ sprite = this.getSprite();
    Animation@ anim = sprite.addAnimation("change", 0, false);
    int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30};
    anim.AddFrames(frames);
    sprite.SetAnimation("change");

    u16 index;
    Vec2f size;

    if (this.getName() == "wooden_sword") 
    {
        index = 9;
        size = Vec2f(16, 16);
    }

    sprite.SetFrameIndex(index);
	this.SetInventoryIcon(sprite.getConsts().filename, index, size);
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    
    string[] spl = this.getName().split("_");
    if (spl.length < 2) return;

    string type = spl[1];
    string pclass = caller.getName();

    if ((type == "sword" || type == "shield") && pclass != "knight") return;
    if (type == "bow" && pclass != "archer") return;
    if (type == "dagger" && pclass != "rogue") return;

    if (type == "sword" || type == "dagger" || type == "bow")
    {
        if (!caller.get_bool("hasweapon"))
        {
            CBitStream params;
	        params.write_u16(caller.getNetworkID());
            params.write_string(this.getName());
	        caller.CreateGenericButton("$"+this.getName()+"$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
        }
    }
    else if (type == "shield")
    {
        if (!caller.get_bool("hassecondaryweapon"))
        {
            CBitStream params;
	        params.write_u16(caller.getNetworkID());
            params.write_string(this.getName());
	        caller.CreateGenericButton("$"+this.getName()+"$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd==this.getCommandID("equip"))
    {
        u16 callerid = params.read_u16();
        CBlob@ caller = getBlobByNetworkID(callerid);

        string fullname = params.read_string();
        string[] spl = fullname.split("_");
        if (spl.length < 2) return;
        
        string type = spl[1];

        if (caller !is null)
        {
            if (caller.getCarriedBlob() !is null) caller.getCarriedBlob().server_Die();

            if (type == "sword" || type == "dagger" || type == "bow")
            {
                caller.set_bool("hasweapon", true);
	            caller.set_string("weaponname", fullname);
            }
            else if (type == "shield")
            {
                caller.set_bool("hassecondaryweapon", true);
	            caller.set_string("secondaryweaponname", fullname); 
            }

            // buffs here
        }
    }
}