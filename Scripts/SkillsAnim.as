
#include "MakeDustParticle.as";

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    //shieldblock
    this.RemoveSpriteLayer("shieldblock");
    CSpriteLayer@ shieldblock = this.addSpriteLayer("shieldblock", "ShieldBlockAnim.png", 64, 64);

	if (shieldblock !is null)
	{
		Animation@ shbanim = shieldblock.addAnimation("shieldblock", 0, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
		shbanim.AddFrames(frames);
        shieldblock.ScaleBy(0.4f, 0.4f);
        shieldblock.SetOffset(Vec2f(0, -27.5f));
		shieldblock.SetVisible(false);
		shieldblock.SetRelativeZ(-5.0f);
	}

    this.RemoveSpriteLayer("concentration");
    CSpriteLayer@ concentration = this.addSpriteLayer("concentration", "ConcentrationAnim.png", 64, 64);

	if (concentration !is null)
	{
		Animation@ concanim = concentration.addAnimation("concentration", 0, false);
		int[] frames = {0, 1, 2, 3, 4};
		concanim.AddFrames(frames);
        concentration.ScaleBy(0.70f, 0.70f);
        concentration.SetOffset(Vec2f(0, -7.5f));
		concentration.SetVisible(false);
		concentration.SetRelativeZ(5.0f);
	}

    this.RemoveSpriteLayer("reassurance");
    CSpriteLayer@ reassurance = this.addSpriteLayer("reassurance", "ReassuranceAnim.png", 32, 32);

	if (reassurance !is null)
	{
		Animation@ reasanim = reassurance.addAnimation("reassurance", 0, false);
		int[] frames = {0, 1, 2};
		reasanim.AddFrames(frames);
        reassurance.ScaleBy(0.70f, 0.70f);
        reassurance.SetOffset(Vec2f(1.5f, -27.5f));
		reassurance.SetVisible(false);
		reassurance.SetRelativeZ(5.0f);
	}

    blob.set_bool("animplaying", false);
    blob.set_string("animname", "");
    blob.set_u32("begintime", 0);
}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob !is null && blob.get_bool("animplaying"))
    {
        if (blob.get_string("animname") == "Shield block") // shieldblock, found out that transparent pixels cant be used in spritelayers
        {
            u32 begin = blob.get_u32("begintime");
            CSpriteLayer@ shieldblock = this.getSpriteLayer("shieldblock");
            if (shieldblock is null) return;
            Animation@ shbanim = shieldblock.getAnimation("shieldblock");
            if (shbanim is null) return;
            
            shieldblock.SetVisible(true);
            shieldblock.SetFacingLeft(false);

            if (getGameTime() == begin+4) DoAnim(this, shbanim, 1, false, "", 0, 0);
            if (getGameTime() == begin+7) DoAnim(this, shbanim, 2, false, "", 0, 0);
            if (getGameTime() == begin+9) DoAnim(this, shbanim, 3, false, "", 0, 0);
            if (getGameTime() == begin+11) DoAnim(this, shbanim, 5, false, "", 0, 0);
            if (getGameTime() == begin+13)
            {
                DoAnim(this, shbanim, 5, false, "", 5, 0);
                this.PlaySound("ArrowHit.ogg", 3.0f, 1.1f);
                this.PlaySound("ShieldBeingHit.ogg", 0.5f, 1.2f);
            }
            if (getGameTime() == begin+16) DoAnim(this, shbanim, 5, true, "ArrowHit.ogg", 3.0, 1.1);
            if (getGameTime() == begin+19) DoAnim(this, shbanim, 6, false, "", 0, 0);
            if (getGameTime() == begin+25) DoAnim(this, shbanim, 7, false, "", 0, 0);
            if (getGameTime() == begin+31) DoAnim(this, shbanim, 8, false, "", 0, 0);
            if (getGameTime() == begin+36) DoAnim(this, shbanim, 9, false, "", 0, 0);
            if (getGameTime() == begin+40)
            {
                blob.set_bool("animplaying", false);
			    blob.set_string("animname", "");
			    blob.set_u32("begintime", 0);
                shieldblock.SetVisible(false);
                DoAnim(this, shbanim, 0, false, "", 0, 0);
            }
        }
        else if (blob.get_string("animname") == "Concentration")
        {
            u32 begin = blob.get_u32("begintime");
            CSpriteLayer@ concentration = this.getSpriteLayer("concentration");
            if (concentration is null) return;
            Animation@ concanim = concentration.getAnimation("concentration");
            if (concanim is null) return;

            concentration.SetVisible(true);
            concentration.SetFacingLeft(false);

            u32 gametime = getGameTime();
            if (gametime == begin+8) DoAnim(this, concanim, 1, true, "Concentration.ogg", 0.5f, 0.975f);
            else if (gametime == begin+16) DoAnim(this, concanim, 2, false, "", 0, 0);
            else if (gametime == begin+23) DoAnim(this, concanim, 3, false, "", 0, 0);
            else if (gametime == begin+29) DoAnim(this, concanim, 4, false, "", 0, 0);
            else if (gametime == begin+35) DoAnim(this, concanim, 3, false, "", 0, 0);
            else if (gametime == begin+41) DoAnim(this, concanim, 4, false, "", 0, 0);
            else if (gametime == begin+47) DoAnim(this, concanim, 3, false, "", 0, 0);
            else if (gametime == begin+53) DoAnim(this, concanim, 4, false, "", 0, 0);
            else if (gametime == begin+59) DoAnim(this, concanim, 3, false, "", 0, 0);
            else if (gametime == begin+65) DoAnim(this, concanim, 4, false, "", 0, 0);
            else if (gametime == begin+70) DoAnim(this, concanim, 3, false, "", 0, 0);
            else if (gametime == begin+75) DoAnim(this, concanim, 4, false, "", 0, 0);
            else if (gametime == begin+80) DoAnim(this, concanim, 3, false, "", 0, 0);
            else if (gametime == begin+85) DoAnim(this, concanim, 2, false, "", 0, 0);
            else if (gametime == begin+90) DoAnim(this, concanim, 1, false, "", 0, 0);
            else if (gametime == begin+95) 
            {
                DoAnim(this, concanim, 0, false, "0", 0, 0);
                blob.set_bool("animplaying", false);
			    blob.set_string("animname", "");
			    blob.set_u32("begintime", 0);
                concentration.SetVisible(false);
            } 
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
            u32 begin = blob.get_u32("begintime");
            CSpriteLayer@ reassurance = this.getSpriteLayer("reassurance");
            if (reassurance is null) return;
            Animation@ reasanim = reassurance.getAnimation("reassurance");
            if (reasanim is null) return;

            reassurance.SetVisible(true);
            reassurance.SetFacingLeft(false);

            if (getGameTime() == begin+4) DoAnim(this, reasanim, 1, false, "", 0, 0);
            else if (getGameTime() == begin+8) DoAnim(this, reasanim, 2, true, "ReassuranceAppear.ogg", 2.0, 1.0);
            else if (getGameTime() == begin+68) DoAnim(this, reasanim, 1, false, "", 0, 0); 
            else if (getGameTime() == begin+72) DoAnim(this, reasanim, 1, false, "", 0, 0);
            else if (getGameTime() == begin+76)
            {
                blob.set_bool("animplaying", false);
			    blob.set_string("animname", "");
			    blob.set_u32("begintime", 0);
                reassurance.SetVisible(false);
            }
        }
    }
}

void DoAnim(CSprite@ this, Animation@ anim, u8 index, bool playsound, string filename, f32 volume, f32 pitch)
{
    anim.SetFrameIndex(index);
    if (playsound) this.PlaySound(filename, volume, pitch);
}