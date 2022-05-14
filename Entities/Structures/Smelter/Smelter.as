
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(7, 9));
	this.set_string("shop description", "Smelter");
	this.set_u8("shop icon", 15);

	this.addCommandID("opensmelter");

	{
		ShopItem@ s = addShopItem(this, "Craft iron sword", "$iron_sword$", "iron_sword", "Use iron ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_ironbar", "Iron bar", 10);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft steel sword", "$steel_sword$", "steel_sword", "Use steel ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_steelbar", "Steel bar", 8);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft golden sword", "$golden_sword$", "golden_sword", "Use golden ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_goldenbar", "Golden bar", 20);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft chromium sword", "$chromium_sword$", "chromium_sword", "Use chromium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_chromiumbar", "Chromium bar", 14);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft palladium sword", "$palladium_sword$", "palladium_sword", "Use palladium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_palladiumbar", "Palladium bar", 12);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft platinum sword", "$platinum_sword$", "platinum_sword", "Use platinum ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_platinumbar", "Platinum bar", 16);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft titanium sword", "$titanium_sword$", "titanium_sword", "Use titanium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_titaniumbar", "Titanium bar", 8);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft iron dagger", "$iron_dagger$", "iron_dagger", "Use iron ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_ironbar", "Iron bar", 7);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft steel dagger", "$steel_dagger$", "steel_dagger", "Use steel ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_steelbar", "Steel bar", 6);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft golden dagger", "$golden_dagger$", "golden_dagger", "Use golden ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_goldenbar", "Golden bar", 14);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft chromium dagger", "$chromium_dagger$", "chromium_dagger", "Use chromium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_chromiumbar", "Chromium bar", 10);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft palladium dagger", "$palladium_dagger$", "palladium_dagger", "Use palladium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_palladiumbar", "Palladium bar", 8);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft platinum dagger", "$platinum_dagger$", "platinum_dagger", "Use platinum ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_platinumbar", "Platinum bar", 12);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft titanium dagger", "$titanium_dagger$", "titanium_dagger", "Use titanium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_titaniumbar", "Titanium bar", 6);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft iron shield", "$iron_shield$", "iron_shield", "Use iron ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_ironbar", "Iron bar", 7);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft steel shield", "$steel_shield$", "steel_shield", "Use steel ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_steelbar", "Steel bar", 6);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft chromium shield", "$chromium_shield$", "chromium_shield", "Use chromium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_chromiumbar", "Chromium bar", 10);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft palladium shield", "$palladium_shield$", "palladium_shield", "Use palladium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_palladiumbar", "Palladium bar", 8);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft platinum shield", "$platinum_shield$", "platinum_shield", "Use platinum ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_platinumbar", "Platinum bar", 12);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft titanium shield", "$titanium_shield$", "titanium_shield", "Use titanium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_titaniumbar", "Titanium bar", 6);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "", "$$", "", "", true);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft iron bow", "$iron_bow$", "iron_bow", "Use iron ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_ironbar", "Iron bar", 24);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft palladium bow", "$palladium_bow$", "palladium_bow", "Use palladium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_palladiumbar", "Palladium bar", 18);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft platinum bow", "$platinum_bow$", "platinum_bow", "Use platinum ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_platinumbar", "Platinum bar", 22);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft titanium bow", "$titanium_bow$", "titanium_bow", "Use titanium ingots.", true);
		AddRequirement(s.requirements, "blob", "mat_titaniumbar", "Titanium bar", 16);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "1", "$$", "", "", true);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "2", "$$", "", "", true);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "3", "$$", "", "", true);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}

	DoFillArmor(this);
}

