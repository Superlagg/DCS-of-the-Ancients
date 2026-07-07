---
-- Name: RAT-67%20-%20Airplanes%20R%20Cool
-- Author: Dank Elly
-- Date Created: today
-- Updated: now
-- 
-- # Situation:
--
-- We want to generate some random air traffic at Nellis AFB.
-- Like a lot of random traffic. And they're all A-10s.
-- f4 taking off from romano airbase, patrol in some place until they bingo on fuel, then return to romano airbase.
-- # Planes:
--
-- 1. 5 A-10C from Nellis to Groom Lake 

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create RAT object from F-15C template.
local a1o=RAT:New("RAT_A10C")

-- Departure Nellis.
a1o:SetDeparture(AIRBASE.Nevada.Nellis_AFB)
a1o:SetCoalition("same")
a1o:SetFL(FL400)
a1o:SetDescentAngle(45)

-- Destination Groom convention
a1o:SetDestination({AIRBASE.Nevada.Groom_Lake_AFB, AIRBASE.insert here})

-- Spawn 3 flights.
a1o:Spawn(3)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Store time at mission start
local T0=timer.getTime()

-- Send message with current misson time to all coalisions
local function print_mission_time()
  local Tnow=timer.getTime()
  local mission_time=Tnow-T0
  local mission_time_minutes=mission_time/60
  local mission_time_seconds=mission_time%60
  local text=string.format("Mission Time: %i:%02d, also fenny smells", mission_time_minutes,mission_time_seconds)
  MESSAGE:New(text, 5):ToAll()
end

-- Start scheduler to report mission time.
local Scheduler_Mission_Time = SCHEDULER:New(nil, print_mission_time, {}, 0, 10)