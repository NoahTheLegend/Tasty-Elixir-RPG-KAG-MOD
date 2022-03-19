
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

Random traderRandom(Time());

const string[] names = {
	"burdockspice",
	"burnetspice",
	"equisetumspice",
	"mindwortspice",
	"poppyspice",
	"thymespice"
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 2));
	this.set_string("shop description", "Potions table");
	this.set_u8("shop icon", 15);

	{
		ShopItem@ s = addShopItem(this, "Add burdock spice", "$burdockspice$", "burdockspice", "Burdock spice", true);
		AddRequirement(s.requirements, "blob", "burdockspice", "Burdock Spice", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Add burnet spice", "$burnetspice$", "burnetspice", "Burnet spice", true);
		AddRequirement(s.requirements, "blob", "burnetspice", "Burnet Spice", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Add equisetum spice", "$equisetumspice$", "equisetumspice", "Equisetum spice", true);
		AddRequirement(s.requirements, "blob", "equisetumspice", "Equisetum Spice", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Finish potion", "$filled_bucket$", "potion", "Let's see what's that!", true);
		//AddRequirement(s.requirements, "blob", "bucket", "Filled bucket", 1);

		s.spawnNothing = true;

		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Add mindwort spice", "$mindwortspice$", "mindwortspice", "Mindwort spice", true);
		AddRequirement(s.requirements, "blob", "mindwortspice", "Mindwort Spice", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Add poppy spice", "$poppyspice$", "poppyspice", "Poppy spice", true);
		AddRequirement(s.requirements, "blob", "poppyspice", "Poppy Spice", 1);

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Add thyme spice", "$thymespice$", "thymespice", "Thyme spice", true);
		AddRequirement(s.requirements, "blob", "thymespice", "Thyme Spice", 1);

		s.spawnNothing = true;
	}

	this.set_string("add1", "");
	this.set_string("add2", "");
	this.set_string("add3", "");
	this.set_string("add4", "");

	string[] combinations = names;

	for (int i = 0; i < 50; i++) // shuffling
	{
		u8 rand = XORRandom(6);
		combinations.push_back(combinations[rand]);
		combinations.erase(rand);
	}

	this.set_string("key1", combinations[0]);
	this.set_string("key2", combinations[1]);
	this.set_string("key3", combinations[2]);
	this.set_string("key4", combinations[3]);
	this.set_string("key5", combinations[4]);
	this.set_string("key6", combinations[5]);
/*
	for (int i = 0; i < combinations.length; i++)
	{
		printf(combinations[i]);
	}
*/
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
		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		//string[] spl = name.split("_");

		if (callerBlob is null) return;

		if (isServer())
		{
			if (name.findFirst("potion") != -1)
			{
				if (this.get_string("add1") == "" && this.get_string("add2") == "" && this.get_string("add3") == "" && this.get_string("add4") == "" )
				{
					this.getSprite().PlaySound("NoAmmo.ogg");
					return;
				}
				// potion goes here
				CBlob@ potion = server_CreateBlobNoInit("potion");

				potion.set_string("add1", this.get_string("add1"));
	        	potion.set_string("add2", this.get_string("add2"));
	        	potion.set_string("add3", this.get_string("add3"));
	        	potion.set_string("add4", this.get_string("add3"));
            	potion.set_string("key1", this.get_string("key1"));
	        	potion.set_string("key2", this.get_string("key2"));
	        	potion.set_string("key3", this.get_string("key3"));
	        	potion.set_string("key4", this.get_string("key4"));
	        	potion.set_string("key5", this.get_string("key5"));
	        	potion.set_string("key6", this.get_string("key6")); 

				potion.setPosition(this.getPosition());
				potion.server_setTeamNum(0);
				potion.server_PutInInventory(callerBlob);
				potion.Init();
				
				this.set_string("add1", "");
				this.set_string("add2", "");
				this.set_string("add3", "");
				this.set_string("add4", "");

				this.getSprite().PlaySound("PotionMade.ogg");
			}
			else
			{
				if (this.get_string("add1") == "") // apply effect1
				{
					this.set_string("add1", name);
					this.getSprite().PlaySound("PotionMade.ogg");
					//printf(name);
				}
				else if (this.get_string("add2") == "") // apply effect2
				{
					this.set_string("add2", name);
					this.getSprite().PlaySound("PotionMade.ogg");
					//printf(name);
				}
				else if (this.get_string("add3") == "") // apply effect3
				{
					this.set_string("add3", name);
					this.getSprite().PlaySound("PotionMade.ogg");
					//printf(name);
				}
				else if (this.get_string("add4") == "") // apply effect4
				{
					this.set_string("add4", name);
					this.getSprite().PlaySound("PotionMade.ogg");
					//printf(name);
				}
				else
				{
					this.getSprite().PlaySound("NoAmmo.ogg");
					server_CreateBlob(name, 0, this.getPosition());
					return;
				}
			}
		}
	}
}