/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Dynamic Crime System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

	* Copyright (c) 2014, Next Generation Gaming, LLC
	*
	* All rights reserved.
	*
	* Redistribution and use in source and binary forms, with or without modification,
	* are not permitted in any case.
	*
	*
	* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <YSI\y_hooks>

#define DIALOG_SHOW_CRIMES		(6530)
#define DIALOG_EDIT_CRIMES 	  	(6531)
#define DIALOG_CRIMES_LIST		(6532)
#define DIALOG_CRIMES_EDIT		(6533)
#define DIALOG_CRIMES_TYPE		(6534)
#define DIALOG_CRIMES_NATION	(6535)
#define DIALOG_CRIMES_NAME		(6536)
#define DIALOG_CRIMES_TIME		(6537)
#define DIALOG_CRIMES_FINE		(6538)


#define MAX_CRIMES				100

forward OnCrimesLoad();
forward LoadCrimes();
// Dynamic Charges
enum eCrimeDatum {
	c_iID, // SQL ID
	c_iType, // how many stars the crime will give
	c_iNation, // Nation, 0 = SA, 1 = TR
	c_szName[32], // Obvious as fuck, you're not Tony Duquesne.
	c_iJTime, // Jail Time
	c_iJFine, // Fine
	c_iBail
}
new arrCrimeData[MAX_CRIMES][eCrimeDatum];

public LoadCrimes()
{
	mysql_function_query(MainPipeline, "SELECT * FROM `crimesdata`", true, "OnCrimesLoad", "");
	print("[LoadCrimes] Loading Crimes...");
}

public OnCrimesLoad()
{

	szMiscArray[0] = 0;
	new rows = cache_get_row_count(MainPipeline);

	for(new i = 0; i < rows; i++)
	{
		arrCrimeData[i][c_iID] = cache_get_field_content_int(i, "id", MainPipeline);
		arrCrimeData[i][c_iType] = cache_get_field_content_int(i, "type", MainPipeline);
		arrCrimeData[i][c_iNation] = cache_get_field_content_int(i, "nation", MainPipeline); 
		cache_get_field_content(i, "name", arrCrimeData[i][c_szName], MainPipeline, 32);
		arrCrimeData[i][c_iJTime] = cache_get_field_content_int(i, "jailtime", MainPipeline); 
		arrCrimeData[i][c_iJFine] = cache_get_field_content_int(i, "fine", MainPipeline); 
		arrCrimeData[i][c_iBail] = cache_get_field_content_int(i, "bail", MainPipeline); 


	}
	print("Crime Data Loaded.");
}

stock SaveCrimes()
{
	for(new i = 0; i < MAX_CRIMES; i++)
	{
		SaveCrime(i);
	}
}

stock SaveCrime(id)
{
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "UPDATE `crimesdata` SET  \
	`type` = '%i', \
	`nation` = '%i', \
	`name` = '%s', \
	`jailtime` = '%i', \
	`fine` = '%i', \
	`bail` = '%i' \
	WHERE `id` = '%i'",
	arrCrimeData[id][c_iType],
	arrCrimeData[id][c_iNation],
	g_mysql_ReturnEscaped(arrCrimeData[id][c_szName], MainPipeline),
	arrCrimeData[id][c_iJTime],
	arrCrimeData[id][c_iJFine],
	arrCrimeData[id][c_iBail],
	arrCrimeData[id][c_iID]);
	mysql_function_query(MainPipeline, szMiscArray, false, "OnQueryFinish", "i", SENDDATA_THREAD);

}

