#include "StatEffectsCommon.as";

void onInit(CBlob@ this)
{
    this.set_u8("saturationhunger", 0);
    this.set_u8("saturationthirst", 1);
    this.set_u8("antisaturationthirst", XORRandom(5)+11);

    this.addCommandID("use");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.get_bool("regen")) return;

    CBitStream params;
	params.write_u16(caller.getNetworkID());
    params.write_u32(this.getNetworkID());
	caller.CreateGenericButton("$burdock$", Vec2f(0, 0), this, this.getCommandID("use"), "Eat/use burdock", params); 
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("use"))
    {
        u16 blobid = params.read_u16();
        u32 herbid = params.read_u32();
        CBlob@ blob = getBlobByNetworkID(blobid);
        CBlob@ herb = getBlobByNetworkID(herbid);

        if (blob !is null)
        {
            giveEffect(blob, 4);
            blob.set_u8("thirst", blob.get_u8("thirst") + this.get_u8("antisaturationthirst"));
            blob.Sync("thirst", true);

            if (isServer()) herb.server_Die();
        }
    }
}