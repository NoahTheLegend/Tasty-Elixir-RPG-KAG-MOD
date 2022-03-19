// A script by TFlippy

void onInit(CSprite@ this)
{
	this.SetZ(-60);
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 30;

	this.addCommandID("sv_store");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CInventory @inv = caller.getInventory();
	if(inv is null) return;

	if(inv.getItemsCount() > 0)
	{
		params.write_u16(caller.getNetworkID());
		CButton@ buttonOwner = caller.CreateGenericButton(28, Vec2f(0, 8), this, this.getCommandID("sv_store"), "Store", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("sv_store"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				if (caller.getName() == "builder")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				if (inv !is null)
				{
					while (inv.getItemsCount() > 0)
					{
						CBlob @item = inv.getItem(0);
						caller.server_PutOutInventory(item);
						this.server_PutInInventory(item);
					}
				}
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this);
}
