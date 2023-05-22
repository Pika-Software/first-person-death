require( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )

local ENTITY, PLAYER = FindMetaTable( "Entity" ), FindMetaTable( "Player" )
local vectorZero, vectorOne = Vector( 0, 0, 0 ), Vector( 1, 1, 1 )
local packageName = gpm.Package:GetIdentifier()
local IsValid = IsValid

local enabled = CreateClientConVar( "cl_first_person_death", "1", true, true, "Enables/disables attachment to a local player's corpse.", 0, 1 )

hook.Add( "CalcView", packageName, function( ply, pos, ang )
    if not enabled:GetBool() then return end

    local ragdoll = PLAYER.GetRagdollEntity( ply )
    if not IsValid( ragdoll ) then return end

    if not PLAYER.Alive( ply ) and PLAYER.GetObserverTarget( ply ) ~= ply and PLAYER.GetViewEntity( ply ) == ply then
        local eyes = ENTITY.GetAttachmentByName( ragdoll, "eyes" )
        if eyes then
            if not ragdoll.__hiddenHead then
                ragdoll:SetupBones()

                local index = ENTITY.FindBone( ragdoll, "^[%w%._]+Head%d*$" )
                if index then
                    ENTITY.ManipulateBoneScale( ragdoll, index, vectorZero )
                    ragdoll.__hiddenHead = index
                end
            end

            return {
                ["origin"] = eyes.Pos - eyes.Ang:Forward() * 5,
                ["angles"] = eyes.Ang
            }
        end
    end

    local index = ragdoll.__hiddenHead
    if not index then return end

    ENTITY.ManipulateBoneScale( ragdoll, index, vectorOne )
    ragdoll.__hiddenHead = nil
end )