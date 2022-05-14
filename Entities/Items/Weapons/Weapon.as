void onInit(CBlob@ this)
{
    this.addCommandID("equip");

    this.set_bool("infernobow?", false);

    this.Tag("weapon");
    this.Tag("customstats"); // for unequip stat syncing

    CSprite@ sprite = this.getSprite();
    Animation@ anim = sprite.addAnimation("change", 0, false);
    int[] frames = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30};
    anim.AddFrames(frames);
    sprite.SetAnimation("change");

    u16 index;
    Vec2f size;
    string name = this.getName();

    if (name == "wooden_shield") 
    {
        index = 0;
        size = Vec2f(16, 16);
    }
    else if (name == "iron_shield") 
    {
        index = 1;
        size = Vec2f(16, 16);
    }
    else if (name == "steel_shield") 
    {
        index = 2;
        size = Vec2f(16, 16);
    }
    else if (name == "greed_shield") // unique money shield
    {
        index = 27;
        size = Vec2f(16, 16);
    }
    else if (name == "chromium_shield") 
    {
        index = 3;
        size = Vec2f(16, 16);
    }
    else if (name == "palladium_shield") 
    {
        index = 4;
        size = Vec2f(16, 16);
    }
    else if (name == "platinum_shield") 
    {
        index = 5;
        size = Vec2f(16, 16);
    }
    else if (name == "titanium_shield") 
    {
        index = 6;
        size = Vec2f(16, 16);
    }
    else if (name == "vamp_shield") 
    {
        index = 7;
        size = Vec2f(16, 16);
    }
    else if (name == "shadow_shield") 
    {
        index = 8;
        size = Vec2f(16, 16);
    }
    else if (name == "wooden_sword") 
    {
        index = 9;
        size = Vec2f(16, 16);
    }
    else if (name == "iron_sword")
    {
        index = 10;
        size = Vec2f(16, 16);
    }
    else if (name == "steel_sword")
    {
        index = 11;
        size = Vec2f(16, 16);
    }
    else if (name == "golden_sword")
    {
        index = 12;
        size = Vec2f(16, 16);
    }
    else if (name == "chromium_sword")
    {
        index = 13;
        size = Vec2f(16, 16);
    }
    else if (name == "palladium_sword")
    {
        index = 14;
        size = Vec2f(16, 16);
    }
    else if (name == "platinum_sword")
    {
        index = 15;
        size = Vec2f(16, 16);
    }
    else if (name == "titanium_sword")
    {
        index = 16;
        size = Vec2f(16,16);
    }
    else if (name == "wooden_dagger")
    {
        index = 18;
        size = Vec2f(16, 16);
    }
    else if (name == "iron_dagger")
    {
        index = 19;
        size = Vec2f(16, 16);
    }
    else if (name == "steel_dagger")
    {
        index = 20;
        size = Vec2f(16, 16);
    }
    else if (name == "golden_dagger")
    {
        index = 21;
        size = Vec2f(16, 16);
    }
    else if (name == "chromium_dagger")
    {
        index = 22;
        size = Vec2f(16, 16);
    }
    else if (name == "palladium_dagger")
    {
        index = 23;
        size = Vec2f(16, 16);
    }
    else if (name == "platinum_dagger")
    {
        index = 24;
        size = Vec2f(16, 16);
    }
    else if (name == "titanium_dagger")
    {
        index = 25;
        size = Vec2f(16, 16);
    }
    else if (name == "wooden_bow")
    {
        index = 0;
        size = Vec2f(32, 32);
    }
    else if (name == "iron_bow")
    {
        index = 1;
        size = Vec2f(32, 32);
    }
    else if (name == "golden_bow")
    {
        index = 2;
        size = Vec2f(32, 32);
    }
    else if (name == "palladium_bow")
    {
        index = 3;
        size = Vec2f(32, 32);
    }
    else if (name == "platinum_bow")
    {
        index = 8;
        size = Vec2f(32, 32);
    }
    else if (name == "titanium_bow")
    {
        index = 4;
        size = Vec2f(32, 32);
    }
    else if (name == "vamp_bow")
    {
        index = 9;
        size = Vec2f(32, 32);
    }
    else if (name == "shadow_bow")
    {
        index = 10;
        size = Vec2f(32, 32);
    }
    else if (name == "greed_bow")
    {
        index = 11;
        size = Vec2f(32, 32);
    }
    else if (name == "inferno_bow")
    {
        index = 5;
        size = Vec2f(32, 32);
        
        Animation@ infbow = sprite.addAnimation("infernobow", 0, false);
        int[] frames = {5,6,7};
        infbow.AddFrames(frames);
        sprite.SetAnimation("infernobow");
        this.set_bool("infernobow?", true);
    }

    sprite.SetFrameIndex(index);
    this.inventoryIconFrame = index;
    this.set_u8("iconindex", index);
	//this.SetInventoryIcon(this.getSprite().getConsts().filename, index, size);
    //printf(this.getSprite().getConsts().filename);
    //printf(""+index);

    this.set_u8("infbowcounter", 0); // anim frames delay
}

void onTick(CBlob@ this)
{
    this.inventoryIconFrame = this.get_u8("iconindex");
    CSprite@ sprite = this.getSprite();
    if (sprite !is null && this.get_bool("infernobow?"))
    {
        this.set_u8("infbowcounter", this.get_u8("infbowcounter") + 1);

        switch (this.get_u8("infbowcounter"))
        {
            case 4:
            {
                u8 index = 0;
                sprite.SetFrameIndex(index);
                this.inventoryIconFrame = 5;
                this.set_u8("iconindex", 5);
                break;
            }
            case 8:
            {
                u8 index = 1;
                sprite.SetFrameIndex(index);
                this.inventoryIconFrame = 6;
                this.set_u8("iconindex", 6);
                break;
            }
            case 12:
            {
                u8 index = 2;
                sprite.SetFrameIndex(index);
                this.inventoryIconFrame = 7;
                this.set_u8("iconindex", 7);
                break;
            }
        }
        if (this.get_u8("infbowcounter") == 12) this.set_u8("infbowcounter", 0);
    }
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