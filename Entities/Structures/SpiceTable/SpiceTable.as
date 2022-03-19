
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Spice table");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Craft burdock spice", "$burdockspice$", "burdockspice", "Burdock spice", true);
		AddRequirement(s.requirements, "blob", "burdock", "Burdock", 2);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft burnet spice", "$burnetspice$", "burnetspice", "Burnet spice", true);
		AddRequirement(s.requirements, "blob", "burnet", "Burnet", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft equisetum spice", "$equisetumspice$", "equisetumspice", "Equisetum spice", true);
		AddRequirement(s.requirements, "blob", "equisetum", "Equisetum", 3);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft mindwort spice", "$mindwortspice$", "mindwortspice", "Mindwort spice", true);
		AddRequirement(s.requirements, "blob", "mindwort", "Mindwort", 2);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft poppy spice", "$poppyspice$", "poppyspice", "Poppy spice", true);
		AddRequirement(s.requirements, "blob", "poppy", "Poppy", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Craft thyme spice", "$thymespice$", "thymespice", "Thyme spice", true);
		AddRequirement(s.requirements, "blob", "thyme", "Thyme", 2);

		s.spawnNothing = true;
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
		this.getSprite().PlaySound("Cooked.ogg");

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