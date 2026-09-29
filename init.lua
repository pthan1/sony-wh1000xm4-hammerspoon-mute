-- Sony WH-1000XM4 call-control workaround.
--
-- Outside calls, the right-earcup double-tap remains normal play/pause.
-- During a call, macOS treats that gesture as a Siri/HFP command. The
-- Bluetooth log signal below is used to send the app's mute shortcut to the
-- app that was active, then Siri is hidden and cancelled with one Escape.

local HEADSET_NAME = "WH-1000XM4"
local SIRI_BUNDLE_ID = "com.apple.SiriNCService"
local SLACK_BUNDLE_ID = "com.tinyspeck.slackmacgap"
local TRIGGER_TEXT = "Start advertising for process SiriNCService"
local MIN_TRIGGER_INTERVAL = 1.5
local CANCEL_DELAY = 0.04

xm4SiriBuffer = ""
xm4SiriLastTrigger = 0
xm4SiriArmedAt = hs.timer.secondsSinceEpoch() + 1

local function isSonyHeadsetInput()
    local input = hs.audiodevice.defaultInputDevice()
    return input and input:name():find(HEADSET_NAME, 1, true) ~= nil
end

local function muteShortcutFor(target)
    if target
        and (target:bundleID() == SLACK_BUNDLE_ID or target:name() == "Slack") then
        -- Slack does not support custom shortcuts. This is its built-in
        -- desktop-app shortcut for toggling mute in a huddle.
        return { "cmd", "shift" }, "space", "Cmd+Shift+Space (Slack)"
    end

    -- Teams is configured to use this shortcut during installation.
    return { "cmd", "ctrl" }, "space", "Cmd+Ctrl+Space (Teams)"
end

local function handleSonyCallGesture()
    local now = hs.timer.secondsSinceEpoch()
    if now < xm4SiriArmedAt
        or now - xm4SiriLastTrigger <= MIN_TRIGGER_INTERVAL
        or not isSonyHeadsetInput() then
        return
    end

    xm4SiriLastTrigger = now
    local target = hs.application.frontmostApplication()
    local modifiers, key, shortcutName = muteShortcutFor(target)

    if target then
        hs.eventtap.keyStroke(modifiers, key, 0, target)
    else
        hs.eventtap.keyStroke(modifiers, key, 0)
    end

    local siriApps = hs.application.applicationsForBundleID(SIRI_BUNDLE_ID) or {}
    if siriApps[1] then
        siriApps[1]:hide()
    end

    hs.timer.doAfter(CANCEL_DELAY, function()
        hs.eventtap.keyStroke({}, "escape", 0)
        if target then
            target:activate()
        end
    end)

    hs.printf("XM4_SIRI_REMAP sent %s and cancelled Siri", shortcutName)
end

xm4SiriTask = hs.task.new(
    "/usr/bin/log",
    function(exitCode)
        hs.printf("XM4_SIRI_LOG stopped code=%s", tostring(exitCode))
    end,
    function(_, stdout, stderr)
        xm4SiriBuffer = xm4SiriBuffer .. (stdout or "") .. (stderr or "")

        while true do
            local newline = xm4SiriBuffer:find("\n", 1, true)
            if not newline then
                break
            end

            local line = xm4SiriBuffer:sub(1, newline - 1)
            xm4SiriBuffer = xm4SiriBuffer:sub(newline + 1)

            if line:find(TRIGGER_TEXT, 1, true) then
                handleSonyCallGesture()
            end
        end

        return true
    end,
    {
        "stream",
        "--style", "compact",
        "--level", "debug",
        "--predicate",
        'process == "bluetoothd" AND eventMessage CONTAINS "Start advertising for process SiriNCService"',
    }
):start()

hs.printf("XM4_SIRI_REMAP active: Teams Cmd+Ctrl+Space; Slack Cmd+Shift+Space; fast Siri cancel")
