
#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

Random traderRandom(Time());

const string[] armortypes = {
	"helmet",
	"chestplate",
	"gloves",
	"boots"
};

const string[] armoralloys = {
	"iron",
	"steel",
	"golden",
	"chromium",
	"palladium",
	"platinum",
	"titanium"
};

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// getMap().server_SetTile(this.getPosition(), CMap::tile_wood_back);

	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", "TraderRich.png", 16, 16, 0, 0);
		trader.SetRelativeZ(20);
		Animation@ stop = trader.addAnimation("stop", 1, false);
		stop.AddFrame(0);
		Animation@ walk = trader.addAnimation("walk", 1, false);
		walk.AddFrame(0); walk.AddFrame(1); walk.AddFrame(2); walk.AddFrame(3);
		walk.time = 10;
		walk.loop = true;
		trader.SetOffset(Vec2f(0, 8));
		trader.SetFrame(0);
		trader.SetAnimation(stop);
		trader.SetIgnoreParentFacing(true);
		this.set_bool("trader moving", false);
		this.set_bool("moving left", false);
		this.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
		this.set_u32("next offset", traderRandom.NextRanged(16));
	}

	AddIconToken("$filled_bucket$", "bucket.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_string("shop description", "Merchant");
	this.set_u8("shop icon", 15);
	
	this.getCurrentScript().tickFrequency = 40;

	DoSetItems(this);

	this.set_Vec2f("shop menu size", Vec2f(9,9));
}

void DoSetItems(CBlob@ this)
{
	string[] items = {
		"food",
		"bread",
		"cake",
		"cooked_fish",
		"mat_ironbar-1",
		"food",
		"bread",
		"cake",
		"cooked_fish",
		"mat_ironbar-5",
		"mat_steelbar-3",
		"mat_goldenbar-3",
		"mat_chromiumbar-4",
		"mat_platinumbar-1",
		"burdockspice",
		"burnetspice",
		"equisetumspice",
		"mindwortspice",
		"poppyspice",
		"thymespice",
		"mat_wood-100"
	};

	s32[] costs = {
		XORRandom(75)+51, // burger
		XORRandom(50)+51, // bread
		XORRandom(85)+51, // cake
		XORRandom(50)+51, // cooked fish
		XORRandom(50)+151, // iron bar (1)
		XORRandom(75)+51, // burger
		XORRandom(50)+51, // bread
		XORRandom(85)+51, // cake
		XORRandom(50)+51, // cooked fish
		XORRandom(450)+251, // iron bar
		XORRandom(575)+221, // steel bar
		XORRandom(500)+201, // gold bar
		XORRandom(800)+541, // chromium bar
		XORRandom(1200)+801, // platinum bar
		XORRandom(100)+101, // burdock spice
		XORRandom(90)+151, // burnet spice
		XORRandom(120)+51, // equisetum spice
		XORRandom(95)+81, // mindwort spice
		XORRandom(45)+201, // poppy spice
		XORRandom(75)+96, // thyme spice
		XORRandom(50)+51 // thyme spice
	};

	// add names array also

	// random armor push_back P.S. add leather armor too!
	for (int i = 0; i < XORRandom(10)+1; i++)
	{
		u8 armortype = XORRandom(4);
		u8 armoralloy = XORRandom(7);
		u32 rand = XORRandom(armoralloy+2);
		u32 modifier = rand*350;

		items.push_back(armoralloys[armoralloy]+"_"+armortypes[armortype]);
		costs.push_back((armoralloy+1)*1000+modifier);

		//printf("items.pushed_back: "+(armoralloys[armoralloy]+"_"+armortypes[armortype]));
		//printf("costs.pushed_back: "+((armoralloy+1)*1000+modifier));
	}

	u16[] currlength;

	for (int i; i < items.length; i++)
	{
		currlength.push_back(i);
	}

	for (int i = 0; i < 35; i++) // shuffle
	{
		u16 ritem1 = XORRandom(currlength.length);
		if (ritem1 >= currlength.length || ritem1 < 0) continue;
		u16 ritem2 = XORRandom(currlength.length);
		if (ritem2 >= currlength.length || ritem2 < 0) continue;
		if (ritem1 == ritem2) continue;
		u16 e = 999;
		e = currlength[ritem1];
		currlength[ritem1] = currlength[ritem2];
		currlength[ritem2] = e;
	}

	for (int i = 0; i < currlength.length; i++)
	{
		if (XORRandom(5) == 0) continue;
		AddAShopItem(this, items[currlength[i]], items[currlength[i]], costs[currlength[i]], 1, 1);
	}

	if (currlength.length == 0) DoSetItems(this); // due to some bug needs a recursive call
	//printf(""+currlength.length);
}

void AddAShopItem(CBlob@ this, string item, string itemname, s32 cost, u8 btnx, u8 btny)
{
	string[] matunsplit = item.split("-");
	string matitem = matunsplit[0];

	string[] theitem = item.split("_");

	if (theitem.length > 1)
	{
		if (theitem[1] == "helmet"
		|| theitem[1] == "chestplate"
		|| theitem[1] == "gloves"
		|| theitem[1] == "boots")
		{
			btnx = 2;
			btny = 2;
		}
		else if (theitem[1] == "bow"
		|| theitem[1] == "staff")
		{
			btnx = 1;
			btny = 2;
		}
	}

	if (btnx == 0) btnx = 1;
	if (btny == 0) btny = 1;

	{
		ShopItem@ s = addShopItem(this, "Purchase "+itemname, "$"+matitem+"$", item, itemname, true);
		AddRequirement(s.requirements, "coin", "", "Coins", cost);

		s.customButton = true;
		s.buttonwidth = btnx;
		s.buttonheight = btny;

		s.spawnNothing = true;
	}	
	//printf("Purchase "+itemname+" "+"$"+matitem+"$"+" "+item+additional+" "+itemname);
}

void DoPlaySound(CBlob@ this, string name)
{
	if (isClient()) Sound::Play(name, this.getPosition(), 1.0f);
}

void onTick(CSprite@ this)
{
	//TODO: empty? show it.
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ trader = this.getSpriteLayer("trader");
	bool trader_moving = blob.get_bool("trader moving");
	bool moving_left = blob.get_bool("moving left");
	u32 move_timer = blob.get_u32("move timer");
	u32 next_offset = blob.get_u32("next offset");

	CMap@ map = getMap();
	if (isClient())
		if (map.getDayTime() == 0.800000)
		{
			this.PlaySound("Cooked.ogg");
			if (isServer())
			{
				CBlob@ blobbie = server_CreateBlob("richmerchant", blob.getTeamNum(), blob.getPosition());
				blobbie.setPosition(blob.getPosition());
				blob.server_Die();
			}
		}

	if (!trader_moving)
	{
		if (move_timer <= getGameTime())
		{
			blob.set_bool("trader moving", true);
			trader.SetAnimation("walk");
			trader.SetFacingLeft(!moving_left);
			Vec2f offset = trader.getOffset();
			offset.x *= -1.0f;
			trader.SetOffset(offset);
		}
	}
	else
	{
		//had to do some weird shit here because offset is based on facing
		Vec2f offset = trader.getOffset();
		if (moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", false);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(4) + 6)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
		else if (!moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (!moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", true);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(3) + 7)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
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
