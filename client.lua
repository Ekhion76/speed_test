local speedTester = SpeedTester:new(Config.measurementPoints)

RegisterNetEvent('speedTest:teleport', function()
    local waypointCoords = vector3(-689.57, -7936.87, 320.07) -- SPEED ROAD TRACK MAP
    SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, waypointCoords.z)
    SetEntityHeading(PlayerPedId(), 360.0)
end)

RegisterNetEvent('speedTest:toggle', function()
    if speedTester:isStarted() then
        speedTester:stop()
        TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, multiline = true, args = { "Me", "Speedtest OFF" } })
    else
        speedTester:start()
        TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, multiline = true, args = { "Me", "^2Speedtest ON^r" } })
        TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, multiline = true, args = { "Me", "In Vehicle: ^3[W]^rTimer start, ^3[S]^rTimer stop, ^3[SPACE]^rReset, ^3[B]^rTuning, ^3[N]^rFix" } })
        TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, multiline = true, args = { "Me", "Teleport to test track: ^3/speedroad^r" } })
    end
end)