void DoFillArmor(CBlob@ this)
{
	for (int i = 0; i < 7*4; i++)
	{
		string alloy;
		string type;
		u8 cost;
		if (i >= 0 && i < 4)
		{
			alloy = "iron";
			switch (i)
			{
				case 0: type = "helmet"; cost = 8; break;
				case 1: type = "chestplate"; cost = 14; break;
				case 2: type = "gloves"; cost = 10; break;
				case 3: type = "boots"; cost = 12; break;
			}
		}
		if (i >= 4 && i < 8)
		{
			alloy = "steel";
			switch (i)
			{
				case 4: type = "helmet"; cost = 6; break;
				case 5: type = "chestplate"; cost = 10; break;
				case 6: type = "gloves"; cost = 7; break;
				case 7: type = "boots"; cost = 8; break;
			}
		}
		if (i >= 8 && i < 12)
		{
			alloy = "golden";
			switch (i)
			{
				case 8: type = "helmet"; cost = 16; break;
				case 9: type = "chestplate"; cost = 20; break;
				case 10: type = "gloves"; cost = 18; break;
				case 11: type = "boots"; cost = 16; break;
			}
		}
		if (i >= 12 && i < 16)
		{
			alloy = "chromium";
			switch (i)
			{
				case 12: type = "helmet"; cost = 12; break;
				case 13: type = "chestplate"; cost = 18; break;
				case 14: type = "gloves"; cost = 20;  break;
				case 15: type = "boots"; cost = 10; break;
			}
		}
		if (i >= 16 && i < 20)
		{
			alloy = "palladium";
			switch (i)
			{
				case 16: type = "helmet"; cost = 12;  break;
				case 17: type = "chestplate"; cost = 16; break;
				case 18: type = "gloves"; cost = 16; break;
				case 19: type = "boots"; cost = 18; break;
			}
		}
		if (i >= 20 && i < 24)
		{
			alloy = "platinum";
			switch (i)
			{
				case 20: type = "helmet"; cost = 20; break;
				case 21: type = "chestplate"; cost = 16; break;
				case 22: type = "gloves"; cost = 14; break;
				case 23: type = "boots"; cost = 12; break;
			}
		}
		if (i >= 24 && i < 28)
		{
			alloy = "titanium";
			switch (i)
			{
				case 24: type = "helmet"; cost = 10; break;
				case 25: type = "chestplate"; cost = 12; break;
				case 26: type = "gloves"; cost = 16; break;
				case 27: type = "boots"; cost = 10; break;
			}
		}
		{
			ShopItem@ s = addShopItem(this, "Craft "+alloy+" "+type, "$"+alloy+"_"+type+"$", alloy+"_"+type, "Use "+alloy+" ingots.", true);
			AddRequirement(s.requirements, "blob", "mat_"+alloy+"bar", alloy+" bar", cost);

			s.spawnNothing = true;

			s.customButton = true;
			s.buttonwidth = 1;
			s.buttonheight = 1;
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getName() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(0, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}
/*
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
	{
		CBitStream params;
	    params.write_u16(caller.getNetworkID());
	    caller.CreateGenericButton("$filled_bucket$", Vec2f(0, 0), this, this.getCommandID("opensmelter"), "Smelter", params);
	}
}
*/
/* //idk if its needed. Looks too much *advanced*
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    if (blob is null) return;

	if (!blob.get_bool("opened")) return;

    u16 scrwidth = getDriver().getScreenWidth();
    u16 scrheight = getDriver().getScreenHeight();

    Vec2f mousePos = getControls().getMouseScreenPos();

	CBlob@ caller = getBlobByNetworkID(blob.get_u16("blobid"));
	if (caller is null) return;
	CControls@ controls = caller.getControls();

	CPlayer@ player = caller.getPlayer();
	if (!player.isMyPlayer()) return;

	if (!blob.isOverlapping(caller)
	|| controls.isKeyJustReleased(KEY_SPACE)
	|| caller.isKeyJustPressed(key_inventory))
		blob.set_bool("opened", false);

	GUI::SetFont("menu");
	GUI::DrawIcon("ChatTexture1.png", Vec2f(scrwidth/2-128*3,scrheight/2-64*3), 3.0f);
	GUI::DrawIcon("ArrowUP.png", Vec2f(scrwidth/2-128*3+128*5.2,scrheight/2-64*3+(scrheight/2-64*3)-32), 2.0f);
	GUI::DrawIcon("ArrowDOWN.png", Vec2f(scrwidth/2-128*3+128*5.2,scrheight/2-64*3+(scrheight/2-64*3)+32), 2.0f);
	GUI::DrawText("0", Vec2f(scrwidth/2-128*3+128*5.27,scrheight/2-64*3+(scrheight/2-64*3)+7), SColor(255, 0, 0, 0));
}
*/
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	/*if (cmd == this.getCommandID("opensmelter"))
	{
		u16 blobid = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(blobid);
		if (blob is null) return;
		CPlayer@ player = blob.getPlayer();
		if (player is null) return;

		this.set_bool("opened", true);
		this.set_u16("blobid", blobid);
	}
	else */if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");
		
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null) return;
			   
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}