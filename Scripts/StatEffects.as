#include "StatEffectsCommon.as";

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob !is null)
    {   // index_name_variable`variable`...
        blob.set_string("eff1", "");
        blob.set_string("eff2", "");
        blob.set_string("eff3", "");
        blob.set_string("eff4", "");
        blob.set_string("eff5", "");
    }
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    //printf(blob.get_string("eff1"));
    if (blob is null) return;
    u16 scrwidth = getDriver().getScreenWidth();
    u16 scrheight = getDriver().getScreenHeight();

    if (blob.get_u16("timer1") <= 0) blob.set_string("eff1", "");
    if (blob.get_u16("timer2") <= 0) blob.set_string("eff2", "");
    if (blob.get_u16("timer3") <= 0) blob.set_string("eff3", "");
    if (blob.get_u16("timer4") <= 0) blob.set_string("eff4", "");
    if (blob.get_u16("timer5") <= 0) blob.set_string("eff5", "");

    string[] spl1;
    string[] spl2;
    string[] spl3;
    string[] spl4;
    string[] spl5;

    if (blob.get_string("eff1") != "") spl1 = blob.get_string("eff1").split("_");
    if (blob.get_string("eff2") != "") spl2 = blob.get_string("eff2").split("_");
    if (blob.get_string("eff3") != "") spl3 = blob.get_string("eff3").split("_");
    if (blob.get_string("eff4") != "") spl4 = blob.get_string("eff4").split("_");
    if (blob.get_string("eff5") != "") spl5 = blob.get_string("eff5").split("_");

    string[] spleff1;
    string[] spleff2;
    string[] spleff3;
    string[] spleff4;
    string[] spleff5;

    u16 gap = 64;

    GUI::SetFont("menu");
    if (spl1.length > 0 && blob.get_u16("timer1") > 0)
    {
        if (spl1.length == 3) spleff1 = spl1[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl1[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32), 0.5f);
    }
    if (spl2.length > 0 && blob.get_u16("timer2") > 0) 
    {
        if (spl2.length == 3) spleff2 = spl2[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl2[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap), 0.5f);
    }
    if (spl3.length > 0 && blob.get_u16("timer3") > 0)
    {
        if (spl3.length == 3) spleff3 = spl3[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl3[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*2), 0.5f);
    }
    if (spl4.length > 0 && blob.get_u16("timer4") > 0)
    {
        if (spl4.length == 3) spleff4 = spl4[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl4[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*3), 0.5f);
    }
    if (spl5.length > 0 && blob.get_u16("timer5") > 0)
    {
        if (spl5.length == 3) spleff5 = spl5[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl5[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*4), 0.5f);
    }

    if (blob !is null)
    {
        Vec2f aimpos = blob.getAimPos();

        if (isMouseOverEffect(Vec2f(scrwidth-48, 32)) && spl1.length > 0)
        {
            if (spl1.length > 1 && spl1[0] != "") 
            {   
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl1[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer1")/30, Vec2f(scrwidth-48-224, 32), SColor(255, 255, 255, 255));
                if (spl1[1] == "potion" && spleff1.length > 0) 
                {
                    if (spleff1.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff1[0]+"\n"+spleff1[1]+"\n"+spleff1[2], Vec2f(scrwidth-48-224, 128), SColor(255, 235, 235, 0));
                    else if (spleff1.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff1[0]+"\n"+spleff1[1], Vec2f(scrwidth-48-224, 128), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff1[0], Vec2f(scrwidth-48-224, 128), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl1[0]) == true) GUI::DrawText(getEffectName(parseInt(spl1[0])), Vec2f(scrwidth-48-174, 31), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl1[0])), Vec2f(scrwidth-48-174, 31), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap)) && spl2.length > 0)
        {
            if (spl2.length > 1 && spl2[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl2[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer2")/30, Vec2f(scrwidth-48-224, 32+gap), SColor(255, 255, 255, 255));
                if (spl2[1] == "potion" && spleff2.length > 0) 
                {
                    if (spleff2.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff2[0]+"\n"+spleff2[1]+"\n"+spleff2[2], Vec2f(scrwidth-48-224, 128+gap), SColor(255, 235, 235, 0));
                    else if (spleff2.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff2[0]+"\n"+spleff2[1], Vec2f(scrwidth-48-224, 128+gap), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff2[0]+"\n"+spleff2[1]+"\n"+spleff2[2], Vec2f(scrwidth-48-224, 128+gap), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl2[0]) == true) GUI::DrawText(getEffectName(parseInt(spl2[0])), Vec2f(scrwidth-48-174, 31+gap), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl2[0])), Vec2f(scrwidth-48-174, 31+gap), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*2)) && spl3.length > 0)
        {
            if (spl3.length > 1 && spl3[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl3[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer3")/30, Vec2f(scrwidth-48-224, 32+gap*2), SColor(255, 255, 255, 255));
                if (spl3[1] == "potion" && spleff3.length > 0) 
                {
                    if (spleff3.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff3[0]+"\n"+spleff3[1]+"\n"+spleff3[2], Vec2f(scrwidth-48-224, 128+gap*2), SColor(255, 235, 235, 0));
                    else if (spleff3.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff3[0]+"\n"+spleff3[1], Vec2f(scrwidth-48-224, 128+gap*2), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff3[0], Vec2f(scrwidth-48-224, 128+gap*2), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl3[0]) == true) GUI::DrawText(getEffectName(parseInt(spl3[0])), Vec2f(scrwidth-48-174, 31+gap*2), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl3[0])), Vec2f(scrwidth-48-174, 31+gap*2), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*3)) && spl4.length > 0)
        {
            if (spl4.length > 1 && spl4[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl4[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer4")/30, Vec2f(scrwidth-48-224, 32+gap*3), SColor(255, 255, 255, 255));
                if (spl4[1] == "potion" && spleff4.length > 0) 
                {
                    if (spleff4.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff2[0]+"\n"+spleff4[1]+"\n"+spleff4[2], Vec2f(scrwidth-48-224, 128+gap*3), SColor(255, 235, 235, 0));
                    else if (spleff4.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff2[0]+"\n"+spleff4[1], Vec2f(scrwidth-48-224, 128+gap*3), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff2[0], Vec2f(scrwidth-48-224, 128+gap*3), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl4[0]) == true) GUI::DrawText(getEffectName(parseInt(spl4[0])), Vec2f(scrwidth-48-174, 31+gap*3), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl4[0])), Vec2f(scrwidth-48-174, 31+gap*3), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*4)) && spl5.length > 0)
        {
            if (spl5.length > 1 && spl5[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl5[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer5")/30, Vec2f(scrwidth-48-224, 32+gap*4), SColor(255, 255, 255, 255));
                if (spl5[1] == "potion" && spleff5.length > 0) 
                {
                    if (spleff5.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff5[0]+"\n"+spleff5[1]+"\n"+spleff5[2], Vec2f(scrwidth-48-224, 128+gap*4), SColor(255, 235, 235, 0));
                    else if (spleff5.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff5[0]+"\n"+spleff5[1], Vec2f(scrwidth-48-224, 128+gap*4), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff5[0], Vec2f(scrwidth-48-224, 128+gap*4), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl5[0]) == true) GUI::DrawText(getEffectName(parseInt(spl5[0])), Vec2f(scrwidth-48-174, 31+gap*4), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl5[0])), Vec2f(scrwidth-48-174, 31+gap*4), SColor(255, 10, 255, 50));
            }
        }
    }
}

bool isMouseOverEffect(Vec2f offset)
{
	Vec2f mousePos = getControls().getMouseScreenPos();
	Vec2f effectPos = offset;

    if (mousePos.x >= effectPos.x-16 && mousePos.x <= effectPos.x + 32+16
    && mousePos.y >= effectPos.y-24 && mousePos.y <= effectPos.y + 32+16) return true;
    else return false;
}