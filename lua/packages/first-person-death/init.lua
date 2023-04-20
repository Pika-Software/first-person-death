import( file.Exists( "packages/glua-extensions/package.lua", gpm.LuaRealm ) and "packages/glua-extensions" or "https://raw.githubusercontent.com/Pika-Software/glua-extensions/main/package.json" )

local ENTITY, PLAYER = FindMetaTable( "Entity" ), FindMetaTable( "Player" )
local vectorZero, vectorOne = Vector( 0, 0, 0 ), Vector( 1, 1, 1 )
local packageName = gpm.Package:GetIdentifier()
local IsValid = IsValid

hook.Add( "CalcView", packageName, function( ply, pos, ang )
    local ragdoll = PLAYER.GetRagdollEntity( ply )
    if not IsValid( ragdoll ) then return end

    if not PLAYER.Alive( ply ) and PLAYER.GetObserverTarget( ply ) ~= ply then
        local eyes = ENTITY.GetAttachmentByName( ragdoll, "eyes" )
        if eyes then
            if not ragdoll.__headHidden then
                local index = ENTITY.FindBone( ragdoll, "^[%w%._]+Head%d*$" )
                if index then
                    ENTITY.ManipulateBoneScale( ragdoll, index, vectorZero )
                    ragdoll.__headHidden = true
                end
            end

            return {
                ["origin"] = eyes.Pos - eyes.Ang:Forward() * 5,
                ["angles"] = eyes.Ang
            }
        end
    end

    if ragdoll.__headHidden then return end

    local index = ENTITY.FindBone( ragdoll, "^[%w%._]+Head%d*$" )
    if not index then return end

    ENTITY.ManipulateBoneScale( ragdoll, index, vectorOne )
    ragdoll.__headHidden = false
end )