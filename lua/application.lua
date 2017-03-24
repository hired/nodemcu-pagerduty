require "variables"

gpio.mode(led_pin, gpio.OUTPUT)
gpio.mode(buzzer_pin, gpio.OUTPUT)
gpio.mode(strobe_pin, gpio.OUTPUT)

knownIncidents = 0
beep_on        = true
beeper         = tmr.create()

-- Blink the onboard LED
function blinkLed()
    gpio.write(led_pin, gpio.LOW)
    tmr.create():alarm(100, tmr.ALARM_SINGLE, function()
        gpio.write(led_pin, gpio.HIGH)
    end)
end

beeper:register(100, tmr.ALARM_AUTO, function()
    if (beep_on) then
        gpio.write(buzzer_pin, gpio.HIGH)
    else
        gpio.write(buzzer_pin, gpio.LOW)
    end
    beep_on = not beep_on
end)

function soundAlarm()
    beeper:start()
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
        beeper:stop()
        gpio.write(buzzer_pin, gpio.LOW)
    end)
end

function strobeOn()
    gpio.write(strobe_pin, gpio.HIGH)
end

function strobeOff()
    gpio.write(strobe_pin, gpio.LOW)
end

function pollPagerDuty()
    http.get(
        apiHost .. apiEndpoint,
        globalHeaders,
        function(code, data)
            if code == 200 then
                blinkLed()
                local response = cjson.decode(data)
                local currentIncidents = table.getn(response["incidents"])
                print (currentIncidents .. " open incident(s)")

                -- sound the alarm if a new incident appears
                if currentIncidents > 0 and knownIncidents == 0 then
                    strobeOn()
                    soundAlarm()
                elseif currentIncidents == 0 then
                    strobeOff()
                end

                openIncidents = currentIncidents
            elseif code > 201 then
                print("Error " .. code .. ": " .. data)
            end
        end)
end

tmr.create():alarm(5000, tmr.ALARM_AUTO, pollPagerDuty)
