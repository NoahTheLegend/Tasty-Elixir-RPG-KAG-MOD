// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "CTFShopCommon.as";

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.getCurrentScript().tickFrequency = 150;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(7, 7));
	this.set_string("shop description", "Mechanist's Workshop");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", "A lantern for seeing through darkness.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 250);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Lava lantern", "$lavalantern$", "lavalantern", "A lantern, that is resistable to oxidized and damp air.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);
		AddRequirement(s.requirements, "blob", "mat_hellstone", "Hellstone", 50);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "A drill for mining stone and gold.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Iron Drill", "$irondrill$", "irondrill", "A drill for mining iron and less hard materials.\nCapable to drill longer, but cools slower.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 50); //change to bars

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Steel Drill", "$steeldrill$", "steeldrill", "A drill for mining *ore* and less hard materials.\nDrills faster.", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron", 50); //change to bars

		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(2,0));

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

				// CBlob@ mat = server_CreateBlob(spl[0]);

				// if (mat !is null)
				// {
					// mat.Tag("do not set materials");
					// mat.server_SetQuantity(parseInt(spl[1]));
					// if (!callerBlob.server_PutInInventory(mat))
					// {
						// mat.setPosition(callerBlob.getPosition());
					// }
				// }
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (callerBlob.getPlayer() !is null ) blob.SetDamageOwnerPlayer(callerBlob.getPlayer());
				
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
