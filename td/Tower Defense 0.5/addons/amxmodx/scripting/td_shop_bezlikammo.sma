/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <td>
#include <cstrike>
#include <engine>

#define PLUGIN "TD: Shop | Nieskonczona amunicja"
#define VERSION "1.0"
#define AUTHOR "tomcionek15 & grs4"

new const maxClip[31] = { -1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 };

new const szName[] = "Nieskonczona amunicja"
new const szDesc[]  = "Nieskonczona amunicja do kazdej broni"
new iPrice = 150;
new iOnePerMap = 1;

new iItem;
new gKupil[33]

public plugin_init() 
{
	new id = register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "CurWeapon", "be", "1=1")
	iItem = td_shop_register_item(szName, szDesc, iPrice, iOnePerMap, id)
}
public td_shop_item_selected(id, itemid)
	if(iItem == itemid)
		gKupil[id] = 1

public client_disconnect(id)
	gKupil[id] = 0
	
public CurWeapon(id)
{
	if(!is_user_alive(id) || !gKupil[id])
		return PLUGIN_CONTINUE
	
	new weaponID = read_data(2)
	
	if(weaponID==CSW_C4 || weaponID==CSW_KNIFE || weaponID==CSW_HEGRENADE || weaponID==CSW_SMOKEGRENADE || weaponID==CSW_FLASHBANG)
		return PLUGIN_CONTINUE
	
	set_user_weapon_clip(id, maxClip[weaponID])
	
	return PLUGIN_CONTINUE
}

set_user_weapon_clip(id, newammo, weapon = 0)
{
	new szWeapon[32], iWeapon = get_user_weapon(id);

	if(!weapon)    
	{
		if(!iWeapon)
			return 0;
		get_weaponname(get_user_weapon(id), szWeapon, 31);    
	}
	else        
		if(!get_weaponname(weapon, szWeapon, 31))
			return 0;    
	
	cs_set_weapon_ammo(find_ent_by_owner(0, szWeapon, id), newammo);
	return 1;
}
