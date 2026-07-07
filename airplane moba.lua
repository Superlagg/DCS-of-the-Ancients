-- Name: Really cool airplane moba thing
-- Author: dank elly
-- Date Created: last tuesday
--
-- # Situation:
--
-- airplane moba
-- blorit air base vs ray romano air base
-- ground groups spawn at 3 points in the teams goal zone, and move to the other teams goal zone
-- - they spawn every like 30 minutes, and go thru a chain of waypoints
-- - cus like thats the only way those things will actually fight each other lol
-- ai planes spawn around the goal, or at the air place, idk fenny o
-- 


-- tables
-- -------------
-- red team
-- red goal zone, closest to the red base with the intel
RedGoalTable = { 
	ZONE:New( "RedNorthRearLines" ),
	ZONE:New( "RedCenterRearLines" ),
	ZONE:New( "RedSouthRearLines" )
}
-- red frontline zone, right before the nut zone
RedFrontlineTable = { 
	ZONE:New( "RedNorthZone" ),
	ZONE:New( "RedCenterZone" ),
	ZONE:New( "RedSouthZone" ),
}
-- ground unit spawn zones
RedSpawnTable = { 
	ZONE:New( "RedNorthSpawn" ),
	ZONE:New( "RedCenterSpawn" ),
	ZONE:New( "RedSouthSpawn" )
}
-- ground unit attack zones, where the ground units will buttrush
-- used by blu team who passed nut zone
RedAttackZoneTable = { 
	ZONE:New( "RedNorthAttackZone" ),
	ZONE:New( "RedCenterAttackZone" ),
	ZONE:New( "RedSouthAttackZone" )
}
-- nut team
NeutralMiddleTable = { 
	ZONE:New( "NeutralNorthZone" ),
	ZONE:New( "NeutralCenterZone" ),
	ZONE:New( "NeutralSouthZone" )
}
NeutralAttackZoneTable = { 
	ZONE:New( "NeutralNorthAttackZone" ),
	ZONE:New( "NeutralCenterAttackZone" ),
	ZONE:New( "NeutralSouthAttackZone" )
}
-- blu team
BluGoalTable = { 
	ZONE:New( "BluNorthRearLines" ),
	ZONE:New( "BluCenterRearLines" ),
	ZONE:New( "BluSouthRearLines" )
}
BluFrontlineTable = { 
	ZONE:New( "BluNorthZone" ),
	ZONE:New( "BluCenterZone" ),
	ZONE:New( "BluSouthZone" )
}
BluSpawnTable = { 
	ZONE:New( "BluNorthSpawn" ),
	ZONE:New( "BluCenterSpawn" ),
	ZONE:New( "BluSouthSpawn" )
}
BluAttackZoneTable = { 
	ZONE:New( "BluNorthAttackZone" ),
	ZONE:New( "BluCenterAttackZone" ),
	ZONE:New( "BluSouthAttackZone" )
}

-- ground chain
-- red: red attack zone -> neutral attack zone -> blu attack zone
-- blu: blu attack zone -> neutral attack zone -> red attack zone

-- defines cus i dont like strings cus my spelling is awful cus i dont know how to read im illiterate
local NORTH = "North"
local CENTER = "Center"
local SOUTH = "South"

local REDTEAM = "Red"
local BLUTEAM = "Blu"
local NEUTRALTEAM = "Neutral"

local PATROLTARGET = "PatrolTarget"
local PUSHERTARGET = "PusherTarget"
local PLANESPAWNZONE = "PlaneSpawnZone"
local GROUNDSPAWNZONE = "GroundSpawnZone"

local PATROLLER = "Patroller"
local PUSHER = "Pusher"
local PLANES = "Planes"
local MAXPLANES = "MaxPlanes"

local function index2position(index)
	if index == 1 then
		return NORTH
	elseif index == 2 then
		return CENTER
	elseif index == 3 then
		return SOUTH
	end
	return NORTH
end

local function position2index(position)
	if position == NORTH then
		return 1
	elseif position == CENTER then
		return 2
	elseif position == SOUTH then
		return 3
	end
	return 1
end

-- fight waypoint chain getters, param: team, north/south/center
local function getAttackZoneChain(team, position)
	OutputChain = {BluAttackZoneTable[2], NeutralAttackZoneTable[2], RedAttackZoneTable[2]}
	if team == REDTEAM then
		if position == NORTH then
			OutputChain = {RedAttackZoneTable[1], NeutralAttackZoneTable[1], BluAttackZoneTable[1]}
		elseif position == CENTER then
			OutputChain = {RedAttackZoneTable[2], NeutralAttackZoneTable[2], BluAttackZoneTable[2]}
		elseif position == SOUTH then
			OutputChain = {RedAttackZoneTable[3], NeutralAttackZoneTable[3], BluAttackZoneTable[3]}
		end
	elseif team == BLUTEAM then
		if position == NORTH then
			OutputChain = {BluAttackZoneTable[1], NeutralAttackZoneTable[1], RedAttackZoneTable[1]}
		elseif position == CENTER then
			OutputChain = {BluAttackZoneTable[2], NeutralAttackZoneTable[2], RedAttackZoneTable[2]}
		elseif position == SOUTH then
			OutputChain = {BluAttackZoneTable[3], NeutralAttackZoneTable[3], RedAttackZoneTable[3]}
		end
	return OutputChain
	end
