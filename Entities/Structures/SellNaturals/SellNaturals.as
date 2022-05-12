
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(6, 2));
	this.set_string("shop description", "Sell your naturals");
	this.set_u8("shop icon", 15);

	{
		s32 cost = XORRandom(45)+51;
		ShopItem@ s = addShopItem(this, "Sell Burdock", "$COIN$", "coin-"+cost, "Sell 1 burdock for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "burdock", "Burdock", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = XORRandom(70)+51;
		ShopItem@ s = addShopItem(this, "Sell Burnet", "$COIN$", "coin-"+cost, "Sell 1 burnet for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "burnet", "Burnet", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = XORRandom(55)+51;
		ShopItem@ s = addShopItem(this, "Sell Equisetum", "$COIN$", "coin-"+cost, "Sell 1 equisetum for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "equisetum", "Equisetum", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = XORRandom(75)+51;
		ShopItem@ s = addShopItem(this, "Sell Mindwort", "$COIN$", "coin-"+cost, "Sell 1 mindwort for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "mindwort", "Mindwort", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = XORRandom(35)+51;
		ShopItem@ s = addShopItem(this, "Sell Poppy", "$COIN$", "coin-"+cost, "Sell 1 mindwort for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "poppy", "Poppy", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = XORRandom(60)+51;
		ShopItem@ s = addShopItem(this, "Sell Thyme", "$COIN$", "coin-"+cost, "Sell 1 thyme for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "thyme", "Thyme", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = (XORRandom(45)+51)*2;
		ShopItem@ s = addShopItem(this, "Sell Burdock Spice", "$COIN$", "coin-"+cost, "Sell 1 burdock spice for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "burdockspice", "Burdock Spice", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = XORRandom(70)+51;
		ShopItem@ s = addShopItem(this, "Sell Burnet Spice", "$COIN$", "coin-"+cost, "Sell 1 burnet spice for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "burnetspice", "Burnet Spice", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = (XORRandom(55)+51)*3;
		ShopItem@ s = addShopItem(this, "Sell Equisetum Spice", "$COIN$", "coin-"+cost, "Sell 1 equisetum spice for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "equisetumspice", "Equisetum Spice", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = (XORRandom(75)+51)*2;
		ShopItem@ s = addShopItem(this, "Sell Mindwort Spice", "$COIN$", "coin-"+cost, "Sell 1 mindwort spice for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "mindwortspice", "Mindwort Spice", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = XORRandom(35)+51;
		ShopItem@ s = addShopItem(this, "Sell Poppy Spice", "$COIN$", "coin-"+cost, "Sell 1 poppy spice for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "poppyspice", "Poppy Spice", 1);
		s.spawnNothing = true;
	}
	{
		s32 cost = (XORRandom(60)+51)*2;
		ShopItem@ s = addShopItem(this, "Sell Thyme Spice", "$COIN$", "coin-"+cost, "Sell 1 thyme spice for "+cost+" coins.");
		AddRequirement(s.requirements, "blob", "thymespice", "Thyme Spice", 1);
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