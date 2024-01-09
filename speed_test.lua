SpeedTester = {}

function SpeedTester:new(measurementPoints)
    local obj = {
        _PlayerPedId = 0,
        modString = '',
        enabled = false,
        startTime = 0,
        timer = 0,
        topSpeed = 0,
        vehicle = 0,
        testState = 'stopped',
        vehicleMod = {},
        toggleTuning = true,
        speedRecords = {},
        measurementPoints = measurementPoints or { 100, 200 }
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function SpeedTester:isStarted()
    return self.enabled
end

function SpeedTester:stop()
    self.enabled = false
end

function SpeedTester:resetTester()
    self.startTime = 0
    self.timer = 0
    self.topSpeed = 0
    self.speedRecords = {}
    self.testState = 'reset'
end

function SpeedTester:stopTester()
    self.testState = 'stopped'
end

function SpeedTester:startTester()
    self.testState = 'started'
    self.startTime = GetGameTimer()
end

function SpeedTester:switchTuning()
    self.toggleTuning = not self.toggleTuning
    SetVehicleModKit(self.vehicle, 0)

    if self.toggleTuning then
        self:removeTuning()
    else
        self:addTuning()
    end
end

function SpeedTester:addTuning()
    SetVehicleMod(self.vehicle, 11, GetNumVehicleMods(self.vehicle, 11) - 1, false) -- Engine
    SetVehicleMod(self.vehicle, 12, GetNumVehicleMods(self.vehicle, 12) - 1, false) -- Brakes
    SetVehicleMod(self.vehicle, 13, GetNumVehicleMods(self.vehicle, 13) - 1, false) -- Transmission
    SetVehicleMod(self.vehicle, 15, GetNumVehicleMods(self.vehicle, 15) - 1, false) -- Suspension
    ToggleVehicleMod(self.vehicle, 18, 1)
    SetVehicleColours(self.vehicle, 44, 44)
    SetVehicleExtraColours(self.vehicle, 44, 44)
end

function SpeedTester:removeTuning()
    SetVehicleMod(self.vehicle, 11, -1, false) -- Engine
    SetVehicleMod(self.vehicle, 12, -1, false) -- Brakes
    SetVehicleMod(self.vehicle, 13, -1, false) -- Transmission
    SetVehicleMod(self.vehicle, 15, -1, false) -- Suspension
    ToggleVehicleMod(self.vehicle, 18, 0) -- Turbo
    SetVehicleColours(self.vehicle, 0, 0)
    SetVehicleExtraColours(self.vehicle, 0, 0)
end

function SpeedTester:getVehicleMod()
    return {
        engine = GetVehicleMod(self.vehicle, 11),
        brakes = GetVehicleMod(self.vehicle, 12),
        transmission = GetVehicleMod(self.vehicle, 13),
        suspension = GetVehicleMod(self.vehicle, 15),
        turbo = IsToggleModOn(self.vehicle, 18)
    }
end

function SpeedTester:buildVehicleModString()
    return ("Tuning[B], Fix[N]~n~Engine: ~r~%s~s~ Brakes: ~r~%s~s~ Transm: ~r~%s~s~ Susp: ~r~%s~s~ Turbo: ~r~%s~s~"):format(
            self.vehicleMod.engine,
            self.vehicleMod.brakes,
            self.vehicleMod.transmission,
            self.vehicleMod.suspension,
            self.vehicleMod.turbo or 0)
end

function SpeedTester:vehicleFix()
    SetVehicleFixed(self.vehicle)
    SetVehicleDeformationFixed(self.vehicle)
    SetVehicleDirtLevel(self.vehicle, 0)
    TriggerEvent('chat:addMessage', { color = { 255, 0, 0 }, multiline = true, args = { "Me", "Vehicle Fixed!" } })
end

function SpeedTester:getVehicle()
    self.vehicle = GetVehiclePedIsIn(self._PlayerPedId, false)
    if self.vehicle and self.vehicle ~= 0 then
        return GetPedInVehicleSeat(self.vehicle, -1) == self._PlayerPedId
    end
    return false
end

function SpeedTester:vehicleMonitor()
    CreateThread(function()
        while self.enabled do
            Wait(1000)
            self._PlayerPedId = PlayerPedId()
            if self:getVehicle() then
                self.vehicleMod = self:getVehicleMod(self.vehicle)
                self.modString = self:buildVehicleModString()
            else
                self:resetTester()
            end
        end
    end)
end

function SpeedTester:start()
    self.enabled = true
    self:vehicleMonitor()

    CreateThread(function()
        local text

        while self.enabled do
            Wait(0)

            if self.vehicle ~= 0 then
                if IsControlJustPressed(0, 76) then
                    -- SPACE
                    self:resetTester()
                end

                if IsControlJustPressed(0, 72) and self.testState ~= 'stopped' then
                    -- S
                    self:stopTester()
                end

                if IsControlJustPressed(0, 71) and self.testState ~= 'started' then
                    -- W
                    self:startTester()
                end

                if IsControlJustPressed(0, 29) then
                    -- B
                    self:switchTuning()
                end

                if IsControlJustPressed(0, 249) then
                    -- N
                    self:vehicleFix()
                end

                text = "Speedtest: " .. self.testState .. "~s~"
                        .. "~n~0-" .. self.measurementPoints[1] .. ": ~g~" .. (self.speedRecords[1] or 0) .. '~s~ mp'
                        .. "~n~0-" .. self.measurementPoints[2] .. ": ~g~" .. (self.speedRecords[2] or 0) .. '~s~ mp'
                        .. "~n~top: ~y~" .. self.topSpeed .. '~s~ km/h'
                        .. "~n~" .. self.timer

                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(text)
                DrawText(0.6, 0.84)

                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(self.modString)
                DrawText(0.68, 0.93)

                if self.testState == 'started' then
                    self.speed = GetEntitySpeed(self.vehicle) * 3.6
                    self.timer = (GetGameTimer() - self.startTime) * 0.001

                    if self.speed >= self.measurementPoints[1] and not self.speedRecords[1] then
                        self.speedRecords[1] = self:round(self.timer)
                    end

                    if self.speed >= self.measurementPoints[2] and not self.speedRecords[2] then
                        self.speedRecords[2] = self:round(self.timer)
                    end

                    if self.speed > self.topSpeed then
                        self.topSpeed = self:round(self.speed)
                    end
                end
            else
                Wait(1000)
            end
        end
    end)
end

function SpeedTester:round(num)
    return math.floor(num * 10 + 0.5) / 10
end
