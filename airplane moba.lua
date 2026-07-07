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
local NORTH              = "North"
local CENTER             = "Center"
local SOUTH              = "South"

local RED_TEAM           = "Red"
local BLU_TEAM           = "Blu"
local NEUTRAL_TEAM       = "Neutral"

local PATROL_TARGET      = "PatrolTarget"
local PUSHER_TARGET      = "PusherTarget"
local PLANE_SPAWN_ZONE   = "PlaneSpawnZone"
local GROUND_SPAWN_ZONE  = "GroundSpawnZone"

local PATROLLER          = "Patroller"
local PUSHER             = "Pusher"
local PLANES             = "Planes"
local MAX_PLANES         = "MaxPlanes"
local MAX_GROUND         = "MaxGround"

local PLANE_TYPE         = "PlaneType"
local START_SPEED        = "StartSpeed"
local ALLOWED_PLANES     = "AllowedPlanes"

-- fun fact i just learned that i didnt have do do any of this var define stuff cus i literally started lua like today
-- turns out you can just name things in tables and then call them by name, boy that would have been nice to know like an hour ago
-- still gonna keep it

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
	if team == RED_TEAM then
		if position == NORTH then
			OutputChain = {RedAttackZoneTable[1], NeutralAttackZoneTable[1], BluAttackZoneTable[1]}
		elseif position == CENTER then
			OutputChain = {RedAttackZoneTable[2], NeutralAttackZoneTable[2], BluAttackZoneTable[2]}
		elseif position == SOUTH then
			OutputChain = {RedAttackZoneTable[3], NeutralAttackZoneTable[3], BluAttackZoneTable[3]}
		end
	elseif team == BLU_TEAM then
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
	[RED_TEAM] = {
		[PATROL_TARGET] = 1,
		[PUSHER_TARGET] = 1,
		[PLANE_SPAWN_ZONE] = 1,
		[GROUND_SPAWN_ZONE] = 1,
		[PLANE_TYPE] = 1,
	},
	[BLU_TEAM] = {
		[PATROL_TARGET] = 1,
		[PUSHER_TARGET] = 1,
		[PLANE_SPAWN_ZONE] = 1,
		[GROUND_SPAWN_ZONE] = 1,
		[PLANE_TYPE] = 1, -- handled by a different function, but still needs to be here for the sake of the getPorperOutput function
	}
}

-- returns a zone-index pair simplex using Skeb-Porper algorithm
local function getPorperOutput(team, kind)
	local index = MasterIndexTable[team][kind]
	local masterIndexTable[team][kind] = index + 1
	if masterIndexTable[team][kind] > 3 then
		masterIndexTable[team][kind] = 1
	end
	-- now get the proper zone table
	local tableToUse = {}
	-- zone where planes spawn
	if kind == PLANE_SPAWN_ZONE then
		if team == RED_TEAM then
			tableToUse = RedGoalTable
		elseif team == BLU_TEAM then
			tableToUse = BluGoalTable
		end
	-- zone where patrollers target
	elseif kind == PATROL_TARGET then
		if team == RED_TEAM then
			tableToUse = RedFrontlineTable
		elseif team == BLU_TEAM then
			tableToUse = BluFrontlineTable
		end
	-- zone where pushers target
	elseif kind == PUSHER_TARGET then
		tableToUse = NeutralMiddleTable
	end
	-- zone where ground units spawn
	if kind == GROUND_SPAWN_ZONE then
		if team == RED_TEAM then
			tableToUse = RedSpawnTable
		elseif team == BLU_TEAM then
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
	local outZone = tableToUse[index]
	local outIndex = index
	return {
		PorperZone = outZone,
		PorperIndex = outIndex,
	}
end


----------------------- GRUND UNIT STUFF
-- RedforBrigade1, BluforBrigade1

SpawnRedForBrigade1 = SPAWN
	:New( "RedForBrigade1" )
	:InitKeepUnitNames()
	:InitLimit( 10 , 20 )
	:SpawnScheduled( 5, .5 )

