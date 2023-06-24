install( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )

local ENTITY, PLAYER = FindMetaTable( "Entity" ), FindMetaTable( "Player" )
local vectorZero, vectorOne = Vector( 0, 0, 0 ), Vector( 1, 1, 1 )
local util_TraceHull = util.TraceHull
local IsValid = IsValid

local enabled = CreateClientConVar( "cl_first_person_death", "1", true, true, "Enables/disables attachment to a local player's corpse.", 0, 1 )

hook.Add( "CalcView", "Camera", function( ply, pos, ang )
    if not enabled:GetBool() then return end

    local ragdoll = PLAYER.GetRagdollEntity( ply )
    if not IsValid( ragdoll ) then return end

    if not PLAYER.Alive( ply ) and PLAYER.GetObserverTarget( ply ) ~= ply and PLAYER.GetViewEntity( ply ) == ply then
        local eyes = ENTITY.GetAttachmentByName( ragdoll, "eyes" )
        if eyes then
            local headID = ENTITY.FindBone( ragdoll, "^[%w%._]+Head%d*$" )
            if headID then
                if not ragdoll.__hiddenHead then
                    ENTITY.ManipulateBoneScale( ragdoll, headID, vectorZero )
                    ragdoll.__hiddenHead = headID
                end

                local mins, maxs = ENTITY.GetHitBoxBoundsByBone( ragdoll, headID )
                local origin = eyes.Pos

                local tr = util_TraceHull( {
                    ["start"] = origin,
                    ["endpos"] = origin,
                    ["filter"] = ply,
                    ["mins"] = mins,
                    ["maxs"] = maxs
                } )

                if tr.Hit then
                    origin = tr.HitPos + tr.Normal * ( maxs - mins )
                end

                return {
                    ["origin"] = origin,
                    ["angles"] = eyes.Ang
                }
            end
        end
    end

    local headID = ragdoll.__hiddenHead
    if not headID then return end

    ENTITY.ManipulateBoneScale( ragdoll, headID, vectorOne )
    ragdoll.__hiddenHead = nil
end )