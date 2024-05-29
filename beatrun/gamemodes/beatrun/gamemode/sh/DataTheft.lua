if SERVER then
	util.AddNetworkString("DataTheft_Start")
	util.AddNetworkString("DataTheft_Sync")

	function Beatrun_StartDataTheft()
		SetGlobalBool("GM_DATATHEFT", true)

		net.Start("DataTheft_Start")
		net.Broadcast()

		for _, v in ipairs(player.GetAll()) do
			v:DataTheft_Bank()

			v:SetNW2Int("DataCubes", 0)
			v:SetNW2Int("DataBanked", 0)
			
			if v:GetMoveType() == MOVETYPE_NOCLIP then
				v:SetMoveType(MOVETYPE_WALK)
				v:Spawn()
			end

			if GetConVar("Beatrun_RandomMWLoadouts"):GetBool() then
				for i = 0, 1 do
					local randomSWEP = getRandomMGBaseWeapon()
					local w = v:Give(randomSWEP.ClassName)

					timer.Simple(1, function()
						if w:GetPrimaryAmmoType() ~= -1 then v:GiveAmmo(10000, w:GetPrimaryAmmoType(), true) end
						if w:GetSecondaryAmmoType() ~= -1 then v:GiveAmmo(5, w:GetSecondaryAmmoType(), true) end
					end)
				end
			else
				for _, b in ipairs(BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)]) do
					local w = v:Give(b)

					timer.Simple(1, function()
						if w:GetPrimaryAmmoType() ~= -1 then v:GiveAmmo(10000, w:GetPrimaryAmmoType(), true) end
						if w:GetSecondaryAmmoType() ~= -1 then v:GiveAmmo(5, w:GetSecondaryAmmoType(), true) end
					end)
				end
			end
		end
	end

	function Beatrun_StopDataTheft()
		SetGlobalBool("GM_DATATHEFT", false)

		for _, v in ipairs(player.GetAll()) do
			v:SetNW2Int("DataCubes", 0)

			v:StripWeapons()
			v:StripAmmo()
			v:Give("runnerhands")
		end
	end

	local function DataTheftSync(ply)
		if GetGlobalBool("GM_DATATHEFT") and not ply.DataTheftSynced then
			net.Start("DataTheft_Sync")
			net.Send(ply)

			ply.DataTheftSynced = true
		end
	end

	hook.Add("PlayerSpawn", "DataTheftSync", DataTheftSync)

	local function DataTheftDeath(ply, inflictor, attacker)
		if GetGlobalBool("GM_DATATHEFT") then
			local datacount = ply:GetNW2Int("DataCubes", 0)

			if datacount > 0 then
				local pos = ply:GetPos() + Vector(0, 0, 32)

				for i = 1, datacount + 1 do
					local datacube = ents.Create("br_datacube")

					datacube:SetPos(pos)
					datacube:Spawn()
				end

				ply:SetNW2Int("DataCubes", 0)
			elseif IsValid(attacker) and attacker ~= ply then
				local pos = ply:GetPos() + Vector(0, 0, 32)
				local datacube = ents.Create("br_datacube")

				datacube:SetPos(pos)
				datacube:Spawn()
			end
		end
	end

	hook.Add("PlayerDeath", "DataTheftDeath", DataTheftDeath)
end

if CLIENT then
	local function DataTheftHUDName()
		if GetGlobalBool("GM_DATATHEFT") then
			local datacubes = LocalPlayer():GetNW2Int("DataCubes", 0)

			return language.GetPhrase("beatrun.datatheft.name"):format(datacubes)
		else
			hook.Remove("BeatrunHUDCourse", "DataTheftHUDName")
		end
	end

	net.Receive("DataTheft_Sync", function()
		hook.Add("BeatrunHUDCourse", "DataTheftHUDName", DataTheftHUDName)
	end)

	net.Receive("DataTheft_Start", function()
		hook.Add("BeatrunHUDCourse", "DataTheftHUDName", DataTheftHUDName)
		chat.AddText(Color(200, 200, 200), language.GetPhrase("beatrun.datatheft.start"))
	end)
end
