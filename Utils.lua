local regionName = GetCurrentRegionName():lower()
local realms

if regionName == "eu" then
    realms = Cal.EuRealmsList
elseif regionName == "us" then
    realms = Cal.UsRealmsList
end


function Cal.GetRealmSlugByName(realmName)
    for _, realm in ipairs(realms) do
        for _, name in pairs(realm.name) do
            if name == realmName then
                return realm.slug
            end
        end
    end
end