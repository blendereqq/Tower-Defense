/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <td>
#include <cstrike>
#include <engine>
#include <colorchat>

#define PLUGIN "TD: Shop | Endless ammunition"
#define VERSION "1.0"
#define AUTHOR "tomcionek15 & grs4"

new const maxClip[31] = { -1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 };

new iItem;
new g_iWaveNums[33]

public plugin_init() 
{
	new id = register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "CurWeapon", "be", "1=1")
	iItem = td_shop_register_item("Unlimited Clip Ammo", "Unlimited Clip ammunition for all weapons for 2 waves", 250, 0, id)
}
public td_reset_player_info(iPlayer)
	g_iWaveNums[iPlayer] = 0;

public client_disconnected(iPlayer)
	g_iWaveNums[iPlayer] = 0;
	
public td_shop_item_selected(id, itemid)
{
	if(iItem == itemid)
	{
		g_iWaveNums[id] += 2;
		
		ColorChat(id, GREEN, "[TD]^x01 Unlimited Clip Ammo now will be enabled for %d waves!", g_iWaveNums[id]);
		
		SetOff(id + 54321);
	}
	return PLUGIN_CONTINUE;
}
public td_wave_ended(iEndedWave)
{
	for(new i = 1; i < 33 ; i++)
		if(g_iWaveNums[i] > 0)
			g_iWaveNums[i]--;
}
public SetOff(id)
{
	id -= 54321;
	
	if(g_iWaveNums[id] == 0)
	{
		set_hudmessage(200, 255, 0, 0.60, 0.84, 0, 0.1, 4.1, 0.1, 0.1, -1)
		show_hudmessage(id,"Unlimited Clip Ammo time down!")

		ColorChat(id, GREEN, "[TD]^x01 Unlimited ammo time down.");
		return;
	}
	set_hudmessage(200, 255, 0, 0.60, 0.84, 1, 0.1, 1.1, 0.1, 0.1, -1)
	show_hudmessage(id,"Unlimited Clip Ammo: %d %s left", g_iWaveNums[id], g_iWaveNums[id] == 1 ? "wave" : "waves")
	
	set_task(1.0, "SetOff", id + 54321);
}
	
public CurWeapon(id)
{
	if(!is_user_alive(id) || !g_iWaveNums[id])
		return PLUGIN_CONTINUE
	
	new weaponID = read_data(2)
	
	if(weaponID==CSW_C4 || weaponID==CSW_KNIFE || weaponID==CSW_HEGRENADE || weaponID==CSW_SMOKEGRENADE || weaponID==CSW_FLASHBANG)
		return PLUGIN_CONTINUE
	
	set_user_weapon_clip(id, maxClip[weaponID])
	
	return PLUGIN_CONTINUE
}

set_user_weapon_clip(id, newammo, weapon = 0)
{
	new szWeapon[32],iWeapon = get_user_weapon(id);

	if(!weapon)    
	{
		if(!iWeapon)
			return 0;
		get_weaponname(get_user_weapon(id), szWeapon, 31);    
	}
	else        
		if(!get_weaponname(weapon, szWeapon, 31))
			return 0;    
	
	cs_set_weapon_ammo(find_ent_by_owner(-1, szWeapon, id), newammo);
	return 1;
}