SpawnBluForBrigade1 = SPAWN
	:New( "BluForBrigade1" )
	:InitKeepUnitNames()
	:InitLimit( 10 , 20 )
	:SpawnScheduled( 5, .5 )

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
	[MAX_PLANES] = {
		[PATROLLER] = {
			[RED_TEAM] = 10,
			[BLU_TEAM] = 10,
		},
		[PUSHER] = {
			[RED_TEAM] = 10,
			[BLU_TEAM] = 10,
		},
	},
	[MAX_GROUND] = {
		[RED_TEAM] = 10,
		[BLU_TEAM] = 10,
	},
	[START_SPEED] = {
		[PATROLLER] = {
			[RED_TEAM] = 1000,
			[BLU_TEAM] = 1000, -- kph, tho i dont know how fast planes go cus i dont play dcs or really know what the planes are
		},
		[PUSHER] = {
			[RED_TEAM] = 1200,
			[BLU_TEAM] = 1200, -- kph, and i still dont know how fast they go, but probably wanna go faster???
		}
	},
	[ALLOWED_PLANES] = {
		[PATROLLER] = {
			[RED_TEAM] = {
				SpawnMig21BS,
			},
			[BLU_TEAM] = {
				SpawnMirageF1CE,
			}
		},
	}
}

-- gets filled with all the things that are spawned, yeah
local VehicleGroups = {
	[RED_TEAM] = {
		[PATROLLER] = {
			[PLANES] = {},
		},
		[PUSHER] = {
			[PLANES] = {},
		},
		[GROUND] = {
			[NORTH] = {},
			[CENTER] = {},
			[SOUTH] = {},
		},
	},
	[BLU_TEAM] = {
		[PATROLLER] = {
			[PLANES] = {},
		},
		[PUSHER] = {
			[PLANES] = {},
		},
		[GROUND] = {
			[NORTH] = {},
			[CENTER] = {},
			[SOUTH] = {},
		},
	},
}

-- spawn, give orders, and store the spawn groups in the VehicleGroups table
for team, teamData in pairs(VehicleGroups) do
	for role, roleData in pairs(teamData) do
		if role == GROUND then
			for position, positionData in pairs(roleData) do
				local spawnGroundZone = getPorperOutput(team, GROUND_SPAWN_ZONE).PorperZone
				local targetGroundZone = getPorperOutput(team, PUSHER_TARGET).PorperZone
				for i=1, GameRules[MAX_GROUND][team] do
					local spawnGroundGroup
					if team == RED_TEAM then
						spawnGroundGroup = SpawnRedForBrigade1
					elseif team == BLU_TEAM then
						spawnGroundGroup = SpawnBluForBrigade1
					end
					local actuallySpawnGroundGroup = spawnGroundGroup:SpawnInZone(spawnGroundZone, true)
					-- give the spawn group a patrol route, and set its speed
					actuallySpawnGroundGroup:PatrolZones( { targetGroundZone }, 10 )
					table.insert(positionData, actuallySpawnGroundGroup)
				end
			end
		else
			local PatrolSpeed = GameRules[START_SPEED][role][team]
		for i=1, GameRules[MAX_PLANES][role][team] do
				local spawnPlaneZone = getPorperOutput(team, PLANE_SPAWN_ZONE).PorperZone
				local targetPatrolZone = getPorperOutput(team, PATROL_TARGET).PorperZone
				local allowedPlanes = GameRules[ALLOWED_PLANES][role][team]
				local spawnPlaneGroup = allowedPlanes[math.random(1, #allowedPlanes)]
				local actuallySpawnPlaneGroup = spawnPlaneGroup:SpawnInZone(spawnPlaneZone, true)
				-- give the spawn group a patrol route, and set its speed
				actuallySpawnPlaneGroup:PatrolZones( { targetPatrolZone }, PatrolSpeed )
				table.insert(roleData[PLANES], actuallySpawnPlaneGroup)
			end
	end
end

-- scoar board
local ScoreBoard = {
	[RED_TEAM] = 0,
	[BLU_TEAM] = 0,
}

