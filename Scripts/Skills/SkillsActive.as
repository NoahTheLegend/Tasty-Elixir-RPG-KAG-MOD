string skill_name;
bool has_animation;
bool has_animation_attack;

void DefineSkill(string name, bool anim, bool atkanim)
{
    if (name == "") return;
    skill_name = name;
    has_animation = anim;
    has_animation_attack = atkanim;
}