stock ShowCrimesDialog(iPlayerID, iSuspectID = INVALID_PLAYER_ID, iDialogID = DIALOG_SHOW_CRIMES)
{
	szMiscArray[0] = 0;
	switch(iDialogID)
	{
		case DIALOG_SHOW_CRIMES:
		{
			format(szMiscArray, sizeof(szMiscArray), "----Misdemeanors----\n");
			for(new i = 0; i < MAX_CRIMES; i++)
			{
				if(arrCrimeData[i][c_iNation] == arrGroupData[PlayerInfo[iPlayerID][pMember]][g_iAllegiance])
				if(arrCrimeData[i][c_iType] == 1)
				{
					format(szMiscArray, sizeof(szMiscArray), "%s{FFFF00}%i-%s\n", szMiscArray, arrCrimeData[i][c_iID], arrCrimeData[i][c_szName]);
				}
			}
			format(szMiscArray, sizeof(szMiscArray), "%s----Felonies----\n", szMiscArray);
			for(new i = 0; i < MAX_CRIMES; i++)
			{
				if(arrCrimeData[i][c_iNation] == arrGroupData[PlayerInfo[iPlayerID][pMember]][g_iAllegiance])
				if(arrCrimeData[i][c_iType] == 2)
				{
					format(szMiscArray, sizeof(szMiscArray), "%s{AA3333}%i-%s\n", szMiscArray, arrCrimeData[i][c_iID], arrCrimeData[i][c_szName]);
				}
			}
			SetPVarInt(iPlayerID, "suspect_TargetID", iSuspectID);
			ShowPlayerDialog(iPlayerID, iDialogID, DIALOG_STYLE_LIST, "Select a committed crime", szMiscArray, "Select", "Exit");
		}
		case DIALOG_EDIT_CRIMES:
		{
			ShowPlayerDialog(iPlayerID, iDialogID, DIALOG_STYLE_LIST, "Select a Nation.", "SA\nTR", "Select", "Exit");
		}

	}
	return 1;
}


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	szMiscArray[0] = 0;
	switch(dialogid)
	{
		case DIALOG_SHOW_CRIMES:
		{
			if(response)
			{
				new id, name[32];
				
				if(sscanf(inputtext, "p<->is[32]", id, name)) return 1;
				for(new i = 0; i < MAX_CRIMES; i++)
				{
					if(arrCrimeData[i][c_iNation] == arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance])
					{
						
						if(arrCrimeData[i][c_iID] == id)
						{
							new iTargetID = GetPVarInt(playerid, "suspect_TargetID");
							if(strlen(inputtext) <= 3)
							{
								return ShowCrimesDialog(playerid, iTargetID);
							}
							if(inputtext[0] == '-')
							{
								return ShowCrimesDialog(playerid, iTargetID);
							}


							++PlayerInfo[iTargetID][pCrimes];
						
							
							
							PlayerInfo[iTargetID][pWantedLevel] += arrCrimeData[i][c_iType];
							
							
							if(PlayerInfo[iTargetID][pWantedLevel] > 6)
							{
								PlayerInfo[iTargetID][pWantedLevel] = 6;
							}
							SetPlayerWantedLevel(iTargetID, PlayerInfo[iTargetID][pWantedLevel]);
							if(PlayerInfo[iTargetID][pConnectHours] < 32)
							{
								PlayerInfo[iTargetID][pWantedJailTime] += arrCrimeData[i][c_iJTime]/10;
								PlayerInfo[iTargetID][pWantedJailFine] += arrCrimeData[i][c_iJFine]/10;
							}
							else
							{
								PlayerInfo[iTargetID][pWantedJailTime] += arrCrimeData[i][c_iJTime];
								PlayerInfo[iTargetID][pWantedJailFine] += arrCrimeData[i][c_iJFine];
							}
							new szCountry[10], szCrime[128];
							if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 1)
							{
								format(szCountry, sizeof(szCountry), "[SA] ");
							}
							else if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 2)
							{
								format(szCountry, sizeof(szCountry), "[TR] ");
							}
							strcat(szCrime, szCountry);
							strcat(szCrime, arrCrimeData[i][c_szName]);
							AddCrime(playerid, iTargetID, szCrime);

							format(szMiscArray, sizeof(szMiscArray), "You've commited a crime ( %s ). Reporter: %s.", szCrime, GetPlayerNameEx(playerid));
							SendClientMessageEx(iTargetID, COLOR_LIGHTRED, szMiscArray);

							format(szMiscArray, sizeof(szMiscArray), "Current wanted level: %d", PlayerInfo[iTargetID][pWantedLevel]);
							SendClientMessageEx(iTargetID, COLOR_YELLOW, szMiscArray);

							foreach(new p: Player)
							{
								if(IsACop(p) && arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == arrGroupData[PlayerInfo[p][pMember]][g_iAllegiance]) {
									format(szMiscArray, sizeof(szMiscArray), "HQ: All units APB (reporter: %s)",GetPlayerNameEx(playerid));
									SendClientMessageEx(p, TEAM_BLUE_COLOR, szMiscArray);
									format(szMiscArray, sizeof(szMiscArray), "HQ: Crime: %s, suspect: %s", szCrime, GetPlayerNameEx(iTargetID));
									SendClientMessageEx(p, TEAM_BLUE_COLOR, szMiscArray);
								}
							}
							PlayerInfo[iTargetID][pDefendTime] = 60;
						}
					}
				}
			}
			else
			{
				return 1;
			}
		}
		case DIALOG_EDIT_CRIMES:
		{
			if(!response) return 1;
			for(new i = 0; i < MAX_CRIMES; i++)
			{
				if(arrCrimeData[i][c_iNation] == (listitem+1))
				{
					
					format(szMiscArray, sizeof(szMiscArray), "%s\n%i-%s", szMiscArray, arrCrimeData[i][c_iID], arrCrimeData[i][c_szName]);
				}
			}
			
			ShowPlayerDialog(playerid, DIALOG_CRIMES_LIST, DIALOG_STYLE_LIST, "Select a crime to edit.", szMiscArray, "Select", "Exit");
		}
		case DIALOG_CRIMES_LIST:
		{
			if(!response) return 1;
			szMiscArray[0] = 0;
			new id, name[32];
			sscanf(inputtext, "p<->is[32]", id, name);
			SetPVarInt(playerid, "iEditCrime", id);
			format(szMiscArray, sizeof(szMiscArray), "{80FF00}%s", name);
			ShowPlayerDialog(playerid, DIALOG_CRIMES_EDIT, DIALOG_STYLE_LIST, szMiscArray, "Edit Type\nEdit Name\nEdit Time\nEdit Fine", "Select", "Cancel");
		
		}
		case DIALOG_CRIMES_EDIT:
		{
			if(!response) return 1;
			szMiscArray[0] = 0;
			new iEditCrime = GetPVarInt(playerid, "iEditCrime");
			iEditCrime = iEditCrime-1;
			switch(listitem)
			{
				case 0:
				{
					format(szMiscArray, sizeof(szMiscArray), "{80FF00}%s - {FF0000}EDIT TYPE", arrCrimeData[iEditCrime][c_szName]);
					ShowPlayerDialog(playerid, DIALOG_CRIMES_TYPE, DIALOG_STYLE_LIST, szMiscArray, "Misdemeanor\nFelony", "Select", "Cancel");
				}
				/*
				case 1:
				{
					format(szMiscArray, sizeof(szMiscArray), "{80FF00}%s - {FF0000}EDIT NATION", arrCrimeData[iEditCrime][c_szName]);
					ShowPlayerDialog(playerid, DIALOG_CRIMES_NATION, DIALOG_STYLE_LIST, szMiscArray, "San Andreas\nTierra Robada", "Select", "Cancel");
				}*/
				case 1:
				{
					format(szMiscArray, sizeof(szMiscArray), "{80FF00}%s - {FF0000}EDIT NAME", arrCrimeData[iEditCrime][c_szName]);
					ShowPlayerDialog(playerid, DIALOG_CRIMES_NAME, DIALOG_STYLE_INPUT, szMiscArray, "Please input a new name for the crime.", "Select", "Cancel");
				}
				case 2:
				{
					format(szMiscArray, sizeof(szMiscArray), "{80FF00}%s - {FF0000}EDIT TIME", arrCrimeData[iEditCrime][c_szName]);
					ShowPlayerDialog(playerid, DIALOG_CRIMES_TIME, DIALOG_STYLE_INPUT, szMiscArray, "Please input a new time for the crime.", "Select", "Cancel");
				}
				case 3:
				{
					format(szMiscArray, sizeof(szMiscArray), "{80FF00}%s - {FF0000}EDIT FINE", arrCrimeData[iEditCrime][c_szName]);
					ShowPlayerDialog(playerid, DIALOG_CRIMES_FINE, DIALOG_STYLE_INPUT, szMiscArray, "Please input a new fine for the crime.", "Select", "Cancel");
				}
			}
		}
		case DIALOG_CRIMES_TYPE:
		{
			if(!response) return 1;
			new iEditCrime = GetPVarInt(playerid, "iEditCrime");
			iEditCrime = iEditCrime-1;

			arrCrimeData[iEditCrime][c_iType] = listitem+1;
			
			szMiscArray[0] = 0;
			format(szMiscArray, sizeof(szMiscArray), "You have set %s's type to %s", arrCrimeData[iEditCrime][c_szName], inputtext);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMiscArray);
			SaveCrime(iEditCrime);
		}
		case DIALOG_CRIMES_NATION:
		{
			if(!response) return 1;
			new iEditCrime = GetPVarInt(playerid, "iEditCrime");
			iEditCrime = iEditCrime-1;

			arrCrimeData[iEditCrime][c_iNation] = listitem+1;
			
			szMiscArray[0] = 0;
			format(szMiscArray, sizeof(szMiscArray), "You have set %s's nation to %s", arrCrimeData[iEditCrime][c_szName], inputtext);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMiscArray);
			SaveCrime(iEditCrime);
		}
		case DIALOG_CRIMES_NAME:
		{
			if(!response) return 1;
			new iEditCrime = GetPVarInt(playerid, "iEditCrime");
			iEditCrime = iEditCrime-1;
			new oldName[32];
			format(oldName, sizeof(oldName), "%s", arrCrimeData[iEditCrime][c_szName]);
			format(arrCrimeData[iEditCrime][c_szName], 32, "%s", inputtext);
		
			
			szMiscArray[0] = 0;
			format(szMiscArray, sizeof(szMiscArray), "You updated crime %s's name to %s", oldName, inputtext);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMiscArray);
			SaveCrime(iEditCrime);
		}
		case DIALOG_CRIMES_TIME:
		{
			if(!response) return 1;
			new iEditCrime = GetPVarInt(playerid, "iEditCrime");
			iEditCrime = iEditCrime-1;
			if(strval(inputtext) < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Please input a time above 0 minutes.");
			arrCrimeData[iEditCrime][c_iJTime] = strval(inputtext);
			
			
			szMiscArray[0] = 0;
			format(szMiscArray, sizeof(szMiscArray), "You updated crime %s's time to %i minutes", arrCrimeData[iEditCrime][c_szName], strval(inputtext));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMiscArray);
			SaveCrime(iEditCrime);
		}
		case DIALOG_CRIMES_FINE:
		{
			if(!response) return 1;
			new iEditCrime = GetPVarInt(playerid, "iEditCrime");
			iEditCrime = iEditCrime-1;
			if(strval(inputtext) < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Please input a fine above $0.");

			arrCrimeData[iEditCrime][c_iJFine] = strval(inputtext);
		
			
			szMiscArray[0] = 0;
			format(szMiscArray, sizeof(szMiscArray), "You updated crime %s's fine to $%i dollars", arrCrimeData[iEditCrime][c_szName], strval(inputtext));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMiscArray);
			SaveCrime(iEditCrime);
		}
	}
	return 1;
}

CMD:clist(playerid, params[])
{
	return cmd_crimelist(playerid, params);

}
CMD:crimelist(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_WHITE, "SERVER: You are not authorized to use this command.");
	ShowCrimesDialog(playerid, 0, DIALOG_EDIT_CRIMES);
	return 1;
}
CMD:su(playerid, params[]) {
	if(IsACop(playerid)) {
		if(PlayerInfo[playerid][pJailTime] > 0) {
			return SendClientMessageEx(playerid, COLOR_WHITE, "You cannot use this in jail/prison.");
		}

		new
			iTargetID;

		if(sscanf(params, "u", iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "USAGE: (/su)spect [player]");
		}
		else if(!IsPlayerConnected(iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GRAD1, "Invalid player specified.");
		}
		else if(IsACop(iTargetID) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == arrGroupData[PlayerInfo[iTargetID][pMember]][g_iAllegiance])) {
			SendClientMessageEx(playerid, COLOR_GREY, "You can't use this command on a law enforcement officer.");
		}
		else if(PlayerInfo[iTargetID][pWantedLevel] >= 6) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Target is already most wanted.");
		}
		else {
		    ShowCrimesDialog(playerid, iTargetID);
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "You're not a law enforcement officer.");
	return 1;
}
