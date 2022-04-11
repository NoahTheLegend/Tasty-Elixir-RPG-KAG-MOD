// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CTFShopCommon.as";
#include "MakeSeed.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	// this.Tag("upkeep building");
	// this.set_u8("upkeep cap increase", 10);
	// this.set_u8("upkeep cost", 0);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(3, 4));
	this.set_string("shop description", "Plant Nursery");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Buy burdock", "$burdock$", "burdock", "Burdock root, leaf, and seeds are used as basic medicine.", true); //hp
		AddRequirement(s.requirements, "coin", "", "Coins", 135);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy burnet", "$burnet$", "burnet", "The small flowers lack true petals\nand are crowded into a dense head or spike.", true); //?
		AddRequirement(s.requirements, "coin", "", "Coins", 150);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy equisetum", "$equisetum$", "equisetum", "It's leaf used to be a\nmust-have in a long travel without a bandage.\nAlso known as horsetail.", true); //bleed
		AddRequirement(s.requirements, "coin", "", "Coins", 115);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy mindwort", "$mindwort$", "mindwort", "Mindwort is used as a potent sedative,\nhelpful in recovery from major shocks", true); //resists
		AddRequirement(s.requirements, "coin", "", "Coins", 160);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy poppy", "$poppy$", "poppy", "In combination with other\nherbs, Poppy is used for\nmental and physical tiredness", true); //mana
		AddRequirement(s.requirements, "coin", "", "Coins", 100);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy thyme", "$thyme$", "thyme", "Thyme contains chemicals that\nmight help bacterial and fungal infections.", true); //poison
		AddRequirement(s.requirements, "coin", "", "Coins", 140);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
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

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
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