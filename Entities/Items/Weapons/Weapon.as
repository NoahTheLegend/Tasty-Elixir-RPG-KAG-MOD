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

        this.set_f32("blockchance", 5.0);
        this.set_f32("damagereduction", 0.25);
        this.set_u16("maxmana", 10);
        this.set_u16("manareg", 5);
    }
    else if (name == "iron_shield") 
    {
        index = 1;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 6.5);
        this.set_f32("damagereduction", 0.3);
        this.set_u16("maxmana", 15);
        this.set_u16("manareg", 7);
        this.set_f32("critchance", 5.0);
    }
    else if (name == "steel_shield") 
    {
        index = 2;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 6.5);
        this.set_f32("damagereduction", 0.5);
        this.set_u16("maxmana", 15);
        this.set_u16("manareg", 8);
        this.set_f32("critchance", 3.0);
    }
    else if (name == "greed_shield") // unique money shield
    {
        index = 27;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 10.0);
        this.set_f32("damagereduction", 0.75);
        this.set_u16("maxmana", 30);
        this.set_u16("manareg", 10);
        this.set_f32("manaregtime", -4*30);
    }
    else if (name == "chromium_shield") 
    {
        index = 3;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 7.5);
        this.set_f32("damagereduction", 0.5);
        this.set_u16("maxmana", 15);
        this.set_u16("manareg", 7);
        this.set_f32("attackspeed", 0.5);
    }
    else if (name == "palladium_shield") 
    {
        index = 4;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 11.5);
        this.set_f32("damagereduction", 0.8);
        this.set_f32("critchance", 10.0);
        this.set_f32("bashchance", 7.5);
    }
    else if (name == "platinum_shield") 
    {
        index = 5;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 5.0);
        this.set_f32("damagereduction", 0.5);
        this.set_u16("maxmana", 50);
        this.set_u16("manareg", 30);
        this.set_f32("manaregtime", -6*30);
        this.set_f32("critchance", 7.5);
    }
    else if (name == "titanium_shield") 
    {
        index = 6;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 15.0);
        this.set_f32("damagereduction", 1.0);
        this.set_u16("maxmana", 30);
        this.set_f32("critchance", 10.0);
        this.set_f32("bashchance", 12.5);
    }
    else if (name == "vamp_shield") 
    {
        index = 7;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 7.5);
        this.set_f32("damagereduction", 0.65);
        this.set_f32("critchance", 15.0);
        this.set_f32("vampirism", 0.15);
    }
    else if (name == "shadow_shield") 
    {
        index = 8;
        size = Vec2f(16, 16);

        this.set_f32("blockchance", 7.5);
        this.set_f32("damagereduction", 1.0);
        this.set_u16("maxmana", 100);
        this.set_f32("critchance", 20.0);
        this.set_f32("bashchance", 17.5);
    }
    else if (name == "wooden_sword") 
    {
        index = 9;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.1);
        this.set_f32("critchance", 5.0);
    }
    else if (name == "iron_sword")
    {
        index = 10;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.25);
        this.set_f32("critchance", 6.5);
        this.set_f32("attackspeed", 0.1);
    }
    else if (name == "steel_sword")
    {
        index = 11;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.45);
        this.set_f32("critchance", 7.5);
        this.set_f32("bashchance", 5.0);
    }
    else if (name == "golden_sword")
    {
        index = 12;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.5);
        this.set_f32("critchance", 10.0);
        this.set_f32("attackspeed", 0.3);
    }
    else if (name == "chromium_sword")
    {
        index = 13;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.75);
        this.set_f32("critchance", 12.5);
        this.set_f32("attackspeed", 0.4);
    }
    else if (name == "palladium_sword")
    {
        index = 14;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 1.0);
        this.set_f32("critchance", 7.5);
        this.set_f32("bashchance", 10.0);
    }
    else if (name == "platinum_sword")
    {
        index = 15;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 1.25);
        this.set_f32("critchance", 10.0);
        this.set_f32("attackspeed", 0.5);
        this.set_f32("bashchance", 7.5);
    }
    else if (name == "titanium_sword")
    {
        index = 16;
        size = Vec2f(16,16);

        this.set_f32("damagebuff", 1.5);
        this.set_f32("critchance", 12.5);
        this.set_f32("attackspeed", 0.5);
        this.set_f32("bashchance", 7.5);
    }
    else if (name == "wooden_dagger")
    {
        index = 18;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.25);
        this.set_f32("critchance", 3.0);
        this.set_f32("attackspeed", 0.1);
    }
    else if (name == "iron_dagger")
    {
        index = 19;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.35);
        this.set_f32("critchance", 4.0);
        this.set_f32("attackspeed", 0.2);
    }
    else if (name == "steel_dagger")
    {
        index = 20;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.5);
        this.set_f32("critchance", 5.0);
        this.set_f32("attackspeed", 0.2);
        this.set_f32("bashchance", 2.5);
    }
    else if (name == "golden_dagger")
    {
        index = 21;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.5);
        this.set_f32("critchance", 6.5);
        this.set_f32("attackspeed", 0.3);
        this.set_f32("vampirism", 0.025);
    }
    else if (name == "chromium_dagger")
    {
        index = 22;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 0.75);
        this.set_f32("critchance", 7.0);
        this.set_f32("attackspeed", 0.4);
    }
    else if (name == "palladium_dagger")
    {
        index = 23;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 1.0);
        this.set_f32("critchance", 7.5);
        this.set_f32("attackspeed", 0.5);
        this.set_f32("bashchance", 5.0);
        this.set_f32("vampirism", 0.025);
    }
    else if (name == "platinum_dagger")
    {
        index = 24;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 1.0);
        this.set_f32("critchance", 8.0);
        this.set_f32("attackspeed", 0.6);
        this.set_f32("vampirism", 0.05);
    }
    else if (name == "titanium_dagger")
    {
        index = 25;
        size = Vec2f(16, 16);

        this.set_f32("damagebuff", 1.5);
        this.set_f32("critchance", 8.5);
        this.set_f32("attackspeed", 0.7);
        this.set_f32("bashchance", 7.5);
        this.set_f32("vampirism", 0.025);
    }
    else if (name == "wooden_bow")
    {
        index = 0;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 0.25);
        this.set_f32("critchance", 5.0);
        this.set_f32("attackspeed", 0.2);
    }
    else if (name == "iron_bow")
    {
        index = 1;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 0.45);
        this.set_f32("critchance", 6.5);
        this.set_f32("attackspeed", 0.3);
    }
    else if (name == "golden_bow")
    {
        index = 2;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 0.65);
        this.set_f32("critchance", 7.5);
        this.set_f32("attackspeed", 0.4);
        this.set_f32("bashchance", 2.5);
    }
    else if (name == "palladium_bow")
    {
        index = 3;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 1.0);
        this.set_f32("critchance", 8.5);
        this.set_f32("attackspeed", 0.5);
        this.set_f32("bashchance", 5.0);
    }
    else if (name == "platinum_bow")
    {
        index = 8;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 1.5);
        this.set_f32("critchance", 10.0);
        this.set_f32("attackspeed", 0.6);
        this.set_f32("bashchance", 7.5);
    }
    else if (name == "titanium_bow")
    {
        index = 4;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 2.0);
        this.set_f32("critchance", 15.0);
        this.set_f32("attackspeed", 0.7);
        this.set_f32("bashchance", 12.5);
    }
    else if (name == "vamp_bow")
    {
        index = 9;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 2.5);
        this.set_f32("critchance", 10.0);
        this.set_f32("attackspeed", 0.8);
    }
    else if (name == "shadow_bow")
    {
        index = 10;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 2.25);
        this.set_f32("critchance", 12.5);
        this.set_f32("attackspeed", 1.0);
        this.set_f32("bashchance", 20.0);
    }
    else if (name == "greed_bow")
    {
        index = 11;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 1.5);
        this.set_f32("critchance", 10.0);
        this.set_f32("attackspeed", 0.9);
    }
    else if (name == "inferno_bow")
    {
        index = 5;
        size = Vec2f(32, 32);

        this.set_f32("damagebuff", 1.25);
        this.set_f32("critchance", 12.5);
        this.set_f32("attackspeed", 0.6);
        this.set_f32("bashchance", 7.5);
        
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
    if (type == "dagger" && (pclass != "rogue" && pclass != "archer")) return;

    if (!caller.get_bool("hasweapon") && (type == "sword" || type == "dagger" || type == "bow"))
    {
        if (!caller.get_bool("hasweapon"))
        {
            CBitStream params;
	        params.write_u16(caller.getNetworkID());
            params.write_string(this.getName());
	        caller.CreateGenericButton("$"+this.getName()+"$", Vec2f(0, 0), this, this.getCommandID("equip"), getTranslatedString("Equip"), params);
        }
    }
    else if (!caller.get_bool("hassecondaryweapon") && (type == "shield" || type == "dagger")
    || (type == "sword" && pclass == "knight" && caller.get_bool("hasweapon"))
    || (type == "dagger" && pclass == "archer" && !caller.get_bool("hassecondaryweapon")))
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

void ApplyStats(CBlob@ this, CBlob@ blob)
{
    //printf('start');
	if (this is null || blob is null) return;
    CPlayer@ player = blob.getPlayer();
    if (player is null) return;
	
    blob.set_f32("dodgechance", this.get_f32("dodgechance") + blob.get_f32("dodgechance")); blob.Sync("dodgechance", true);
	blob.set_f32("blockchance", this.get_f32("blockchance") + blob.get_f32("blockchance")); blob.Sync("blockchance", true);
    blob.set_f32("damagereduction", this.get_f32("damagereduction") + blob.get_f32("damagereduction")); blob.Sync("damagereduction", true);
	if (player.isMyPlayer()) blob.set_f32("manaregtime", this.get_f32("manaregtime") - (blob.get_f32("manaregtime"))*-1); blob.Sync("manaregtime", true);
	blob.set_u16("manareg", this.get_u16("manareg") + blob.get_u16("manareg")); blob.Sync("manareg", true);
	blob.set_u16("maxmana", this.get_u16("maxmana") + blob.get_u16("maxmana")); blob.Sync("maxmana", true);
	blob.set_f32("critchance", this.get_f32("critchance") + blob.get_f32("critchance")); blob.Sync("critchance", true);
	if (player.isMyPlayer()) 
    {
        string[] wep = this.getName().split("_");
        string type;
        if (wep.length > 1) type = wep[1];
        if (blob.getName() == "archer" && type == "dagger")
        {
            blob.set_f32("stabdmg", this.get_f32("damagebuff") + blob.get_f32("stabdmg"));
            blob.Sync("stabdmg", true);
        }
        else
        {
            blob.set_f32("damagebuff", this.get_f32("damagebuff") + blob.get_f32("damagebuff"));
            blob.Sync("damagebuff", true);
        }
    }
	blob.set_f32("attackspeed", this.get_f32("attackspeed") + blob.get_f32("attackspeed")); blob.Sync("attackspeed", true);
	blob.set_f32("vampirism", this.get_f32("vampirism") + blob.get_f32("vampirism")); blob.Sync("vampirism", true);
	blob.set_f32("bashchance", this.get_f32("bashchance") + blob.get_f32("bashchance")); blob.Sync("bashchance", true);

    if (this.get_f32("attackspeed") > 0)
    {
        //printf("sent?");
        CBitStream params;
		params.write_f32(this.get_f32("attackspeed"));
		params.write_bool(true);
		blob.SendCommand(blob.getCommandID("doattackspeedchange"), params);
       // printf("yes");
    }
   // printf('end');
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
            if (caller.getName() == "knight" && type == "sword")
            {
                string[] weapontype = caller.get_string("weaponname").split("_");
                if (weapontype.length > 1)
                {
                    string weapon = weapontype[1];
                    if (type == weapon
                    && (caller.get_bool("hasweapon")))
                    {
                        caller.Tag("doublesword");
                        caller.set_f32("attackspeed", caller.get_f32("attackspeed") + 0.8);
                        caller.set_f32("critchance", caller.get_f32("critchance") + 10.0);

                        CBitStream params;
						params.write_f32(0.8);
						params.write_bool(true);
						caller.SendCommand(caller.getCommandID("doattackspeedchange"), params);
                    }
                }
            }
            if (!caller.get_bool("hasweapon") && (type == "sword" || type == "dagger" || type == "bow"))
            {
                if (caller.getName() == "archer" && !caller.get_bool("hassecondaryweapon") && type == "dagger")
                {
                    caller.set_bool("hassecondaryweapon", true);
	                caller.set_string("secondaryweaponname", fullname);
                }
                else
                {
                    if (caller.getName() == "archer" && type == "dagger") return;
                    caller.set_bool("hasweapon", true);
	                caller.set_string("weaponname", fullname);
                }
            }
            else if (!caller.get_bool("hassecondaryweapon") && (type == "shield" || type == "dagger" || type == "sword"))
            {
                caller.set_bool("hassecondaryweapon", true);
	            caller.set_string("secondaryweaponname", fullname); 
            }
            //give extra buffs for doublesword knight

            if (caller.getCarriedBlob() !is null) caller.getCarriedBlob().server_Die();

            // buffs here
            ApplyStats(this, caller);
        }
    }
}