end

-- master index table, multidimensional, handles spawn index, zone index for patrollers and pushers, and other stuff, for each team!
local MasterIndexTable = {
	[REDTEAM] = {
		[PATROLTARGET] = 1,
		[PUSHERTARGET] = 1,
		[PLANESPAWNZONE] = 1,
		[GROUNDSPAWNZONE] = 1,
		[PLANETYPE] = 1,
	},
	[BLUTEAM] = {
		[PATROLTARGET] = 1,
		[PUSHERTARGET] = 1,
		[PLANESPAWNZONE] = 1,
		[GROUNDSPAWNZONE] = 1,
		[PLANETYPE] = 1, -- handled by a different function, but still needs to be here for the sake of the getPorperOutput function
	}
}

-- returns a zone using Skeb-Porper algorithm
local function getPorperOutput(team, kind)
	local index = MasterIndexTable[team][kind]
	local masterIndexTable[team][kind] = index + 1
	if masterIndexTable[team][kind] > 3 then
		masterIndexTable[team][kind] = 1
	end
	-- now get the proper zone table
	local tableToUse = {}
	-- zone where planes spawn
	if kind == PLANESPAWNZONE then
		if team == REDTEAM then
			tableToUse = RedGoalTable
		elseif team == BLUTEAM then
			tableToUse = BluGoalTable
		end
	-- zone where patrollers target
	elseif kind == PATROLTARGET then
		if team == REDTEAM then
			tableToUse = RedFrontlineTable
		elseif team == BLUTEAM then
			tableToUse = BluFrontlineTable
		end
	-- zone where pushers target
	elseif kind == PUSHERTARGET then
		tableToUse = NeutralMiddleTable
	end
	-- zone where ground units spawn
	if kind == GROUNDSPAWNZONE then
		if team == REDTEAM then
			tableToUse = RedSpawnTable
		elseif team == BLUTEAM then
			tableToUse = BluSpawnTable
		end
	end
	-- if no table was found, return, idk, red spawn index 1, i guess
	if #tableToUse == 0 then
		return RedSpawnTable[1]
	end
	-- if length of table is less than index, reset index to 1
	if #tableToUse < index then
		masterIndexTable[team][kind] = 1
		index = 1
	end
	return tableToUse[index]
end


----------------------- GRUND UNIT STUFF

-- todoL this

---------`------------ AIRPLANE STUFF
---- SPAWN TEMPLATES
SpawnMig21BS = SPAWN
	:New( "Mig-21BS" )
	:InitKeepUnitNames()
	:InitLimit( 10 , 20 )
	:SpawnScheduled( 5, .5 )

SpawnMirageF1CE = SPAWN
	:New( "Mirage-F1CE" )
	:InitKeepUnitNames()
	:InitLimit( 10 , 20 )
	:SpawnScheduled( 5, .5 )

-- gamerules which is kinda like a config but more esoteric and less user friendly, but makes me feel like a better coder

local GameRules = {
	[MAXPLANES] = {
		[PATROLLER] = {
			[REDTEAM] = 10,
			[BLUTEAM] = 10,
		},
		[PUSHER] = {
			[REDTEAM] = 10,
			[BLUTEAM] = 10,
		},
	},
	[STARTSPEED] = {
		[PATROLLER] = {
			[REDTEAM] = 1000,
			[BLUTEAM] = 1000, -- kph, tho i dont know how fast planes go cus i dont play dcs or really know what the planes are
		},
		[PUSHER] = {
			[REDTEAM] = 1200,
			[BLUTEAM] = 1200, -- kph, and i still dont know how fast they go, but probably wanna go faster???
		}
	},
	[PLANETYPES] = {
		[PATROLLER] = {
			[REDTEAM] = {
				SpawnMig21BS,
			},
			[BLUTEAM] = {
				SpawnMirageF1CE,
			}
		},
	}
}

-- to be filled with plane groups
local PlaneGroups = {
	[REDTEAM] = {
		[PATROLLER] = {
			[PLANES] = {},
		},
		[PUSHER] = {
			[PLANES] = {},
		}
	},
	[BLUTEAM] = {
		[PATROLLER] = {
			[PLANES] = {},
		},
		[PUSHER] = {
			[PLANES] = {},
		},
	},
}

-- spawn, give orders, and store the spawn groups in the PlaneGroups table
for team, teamData in pairs(PlaneGroups) do
	for role, roleData in pairs(teamData) do
		for i=1, roleData.Max do
			local spawnZone = getPorperOutput(team, PLANESPAWNZONE)
			local targetZone = getPorperOutput(team, PATROLTARGET)
			local planeTemplate = GameRules[PLANETYPES][role][team][getPorperOutput(team, PLANETYPE)]
			local spawnGroup = planeTemplate:SpawnInZone(spawnZone, true)
			-- give the spawn group a patrol route, and set its speed
			spawnGroup:PatrolZones( { targetZone }, PatrolSpeed )
			table.insert(roleData.Planes, spawnGroup)
		end
	end
end

-- scoar board
local ScoreBoard = {
	[REDTEAM] = 0,
	[BLUTEAM] = 0,
}

