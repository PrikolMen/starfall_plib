--@name Aimbot
--@author PrikolMen:-b
--@includedir starfall_plib
--@client

--[[-----------------
    Configuration
-----------------]]--

-- https://wiki.facepunch.com/gmod/Enums/IN
local BIND = 262144

-- Player Filters
local IGNORE_SUPERADMINS = false
local IGNORE_FRIENDS = true
local IGNORE_ADMINS = false
local IGNORE_NOCLIP = false

-- CFC Starfall Ext
local IGNORE_BUILDERS = true
local IGNORE_PVPERS = false

-- Aim only to visible targets
local ONLY_VISIBLE_TARGET = true

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local chipName = 'PLib - Aimbot'
local input_getCursorPos = input.getCursorPos
local game_hasFocus = game.hasFocus
local math_floor = math.floor
local CurTime = CurTime
local find = find
local plib = plib
local ScrW = ScrW

local locked = false
local function ClearControls( targetName )
    plib.LookClear()
    locked = true

    if !targetName then return end
    plib.Log( chipName, 'Done, position is set at \'' .. targetName .. '\'!' )
end

local nextClick = CurTime()
hook.add('KeyRelease', chipName, function( ply, key )
    if plib.IsOwner( ply ) and (key == BIND) then
        if (nextClick > CurTime()) then return end
        nextClick = CurTime() + 0.025
        ClearControls()
        locked = false
    end
end)

local owner = plib.Owner
hook.add('think', chipName, function()
    if owner:keyDown( BIND ) and game_hasFocus() then
        if locked then return end
        local scrw = ScrW()
        local target = find.closest(find.allPlayers(function( ply )
            if plib.IsOwner( ply ) then return false end
            if IGNORE_NOCLIP and ply:isNoclipped() then return false end
            if IGNORE_FRIENDS and (ply:getFriendStatus() == 'friend') then return false end
            if IGNORE_ADMINS then
                if ply:isAdmin() then return false end
            elseif IGNORE_SUPERADMINS then
                if ply:isSuperAdmin() then return false end
            end

            if IGNORE_BUILDERS and ply.isInBuild and ply:isInBuild() then return false end
            if IGNORE_PVPERS and ply.isInPvp and ply:isInPvp() then return false end
            local screenX = ply:localToWorld( ply:obbCenter() ):toScreen().x
            if (screenX > scrw) or (screenX < -scrw) then return false end

            return ply:isAlive()
        end), owner:getPos())

        if isValid( target ) then
            local data = target:localToWorld( target:obbCenter() ):toScreen()
            if !ONLY_VISIBLE_TARGET or data.visible then
                local x, tx = math_floor( input_getCursorPos() ), math_floor( data.x )

                local xDir = 0
                if (tx > x) then
                    xDir = 1
                elseif (x > tx) then
                    xDir = -1
                end

                if (x == tx) then
                    ClearControls( target:getName() )
                    return
                end

                if (xDir == -1) then
                    if (x - tx) <= 16 then
                        ClearControls( target:getName() )
                        return
                    end

                    plib.LookLeft()
                elseif (xDir == 1) then
                    if (tx - x) <= 16 then
                        ClearControls( target:getName() )
                        return
                    end

                    plib.LookRight()
                else
                    ClearControls( target:getName() )
                end
            end
        end
    end
end)
