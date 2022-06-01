#include "RunnerCommon.as";

void onInit(CBlob@ this)
{
   this.addCommandID("scrolltp");
   CSprite@ sprite = this.getSprite();
   if (sprite is null) return;
   sprite.SetEmitSound("LevitateLoop.ogg");
   sprite.SetEmitSoundPaused(true);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.hasTag("teleporting")) return;

    CBitStream params;
    params.write_u16(caller.getNetworkID());

    caller.CreateGenericButton("$"+this.getName()+"$", Vec2f(0, 0), this, this.getCommandID("scrolltp"), "Teleport to respawn", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("scrolltp"))
    {
        u16 callerid = params.read_u16();
        this.set_u16("caller", callerid);
        CBlob@ blob = getBlobByNetworkID(callerid);
        if (blob !is null)
        {
            if (!blob.isOnGround()) return;
            blob.Tag("teleporting");
            this.set_Vec2f("stickpos", Vec2f(this.getPosition().x, this.getPosition().y-26.0f));
            this.set_u32("begintime", getGameTime()+120);
        }
    }
}

void onTick(CBlob@ this)
{
    if (this.hasTag("die"))
    {
        if (isServer()) this.server_Die();
    }
}

void onRender(CSprite@ this)
{
    CBlob@ scroll = this.getBlob();
    if (scroll is null) return;
    CBlob@ blob = getBlobByNetworkID(scroll.get_u16("caller"));
    if (blob is null || !blob.isMyPlayer()) return;

    u32 diff = scroll.get_u32("begintime") - getGameTime();

    if (diff < 120 && blob.hasTag("teleporting"))
    {
        if (this !is null)
        {
            this.SetEmitSoundVolume(2.0f);
            this.SetEmitSoundSpeed(1.25f);
            this.SetEmitSoundPaused(false);
        }
        
        if (isServer() && !scroll.isAttached()) scroll.server_AttachTo(blob, "PICKUP");
        RunnerMoveVars@ moveVars;
	    if (!blob.get("moveVars", @moveVars))
	    {
		    return;
	    }
        
        blob.setVelocity(Vec2f(0,0));
        moveVars.walkSpeed = 0;
        moveVars.walkFactor = 0;
        moveVars.walkSpeedInAir = 0;

        Vec2f pos = Vec2f(blob.getPosition().x+XORRandom(Maths::Pow(-7, 2))-24.0f, blob.getPosition().y);

        if (getGameTime() % 3 == 0)
        {
            CParticle@ temp = ParticleAnimated("DustPurpleSmall.png", pos, Vec2f(0, 1.0f), 0.0f, 1.2f, 2, 0.0f, false);
        }

        if (diff > 105)
        {
            blob.setPosition(Vec2f(blob.getPosition().x, blob.getPosition().y-0.75f));
        }
        else if (diff <= 105 && diff > 90)
        {
            blob.setPosition(Vec2f(blob.getPosition().x, blob.getPosition().y-0.5f));
        }
        else if (diff <= 90 && diff > 75)
        {
            blob.setPosition(Vec2f(blob.getPosition().x, blob.getPosition().y-0.35f));
        }
        else blob.setPosition(scroll.get_Vec2f("stickpos"));
        if (diff <= 1)
        {
            blob.Untag("teleporting");
            scroll.Tag("die");
            CBlob@ spawn = getBlobByName("tdm_spawn");
            if (spawn !is null) blob.setPosition(spawn.getPosition());
            else if (isServer()) server_CreateBlob("tpscroll", 0, blob.getPosition());
            this.SetEmitSoundPaused(true);
        }
    }
}