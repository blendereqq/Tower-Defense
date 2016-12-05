/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <td>

#define PLUGIN "TD: Class | Sniper"
#define VERSION "1.0"
#define AUTHOR "tomcionek15 & grs4"

new const szClassName[] = "Snajper"
new const szClassDesc[] = "Z kazdej broni z luneta zadajesz 1.5x wiecej obrazen. Jestes 5%% szybszy."

new iItem;
new bool:g_ClassEnabled[33];

public plugin_init() 
{
	new id = register_plugin(PLUGIN, VERSION, AUTHOR)
	
	iItem = td_register_class(szClassName, szClassDesc, id)
}
public td_class_selected(id, classid)
{
	if(iItem == classid)
	{
		g_ClassEnabled[id] = true;
		td_set_user_info(id, PLAYER_EXTRA_SPEED, (td_get_user_info(id, PLAYER_EXTRA_SPEED) + 13))
	}
}

public td_class_disabled(id, classid) {
	if(iItem == classid)
	{
		g_ClassEnabled[id] = false;
		td_set_user_info(id, PLAYER_EXTRA_SPEED, (td_get_user_info(id, PLAYER_EXTRA_SPEED) - 13))
	}
}

public td_take_damage(id, ent, iWeapon, Float:damage, szData[2]) {
	
	if((iWeapon == CSW_AWP || iWeapon == CSW_SG550 || iWeapon == CSW_AUG || iWeapon == CSW_SG552 || iWeapon == CSW_SCOUT) && g_ClassEnabled[id]) {
		damage *= 1.5
		szData[0] = floatround(damage)
	}
}
