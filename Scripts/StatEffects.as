#include "StatEffectsCommon.as";

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob !is null)
    {   // index_name_variable`variable`...
        for (u8 i = 1; i <= 20; i++)
        {
            blob.set_string("eff"+i, "");
        }
    }
}

const u16 scrwidth = getDriver().getScreenWidth();
const u16 scrheight = getDriver().getScreenHeight();

void RenderIcons(CSprite@ this, CBlob@ blob, u8 idx)
{

    string[] spl;
    if (blob.get_string("eff"+idx) != "") spl = blob.get_string("eff"+idx).split("_");
    string[] spleff;
    u16 gap = 64;

    GUI::SetFont("menu");
    if (spl.length > 0 && blob.get_u16("timer"+idx) > 0)
    {
        if (spl.length == 3) spleff = spl[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl[0])), 0, Vec2f(32, 32), Vec2f(scrwidth-48,32+(gap*(idx-1))), 0.5f);
    }

    Vec2f aimpos = blob.getAimPos();

    if (isMouseOverEffect(Vec2f(scrwidth-48, 32+(gap*(idx-1)))) && spl.length > 0)
    {
        if (spl.length > 1 && spl[0] != "") 
        {   
            GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer"+idx)/30, Vec2f(scrwidth-48-224, 32+(gap*(idx-1))), SColor(255, 255, 255, 255));
            if (spl[1] == "potion" && spleff.length > 0) 
            {
                if (spleff.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff[0]+"\n"+spleff[1]+"\n"+spleff[2], Vec2f(scrwidth-48-224, 128+(gap*(idx-1))), SColor(255, 235, 235, 0));
                else if (spleff.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff[0]+"\n"+spleff[1], Vec2f(scrwidth-48-224, 128+(gap*(idx-1))), SColor(255, 235, 235, 0));
                else GUI::DrawText("Subeffects:\n\n"+spleff[0], Vec2f(scrwidth-48-224, 128+(gap*(idx-1))), SColor(255, 235, 235, 0));
            }
            if (getEffectType(spl[0]) == true) GUI::DrawText(getEffectName(parseInt(spl[0])), Vec2f(scrwidth-48-174, 31+(gap*(idx-1))), SColor(255, 255, 50, 10));
            else GUI::DrawText(getEffectName(parseInt(spl[0])), Vec2f(scrwidth-48-174, 31+(gap*(idx-1))), SColor(255, 10, 255, 50));
        }
    }
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;

    for (u8 i = 1; i <= 20; i++)
    {
        if (blob.get_u16("timer"+i) <= 0) blob.set_string("eff"+i, "");
    }

    RenderIcons(this, blob, 1);
    RenderIcons(this, blob, 2);
    RenderIcons(this, blob, 3);
    RenderIcons(this, blob, 4);
    RenderIcons(this, blob, 5);
    RenderIcons(this, blob, 6);
    RenderIcons(this, blob, 7);
    RenderIcons(this, blob, 8);
    RenderIcons(this, blob, 9);
    RenderIcons(this, blob, 10);

}

bool isMouseOverEffect(Vec2f offset)
{
	Vec2f mousePos = getControls().getMouseScreenPos();
	Vec2f effectPos = offset;

    if (mousePos.x >= effectPos.x-8 && mousePos.x <= effectPos.x + 32+8
    && mousePos.y >= effectPos.y-8 && mousePos.y <= effectPos.y + 32+18) return true;
    else return false;
}