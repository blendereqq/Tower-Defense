#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <td>

#define ID_BURN (taskid - 1000)

#define type pev_iuser1

new g_SoundsGrenadeFire[] = "weapons/hegrenade-1.wav"
new g_SoundsBuyAmmo[] = "items/9mmclip1.wav"

new g_SpriteTrailSource[] = "sprites/laserbeam.spr"
new g_SpriteRingSource[] = "sprites/shockwave.spr"

new g_SpriteTrail
new g_SpriteExplode

new g_duration, Float:g_radius

new const szName[] = "Granat spowalniajcy"
new const szDesc[]  = "Granat spowalniajcy, czas trwania: 5 sekund"
new iPrice = 30;
new iOnePerMap = 0;

new iItem;

public plugin_precache(){
	engfunc(EngFunc_PrecacheSound, g_SoundsGrenadeFire)
	engfunc(EngFunc_PrecacheSound, g_SoundsBuyAmmo)

	g_SpriteTrail = engfunc(EngFunc_PrecacheModel, g_SpriteTrailSource)
	g_SpriteExplode = engfunc(EngFunc_PrecacheModel, g_SpriteRingSource)
}

public plugin_init(){
	new id = register_plugin("TD: SHOP| Napaln Nade", "1.0", "MeRcyLeZZ & edited by GT Team for TD")
	
	iItem = td_shop_register_item(szName, szDesc, iPrice, iOnePerMap, id)

	register_forward(FM_SetModel, "fw_SetModel")
	
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	RegisterHam(Ham_Touch, "info_target", "fw_TouchMonster")
}

public plugin_cfg()
	set_task(0.5, "loadConfig")


public loadConfig(){
	/* czas trwania oparze� */
	g_duration = 5

	/* zasi�g */
	g_radius = 305.0
}

public fw_SetModel(entity, const model[]){
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	if (dmgtime == 0.0)
		return FMRES_IGNORED;
	
	if (!equal(model[7], "w_sm", 4))
		return FMRES_IGNORED;
	
	static owner, napalm_weaponent
	owner = pev(entity, pev_owner)
	napalm_weaponent = fm_get_user_current_weapon_ent(owner)
	
	if (pev(napalm_weaponent, pev_flTimeStepSound) != 681856)
		return FMRES_IGNORED;
	fm_set_rendering(entity, kRenderFxGlowShell, 0, 50, 255, kRenderNormal, 16)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) 
	write_short(entity) 
	write_short(g_SpriteTrail) 
	write_byte(10) 
	write_byte(10) 
	write_byte(0) 
	write_byte(100) 
	write_byte(255) 
	write_byte(200)
	message_end()
	
	static napalm_ammo
	napalm_ammo = pev(napalm_weaponent, pev_flSwimTime)
	set_pev(napalm_weaponent, pev_flSwimTime, --napalm_ammo)
	set_pev(entity, type, 2)
	if (napalm_ammo < 1)
		set_pev(napalm_weaponent, pev_flTimeStepSound, 0)
	set_pev(entity, pev_flTimeStepSound, 681856)
	
	return FMRES_SUPERCEDE;
}

public fw_ThinkGrenade(entity){
	if (!pev_valid(entity)) 
		return HAM_IGNORED;
	if(pev(entity, type) != 2)
		return HAM_IGNORED
		
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	if (dmgtime > get_gametime())
		return HAM_IGNORED;
	
	if (pev(entity, pev_flTimeStepSound) != 681856)
		return HAM_IGNORED;

	napalm_explode(entity)

	engfunc(EngFunc_RemoveEntity, entity)
	return HAM_SUPERCEDE;
}

public fw_TouchMonster(self, other){
	if (!td_is_monster(other))
		return;
	
	if (!task_exists(self+1000) || task_exists(other+1000))
		return;
	
	static params[2]
	params[0] = g_duration * 2 
	params[1] = self	

	set_task(0.1, "burning_flame", other+1000, params, sizeof params)
}


public td_shop_item_selected(id, itemid)
{
	if(iItem == itemid)
	{
		static napalm_weaponent
		napalm_weaponent = fm_get_napalm_entity(id)
	
		if (napalm_weaponent != 0){
			static napalm_ammo
			napalm_ammo = pev(napalm_weaponent, pev_flSwimTime)
		
			set_pev(napalm_weaponent, pev_flSwimTime, ++napalm_ammo)
			
			set_pdata_int(id, 389, get_pdata_int(id, 389) + 1, 5)
			
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoPickup"), _, id)
			write_byte(12)
			write_byte(1) 
			message_end()
			
			engfunc(EngFunc_EmitSound, id, CHAN_ITEM, g_SoundsBuyAmmo, 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_pev(napalm_weaponent, pev_flTimeStepSound, 681856)
		}
		else {
			fm_give_item(id, "weapon_smokegrenade")
			napalm_weaponent = fm_get_napalm_entity(id)

			set_pev(napalm_weaponent, type, 2)
			set_pev(napalm_weaponent, pev_flTimeStepSound, 681856)
			set_pev(napalm_weaponent, pev_flSwimTime, 1)
		}
	}
}

napalm_explode(ent){
	
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	create_blast2(originF)
	
	engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, g_SoundsGrenadeFire, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static victim
	victim = 0
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, g_radius)) != 0){
		if (!td_is_monster(victim))
			continue
		set_task(0.1, "burning_flame", victim+1000)
	}
}

public burning_flame(taskid){
	if (!td_is_monster(ID_BURN) || pev(ID_BURN, pev_health) <= 0)
		return;
	
	fm_set_rendering(ID_BURN, kRenderFxGlowShell, 0, 100, 255, kRenderNormal, 16)
	td_set_monster_speed(ID_BURN, td_get_monster_speed(ID_BURN)-75)
	set_task(5.0, "end", taskid)
}

public end(taskid) {
	fm_set_rendering(ID_BURN, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0)
	td_set_monster_speed(ID_BURN, 0, 1)
}
	
create_blast2(const Float:originF[3]){
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_SpriteExplode) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_SpriteExplode) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_SpriteExplode) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16){
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}

stock fm_give_item(id, const item[]){
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF);
	set_pev(ent, pev_origin, originF);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);
	
	static save
	save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, id);
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent);
}

stock fm_find_ent_by_owner(entity, const classname[], owner){
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}
	return entity;
}

stock fm_get_napalm_entity(id)
	return fm_find_ent_by_owner(-1, "weapon_smokegrenade", id);

stock fm_get_user_current_weapon_ent(id)
	return get_pdata_cbase(id, 373, 5);

stock fm_get_weapon_ent_id(ent)
	return get_pdata_int(ent, 43, 4);

stock fm_get_weapon_ent_owner(ent)
	return get_pdata_cbase(ent, 41, 4);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
