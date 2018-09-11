/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <td>
#include <fakemeta>
#include <colorchat>

#define PLUGIN "TD: Shop | No recoil"
#define VERSION "1.0"
#define AUTHOR "tomcionek15 & grs4"

new iItem;
new g_iWaveNums[33]

public plugin_init()  {
	new id = register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
	
	iItem = td_shop_register_item("No recoil", "No recoil for all weapons for 2 waves", 250, 0, id)
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
		
		ColorChat(id, GREEN, "[TD]^x01 No recoil now will be enabled for %d waves!", g_iWaveNums[id]);
		
		SetOff(id + 54222);
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
	id -= 54222;
	
	if(g_iWaveNums[id] == 0)
	{
		set_hudmessage(200, 255, 0, 0.60, 0.69, 0, 0.1, 4.1, 0.1, 0.1, -1)
		show_hudmessage(id,"No recoil Ammo time down!")

		ColorChat(id, GREEN, "[TD]^x01 No recoil time down.");
		return;
	}
	set_hudmessage(200, 255, 0, 0.60, 0.69, 1, 0.1, 1.1, 0.1, 0.1, -1)
	show_hudmessage(id,"No recoil: %d %s left", g_iWaveNums[id], g_iWaveNums[id] == 1 ? "wave" : "waves")
	
	set_task(1.0, "SetOff", id + 54222);
}

public PreThink(id)
	if(g_iWaveNums[id])
		set_pev(id, pev_punchangle, {0.0,0.0,0.0})

public UpdateClientData(id, sw, cd_handle)
	if(g_iWaveNums[id])
		set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})
