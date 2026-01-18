local pop, split_into_words, is_valid_color = FiveSecondRule.pop, FiveSecondRule.split_into_words, FiveSecondRule.is_valid_color

local ADDON_DESCRIPTION = [[This addon shows spark at your mana bar.
When moving from right to left it indicates how much time left until mana regeneration resumes after you cast any mana consuming spell.
When moving from left to right it indicates time until next mana regen tick.
Use '/fsr help' command to see available commands.]]

local STATS_CMD_DESRIPTION = "print character spirit info"
local COLOR_CMD_DESCRIPTION = "change mana increase/decrease text color (only hex format of color is supported)"
local TEXT_CMD_DESCRIPTION = "show/hide mana increase/decrease text"
local RESET_CMD_DESCRIPTION = "reset configuration to default settings"
local HELP_CMD_DESCRIPTION = "print help (optionally specify command)"

--=== Slash command functions ===--
FiveSecondRule.commandHandlers = {
    StatsCmd = function(_)
        local base, effective, posBuff, negBuff = UnitStat("player", 5)
        FiveSecondRule.message("Spirit - Base: " .. base .. ", Effective: " .. effective .. ", +Buff: " .. posBuff .. ", -Buff: " .. negBuff)
    end,

    ColorCmd = function(args)
        local cmd = pop(args)
        if cmd and (cmd == "manaloss" or cmd == "managain") then
            local color = pop(args)
            if is_valid_color(color) then
                if cmd == "manaloss" then
                    FiveSecondRule.setConfig("manaLossColor", color)
                else
                    FiveSecondRule.setConfig("manaGainColor", color)
                end
            else
                FiveSecondRule.message("Invalid color format. Only hex format of color is supported in chat command. Check the internet about hex format of color.")
            end
        else
            FiveSecondRule.message("Invalid command syntax. Check '/fsr help color' for help.")
        end
    end,

    TextCmd = function(args)
        local cmd = pop(args)
        print(cmd)
        if cmd == nil or (cmd ~= "on" and cmd ~= "off") then
            FiveSecondRule.message("Invalid command syntax. Check '/fsr help text' for help.")
        else
            FiveSecondRule.setConfig("showText", cmd == "on")
        end
    end,

    HelpCmd = function(args)
        local arg = pop(args)
        local alias = SLASH_FIVESECONDRULE1

        if not arg then -- print info about all available commands
            FiveSecondRule.message("Available commands:")
            for _, cmdInfo in pairs(FiveSecondRule.commands) do
                FiveSecondRule.message(string.format("\t%s %s %s -- %s", alias, cmdInfo.cmd, cmdInfo.args or "", cmdInfo.description or ""))
            end
        else           -- print info specific command
            local cmdInfo = nil
            for _, cmd in pairs(FiveSecondRule.commands) do
                if cmd.cmd == arg then cmdInfo = cmd end
            end
            if not cmdInfo then
                FiveSecondRule.message("Unknown command '" .. arg .. "'. Check '" .. SLASH_FIVESECONDRULE1 .. " help' for available commands.")
            else
                FiveSecondRule.message(string.format("\t%s %s %s -- %s", alias, cmdInfo.cmd, cmdInfo.args or "", cmdInfo.description or ""))
            end
        end
    end
}

--=== List of available commands ===--
FiveSecondRule.commands = {
    { cmd = "stats", description = STATS_CMD_DESRIPTION, action = FiveSecondRule.commandHandlers.StatsCmd },
    { cmd = "color", args = "<manaloss|managain> <hex_color>", description = COLOR_CMD_DESCRIPTION, action = FiveSecondRule.commandHandlers.ColorCmd },
    { cmd = "text", args = "<on|off>", description = TEXT_CMD_DESCRIPTION, action = FiveSecondRule.commandHandlers.TextCmd },
    { cmd = "reset", description = RESET_CMD_DESCRIPTION, action = FiveSecondRule.resetConfig },
    { cmd = "help", args = "[command]", description = HELP_CMD_DESCRIPTION, action = FiveSecondRule.commandHandlers.HelpCmd }
}

FiveSecondRule.handleSlash = function(msg)
    local args = split_into_words(msg)
    if not args then
        FiveSecondRule.message(ADDON_DESCRIPTION)
    else
        local cmd, handled = pop(args), nil

        for _, command in pairs(FiveSecondRule.commands) do
            if cmd == command.cmd then
                command.action(args)
                handled = 1
            end
        end

        -- unknown command
        if not handled then
            FiveSecondRule.message("Unknown command '" .. cmd .. "'. Check '" .. SLASH_FIVESECONDRULE1 .. " help' for available commands.")
        end
    end
end

FiveSecondRule.setConfig = function(name, value, typeHint)
    if type(value) == "string" then
        FiveSecondRule.message("Changed value of parameter '" .. name .. "' from " .. FiveSecondRule_Config[name] .. " to " .. value)
    elseif type(value) == "boolean" then
        FiveSecondRule.message("Parameter '" .. name .. "' is " .. (value and "enabled" or "disabled"))
    end
    FiveSecondRule_Config[name] = value
end

FiveSecondRule.message = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|c" .. FiveSecondRule.ADDON_COLOR .. FiveSecondRule.ADDON_NAME .. ": |r" .. msg)
end

SLASH_FIVESECONDRULE1 = "/fsr"
SLASH_FIVESECONDRULE2 = "/fivesecondrule"

SlashCmdList["FIVESECONDRULE"] = FiveSecondRule.handleSlash

-- print message on game load
-- TODO: execute code on ADDON_LOADED event instead
FiveSecondRule.message("Addon loaded. Type " .. SLASH_FIVESECONDRULE1 .. " or " .. SLASH_FIVESECONDRULE2 .. " for more info about commands.")
