
#include "MakeDustParticle.as";

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    //shieldblock
    int[] shbf = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}; // shieldblock
    SetAnimationUp(this, "shieldblock", "ShieldBlockAnim.png", 64, 64, shbf, 0.4f, Vec2f(0, -27.5f), 5.0f);

    int[] concf = {0, 1, 2, 3, 4}; // concentration
    SetAnimationUp(this, "concentration", "ConcentrationAnim.png", 64, 64, concf, 0.7f, Vec2f(0, -7.5f), 5.0f);

    int[] reasf = {0, 1, 2}; // reassurance
    SetAnimationUp(this, "reassurance", "ReassuranceAnim.png", 32, 32, reasf, 0.7f, Vec2f(1.5f, -27.5f), 5.0f);

    int[] mbf = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}; // massbash
    SetAnimationUp(this, "massbash", "ShieldBlockAnim.png", 64, 64, mbf, 0.4f, Vec2f(0, -27.5f), 5.0f);

    blob.set_bool("animplaying", false);
    blob.set_string("animname", "");
    blob.set_u32("begintime", 0);
}

void SetAnimationUp(CSprite@ this, string spritelayer, string name, f32 x, f32 y, int[] frames, f32 scale, Vec2f offset, f32 z)
{
    this.RemoveSpriteLayer(spritelayer);
    CSpriteLayer@ sl = this.addSpriteLayer(spritelayer, name, x, y);

	if (sl !is null)
	{
		Animation@ anim = sl.addAnimation(spritelayer, 0, false);
		anim.AddFrames(frames);
        sl.ScaleBy(scale, scale);
        sl.SetOffset(offset);
		sl.SetVisible(false);
		sl.SetRelativeZ(z);
	}
}

u16[] ttemp = {

};
u16[] ftemp = {

};

void UpdateAnim(CSprite@ this, CBlob@ blob, string name, string sl, u16[] timers, u16[] frames)
{
    u32 begin = blob.get_u32("begintime");
    CSpriteLayer@ slayer = this.getSpriteLayer(sl);
    if (slayer is null) return;

    u32 gametime = getGameTime();

    Animation@ anim = slayer.getAnimation(sl);
    if (anim is null) return;

    slayer.SetVisible(true);
    slayer.SetFacingLeft(false);

    if (ttemp.length == 0) ttemp = timers;
    if (ftemp.length == 0) ftemp = frames;
    
    if (gametime == begin+ttemp[ttemp.length-1])
    {
        bool track;
        string trackname;
        f32 vol;
        f32 pitch;
        if (sl == "shieldblock")
        {
            if (ftemp.length == 7)
            {
                this.PlaySound("ArrowHit.ogg", 3.0f, 1.1f);
                this.PlaySound("ShieldBeingHit.ogg", 0.5f, 1.2f);
            }
        }
        else if (sl == "concentration")
        {
            if (ftemp.length == 16)
            {
                track = true;
                trackname = "Concentration.ogg";
                vol = 0.35f;
                pitch = 1.1f;
            }
        }
        else if (sl == "reassurance")
        {
            if (ftemp.length == 4)
            {
                track = true;
                trackname = "ReassuranceAppear.ogg";
                vol = 2.0f;
                pitch = 1.0f;
            }
        }
        DoAnim(this, anim, ftemp[ftemp.length-1], track, trackname, vol, pitch);

        ttemp.erase(ttemp.length-1);
        ftemp.erase(ftemp.length-1);
    }

    if (ttemp.length == 0)
    {
        blob.set_bool("animplaying", false);
	    blob.set_string("animname", "");
	    blob.set_u32("begintime", 0);
        slayer.SetVisible(false);
    }
}

void onTick(CSprite@ this)
{
    u32 gametime = getGameTime();
    CBlob@ blob = this.getBlob();
    if (blob !is null && blob.get_bool("animplaying"))
    {
        if (blob.get_string("animname") == "Shield block") // shieldblock, found out that transparent pixels cant be used in spritelayers
        {
            u16[] timers = {40,36,31,25,19,16,13,11,9,7,4}; // reversed!
            u16[] frames = {0,9,8,7,6,5,5,4,3,2,1}; // reversed!
            UpdateAnim(this, blob, blob.get_string("animname"), "shieldblock", timers, frames);
        }
        else if (blob.get_string("animname") == "Concentration")
        {
            u16[] timers = {77,72,67,62,57,52,47,42,37,32,27,22,17,12,7,4};
            u16[] frames = {0, 1, 2, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 2, 1};
            UpdateAnim(this, blob, blob.get_string("animname"), "concentration", timers, frames);
        }
        else if (blob.get_string("animname") == "Silence")
        {
            ParticleAnimated("Entities/Effects/Sprites/LargeSmoke.png", blob.getPosition(), Vec2f(0, 0.0f), 0.0f, 1.0f, 1.75, 0.0f, true);
            this.PlaySound("Silence.ogg", 1.0f, 1.75f);
            blob.set_bool("animplaying", false);
			blob.set_string("animname", "");
			blob.set_u32("begintime", 0);
        }
        else if (blob.get_string("animname") == "Reassurance")
        {
            u16[] timers = {66,63,60,6,3};
            u16[] frames = {0, 0, 1, 2, 1};
            UpdateAnim(this, blob, blob.get_string("animname"), "reassurance", timers, frames);
        }
        else if (blob.get_string("animname") == "Mass bash") // shieldblock, found out that transparent pixels cant be used in spritelayers
        {
            u16[] timers = {40,36,31,25,19,16,13,11,9,7,4}; // reversed!
            u16[] frames = {0,9,8,7,6,5,5,4,3,2,1}; // reversed!
            UpdateAnim(this, blob, blob.get_string("animname"), "massbash", timers, frames);
        }
    }
}

void DoAnim(CSprite@ this, Animation@ anim, u8 index, bool playsound, string filename, f32 volume, f32 pitch)
{
    anim.SetFrameIndex(index);
    if (playsound) this.PlaySound(filename, volume, pitch);
}