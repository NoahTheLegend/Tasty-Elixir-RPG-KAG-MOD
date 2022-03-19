#include "StatEffectsCommon.as";

void onInit(CBlob@ this)
{
    this.set_u8("antisaturationthirst", XORRandom(5)+16);

    this.addCommandID("use");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;

    CBitStream params;
	params.write_u16(caller.getNetworkID());
    params.write_u32(this.getNetworkID());
	caller.CreateGenericButton("$thyme$", Vec2f(0, 0), this, this.getCommandID("use"), "Eat/use thyme", params); 
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
            if (blob.get_string("eff1") == "2_poison")
            {
                blob.set_u16("timer1", 0);
                blob.set_string("buffs1", "");
                blob.set_string("eff1", "");
                blob.Sync("timer1", true);
                blob.Sync("buffs1", true);
                blob.Sync("eff1", true);
            }
            else if (blob.get_string("eff2") == "2_poison")
            {
                blob.set_u16("timer2", 0);
                blob.set_string("buffs2", "");
                blob.set_string("eff2", "");
                blob.Sync("timer2", true);
                blob.Sync("buffs2", true);
                blob.Sync("eff2", true);
            }
            else if (blob.get_string("eff3") == "2_poison")
            {
                blob.set_u16("timer3", 0);
                blob.set_string("buffs3", "");
                blob.set_string("eff3", "");
                blob.Sync("timer3", true);
                blob.Sync("buffs3", true);
                blob.Sync("eff3", true);                
            }
            else if (blob.get_string("eff4") == "2_poison")
            {
                blob.set_u16("timer4", 0);
                blob.set_string("buffs4", "");
                blob.set_string("eff4", "");
                blob.Sync("timer4", true);
                blob.Sync("buffs4", true);
                blob.Sync("eff4", true);
            }
            else if (blob.get_string("eff5") == "2_poison")
            {
                blob.set_u16("timer5", 0);
                blob.set_string("buffs5", "");
                blob.set_string("eff5", "");
                blob.Sync("timer5", true);
                blob.Sync("buffs5", true);
                blob.Sync("eff5", true);
            }
            else return;

            blob.set_bool("poisoned", false);
            blob.Sync("poisoned", true);
            blob.set_u8("thirst", blob.get_u8("thirst") + this.get_u8("antisaturationthirst"));
            blob.Sync("thirst", true);
            if (isServer()) herb.server_Die();
        }
    }
}