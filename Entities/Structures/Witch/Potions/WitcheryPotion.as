
void onInit(CBlob@ this)
{
    this.addCommandID("drinkpotion");
    
    u8 type = this.get_u8("type");
    //type = 0;

    CSprite@ sprite = this.getSprite();
    Animation@ anim = sprite.addAnimation("potions", 0, false);
    int[] frames = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
    anim.AddFrames(frames);
    sprite.SetAnimation("potions");
    AddIconToken("$witcherypotion$", "WitcheryPotions.png", Vec2f(8, 8), type, this.getTeamNum());

    if (sprite is null) return;
    this.inventoryIconFrame = type;
    sprite.SetFrameIndex(type);
    switch (type)
    {
        case 0:
        {
            this.setInventoryName("Small lightness potion");
            break;
        }
        case 1:
        {
            this.setInventoryName("Lesser lightness potion");
            break;
        }
        case 2:
        {
            this.setInventoryName("Medium lightness potion");
            break;
        }
        case 3:
        {
            this.setInventoryName("Big lightness potion");
            break;
        }
        case 4:
        {
            this.setInventoryName("Small healing potion");
            break;
        }
        case 5:
        {
            this.setInventoryName("Lesser healing potion");
            break;
        }
        case 6:
        {
            this.setInventoryName("Medium healing potion");
            break;
        }
        case 7:
        {
            this.setInventoryName("Big healing potion");
            break;
        }
        case 8:
        {
            this.setInventoryName("Basic glowness potion");
            break;
        }
        case 9:
        {
            this.setInventoryName("Basic glowness potion (longer)");
            break;
        }
        case 10:
        {
            this.setInventoryName("Advanced glowness potion");
            break;
        }
        case 11:
        {
            this.setInventoryName("Advanced glowness potion (longer)");
            break;
        }
        case 12:
        {
            this.setInventoryName("Small mana potion");
            break;
        }
        case 13:
        {
            this.setInventoryName("Lesser mana potion");
            break;
        }
        case 14:
        {
            this.setInventoryName("Medium mana potion");
            break;
        }
        case 15:
        {
            this.setInventoryName("Big mana potion");
            break;
        }
    }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.hasTag("wpotioned")) return;

    CBitStream params;
    params.write_u16(caller.getNetworkID());
    params.write_string(this.get_string("buff1"));
    caller.CreateGenericButton("$witcherypotion$", Vec2f(0, 0), this, this.getCommandID("drinkpotion"), "Drink " + this.getInventoryName(), params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("drinkpotion"))
    {
        u8 i = this.get_u8("type");
        u8 size;
        u16 callerid = params.read_u16();
        CBlob@ caller = getBlobByNetworkID(callerid);
        if (caller is null) return;

        string effect;
        if (i < 4)
        {
            size = i;
            effect = "lightness";
            this.set_string("buff1", "gravityresist`f32`"+((2.0*(size+1))));
        }
		else if (i < 8 && i >= 4)
        {
            size = i - 3;
            effect = "heal";
        }
		else if (i < 12 && i >= 8)
        {
            size = i - 7;
            effect = "glowness";
            if (size <= 2) this.set_string("buff1", "glowness`bool`false");
            else this.set_string("buff1", "glowness2`bool`false");
        }
		else if (i >= 12)
        {
            size = i - 11;
            effect = "mana";
        }

        if (effect == "lightness" && isServer())
        {
            caller.Tag("wpotioned");
            for (u8 i = 1; i <= 20; i++)
            {
                if (caller.get_string("eff"+i) == "")
                {
                    string[] effdatas = this.get_string("buff1").split("`");
                    string effdata;
                    if (effdatas.length == 3)
                    {
                        effdata = effdatas[0]+" "+effdatas[2];
                        printf(effdata);
                        caller.set_f32("gravityresist", parseFloat(effdatas[2]));
                        caller.Sync("gravityresist", true);
                    }

                    caller.set_string("eff"+i, "1_potion_"+effdata);
                    caller.set_string("buffs"+i, this.get_string("buff1"));
                    caller.set_u16("timer"+i, size*XORRandom(600) + XORRandom(800*size)+300*size);
                    caller.Sync("eff"+i, true);
                    caller.Sync("buffs"+i, true);
                    caller.Sync("timer"+i, true);
                    break;
                }
            }
        }
        else if (effect == "heal")
        {
            if (isServer()) caller.server_Heal(1.0f*size);
        }
        else if (effect == "glowness" && isServer())
        {
            caller.Tag("wpotioned");
            for (u8 i = 1; i <= 20; i++)
            {
                if (caller.get_string("eff"+i) == "")
                {
                    string[] effdatas = this.get_string("buff1").split("`");
                    string effdata;
                    if (effdatas.length == 3)
                    {
                        effdata = effdatas[0]+" true";
                        if (effdatas[0] == "glowness")
                        {
                            caller.set_bool("glowness", true);
                            caller.Sync("glowness", true);
                        }
                        else
                        {
                            caller.set_bool("glowness2", true);
                            caller.Sync("glowness2", true);
                        }
                    }

                    caller.set_string("eff"+i, "1_potion_"+effdata);
                    caller.set_string("buffs"+i, this.get_string("buff1"));
                    caller.set_u16("timer"+i, size*XORRandom(600) + XORRandom(800*size)+300*size);
                    caller.Sync("eff"+i, true);
                    caller.Sync("buffs"+i, true);
                    caller.Sync("timer"+i, true);
                    break;
                }
            }
        }
        else if (effect == "mana")
        {
            caller.set_u16("mana", caller.get_u16("mana") + caller.get_u16("maxmana") * (0.25*size));
            if (caller.get_u16("mana") > caller.get_u16("maxmana")) caller.set_u16("mana", caller.get_u16("maxmana"));
        }

        if (isClient()) this.getSprite().PlaySound("WitcheryPotionDrink.ogg", 1.0f);
        if (isServer()) this.server_Die();
    }
}