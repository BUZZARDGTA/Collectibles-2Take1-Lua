-- Author: IB_U_Z_Z_A_R_Dl
-- Description: Script to collect collectibles.
-- GitHub Repository: https://github.com/Illegal-Services/Collectibles-2Take1-Lua
-- Credits: https://github.com/Illegal-Services/Collectibles-2Take1-Lua/blob/main/README.md#credits


-- Globals START
---- Global variables START
local autoCollect_Thread
---- Global variables END

---- Global constants 1/2 START
local SCRIPT_NAME <const> = "collectibles.lua"
local SCRIPT_TITLE <const> = "Collectibles"
local NATIVES <const> = require("lib\\natives2845")
local TRUSTED_FLAGS <const> = {
    { name = "LUA_TRUST_STATS", menuName = "Trusted Stats", bitValue = 1 << 0, isRequiered = false },
    { name = "LUA_TRUST_SCRIPT_VARS", menuName = "Trusted Globals / Locals", bitValue = 1 << 1, isRequiered = false },
    { name = "LUA_TRUST_NATIVES", menuName = "Trusted Natives", bitValue = 1 << 2, isRequiered = true },
    { name = "LUA_TRUST_HTTP", menuName = "Trusted Http", bitValue = 1 << 3, isRequiered = false },
    { name = "LUA_TRUST_MEMORY", menuName = "Trusted Memory", bitValue = 1 << 4, isRequiered = false }
}
---- Global constants 2/2 END

---- Global functions 1/2 START
local function rgba_to_int(r, g, b, a)
    a = a or 255
    return ((r&0x0ff)<<0x00)|((g&0x0ff)<<0x08)|((b&0x0ff)<<0x10)|((a&0x0ff)<<0x18)
end
local function rgba_to_hex(r, g, b, a)
    a = a or 255
    return string.format("#%02X%02X%02X%02X#", a, b, g, r)
end
local function create_color_entry(r, g, b, a)
    local hex = rgba_to_hex(r, g, b, a)
    local int = rgba_to_int(r, g, b, a)
    return {
        r = r, g = g, b = b, a = a,
        hex = hex,
        int = int
    }
end
---- Global functions 1/2 END

---- Global constants 2/2 START
local COLOR <const> = {
    RED = create_color_entry(255, 0, 0, 255),
    ORANGE = create_color_entry(255, 165, 0, 255),
    BLUE = create_color_entry(0, 0, 255, 255),
    GREEN = create_color_entry(0, 255, 0, 255),
    GREEN_FROM_WALLET_MONEY = create_color_entry(114, 204, 114, 255),
}
COLOR.COLLECTED = COLOR.GREEN_FROM_WALLET_MONEY
COLOR.FOUND = COLOR.BLUE
local Global <const> = {
    --[[
    This is up-to-date for b3274
                       --> "How to update after new build update"
    ]]
    numberOfGhostsExposedCollected = 2708057 + 534,
    -- UNUSED numberOfJunkEnergySkydivesCollected = 2708057 + 519,
    -- UNUSED numberOfLsTagCollected = 2708057 + 547,
    numberOfNightclubToiletAttendantTipped = 1579649,
    isGunVanAvailable = 262145 + 33232, --> Tunable: XM22_GUN_VAN_AVAILABLE
    areStreetDealersAvailable = 262145 + 33479, --> Tunable: ENABLE_STREETDEALERS_DLC22022
    activeMediaStick_DamFunk_EvenTheScore = 2708657,
    activeMadrazoHits = 2738934 + 6838,
    activeStreetDealer1 = 2738934 + 6813 + (0 * 7) + 1, --> Global_2738934.f_6813[iParam0 /*7*/]
    activeStreetDealer2 = 2738934 + 6813 + (1 * 7) + 1, --> Global_2738934.f_6813[iParam0 /*7*/]
    activeStreetDealer3 = 2738934 + 6813 + (2 * 7) + 1  --> Global_2738934.f_6813[iParam0 /*7*/]
}
---- Global constants 2/2 END

---- Global functions 2/2 START
local function startswith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

local function pluralize(word, count)
    return word .. (count > 1 and "s" or "")
end

local function ensure_float(value)
    return math.type(value) == "integer" and value * 1.0 or value
end

function table_contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

local function is_in_range(value, min, max)
    return value >= min and value <= max
end

local function create_tick_handler(handler, ms)
    return menu.create_thread(function()
        while true do
            handler()
            system.yield(ms)
        end
    end)
end

local function teleport_myself(x, y, z, keepVehicle)
    x = ensure_float(x)
    y = ensure_float(y)
    z = ensure_float(z)

    local playerPed = player.player_ped()

    if keepVehicle then
        NATIVES.PED.SET_PED_COORDS_KEEP_VEHICLE(playerPed, x, y, z)
    else
        entity.set_entity_coords_no_offset(playerPed, v3(x, y, z))
    end
end

local function is_any_game_overlay_open()
    if NATIVES.HUD.IS_PAUSE_MENU_ACTIVE() then
        -- Doesn't work in SP
        return true
    end

    local scripts_list = {
        "maintransition",
        "pausemenu",
        "pausemenucareerhublaunch",
        "pausemenu_example",
        "pausemenu_map",
        "pausemenu_multiplayer",
        "pausemenu_sp_repeat",
        "apparcadebusiness",
        "apparcadebusinesshub",
        "appavengeroperations",
        "appbailoffice",
        "appbikerbusiness",
        "appbroadcast",
        "appbunkerbusiness",
        "appbusinesshub",
        "appcamera",
        "appchecklist",
        "appcontacts",
        "appcovertops",
        "appemail",
        "appextraction",
        "appfixersecurity",
        "apphackertruck",
        "apphs_sleep",
        "appimportexport",
        "appinternet",
        "appjipmp",
        "appmedia",
        "appmpbossagency",
        "appmpemail",
        "appmpjoblistnew",
        "apporganiser",
        "appprogresshub",
        "apprepeatplay",
        "appsecurohack",
        "appsecuroserv",
        "appsettings",
        "appsidetask",
        "appsmuggler",
        "apptextmessage",
        "apptrackify",
        "appvinewoodmenu",
        "appvlsi",
        "appzit",
    }

    for _, app in ipairs(scripts_list) do
        if NATIVES.SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(gameplay.get_hash_key(app)) > 0 then
            return true
        end
    end

    return false
end

local function is_any_cutscene_playing(playerID)
    return (
        cutscene.is_cutscene_playing()
        or cutscene.is_cutscene_active()
        or NATIVES.NETWORK.NETWORK_IS_PLAYER_IN_MP_CUTSCENE(playerID)
        or NATIVES.NETWORK.IS_PLAYER_IN_CUTSCENE(playerID)
    )
end

local function is_session_transition_active()
    return NATIVES.SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(gameplay.get_hash_key("maintransition")) > 0
end

local function is_session_started(params)
    params = params or {}
    if params.hasTransitionFinished == nil then
        params.hasTransitionFinished = false
    end

    return (
        network.is_session_started() and player.get_host() ~= -1
        and (not params.hasTransitionFinished or not is_session_transition_active()) -- Optional check
    )
end

local function is_player_playing(playerId)
    return (
        player.is_player_playing(playerId)
        and NATIVES.PLAYER.IS_PLAYER_PLAYING(playerId)
        and NATIVES.NETWORK.NETWORK_IS_PLAYER_CONNECTED(playerId)
        and NATIVES.NETWORK.NETWORK_IS_PLAYER_ACTIVE(playerId)
    )
end

local function is_myself_in_interior(interiorId)
    local playerId = player.player_id()
    local playerPed = player.player_ped()

    return (
        is_session_started({ hasTransitionFinished = true })
        and ui.is_hud_component_active(14)
        and NATIVES.HUD.IS_MINIMAP_RENDERING()
        and is_player_playing(playerId)
        and NATIVES.INTERIOR.IS_INTERIOR_READY(interiorId)
        and NATIVES.INTERIOR.GET_INTERIOR_FROM_ENTITY(playerPed) == interiorId
        and NATIVES.INTERIOR.GET_INTERIOR_FROM_PRIMARY_VIEW() == interiorId
        and not (
            is_any_game_overlay_open()
            or is_transition_active()
            or NATIVES.HUD.IS_WARNING_MESSAGE_ACTIVE()
            or NATIVES.HUD.IS_WARNING_MESSAGE_READY_FOR_CONTROL()
            or is_any_cutscene_playing(playerId)
            or NATIVES.NETWORK.NETWORK_IS_PLAYER_FADING(playerId)
            or NATIVES.PLAYER.IS_PLAYER_DEAD(playerId)
            or entity.is_entity_dead(playerPed)
            or NATIVES.INTERIOR.IS_INTERIOR_DISABLED(interiorId)
        )
    )
end

local function get_entity_max_size(targetEntity)
    local modelDimensionsMin, modelDimensionsMax = entity.get_entity_model_dimensions(targetEntity)

    return modelDimensionsMax
end

local function teleport_in_marker(markerPos, interiorId, notificationText)
    local start_Time = os.clock()

    while not (
        NATIVES.NETWORK.NETWORK_IS_PLAYER_IN_MP_CUTSCENE(player.player_id())
        or is_myself_in_interior(interiorId)
    ) do
        system.yield()

        teleport_myself(markerPos.x, markerPos.y, markerPos.z)
        system.yield(1000)
        -- [BUG]: Doesn't work in first person ...
        entity.set_entity_heading(player.player_ped(), 360.0)
        system.yield(2000)

        if (os.clock() - start_Time) >= 3 then
            menu.notify(notificationText, SCRIPT_TITLE, 3, COLOR.BLUE.int)
            start_Time = os.clock()
        end
    end

    while not is_myself_in_interior(interiorId) do
        system.yield()

        if (os.clock() - start_Time) >= 1 then
            menu.notify(notificationText, SCRIPT_TITLE, 1, COLOR.BLUE.int)
            start_Time = os.clock()
        end
    end
end


local nightclubs = {
    [1]  = v3(756.989,-1332.463,26.2802),
    [2]  = v3(345.2846,-977.7734,29.4634),
    [3]  = v3(-120.798,-1260.488,28.3088),
    [4]  = v3(5.667,221.309,106.7566),
    [5]  = v3(871.312,-2099.551,29.4768),
    [6]  = v3(-676.6141,-2458.2104,12.9444),
    [7]  = v3(195.416,-3167.3811,4.7903),
    [8]  = v3(371.0099,252.2451,103.0081),
    [9]  = v3(-1285.0198,-652.3701,25.6332),
    [10] = v3(-1174.5742,-1153.4714,4.6582)
}

local collectibles = {
    actionFigures = {
        {-2557.4053,2315.502,33.742,    name="Pogo"},
        {2487.128,3759.327,42.317,      name="Alien"},
        {457.198,5573.861,780.184,      name="Alien"},
        {-1280.407,2549.743,17.534,     name="Alien"},
        {-107.722,-856.981,38.261,      name="Alien"},
        {-1050.513,-522.612,36.634,     name="Alien"},
        {693.306,1200.583,344.524,      name="Alien"},
        {2500.654,-389.482,94.245,      name="Alien"},
        {483.4,-3110.621,6.627,         name="Alien"},
        {-2169.277,5192.986,16.295,     name="Impotent Rage"},
        {177.674,6394.054,31.376,       name="Impotent Rage"},
        {2416.9421,4994.557,45.239,     name="Impotent Rage"},
        {1702.9,3291,48.72,             name="Impotent Rage"},
        {-600.813,2088.011,132.336,     name="Impotent Rage"},
        {-3019.7935,41.9486,10.2924,    name="Impotent Rage"},
        {-485.4648,-54.441,38.9945,     name="Impotent Rage"},
        {-1350.785,-1547.089,4.675,     name="Impotent Rage"},
        {379.535,-1509.398,29.34,       name="Impotent Rage"},
        {2548.713,385.386,108.423,      name="Impotent Rage"},
        {-769.346,877.307,203.424,      name="Impotent Rage"},
        {-1513.54,1517.184,111.305,     name="Impotent Rage"},
        {-1023.899,190.912,61.282,      name="Impotent Rage"},
        {1136.355,-666.404,57.044,      name="Impotent Rage"},
        {3799.76,4473.048,6.032,        name="Impotent Rage"},
        {1243.588,-2572.136,42.603,     name="Impotent Rage"},
        {219.811,97.162,96.336,         name="Impotent Rage"},
        {-1545.826,-449.397,40.318,     name="Impotent Rage"},
        {-928.683,-2938.691,13.059,     name="Princess Robot Bubblegum"},
        {-1647.926,-1094.716,12.736,    name="Princess Robot Bubblegum"},
        {-2185.939,4249.814,48.803,     name="Princess Robot Bubblegum"},
        {-262.339,4729.229,137.329,     name="Princess Robot Bubblegum"},
        {-311.701,6315.024,31.978,      name="Princess Robot Bubblegum"},
        {3306.444,5194.742,17.432,      name="Princess Robot Bubblegum"},
        {1389.886,3608.834,35.06,       name="Princess Robot Bubblegum"},
        {852.846,2166.327,52.717,       name="Princess Robot Bubblegum"},
        {-1501.96,814.071,181.433,      name="Princess Robot Bubblegum"},
        {2634.972,2931.061,44.608,      name="Princess Robot Bubblegum"},
        {660.57,549.947,129.157,        name="Princess Robot Bubblegum"},
        {-710.626,-905.881,19.015,      name="Princess Robot Bubblegum"},
        {1207.701,-1479.537,35.166,     name="Princess Robot Bubblegum"},
        {-90.151,939.849,232.515,       name="Princess Robot Bubblegum"},
        {-180.059,-631.866,48.534,      name="Princess Robot Bubblegum"},
        {-299.634,2847.173,55.485,      name="Princess Robot Bubblegum"},
        {621.365,-409.254,-1.308,       name="Princess Robot Bubblegum"},
        {-988.92,-102.669,40.157,       name="Princess Robot Bubblegum"},
        {63.999,3683.868,39.763,        name="Pogo"},
        {-688.668,5829.006,16.775,      name="Pogo"},
        {1540.435,6323.453,23.519,      name="Pogo"},
        {2725.806,4142.14,43.293,       name="Pogo"},
        {1297.977,4306.744,37.897,      name="Pogo"},
        {1189.579,2641.222,38.413,      name="Pogo"},
        {-440.796,1596.48,358.648,      name="Pogo"},
        {-2237.557,249.282,175.352,     name="Pogo"},
        {-1211.932,-959.965,0.393,      name="Pogo"},
        {153.845,-3077.341,6.744,       name="Pogo"},
        {-66.231,-1451.825,31.164,      name="Pogo"},
        {987.982,-136.863,73.454,       name="Pogo"},
        {-507.032,393.905,96.411,       name="Pogo"},
        {172.1275,-564.1393,22.145,     name="Pogo"},
        {1497.202,-2133.147,76.302,     name="Pogo"},
        {-2958.706,386.41,14.434,       name="Pogo"},
        {1413.963,1162.483,114.351,     name="Pogo"},
        {-1648.058,3018.313,31.25,      name="R. Space Ranger (Commander)"},
        {-1120.2,4977.292,185.445,      name="R. Space Ranger (Commander)"},
        {1310.683,6545.917,4.798,       name="R. Space Ranger (Commander)"},
        {1714.573,4790.844,41.539,      name="R. Space Ranger (Commander)"},
        {1886.6438,3913.7578,32.039,    name="R. Space Ranger (Commander)"},
        {543.476,3074.79,40.324,        name="R. Space Ranger (Commander)"},
        {1408.045,2157.34,97.575,       name="R. Space Ranger (Commander)"},
        {-3243.858,996.179,12.486,      name="R. Space Ranger (Commander)"},
        {-1905.566,-709.6311,8.766,     name="R. Space Ranger (Commander)"},
        {-1462.089,182.089,54.953,      name="R. Space Ranger (Commander)"},
        {86.997,812.619,211.062,        name="R. Space Ranger (Commander)"},
        {-886.554,-2096.579,8.699,      name="R. Space Ranger (Commander)"},
        {367.684,-2113.475,16.274,      name="R. Space Ranger (Commander)"},
        {679.009,-1522.824,8.834,       name="R. Space Ranger (Commander)"},
        {1667.377,0.119,165.118,        name="R. Space Ranger (Commander)"},
        {-293.486,-342.485,9.481,       name="R. Space Ranger (Commander)"},
        {462.664,-765.675,26.358,       name="R. Space Ranger (Commander)"},
        {-57.784,1939.74,189.655,       name="R. Space Ranger (Commander)"},
        {2618.4114,1692.3947,31.9462,   name="R. Space Ranger (Generic)"},
        {-1894.5538,2043.5173,140.9093, name="R. Space Ranger (Generic)"},
        {2221.8577,5612.785,54.0631,    name="R. Space Ranger (Generic)"},
        {-551.3712,5330.728,73.9861,    name="R. Space Ranger (Generic)"},
        {-2171.4058,3441.188,32.175,    name="R. Space Ranger (Generic)"},
        {1848.131,2700.702,63.008,      name="R. Space Ranger (Generic)"},
        {-1719.6017,-232.886,54.4441,   name="R. Space Ranger (Generic)"},
        {-55.3785,-2519.7546,7.2875,    name="R. Space Ranger (Generic)"},
        {874.8454,-2163.9976,32.3688,   name="R. Space Ranger (Generic)"},
        {-43.6983,-1747.9608,29.2778,   name="R. Space Ranger (Generic)"},
        {173.324,-1208.43,29.6564,      name="R. Space Ranger (Generic)"},
        {2936.3228,4620.4834,48.767,    name="R. Space Ranger (Generic)"},
        {3514.6545,3754.6873,34.4766,   name="R. Space Ranger (Generic)"},
        {656.9,-1046.9314,21.5745,      name="R. Space Ranger (Generic)"},
        {-141.1536,234.8366,99.0008,    name="R. Space Ranger (Generic)"},
        {-1806.68,427.6159,131.765,     name="R. Space Ranger (Generic)"},
        {-908.9565,-1148.9175,2.3868,   name="R. Space Ranger (Generic)"},
        {387.9323,2570.408,43.299,      name="R. Space Ranger (Generic)"},
        {2399.5054,3062.7463,53.4703,   name="Beast", hint="99 and 100 will only appear after you've collected all the others."},
        {2394.7214,3062.6895,51.2379,   name="Sasquatch (Bigfoot)", hint="99 and 100 will only appear after you've collected all the others."}
    },
    ghostsExposed = {
        {63.7611,6664.9165,30.7754,    56.4365,6648.026,35.202,     name="Salton",         hint="Spawns at: [03:00 - 04:00]"},
        {1907.7869,4931.8643,53.9633,  1899.1356,4915.775,53.909,   name="Rurmeth",        hint="Spawns at: [20:00 - 21:00]"},
        {1487.9966,3640.324,34.5941,   1494.1414,3641.636,34.5945,  name="Skidrow",        hint="Spawns at: [21:00 - 22:00]"},
        {2771.9521,4231.4917,47.5589,  2768.0103,4237.0874,47.9673, name="Zombie",         hint="Spawns at: [22:00 - 23:00]"},
        {3428.8845,5175.512,34.8858,   3419.0137,5163.6255,4.9424,  name="Rurmeth",        hint="Spawns at: [23:00 - 00:00]"},
        {162.7387,3132.652,42.6697,    160.3883,3117.737,45.3621,   name="Salton",         hint="Spawns at: [01:00 - 02:00]"},
        {-278.0607,2844.7852,53.0073,  -326.7574,2794.708,71.3455,  name="Zombie",         hint="Spawns at: [02:00 - 03:00]"},
        {-1648.1831,2082.6343,86.9693, -1630.0956,2076.976,75.756,  name="Rurmeth",        hint="Spawns at: [04:00 - 05:00]"},
        {-521.8892,4424.734,88.7805,   -530.072,4534.4917,100.2717, name="Skidrow",        hint="Spawns at: [05:00 - 06:00]"},
        {2015.5793,3827.2444,32.3306,                               name="Johnny Klebitz", hint="Spawns at: [00:00 - 01:00]"}
    },
    ldOrganicsProduct = {
        {-1002.254,130.075,55.519},
        {-1504.595,-36.351,54.707},
        {-1677.4098,-443.6646,39.8968},
        {-842.328,-345.95,38.501},
        {-430.64,288.196,86.174},
        {1575.0677,-1732.0293,87.9448},
        {-2038.497,539.83,109.752},
        {-2973.7725,20.3182,7.4278},
        {-3235.982,1104.414,2.602},
        {-2630.007,1874.927,160.251},
        {-1875.84,2027.968,139.838},
        {-1596.847,3054.303,33.12},
        {1740.868,3327.709,41.211},
        {1323.174,3008.294,44.09},
        {1766.628,3916.891,34.821},
        {2704.12,3521.006,61.773},
        {3608.93,3625.699,40.827},
        {2141.796,4790.2764,40.7243},
        {439.911,6455.761,36.068},
        {1444.224,6331.349,23.806},
        {-581.923,5368.024,70.294},
        {497.611,5606.312,795.85},
        {1384.78,4288.897,36.391},
        {712.585,4111.207,31.65},
        {325.916,4429.151,64.688},
        {-214.4409,3601.9602,61.6145},
        {66.001,3760.242,39.943},
        {98.651,3601.149,39.752},
        {-1147.7292,4949.988,221.278},
        {-2511.306,3613.96,13.469},
        {-1936.931,3329.973,33.215},
        {2497.9932,-429.74,93.2676},
        {3818.776,4488.587,4.532},
        {96.5449,-255.7652,47.0503},
        {-1393.931,-1445.899,4.308},
        {-929.642,-746.513,19.752},
        {154.263,1098.689,231.338},
        {2982.726,6368.5,2.311},
        {-512.5049,-1626.8174,17.4995},
        {-56.232,80.423,71.868},
        {431.973,-2910.015,6.734},
        {664.98,1284.7817,360.1198},
        {-452.9,1079.414,327.803},
        {-196.239,-2354.753,9.478},
        {248.439,128.028,103.099},
        {2661.16,1640.974,24.654},
        {1668.438,-26.473,184.91},
        {-37.931,1937.999,189.8},
        {-1591.535,801.656,186.161},
        {2193.213,5593.691,53.684},
        {1641.563,2656.195,54.855},
        {-1608.398,5262.396,3.966},
        {-937.037,-1044.216,0.436},
        {-2200.313,4237.116,48.046},
        {-1263.3214,-367.5901,44.5355},
        {1018.407,2457.103,44.758},
        {-3091.239,660.393,1.701},
        {-193.708,793.051,197.758},
        {987.808,-105.7523,74.1212},
        {-927.8402,-2934.0337,14.1399},
        {-1640.2965,-3165.1382,40.8515},
        {-1011.2722,-1491.9674,4.7604},
        {343.7568,946.6004,204.4755},
        {750.829,196.948,85.651},
        {-331.626,6285.987,34.8},
        {-311.981,-1626.432,31.473},
        {819.625,-796.649,35.338},
        {132.977,-576.783,18.278},
        {-1442.642,567.622,121.601},
        {-363.567,572.64,127.044},
        {-763.812,705.641,144.732},
        {1902.373,572.778,176.627},
        {-672.715,59.853,61.902},
        {43.7134,2791.5322,57.6598},
        {1220.9852,1902.9747,78.0406},
        {2517.942,2615.929,38.086},
        {3455.177,5510.634,18.769},
        {1500.862,-2513.839,56.26},
        {1467.102,1096.74,113.988},
        {545.206,2880.917,42.441},
        {2612.129,2782.483,34.102},
        {-14.178,6491.451,37.251},
        {-788.846,-2086.048,9.164},
        {981.079,-2583.384,10.37},
        {964.371,-1811.011,31.146},
        {511.737,-1335.028,29.488},
        {-69.0361,-1229.7703,29.3137},
        {202.812,-1758.72,33.229},
        {-328.378,-1372.415,41.193},
        {-1635.991,-1031.127,13.024},
        {955.454,73.628,112.592},
        {265.722,-1335.354,36.17},
        {-1033.097,-825.029,19.049},
        {-592.9804,-875.5658,25.5693},
        {-246.484,-786.507,30.531},
        {479.364,-574.451,28.5},
        {1098.204,-1528.952,34.475},
        {580.785,-2284.23,6.491},
        {-295.973,-308.098,9.511},
        {-117.05,-1025.36,27.318}
    },
    movieProps = {
        {94.202,-1294.965,29.067,     name="Meltdown Film Reel"},
        {-1010.051,-502.175,36.493,   name="WIFA Award"},
        {2517.254,3789.326,53.698,    name="Indian Headdress"},
        {-2349.036,3270.785,32.968,   name="Alien Head"},
        {1165.416,247.5531,-50.73,    name="Mummy Head", extraWait_Time=8},
        {-41.795,2873.231,59.625,     name="Clapperboard"},
        {-1169.573,4926.988,223.7279, name="Monster Mask"},
        {744.011,-971.328,24.57,  463.492,-737.44,27.35,    514.737,-859.692,25.13,  name="Tiger Rug",   hint="Random Event: Vehicle Prop (Pony)"},
        {-667.25,80.216,51.14,    -2316.255,280.381,169.48, -1861.402,150.232,80.22, name="Sarcophagus", hint="Random Event: Vehicle Prop (Rumpo)"},
        {-290.654,6303.431,31.47, -77.11,6537.942,31.50,    1254.091,6483.862,20.62, name="Globe",       hint="Random Event: Vehicle Prop (Rebel)"}
    },
    playingCards = {
        {1992.183,3046.28,47.125},
        {120.38,-1297.669,28.705},
        {79.293,3704.578,40.945},
        {2937.738,5325.846,100.176},
        {727.153,4189.818,40.476},
        {-103.14,369.008,112.267},
        {99.959,6619.539,32.314},
        {-282.6689,6226.274,31.3554},
        {1707.556,4921.021,41.865},
        {-1581.8604,5204.295,3.9093},
        {10.8264,-1101.1573,29.613},
        {1690.0428,3589.0144,35.5883},
        {1159.1442,-316.5876,69.5134},
        {2341.8074,2571.737,47.6079},
        {-3048.193,585.2986,7.7708},
        {-3149.7073,1115.8302,20.7216},
        {-1840.641,-1235.3188,13.2937},
        {810.6056,-2978.7407,5.8116},
        {202.2747,-1645.2251,29.7679},
        {253.2056,215.9778,106.2848},
        {-1166.183,-233.9277,38.262},
        {729.9886,2514.7131,73.1663},
        {188.1851,3076.3318,43.0447},
        {3687.9143,4569.0728,24.9397},
        {1876.9755,6410.034,46.5982},
        {2121.1458,4784.6865,40.8114},
        {900.0845,3558.1562,33.6258},
        {2695.2722,4324.496,45.6516},
        {-1829.4277,798.4049,138.0583},
        {-1203.7251,-1558.8663,4.1736},
        {-73.2829,-2005.4764,18.2561},
        {-1154.2014,-527.2959,31.7117},
        {990.0786,-1800.3907,31.3781},
        {827.5513,-2158.7441,29.417},
        {-1512.0801,-103.625,54.2027},
        {-970.7493,104.3396,55.0431},
        {-428.6815,1213.9049,325.9329},
        {-167.8387,-297.1122,39.0353},
        {2747.3215,3465.1196,55.6336},
        {-1103.659,2714.6895,19.4539},
        {549.4841,-189.3053,54.4369},
        {-1287.6895,-1118.8177,6.3057},
        {1131.428,-982.0297,46.6521},
        {-1028.0834,-2746.9358,13.3589},
        {-538.5779,-1278.5424,26.3437},
        {1326.4489,-1651.2626,52.0964},
        {183.3252,-685.2661,42.607},
        {1487.8461,1129.2,114.3005},
        {-2305.538,3387.973,31.0201},
        {-522.632,4193.4595,193.7517},
        {-748.9897,5599.5337,41.5794},
        {-288.0628,2545.2104,74.4223},
        {2565.3264,296.8703,108.7367},
        {-408.2484,585.783,124.378}
    },
    signalJammers = {
        {1006.372,-2881.68,30.422},
        {-980.242,-2637.703,88.528},
        {-688.195,-1399.329,23.331},
        {1120.696,-1539.165,54.871},
        {2455.134,-382.585,112.635},
        {793.878,-717.299,48.083},
        {-168.3,-590.153,210.936},
        {-1298.3429,-435.8369,108.129},
        {-2276.4841,335.0941,195.723},
        {-667.25,228.545,154.051},
        {682.561,567.5302,153.895},
        {2722.561,1538.1031,85.202},
        {758.539,1273.6871,445.181},
        {-3079.2578,768.5189,31.569},
        {-2359.338,3246.831,104.188},
        {1693.7318,2656.602,60.84},
        {3555.018,3684.98,61.27},
        {1869.0221,3714.4348,117.068},
        {2902.552,4324.699,101.106},
        {-508.6141,4426.661,87.511},
        {-104.417,6227.2783,63.696},
        {1607.5012,6437.3154,32.162},
        {2792.933,5993.922,366.867},
        {1720.6129,4822.467,59.7},
        {-1661.0101,-1126.742,29.773},
        {-1873.49,2058.357,154.407},
        {2122.4602,1750.886,138.114},
        {-417.424,1153.1431,339.128},
        {3303.9011,5169.7925,28.735},
        {-1005.8481,4852.1475,302.025},
        {-306.627,2824.859,69.512},
        {1660.6631,-28.07,179.137},
        {754.647,2584.067,133.904},
        {-279.9081,-1915.608,54.173},
        {-260.4421,-2411.8071,126.019},
        {552.132,-2221.8528,73},
        {394.3919,-1402.144,76.267},
        {1609.7911,-2243.767,130.187},
        {234.2919,220.771,168.981},
        {-1237.1211,-850.4969,82.98},
        {-1272.7319,317.9532,90.352},
        {0.088,-1002.4039,96.32},
        {470.5569,-105.049,135.908},
        {-548.5471,-197.9911,82.813},
        {2581.0469,461.9421,115.095},
        {720.14,4097.634,38.075},
        {1242.4711,1876.0681,92.242},
        {2752.1128,3472.779,67.911},
        {-2191.856,4292.4077,55.013},
        {450.475,5581.514,794.0683}
    },
    snowmen = {
        {-374.0548,6230.472,30.4462},
        {1558.4845,6449.3965,22.8348},
        {3314.504,5165.038,17.386},
        {1709.097,4680.172,41.919},
        {-1414.734,5101.661,59.248},
        {1988.997,3830.344,31.376},
        {234.725,3103.582,41.434},
        {2357.556,2526.069,45.5},
        {1515.591,1721.268,109.26},
        {-45.725,1963.218,188.93},
        {-1517.221,2140.711,54.936},
        {-2830.558,1420.358,99.885},
        {-2974.7288,713.9555,27.3101},
        {-1938.257,589.845,118.757},
        {-456.1271,1126.6056,324.7816},
        {-820.763,165.984,70.254},
        {218.7153,-104.1239,68.7078},
        {902.2285,-285.8174,64.6523},
        {-777.0854,880.5856,202.3774},
        {1270.0951,-645.7452,66.9289},
        {180.9037,-904.4719,29.6439},
        {-958.819,-780.149,16.819},
        {-1105.3816,-1398.6503,4.1505},
        {-252.2187,-1561.5228,30.8514},
        {1340.639,-1585.771,53.218}
    },
    stuntJumps = {
        [1]  = {coords = {_start = v3(2.143237, 1720.5264, 224.36223),    _end = v3(98.661514,1846.0696,173.6653)}},
        [2]  = {coords = {_start = v3(-437.43567, -1196.3062, 52.99947),  _end = v3(-435.02042,-1242.0337,48.43407)}},
        [3]  = {coords = {_start = v3(466.72003, 4319.375, 59.95854),     _end = v3(401.46814,4394.32,61.782753)}},
        [4]  = {coords = {_start = v3(-166.34563, 6578.911, 12.059387),   _end = v3(-151.75652,6588.687,8.772982)}},
        [5]  = {coords = {_start = v3(-977.3154, 4180.1816, 133.4073),    _end = v3(-1068.2544,4267.542,101.99857)}},
        [6]  = {coords = {_start = v3(-7.579316, -1037.7183, 37.534637),  _end = v3(-32.064377,-1018.61975,26.909771)}},
        [7]  = {coords = {_start = v3(-268.0506, -770.5955, 55.124),      _end = v3(-213.37762,-799.55383,28.454012)}},
        [8]  = {coords = {_start = v3(-86.19047, -537.1067, 38.11981),    _end = v3(-102.13432,-526.78503,26.510422)}},
        [9]  = {coords = {_start = v3(-1594.7732, -762.3895, 20.853231),  _end = v3(-1634.0385,-735.4114,9.369503)}},
        [10] = {coords = {_start = v3(-248.65648, -215.40202, 47.082996), _end = v3(-288.78427,-199.22147,36.635315)}},
        [11] = {coords = {_start = v3(-1442.9155, 403.0396, 109.28736),   _end = v3(-1431.1521,327.97552,60.381454)}},
        [12] = {coords = {_start = v3(3351.9866, 5156.3345, 18.207516),   _end = v3(3418.5293,5166.2812,3.857807)}},
        [13] = {coords = {_start = v3(1687.4855, 2340.2605, 73.36435),    _end = v3(1685.3633,2411.0728,43.42663)}},
        [14] = {coords = {_start = v3(307.3563, -621.0101, 42.3353),      _end = v3(-649.0976,27.6553,390.8702)}},
        [15] = {coords = {_start = v3(-882.79474, -854.2749, 17.6236),    _end = v3(-963.61,-859.19727,11.989673)}},
        [16] = {coords = {_start = v3(364.7186, -1162.9991, 28.2918),     _end = v3(-1195.9619,37.1024,344.4012)}},
        [17] = {coords = {_start = v3(396.10138, -1656.2368, 48.000576),  _end = v3(423.40088,-1627.2831,27.291819)}},
        [18] = {coords = {_start = v3(52.473076, -779.20447, 42.219185),  _end = v3(74.71162,-792.1132,29.642887)}},
        [19] = {coords = {_start = v3(32.60692, 6526.0977, 29.624762),    _end = v3(28.092398,6507.57,29.43886)}},
        [20] = {coords = {_start = v3(1789.045, 2049.2378, 65.45301),     _end = v3(1839.6664,1912.0605,56.960133)}},
        [21] = {coords = {_start = v3(-1070.7548, 10.703864, 50.348785),  _end = v3(-1059.8037,7.505019,59.629753)}},
        [22] = {coords = {_start = v3(84.6931, -2196.2747, 5.747),        _end = v3(15.7866,-2207.5728,3.1184)}},
        [23] = {coords = {_start = v3(1637.9042, 3608.2751, 33.474846),   _end = v3(1590.5509,3584.659,30.728943)}},
        [24] = {coords = {_start = v3(566.68, -594.16003, 43.86801),      _end = v3(584.3754,-656.73627,10.542001)}},
        [25] = {coords = {_start = v3(452.99863, -1374.922, 43.02972),    _end = v3(491.9446,-1413.1997,27.305395)}},
        [26] = {coords = {_start = v3(-425.5986, -1555.6082, 22.706762),  _end = v3(-425.47293,-1443.8934,19.719975)}},
        [27] = {coords = {_start = v3(-963.1714, -2778.5056, 14.478279),  _end = v3(-988.8297,-2830.7893,11.964784)}},
        [28] = {coords = {_start = v3(-2009.6931, -319.28024, 47.545036), _end = v3(-2102.1323,-241.92262,7.677715)}},
        [29] = {coords = {_start = v3(1671.9133, 3151.226, 45.29734),     _end = v3(1658.6874,3255.261,38.572178)}},
        [30] = {coords = {_start = v3(-524.65186, -1489.8649, 12.315341), _end = v3(-499.42178,-1491.9802,8.405223)}},
        [31] = {coords = {_start = v3(787.837, -2912.4077, 5.628719),     _end = v3(734.11743,-2910.2605,3.919759)}},
        [32] = {coords = {_start = v3(1978.6943, 1925.877, 87.246),       _end = v3(1918.1731,1913.6854,55.10921)}},
        [33] = {coords = {_start = v3(672.2588, -3003.4043, 6.047905),    _end = v3(782.1926,-2994.9321,4.036896)}},
        [34] = {coords = {_start = v3(108.17593, -2815.1226, 9.17942),    _end = v3(93.96964,-2739.8582,4.505202)}},
        [35] = {coords = {_start = v3(109.05937, -3209.3123, 7.463991),   _end = v3(127.454666,-3257.3904,14.779922)}},
        [36] = {coords = {_start = v3(124.214874, -2954.8147, 9.250035),  _end = v3(128.92989,-3006.8005,15.476112)}},
        [37] = {coords = {_start = v3(174.63142, -2782.5117, 7.013673),   _end = v3(260.69302,-2675.1648,16.322165)}},
        [38] = {coords = {_start = v3(163.6802, -2961.3328, 7.712487),    _end = v3(142.2329,-2895.0386,12.959893)}},
        [39] = {coords = {_start = v3(285.75012, -3014.0552, 8.774601),   _end = v3(274.98248,-2988.7988,3.447593)}},
        [40] = {coords = {_start = v3(371.4717, -2635.26, 9.349143),      _end = v3(506.06033,-2627.2344,4.586116)}},
        [41] = {coords = {_start = v3(-854.31323, -2551.8374, 20.418636), _end = v3(-798.0812,-2469.6638,11.884529)}},
        [42] = {coords = {_start = v3(-986.5257, -2507.1882, 20.45239),   _end = v3(-987.5785,-2554.4663,32.705853)}},
        [43] = {coords = {_start = v3(-589.2717, -1532.1613, 3.122784),   _end = v3(-704.96295,-1488.5146,3.172576)}},
        [44] = {coords = {_start = v3(-626.5751, -1075.8972, 21.066702),  _end = v3(-704.2628,-1075.6385,11.31195)}},
        [45] = {coords = {_start = v3(-453.6471, -1397.4199, 30.327072),  _end = v3(-456.18817,-1440.832,27.297173)}},
        [46] = {coords = {_start = v3(-445.23865, -542.0142, 24.500528),  _end = v3(-445.70044,-442.11624,40.409298)}},
        [47] = {coords = {_start = v3(-594.9152, -109.85971, 40.96681),   _end = v3(-625.0757,-166.66788,35.669353)}},
        [48] = {coords = {_start = v3(-726.34106, -58.790874, 39.675186), _end = v3(-771.4631,-75.396164,35.85175)}},
        [49] = {coords = {_start = v3(1480.1853, -2218.5376, 77.756454),  _end = v3(1429.0216,-2249.86,59.383785)}},
        [50] = {coords = {_start = v3(367.16415, -2522.2588, 6.246408),   _end = v3(401.67624,-2508.9697,10.139722)}}
    },
    -- Arena War: December 11th, 2018
    epsilonRobes = {
        [1] = {tips = 12,  name = "Seeking the Truth", hint = "Need help?\nCheck out the guide on GTA Wiki:\nhttps://gta.fandom.com/wiki/Epsilon_Robes\n\nNote:\nDon't forget that the nightclub toilet attendant only accepts wallet money."},
        [2] = {tips = 157, name = "Chasing the Truth", hint = "Need help?\nCheck out the guide on GTA Wiki:\nhttps://gta.fandom.com/wiki/Epsilon_Robes\n\nNote:\nDon't forget that the nightclub toilet attendant only accepts wallet money."},
        [3] = {tips = 577, name = "Bearing the Truth", hint = "Need help?\nCheck out the guide on GTA Wiki:\nhttps://gta.fandom.com/wiki/Epsilon_Robes\n\nNote:\nDon't forget that the nightclub toilet attendant only accepts wallet money."}
    },
    -- Los Santos Tuners: July 20, 2021
    mediaSticks = {
        -- CREDIT: https://gtalens.com/map/media-sticks
        { group = "Permanent Locations (LS Tuners DLC)", locations = {
            { coords = v3(778.3044,-1859.3079,29.2997), bools = { 31733,31711 }, artist = "CircoLoco Records", title = "Black EP", hint = "Inside LS Car Meet." },
            { coords = v3(955.8713,48.9292,112.0268), bools = { 31730 }, artist = "CircoLoco Records", title = "Blue EP", hint = "On the roof of the Diamond Casino." },
            { coords = v3(778.7164,-1851.8921,29.2997), bools = { 31758,31712 }, artist = "Moodymann", title = "Kenny's Backyard Boogie", hint = "Inside the trunk of randomly parked Moodymann's white Gauntlet Hellfire at the LS Car Meet. The car is not always available." }
            }
        },
        { group = "Permanent Locations (The Contract DLC)", locations = {
            { coords = v3(25.73371,521.6043,170.028), bools = { 31722,31714 }, artist = "NEZ ft. Schoolboy Q", title = "Let's Get It", hint = "At the Franklin Clinton's house." },
            { coords = v3(-861.0848,-230.468,61.228), bools = { 31732,31713 }, artist = "NEZ", title = "You Wanna?", hint = "On the roof of Record A Studios." }
            }
        },
        { group = "Nightclub", locations = {
            { coords = nightclubs[1],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[2],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[3],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[4],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[5],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[6],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[7],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[8],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[9],  bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = nightclubs[10], bools = { 31726,31710 }, artist = "CircoLoco Records", title = "Violet EP", hint = "Note:\nIt only spawns in one of them." }
            }
        },
        { group = "Arcade", locations = {
            { coords = v3(-247.6898,6212.915,30.944), bools = { 31723, 31709 }, artist = "CircoLoco Records", title = "Green EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(1695.1714,4785.1177,40.9847), bools = { 31723, 31709 }, artist = "CircoLoco Records", title = "Green EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(-116.3816,-1772.1368,28.8592), bools = { 31723, 31709 }, artist = "CircoLoco Records", title = "Green EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(-599.5152,279.6308,81.074), bools = { 31723, 31709 }, artist = "CircoLoco Records", title = "Green EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(-1273.2231,-304.1054,37.2289), bools = { 31723, 31709 }, artist = "CircoLoco Records", title = "Green EP", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(758.3455,-815.9312,25.2905), bools = { 31723, 31709 }, artist = "CircoLoco Records", title = "Green EP", hint = "Note:\nIt only spawns in one of them." }
            }
        },
        { group = "Agency", locations = {
            { coords = v3(388.3036,-74.6683,67.1805), bools = { 32316,32294,32287 }, artist = "Dr. Dre", hint = "Note:\nRequires completion of the Dr. Dre contract before it will be available.\nIt only spawns in one of them." },
            { coords = v3(-1016.535,-413.186,38.6161), bools = { 32316,32294,32287 }, artist = "Dr. Dre", hint = "Note:\nRequires completion of the Dr. Dre contract before it will be available.\nIt only spawns in one of them." },
            { coords = v3(-589.4908,-707.4646,35.2844), bools = { 32316,32294,32287 }, artist = "Dr. Dre", hint = "Note:\nRequires completion of the Dr. Dre contract before it will be available.\nIt only spawns in one of them." },
            { coords = v3(-1039.083,-756.4792,18.8395), bools = { 32316,32294,32287 }, artist = "Dr. Dre", hint = "Note:\nRequires completion of the Dr. Dre contract before it will be available.\nIt only spawns in one of them." }
            }
        },
        { group = "Permanent Locations (Chop Shop DLC)", locations = {
            { coords = v3(-55.69081,-1089.542,25.913), bools = { 42149 }, artist = "DâM-FunK", title = "Even the Score", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(77.626,-1946.111,21.038), bools = { 42149 }, artist = "DâM-FunK", title = "Even the Score", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(-435.913,1058.663,327.705), bools = { 42149 }, artist = "DâM-FunK", title = "Even the Score", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(-67.077,-806.703,321.239), bools = { 42149 }, artist = "DâM-FunK", title = "Even the Score", hint = "Note:\nIt only spawns in one of them." },
            { coords = v3(-1636.231,-1091.961,13.238), bools = { 42149 }, artist = "DâM-FunK", title = "Even the Score", hint = "Note:\nIt only spawns in one of them." }
            }
        }
    },
    -- The Criminal Enterprises: July 26th, 2022
    metalDetectors = {
        -- CREDIT: https://gtalens.com/map/metal-detectors
        [1]  = {coords = v3(-3122.528,201.104,1.538)},
        [2]  = {coords = v3(-1802.943,-974.623,1.086)},
        [3]  = {coords = v3(-834.239,-1634.443,0.285)},
        [4]  = {coords = v3(-1814.044,-2721.336,3.397)},
        [5]  = {coords = v3(-28.226,-2732.247,0.507)},
        [6]  = {coords = v3(68.601,-2194.863,0.468)},
        [7]  = {coords = v3(618.367,-2024.049,8.583)},
        [8]  = {coords = v3(1556.522,-2752.049,0.615)},
        [9]  = {coords = v3(2258.103,-2231.355,1.057)},
        [10] = {coords = v3(2827.373,-684.395,-0.042)}
    },
    -- The Criminal Enterprises: August 11, 2022
    weaponComponents = {
        [1]  = {coords = v3(-197.706,6379.5933,30.8371)},
        [2]  = {coords = v3(1782.1915,4608.0522,36.1828)},
        [3]  = {coords = v3(909.8119,3646.6177,35.1457)},
        [4]  = {coords = v3(2529.068,2585.608,36.9449)},
        [5]  = {coords = v3(-2945.886,438.0791,14.2707)},
        [6]  = {coords = v3(-427.0431,292.809,82.2292)},
        [7]  = {coords = v3(814.2508,-485.0651,29.2078)},
        [8]  = {coords = v3(-1516.2374,-884.6562,9.1075)},
        [9]  = {coords = v3(-309.1961,-1186.2217,23.0354)},
        [10] = {coords = v3(488.1019,-2830.6887,1.771)}
    },
    -- Bottom Dollar Bounties: June 25th, 2024
    sprayCans = {
        [1]  = {coords = v3(-95.608,-1447.339,32.416)},
        [2]  = {coords = v3(391.1991,-2001.3088,22.5562)},
        [3]  = {coords = v3(-1374.996,-1429.135,2.573)},
        [4]  = {coords = v3(717.014,-1231.728,23.674)},
        [5]  = {coords = v3(-941.5645,-800.6533,14.9212)},
        [6]  = {coords = v3(294.442,-213.8255,60.5704)},
        [7]  = {coords = v3(2341.6877,2569.9302,45.6776)},
        [8]  = {coords = v3(1480.3708,6412.3506,21.419)},
        [9]  = {coords = v3(-427.2096,5993.384,30.4901)},
        [10] = {coords = v3(2476.1272,3798.8647,39.7158)},
        [11] = {coords = v3(1594.3569,3596.774,34.4348)},
        [12] = {coords = v3(-1130.8267,2678.497,17.3529)},
        [13] = {coords = v3(-2946.0388,411.1234,14.2788)},
        [14] = {coords = v3(1166.3623,-1641.4274,35.9563)},
        [15] = {coords = v3(-602.332,-1700.2163,22.9448)},
        [16] = {coords = v3(763.4998,-2547.4656,9.1047)},
        [17] = {coords = v3(47.9363,-829.5912,30.099)},
        [18] = {coords = v3(1009.5839,-331.524,47.628)},
        [19] = {coords = v3(-1557.8066,-468.7536,34.8082)},
        [20] = {coords = v3(-498.0171,69.3924,55.4961)},
        [21] = {coords = v3(2564.824,278.9633,107.5174)},
        [22] = {coords = v3(559.4123,2674.9053,41.1594)},
        [23] = {coords = v3(79.2603,3723.0315,38.7456)},
        [24] = {coords = v3(781.3615,1280.2087,359.2967)},
        [25] = {coords = v3(-1098.6643,4948.5493,217.3544)},
        [26] = {coords = v3(1684.6514,4834.936,41.0174)},
        [27] = {coords = v3(2666.449,1483.2086,23.6957)},
        [28] = {coords = v3(158.3901,-2912.235,6.2447)},
        [29] = {coords = v3(-1132.1085,-1972.0721,12.1604)},
        [30] = {coords = v3(361.8988,328.2904,102.8024)}
    }
}
local dailyCollectibles = {
    buriedStashes = {
        [1]  = {coords = v3(5579.7026,-5231.42,14.2512)},
        [2]  = {coords = v3(5481.595,-5855.187,19.128)},
        [3]  = {coords = v3(5549.2407,-5747.577,10.427)},
        [4]  = {coords = v3(5295.542,-5587.4307,61.3964)},
        [5]  = {coords = v3(5136.9844,-5524.6675,52.7719)},
        [6]  = {coords = v3(4794.91,-5546.516,21.4945)},
        [7]  = {coords = v3(4895.3125,-5335.3433,9.0204)},
        [8]  = {coords = v3(4994.968,-5136.416,1.476)},
        [9]  = {coords = v3(5323.654,-5276.0596,33.0353)},
        [10] = {coords = v3(5362.1177,-5170.0854,28.035)},
        [11] = {coords = v3(5164.5522,-4706.8384,1.1632)},
        [12] = {coords = v3(4888.6104,-4789.4756,1.4911)},
        [13] = {coords = v3(4735.3096,-4687.2236,1.2879)},
        [14] = {coords = v3(4887.2036,-4630.111,13.149)},
        [15] = {coords = v3(4796.803,-4317.4175,4.3515)},
        [16] = {coords = v3(4522.936,-4649.638,10.037)},
        [17] = {coords = v3(4408.228,-4470.875,3.3683)},
        [18] = {coords = v3(4348.7827,-4311.3193,1.3335)},
        [19] = {coords = v3(4235.67,-4552.0557,4.0738)},
        [20] = {coords = v3(3901.899,-4720.187,3.4537)}
    },
    hiddenCaches = {
        [1]   = {coords = v3(-150.585,-2852.332,-17.97)},
        [2]   = {coords = v3(-540.975,-2465.579,-18.201)},
        [3]   = {coords = v3(15.332,-2323.989,-14.224)},
        [4]   = {coords = v3(461.483,-2386.212,-10.055)},
        [5]   = {coords = v3(839.554,-2782.746,-20.516)},
        [6]   = {coords = v3(1309.934,-2985.761,-21.344)},
        [7]   = {coords = v3(1394.588,-3371.972,-17.855)},
        [8]   = {coords = v3(1067.032,-3610.489,-52.777)},
        [9]   = {coords = v3(371.111,-3226.341,-19.88)},
        [10]  = {coords = v3(-1365.19,-3701.575,-32.056)},
        [11]  = {coords = v3(-1983.722,-2769.391,-22.868)},
        [12]  = {coords = v3(-1295.859,-1948.583,-7.47)},
        [13]  = {coords = v3(-1791.493,-1284.341,-16.36)},
        [14]  = {coords = v3(-1879.817,-1111.846,-19.249)},
        [15]  = {coords = v3(-2086.537,-862.681,-37.465)},
        [16]  = {coords = v3(-2614.496,-636.549,-35.296)},
        [17]  = {coords = v3(-2815.156,-585.703,-59.753)},
        [18]  = {coords = v3(-3412.1304,165.8565,-32.6174)},
        [19]  = {coords = v3(-3554.145,817.679,-28.592)},
        [20]  = {coords = v3(-3440.336,1416.229,-33.629)},
        [21]  = {coords = v3(-3295.557,2020.828,-20.276)},
        [22]  = {coords = v3(-3020.068,2527.044,-22.628)},
        [23]  = {coords = v3(-3183.344,3051.828,-39.251)},
        [24]  = {coords = v3(-3270.3245,3670.6917,-26.5299)},
        [25]  = {coords = v3(-2860.754,3912.275,-33.684)},
        [26]  = {coords = v3(-2752.189,4572.626,-21.415)},
        [27]  = {coords = v3(-2407.659,4898.846,-45.411)},
        [28]  = {coords = v3(-1408.649,5734.096,-36.339)},
        [29]  = {coords = v3(-1008.661,6531.678,-22.122)},
        [30]  = {coords = v3(-811.495,6667.619,-14.098)},
        [31]  = {coords = v3(-420.119,7224.093,-44.899)},
        [32]  = {coords = v3(425.78,7385.154,-44.087)},
        [33]  = {coords = v3(556.131,7158.932,-38.031)},
        [34]  = {coords = v3(1441.456,6828.521,-44.977)},
        [35]  = {coords = v3(1820.262,7017.078,-78.959)},
        [36]  = {coords = v3(2396.039,6939.861,-104.858)},
        [37]  = {coords = v3(2475.159,6704.704,-9.333)},
        [38]  = {coords = v3(2696.607,6655.181,-21.513)},
        [39]  = {coords = v3(3049.285,6549.182,-36.306)},
        [40]  = {coords = v3(3411.339,6308.514,-52.545)},
        [41]  = {coords = v3(3770.457,5838.503,-27.88)},
        [42]  = {coords = v3(3625,5543.203,-26.645)},
        [43]  = {coords = v3(3986.087,3867.625,-31.705)},
        [44]  = {coords = v3(3846.006,3683.454,-17.227)},
        [45]  = {coords = v3(4130.328,3530.792,-27.516)},
        [46]  = {coords = v3(3897.776,3050.804,-19.277)},
        [47]  = {coords = v3(3751.005,2672.416,-48.526)},
        [48]  = {coords = v3(3559.241,2070.137,-38.01)},
        [49]  = {coords = v3(3410.804,1225.255,-55.684)},
        [50]  = {coords = v3(3373.351,323.788,-20.246)},
        [51]  = {coords = v3(3152.983,-261.257,-8.355)},
        [52]  = {coords = v3(3192.368,-367.909,-30.311)},
        [53]  = {coords = v3(3178.722,-988.684,-25.133)},
        [54]  = {coords = v3(2701.915,-1365.816,-13.163)},
        [55]  = {coords = v3(3045.378,-1682.987,-31.797)},
        [56]  = {coords = v3(2952.829,-2313.142,-94.421)},
        [57]  = {coords = v3(2361.167,-2728.077,-67.131)},
        [58]  = {coords = v3(1824.039,-2973.19,-41.865)},
        [59]  = {coords = v3(-575.734,-3132.886,-21.879)},
        [60]  = {coords = v3(-1872.968,-2087.878,-61.897)},
        [61]  = {coords = v3(-3205.486,-144.9,-31.784)},
        [62]  = {coords = v3(-1760.539,5721.301,-74.808)},
        [63]  = {coords = v3(-1293.948,5886.757,-27.186)},
        [64]  = {coords = v3(-6.032,7464.313,-12.313)},
        [65]  = {coords = v3(3627.174,5286.089,-35.437)},
        [66]  = {coords = v3(3978.554,4987.259,-69.702)},
        [67]  = {coords = v3(3995.491,4858.986,-37.555)},
        [68]  = {coords = v3(4218.075,4116.594,-29.013)},
        [69]  = {coords = v3(3795.855,2327.765,-37.352)},
        [70]  = {coords = v3(3247.753,1395.029,-50.268)},
        [71]  = {coords = v3(3451.907,278.014,-99.633)},
        [72]  = {coords = v3(1061.475,7157.525,-28.239)},
        [73]  = {coords = v3(-1551.109,5558.511,-22.472)},
        [74]  = {coords = v3(-29.194,-3484.225,-34.377)},
        [75]  = {coords = v3(2981.125,843.773,-4.586)},
        [76]  = {coords = v3(2446.59,-2413.441,-35.135)},
        [77]  = {coords = v3(423.342,-2864.345,-16.944)},
        [78]  = {coords = v3(668.404,-3173.142,-6.337)},
        [79]  = {coords = v3(-2318.251,4976.115,-101.11)},
        [80]  = {coords = v3(806.924,6846.94,-3.666)},
        [81]  = {coords = v3(4404.907,4617.076,-20.163)},
        [82]  = {coords = v3(3276.699,1648.139,-44.099)},
        [83]  = {coords = v3(2979.325,1.033,-16.746)},
        [84]  = {coords = v3(-838.069,-1436.609,-10.248)},
        [85]  = {coords = v3(-3334.358,3276.015,-27.291)},
        [86]  = {coords = v3(-808.456,6165.307,-3.398)},
        [87]  = {coords = v3(-397.854,6783.974,-19.076)},
        [88]  = {coords = v3(95.133,3898.854,24.086)},
        [89]  = {coords = v3(660.099,3760.461,19.43)},
        [90]  = {coords = v3(2241.487,4022.88,25.675)},
        [91]  = {coords = v3(1553.867,4321.805,19.761)},
        [92]  = {coords = v3(857.875,3958.953,6.001)},
        [93]  = {coords = v3(3431.468,717.226,-93.674)},
        [94]  = {coords = v3(-1634.57,-1741.677,-34.462)},
        [95]  = {coords = v3(-3378.466,503.853,-27.274)},
        [96]  = {coords = v3(-1732.212,5336.15,-7.72)},
        [97]  = {coords = v3(-2612.415,4266.765,-30.535)},
        [98]  = {coords = v3(3406.32,-584.198,-18.545)},
        [99]  = {coords = v3(-3106.876,2432.615,-23.172)},
        [100] = {coords = v3(-2172.952,-3199.194,-33.315)}
    },
    -- CREDIT: https://gtalens.com/map/junk-energy-skydives
    junkEnergySkydives = {
        [1]  = {location = "Pillbox Hill",      coords = v3(-121.199, -962.557, 26.524)},
        [2]  = {location = "FIB Headquarters",  coords = v3(153.572, -721.103, 46.328)},
        [3]  = {location = "Rockford Hills",    coords = v3(-812.47, 299.77, 85.407)},
        [4]  = {location = "Mount Josiah",      coords = v3(-1223.345, 3856.44, 488.126)},
        [5]  = {location = "Mount Chiliad",     coords = v3(426.341, 5612.683, 765.588)},
        [6]  = {location = "Alamo Sea",         coords = v3(503.8174, 5506.424, 773.6786)},
        [7]  = {location = "Pricopio Beach",    coords = v3(813.5065, 5720.619, 693.7969)},
        [8]  = {location = "Cassidy Creek",     coords = v3(-860.4413, 4729.499, 275.6516)},
        [9]  = {location = "Sandy Shores Airf", coords = v3(1717.648, 3295.517, 40.4591)},
        [10] = {location = "McKenzie Field",    coords = v3(2033.484, 4733.43, 40.8773)},
        [11] = {location = "LSIA",              coords = v3(-1167.212, -2494.621, 12.956)},
        [12] = {location = "Palmer-Taylor Pow", coords = v3(2790.4, 1465.635, 23.518)},
        [13] = {location = "La Puerta",         coords = v3(-782.166, -1452.285, 4.013)},
        [14] = {location = "Little Seoul",      coords = v3(-559.43, -909.031, 22.863)},
        [15] = {location = "Paleto Bay",        coords = v3(-136.551, 6356.967, 30.492)},
        [16] = {location = "Grand Senora Dese", coords = v3(742.95, 2535.935, 72.156)},
        [17] = {location = "Banham Canyon",     coords = v3(-2952.79, 441.363, 14.251)},
        [18] = {location = "Tongva Valley",     coords = v3(-1522.113, 1491.642, 110.595)},
        [19] = {location = "Alta",              coords = v3(261.555, -209.291, 60.566)},
        [20] = {location = "La Mesa",           coords = v3(739.4191, -1223.175, 23.7705)},
        [21] = {location = "Del Perro Pier",    coords = v3(-1724.428, -1129.78, 12.0438)},
        [22] = {location = "Baytree Canyon",    coords = v3(735.9623, 1303.177, 359.293)},
        [23] = {location = "Land Act Dam",      coords = v3(2555.34, 301.0995, 107.4623)},
        [24] = {location = "Zancudo River",     coords = v3(-1143.571, 2683.302, 17.0937)},
        [25] = {location = "Vespucci Canals",   coords = v3(-917.5775, -1155.129, 3.7723)}
    },
    shipwreck = {
        [1] = {coords = v3(-388.326,-2216.494,0.456)},
        [2] = {coords = v3(-870.536,-3121.905,2.382)},
        [3] = {coords = v3(-1968.847,-3076.143,2.048)},
        [4] = {coords = v3(-1224.298,-1860.696,1.785)},
        [5] = {coords = v3(-1681.625,-1079.203,0.391)},
        [6] = {coords = v3(-2219.021,-435.363,1.403)},
        [7] = {coords = v3(-3094.448,497.921,1.088)},
        [8] = {coords = v3(-3224.264,1333.485,1.344)},
        [9] = {coords = v3(-2882.416,2246.783,0.94)},
        [10] = {coords = v3(-1767.434,2645.192,0.559)},
        [11] = {coords = v3(-178.102,3081.764,19.454)},
        [12] = {coords = v3(-2199.604,4603.461,1.529)},
        [13] = {coords = v3(-1359.509,5378.855,0.583)},
        [14] = {coords = v3(-847.562,6048.969,1.312)},
        [15] = {coords = v3(123.999,7097.121,0.932)},
        [16] = {coords = v3(474.961,6741.652,0.674)},
        [17] = {coords = v3(1469.995,6632.111,-0.189)},
        [18] = {coords = v3(2355.716,6660.165,0.168)},
        [19] = {coords = v3(3378.922,5673.946,0.863)},
        [20] = {coords = v3(3199.307,5097.294,-0.979)},
        [21] = {coords = v3(3949.8467,4402.4434,0.4147)},
        [22] = {coords = v3(3899.0745,3324.2227,0.9796)},
        [23] = {coords = v3(3647.4497,3122.7847,0.6729)},
        [24] = {coords = v3(2893.9724,1791.9009,1.7525)},
        [25] = {coords = v3(2782.5322,1107.6036,0.5058)},
        [26] = {coords = v3(2782.7258,86.5943,0.5355)},
        [27] = {coords = v3(2822.303,-757.3513,1.4762)},
        [28] = {coords = v3(2774.8013,-1603.5303,0.1327)},
        [29] = {coords = v3(1821.4579,-2718.45,0.0513)},
        [30] = {coords = v3(987.9012,-2683.0593,3.597)}
    },
    treasureChests = {
        {
            name = "land", spawns = {
                [1]  = {id = 1,  coords = v3(4877.7646,-4781.151,1.1379)},
                [2]  = {id = 2,  coords = v3(4535.187,-4703.817,1.1286)},
                [3]  = {id = 3,  coords = v3(3900.6318,-4704.9194,3.4813)},
                [4]  = {id = 4,  coords = v3(4823.4844,-4323.176,4.6816)},
                [5]  = {id = 5,  coords = v3(5175.097,-4678.9375,1.4205)},
                [6]  = {id = 6,  coords = v3(5590.9507,-5216.8467,13.351)},
                [7]  = {id = 7,  coords = v3(5457.7954,-5860.7734,19.0936)},
                [8]  = {id = 8,  coords = v3(4855.598,-5561.794,26.5093)},
                [9]  = {id = 9,  coords = v3(4854.77,-5162.7295,1.4387)},
                [10] = {id = 10, coords = v3(4178.2944,-4357.763,1.5826)}
            }
        }, {
            name = "underwater", spawns = {
                [1]  = {id = 11, coords = v3(4942.0825,-5168.135,-3.575)},
                [2]  = {id = 12, coords = v3(4560.804,-4356.775,-7.888)},
                [3]  = {id = 13, coords = v3(5598.9644,-5604.2393,-6.0489)},
                [4]  = {id = 14, coords = v3(5264.7236,-4920.671,-2.8715)},
                [5]  = {id = 15, coords = v3(4944.2183,-4293.736,-6.6942)},
                [6]  = {id = 16, coords = v3(4560.804,-4356.775,-7.888)}, -- Duplicate of [2] lol
                [7]  = {id = 17, coords = v3(3983.0261,-4540.1865,-6.1264)},
                [8]  = {id = 18, coords = v3(4414.676,-4651.4575,-5.083)},
                [9]  = {id = 19, coords = v3(4540.07,-4774.899,-3.9321)},
                [10] = {id = 20, coords = v3(4777.6006,-5394.6265,-5.0127)}
            }
        }
    },
    trickOrTreats = {
        [1]   = {coords = v3(-189.701,-763.3126,29.454)},
        [2]   = {coords = v3(-233.321,-909.614,31.3158)},
        [3]   = {coords = v3(-553.5505,-815.0607,29.6916)},
        [4]   = {coords = v3(-728.8868,-678.7939,29.315)},
        [5]   = {coords = v3(-1185.5071,-566.7111,27.3348)},
        [6]   = {coords = v3(-1339.806,-409.658,35.373)},
        [7]   = {coords = v3(-1536.5579,-423.9365,34.597)},
        [8]   = {coords = v3(-1580.6218,-952.5058,12.0174)},
        [9]   = {coords = v3(-1976.58,-532.485,10.826)},
        [10]  = {coords = v3(-1884.625,-366.126,48.354)},
        [11]  = {coords = v3(-1289.2849,-1115.446,6.0404)},
        [12]  = {coords = v3(-1503.1207,-936.5198,9.1563)},
        [13]  = {coords = v3(-1334.7336,-1280.1775,3.836)},
        [14]  = {coords = v3(-1183.4398,-1559.4344,3.3591)},
        [15]  = {coords = v3(-971.0191,-1093.4802,1.1503)},
        [16]  = {coords = v3(-840.8212,-1207.8795,5.6051)},
        [17]  = {coords = v3(-296.9001,-1334.1732,30.2995)},
        [18]  = {coords = v3(-225.556,-1500.448,31.131)},
        [19]  = {coords = v3(-121.627,-1489.878,32.821)},
        [20]  = {coords = v3(-195.651,-1607.897,33.0368)},
        [21]  = {coords = v3(-160.142,-1681.59,35.964)},
        [22]  = {coords = v3(-81.4956,-1642.0433,28.3083)},
        [23]  = {coords = v3(-20.704,-1856.823,24.016)},
        [24]  = {coords = v3(23.953,-1897.309,21.969)},
        [25]  = {coords = v3(151.071,-1865.461,23.205)},
        [26]  = {coords = v3(177.9339,-1927.6476,20.0126)},
        [27]  = {coords = v3(224.824,-2036.894,17.38)},
        [28]  = {coords = v3(325.4174,-1946.5948,23.7789)},
        [29]  = {coords = v3(386.328,-1880.668,25.035)},
        [30]  = {coords = v3(321.5227,-1758.7201,28.3096)},
        [31]  = {coords = v3(496.8552,-1819.1217,27.501)},
        [32]  = {coords = v3(430.3069,-1724.5426,28.6064)},
        [33]  = {coords = v3(413.243,-1487.521,29.152)},
        [34]  = {coords = v3(376.6,-2067.951,20.369)},
        [35]  = {coords = v3(297.152,-2096.86,16.667)},
        [36]  = {coords = v3(1257.384,-1762.429,48.662)},
        [37]  = {coords = v3(1310.985,-1698.068,56.836)},
        [38]  = {coords = v3(1203.222,-1672.258,41.356)},
        [39]  = {coords = v3(1296.15,-1619.214,53.224)},
        [40]  = {coords = v3(1231.962,-1590.563,52.769)},
        [41]  = {coords = v3(1152.695,-1531.528,34.3815)},
        [42]  = {coords = v3(1184.524,-1464.062,33.823)},
        [43]  = {coords = v3(1320.3418,-1557.6378,50.2518)},
        [44]  = {coords = v3(1435.174,-1491.414,62.625)},
        [45]  = {coords = v3(806.0478,-1073.2883,27.924)},
        [46]  = {coords = v3(847.3984,-1021.431,26.536)},
        [47]  = {coords = v3(477.993,-976.005,26.982)},
        [48]  = {coords = v3(387.744,-973.043,28.437)},
        [49]  = {coords = v3(359.719,-1072.742,28.545)},
        [50]  = {coords = v3(262.8465,-1026.9795,28.2158)},
        [51]  = {coords = v3(244.76,-1073.888,28.287)},
        [52]  = {coords = v3(1209.887,-1388.9767,34.3769)},
        [53]  = {coords = v3(1142.299,-981.9567,45.1429)},
        [54]  = {coords = v3(73.529,-1026.593,28.475)},
        [55]  = {coords = v3(68.017,-960.636,28.807)},
        [56]  = {coords = v3(-16.947,-979.452,28.503)},
        [57]  = {coords = v3(-1205.7654,-1135.7906,6.8417)},
        [58]  = {coords = v3(-1124.566,-1089.562,1.549)},
        [59]  = {coords = v3(-1075.785,-1027.721,3.548)},
        [60]  = {coords = v3(-961.535,-940.509,1.149)},
        [61]  = {coords = v3(-1028.6696,-920.2025,4.0462)},
        [62]  = {coords = v3(-1150.722,-990.091,1.149)},
        [63]  = {coords = v3(-1726.561,-192.421,57.511)},
        [64]  = {coords = v3(-62.999,-1450.7926,31.1237)},
        [65]  = {coords = v3(-1548.042,-90.522,53.933)},
        [66]  = {coords = v3(-1465.655,-31.124,53.696)},
        [67]  = {coords = v3(-1475.253,63.768,52.328)},
        [68]  = {coords = v3(-1565.532,40.189,57.883)},
        [69]  = {coords = v3(-1650.799,150.181,61.167)},
        [70]  = {coords = v3(-1538.653,130.704,56.37)},
        [71]  = {coords = v3(-1179.64,292.144,68.497)},
        [72]  = {coords = v3(-1023.641,358.387,70.36)},
        [73]  = {coords = v3(-1131.7239,390.5965,69.8053)},
        [74]  = {coords = v3(-1214.8945,461.5896,90.8536)},
        [75]  = {coords = v3(-1499.284,523.861,117.271)},
        [76]  = {coords = v3(-1290.1078,648.5641,140.4938)},
        [77]  = {coords = v3(-1123.263,575.838,103.394)},
        [78]  = {coords = v3(-1025.834,505.1749,80.6515)},
        [79]  = {coords = v3(-969.444,434.741,79.57)},
        [80]  = {coords = v3(-864.8736,389.6919,86.4873)},
        [81]  = {coords = v3(-819.564,266.954,85.392)},
        [82]  = {coords = v3(-597.9922,278.1837,81.1112)},
        [83]  = {coords = v3(-571.93,401.957,99.665)},
        [84]  = {coords = v3(-585.74,494.794,106.106)},
        [85]  = {coords = v3(-718.91,490.583,108.388)},
        [86]  = {coords = v3(-884.518,519.033,91.441)},
        [87]  = {coords = v3(-937.445,591.477,100.499)},
        [88]  = {coords = v3(-702.494,589.252,140.929)},
        [89]  = {coords = v3(-888.666,699.998,149.6837)},
        [90]  = {coords = v3(-1019.0078,718.9766,162.9962)},
        [91]  = {coords = v3(-1163.977,729.633,154.61)},
        [92]  = {coords = v3(-578.299,734.835,183.03)},
        [93]  = {coords = v3(-549.275,826.159,196.508)},
        [94]  = {coords = v3(-493.592,739.668,162.035)},
        [95]  = {coords = v3(-447.063,685.288,151.955)},
        [96]  = {coords = v3(-344.611,624.076,170.355)},
        [97]  = {coords = v3(-247.952,622.206,186.809)},
        [98]  = {coords = v3(-137.8688,592.7097,203.5206)},
        [99]  = {coords = v3(-178.251,502.183,135.827)},
        [100] = {coords = v3(-353.838,467.898,111.6)},
        [101] = {coords = v3(-370.018,343.79,108.946)},
        [102] = {coords = v3(-250.332,397.556,110.251)},
        [103] = {coords = v3(-85.666,424.562,112.224)},
        [104] = {coords = v3(-822.3367,813.652,199.8532)},
        [105] = {coords = v3(-1313.3723,451.3146,99.9888)},
        [106] = {coords = v3(-1686.279,-290.491,50.892)},
        [107] = {coords = v3(82.5397,-91.9352,59.5567)},
        [108] = {coords = v3(124.799,66.057,78.74)},
        [109] = {coords = v3(12.9173,-8.399,69.1162)},
        [110] = {coords = v3(-176.8698,86.8545,69.2855)},
        [111] = {coords = v3(-438.5465,-67.3735,42.0095)},
        [112] = {coords = v3(-375.576,44.577,53.428)},
        [113] = {coords = v3(-569.9086,168.254,65.5663)},
        [114] = {coords = v3(1775.932,3740.6697,33.6562)},
        [115] = {coords = v3(1915.427,3825.728,31.443)},
        [116] = {coords = v3(2002.334,3780.291,31.179)},
        [117] = {coords = v3(1923.4122,3916.0962,31.5573)},
        [118] = {coords = v3(1759.4656,3870.6042,33.7011)},
        [119] = {coords = v3(1661.887,3822.058,34.473)},
        [120] = {coords = v3(1419.6428,3668.2358,38.7334)},
        [121] = {coords = v3(439.621,3571.637,32.237)},
        [122] = {coords = v3(247.488,3167.516,41.885)},
        [123] = {coords = v3(197.3604,3030.443,42.8867)},
        [124] = {coords = v3(-286.359,2838.471,53.973)},
        [125] = {coords = v3(-325.2867,2816.4832,58.4498)},
        [126] = {coords = v3(-461.6427,2859.4268,33.7354)},
        [127] = {coords = v3(-37.136,2869.897,58.625)},
        [128] = {coords = v3(470.221,2607.623,43.481)},
        [129] = {coords = v3(563.666,2599.943,42.113)},
        [130] = {coords = v3(733.646,2524.984,72.34)},
        [131] = {coords = v3(721.333,2331.018,50.754)},
        [132] = {coords = v3(789.176,2180.511,51.652)},
        [133] = {coords = v3(843.259,2113.888,51.267)},
        [134] = {coords = v3(1531.9417,1729.3099,108.9177)},
        [135] = {coords = v3(2588.599,3167.521,50.371)},
        [136] = {coords = v3(2618.848,3280.744,54.249)},
        [137] = {coords = v3(2985.0105,3482.104,70.4419)},
        [138] = {coords = v3(1356.3026,1147.1112,112.759)},
        [139] = {coords = v3(1533.893,2219.8833,76.2135)},
        [140] = {coords = v3(-148.0881,287.3474,95.804)},
        [141] = {coords = v3(1989.794,3054.594,46.213)},
        [142] = {coords = v3(2166.818,3381.051,45.46)},
        [143] = {coords = v3(2180.096,3497.3606,44.4592)},
        [144] = {coords = v3(2418.844,4021.485,35.802)},
        [145] = {coords = v3(346.24,441.64,146.706)},
        [146] = {coords = v3(325.772,536.228,152.811)},
        [147] = {coords = v3(216.718,621.505,186.634)},
        [148] = {coords = v3(167.685,487.5329,142.1009)},
        [149] = {coords = v3(57.1598,451.9345,145.9096)},
        [150] = {coords = v3(8.554,542.77,174.827)},
        [151] = {coords = v3(-148.985,996.5,235.885)},
        [152] = {coords = v3(-2006.6747,445.9337,102.021)},
        [153] = {coords = v3(-1975.162,629.493,121.535)},
        [154] = {coords = v3(-1812.3351,342.8018,87.9612)},
        [155] = {coords = v3(-1963.542,246.943,85.567)},
        [156] = {coords = v3(-340.031,6165.106,30.663)},
        [157] = {coords = v3(-404.723,6316.063,27.943)},
        [158] = {coords = v3(-305.281,6329.808,31.4893)},
        [159] = {coords = v3(-245.486,6413.258,30.261)},
        [160] = {coords = v3(-110.0724,6460.96,30.6408)},
        [161] = {coords = v3(-48.2033,6580.343,31.1805)},
        [162] = {coords = v3(56.455,6643.994,31.28)},
        [163] = {coords = v3(-103.7947,6315.484,30.5812)},
        [164] = {coords = v3(2232.9812,5611.867,53.9195)},
        [165] = {coords = v3(1856.4385,3683.8718,33.2675)},
        [166] = {coords = v3(3312.5024,5176.1436,18.6196)},
        [167] = {coords = v3(1662.391,4775.14,41.006)},
        [168] = {coords = v3(1724.5878,4643.4307,42.8755)},
        [169] = {coords = v3(1968.356,4622.632,40.083)},
        [170] = {coords = v3(1309.1057,4362.9126,40.5463)},
        [171] = {coords = v3(722.405,4186.963,39.886)},
        [172] = {coords = v3(92.067,3743.533,38.623)},
        [173] = {coords = v3(33.199,3668.209,38.715)},
        [174] = {coords = v3(-267.7338,2628.924,60.8669)},
        [175] = {coords = v3(-263.6633,2197.2686,129.4037)},
        [176] = {coords = v3(749.868,224.827,86.426)},
        [177] = {coords = v3(133.2061,-567.3676,42.8161)},
        [178] = {coords = v3(-1874.8036,2030.1644,138.7318)},
        [179] = {coords = v3(-1114.113,2689.1895,17.5833)},
        [180] = {coords = v3(-3184.543,1293.3907,13.5473)},
        [181] = {coords = v3(-3205.8713,1151.4941,8.6673)},
        [182] = {coords = v3(-3233.1646,933.7818,16.1599)},
        [183] = {coords = v3(-2997.6167,695.5018,24.7621)},
        [184] = {coords = v3(-3036.4973,491.4613,5.7679)},
        [185] = {coords = v3(-3087.5505,220.9675,13.0732)},
        [186] = {coords = v3(-769.6445,5514.0327,33.8517)},
        [187] = {coords = v3(1706.9729,6425.33,31.7671)},
        [188] = {coords = v3(2452.6084,4964.7036,45.581)},
        [189] = {coords = v3(2638.9387,4245.413,43.7446)},
        [190] = {coords = v3(964.9565,-545.2515,58.3475)},
        [191] = {coords = v3(961.9368,-596.4669,58.9027)},
        [192] = {coords = v3(997.1859,-728.1738,56.8192)},
        [193] = {coords = v3(1207.3008,-621.1257,65.4421)},
        [194] = {coords = v3(1371.0745,-555.7357,73.6891)},
        [195] = {coords = v3(1323.7899,-583.4503,72.2514)},
        [196] = {coords = v3(1261.8739,-428.6422,68.8054)},
        [197] = {coords = v3(1011.4825,-424.2754,63.9561)},
        [198] = {coords = v3(-2553.464,1914.7833,168.0181)},
        [199] = {coords = v3(3688.2966,4563.8584,24.1865)},
        [200] = {coords = v3(-1523.871,852.2529,180.5948)}
    },
    lsTags = {
        [1]  = {coords = v3(-977.6928,-2639.573,16.474)},
        [2]  = {coords = v3(819.4288,-2227.2385,32.6184)},
        [3]  = {coords = v3(37.9683,-1469.2217,32.235)},
        [4]  = {coords = v3(-768.9666,-1321.6681,7.1244)},
        [5]  = {coords = v3(1209.1267,-1505.5887,36.4654)},
        [6]  = {coords = v3(845.3231,-1203.0039,27.46)},
        [7]  = {coords = v3(188.2855,-1843.3844,29.2995)},
        [8]  = {coords = v3(182.0389,-941.2879,32.2661)},
        [9]  = {coords = v3(-501.2574,-684.436,35.186)},
        [10] = {coords = v3(-1636.3019,-1063.8951,15.1266)},
        [11] = {coords = v3(1165.2151,-314.1255,71.217)},
        [12] = {coords = v3(369.5584,-326.8165,49.145)},
        [13] = {coords = v3(-942.4161,-343.455,40.765)},
        [14] = {coords = v3(-2066,-345.2393,15.761)},
        [15] = {coords = v3(-359.6902,141.5108,68.5588)},
        [16] = {coords = v3(2581.005,487.5057,110.868)},
        [17] = {coords = v3(760.227,583.9885,128.3567)},
        [18] = {coords = v3(-481.0848,1112.5974,322.24)},
        [19] = {coords = v3(-1834.4456,788.6052,140.539)},
        [20] = {coords = v3(-3195.2385,1318.3502,11.5263)},
        [21] = {coords = v3(-2557.941,2302.0186,34.956)},
        [22] = {coords = v3(-2219.9644,4222.4917,49.078)},
        [23] = {coords = v3(2469.77,4082.911,39.8446)},
        [24] = {coords = v3(575.3076,2676.81,43.712)},
        [25] = {coords = v3(2741.5925,3453.4548,58.443)},
        [26] = {coords = v3(1928.9758,3736.5696,34.514)},
        [27] = {coords = v3(1723.0552,4790.159,43.9136)},
        [28] = {coords = v3(-756.7117,5600.3823,38.6646)},
        [29] = {coords = v3(1.7607,6410.2383,33.779)},
        [30] = {coords = v3(1411.0867,3608.7688,37.0159)}
    },
    -- Eclipse Blvd Garage Week: February 16, 2023
    gCaches = {
        [1] = {
            zone = v3(1095.4236,-677.9631,54.4793), spawns = {
                [1] = v3(1113.557,-645.957,56.091),
                [2] = v3(1142.874,-662.951,57.135),
                [3] = v3(1146.691,-703.717,56.167),
                [4] = v3(1073.542,-678.236,56.583),
                [5] = v3(1046.454,-722.915,56.419)
            }
        },
        [2] = {
            zone = v3(2043.2688,3533.9194,39.6891), spawns = {
                [1] = v3(2064.713,3489.88,44.223),
                [2] = v3(2081.859,3553.254,42.157),
                [3] = v3(2014.72,3551.499,42.726),
                [4] = v3(1997.019,3507.838,39.666),
                [5] = v3(2045.597,3564.346,39.343)
            }
        },
        [3] = {
            zone = v3(-1328.4795,-1441.1301,3.5707), spawns = {
                [1] = v3(-1317.344,-1481.97,3.923),
                [2] = v3(-1350.041,-1478.273,4.567),
                [3] = v3(-1393.87,-1445.139,3.437),
                [4] = v3(-1367.034,-1413.992,2.611),
                [5] = v3(-1269.861,-1426.272,3.556)
            }
        },
        [4] = {
            zone = v3(-314.0382,2813.678,71.117), spawns = {
                [1] = v3(-295.468,2787.385,59.864),
                [2] = v3(-284.69,2848.234,53.266),
                [3] = v3(-329.193,2803.404,57.787),
                [4] = v3(-306.847,2825.6,58.219),
                [5] = v3(-336.046,2829.988,55.448)
            }
        },
        [5] = {
            zone = v3(-1693.0406,195.5165,62.8455), spawns = {
                [1] = v3(-1725.245,233.946,57.685),
                [2] = v3(-1639.892,225.521,60.336),
                [3] = v3(-1648.48,212.049,59.777),
                [4] = v3(-1693.318,156.665,63.855),
                [5] = v3(-1699.193,179.574,63.185)
            }
        },
        [6] = {
            zone = v3(-929.5993,-751.5354,18.7911), spawns = {
                [1] = v3(-949.714,-710.658,19.604),
                [2] = v3(-938.774,-781.817,19.657),
                [3] = v3(-884.91,-786.863,15.043),
                [4] = v3(-895.257,-729.943,19.143),
                [5] = v3(-932.986,-746.452,19.008)
            }
        },
        [7] = {
            zone = v3(-419.2222,1146.5547,324.8567), spawns = {
                [1] = v3(-425.948,1213.342,324.936),
                [2] = v3(-387.267,1137.65,321.704),
                [3] = v3(-477.999,1135.36,320.123),
                [4] = v3(-431.822,1119.449,325.964),
                [5] = v3(-387.902,1161.655,324.529)
            }
        },
        [8] = {
            zone = v3(-3405.758,967.8626,7.2965), spawns = {
                [1] = v3(-3381.278,965.534,7.426),
                [2] = v3(-3427.724,979.944,7.526),
                [3] = v3(-3413.606,961.845,11.038),
                [4] = v3(-3419.585,977.595,11.167),
                [5] = v3(-3425.687,961.215,7.536)
            }
        },
        [9] = {
            zone = v3(-682.5329,5800.573,16.331), spawns = {
                [1] = v3(-688.732,5828.4,16.696),
                [2] = v3(-673.425,5799.744,16.467),
                [3] = v3(-710.348,5769.631,16.75),
                [4] = v3(-699.926,5801.619,16.504),
                [5] = v3(-660.359,5781.733,18.774)
            }
        },
        [10] = {
            zone = v3(66.9237,6267.2993,30.5192), spawns = {
                [1] = v3(38.717,6264.173,32.88),
                [2] = v3(84.67,6292.286,30.731),
                [3] = v3(97.17,6288.558,38.447),
                [4] = v3(14.453,6243.932,35.445),
                [5] = v3(67.52,6261.744,32.029)
            }
        },
        [11] = {
            zone = v3(2925.033,4639.913,47.5449), spawns = {
                [1] = v3(2954.598,4671.458,50.106),
                [2] = v3(2911.146,4637.608,49.3),
                [3] = v3(2945.212,4624.044,49.078),
                [4] = v3(2941.139,4617.117,52.114),
                [5] = v3(2895.884,4686.396,48.094)
            }
        },
        [12] = {
            zone = v3(1343.5115,4334.412,37.0567), spawns = {
                [1] = v3(1332.319,4271.446,30.646),
                [2] = v3(1353.332,4387.911,43.541),
                [3] = v3(1337.892,4321.563,38.093),
                [4] = v3(1386.603,4366.511,42.236),
                [5] = v3(1303.193,4313.509,36.939)
            }
        },
        [13] = {
            zone = v3(2683.336,1602.0623,23.5239), spawns = {
                [1] = v3(2720.03,1572.762,20.204),
                [2] = v3(2663.161,1581.395,24.418),
                [3] = v3(2658.245,1643.373,24.061),
                [4] = v3(2671.003,1561.394,23.882),
                [5] = v3(2660.104,1606.54,28.61)
            }
        },
        [14] = {
            zone = v3(199.5413,-929.7557,29.6918), spawns = {
                [1] = v3(211.775,-934.269,23.466),
                [2] = v3(198.265,-884.039,30.696),
                [3] = v3(189.542,-919.726,29.96),
                [4] = v3(169.504,-934.841,29.228),
                [5] = v3(212.376,-934.807,29.007)
            }
        },
        [15] = {
            zone = v3(1290.242,-2553.7288,42.7441), spawns = {
                [1] = v3(1330.113,-2520.754,46.365),
                [2] = v3(1328.954,-2538.302,46.976),
                [3] = v3(1237.506,-2572.335,39.791),
                [4] = v3(1244.602,-2563.721,42.646),
                [5] = v3(1278.421,-2565.117,43.544)
            }
        }
    },
    -- Eclipse Blvd Garage Week: February 16th, 2023
    stashHouses = {
        [1]  = {coords = v3(-156.345,6292.5244,30.6833)},
        [2]  = {coords = v3(-1101.3784,4940.878,217.3541)},
        [3]  = {coords = v3(2258.4717,5165.8105,58.1167)},
        [4]  = {coords = v3(2881.7866,4511.734,46.9993)},
        [5]  = {coords = v3(1335.4141,4306.677,37.0984)},
        [6]  = {coords = v3(1857.9542,3854.2195,32.0891)},
        [7]  = {coords = v3(905.7146,3586.9836,32.3914)},
        [8]  = {coords = v3(2404.0786,3127.706,47.1533)},
        [9]  = {coords = v3(550.6724,2655.782,41.223)},
        [10] = {coords = v3(-1100.8274,2722.5867,17.8004)},
        [11] = {coords = v3(-125.9821,1896.2302,196.3329)},
        [12] = {coords = v3(1546.2168,2166.431,77.7258)},
        [13] = {coords = v3(-3169.8516,1034.2666,19.8417)},
        [14] = {coords = v3(121.2199,318.9121,111.1516)},
        [15] = {coords = v3(-583.559,195.3448,70.4433)},
        [16] = {coords = v3(-1308.2467,-168.6344,43.132)},
        [17] = {coords = v3(99.3476,-240.9664,50.3995)},
        [18] = {coords = v3(1152.2288,-431.8629,66.0115)},
        [19] = {coords = v3(-546.0123,-873.7389,26.1988)},
        [20] = {coords = v3(-1293.3013,-1259.5853,3.2025)},
        [21] = {coords = v3(161.7004,-1306.8784,28.3547)},
        [22] = {coords = v3(979.653,-1981.9202,29.6675)},
        [23] = {coords = v3(1124.7676,-1010.5512,43.6728)},
        [24] = {coords = v3(167.95,-2222.4854,6.2361)},
        [25] = {coords = v3(-559.2866,-1803.9038,21.6104)}
    },
    -- Bottom Dollar Bounties: 25 June 2024 (continuation)
    madrazoHits = {
        -- CREDIT: https://gtalens.com/map/madrazo-hits (spawns)
        [1]  = {
            eventTrigger = v3(1355.1779,3600.6501,33.9761),  spawns = {
                v3(1571.202,3687.559,33.736),
                v3(1505.345,3696.325,38.064),
                v3(1478.279,3677.749,33.269)
            }
        },
        [2]  = {
            eventTrigger = v3(2258.5862,3146.8416,47.7513),  spawns = {
                v3(2407.565,3034.177,47.153),
                v3(2424.757,3146.639,47.161),
                v3(2333.051,3035.219,47.151)
            }
        },
        [3]  = {
            eventTrigger = v3(2414.5872,4850.1777,37.2357),  spawns = {
                v3(2414.611,5003.911,45.671),
                v3(2399.046,5021.555,45.094),
                v3(2436.6,4977.404,45.576)
            }
        },
        [4]  = {
            eventTrigger = v3(-306.0638,6248.7246,30.4665),  spawns = {
                v3(-132.3,6377.948,31.18),
                v3(-113.825,6369.969,30.524),
                v3(-108.241,6395.492,30.562)
            }
        },
        [5]  = {
            eventTrigger = v3(924.7427,-2066.5093,29.5178),  spawns = {
                v3(932.552,-1906.909,30.049),
                v3(964.806,-1868.257,30.238),
                v3(970.11,-1932.773,30.134)
            }
        },
        [6]  = {
            eventTrigger = v3(302.9755,-1860.7911,25.7811),  spawns = {
                v3(417.348,-1833.976,27.074),
                v3(378.679,-1869.86,24.662),
                v3(461.487,-1870.195,26.001)
            }
        },
        [7]  = {
            eventTrigger = v3(-592.9996,-882.7405,24.918),   spawns = {
                v3(-692.072,-811.014,23.02),
                v3(-718.762,-904.593,19.043),
                v3(-712.497,-886.102,22.805)
            }
        },
        [8]  = {
            eventTrigger = v3(-140.1684,-1534.7019,33.2548), spawns = {
                v3(-161.368,-1635.99,33.034),
                v3(-209.592,-1592.747,33.869),
                v3(-222.907,-1648.924,37.437)
            }
        },
        [9]  = {
            eventTrigger = v3(1317.918,-1614.6876,51.3666),  spawns = {
                v3(1389.258,-1505.808,57.041),
                v3(1347.077,-1554.153,52.649),
                v3(1409.756,-1488.04,59.657)
            }
        },
        [10] = {
            eventTrigger = v3(650.728,-2872.411,5.057),      spawns = {
                v3(468.922,-3063.352,10.086),
                v3(481.943,-3009.374,5.08),
                v3(551.216,-3050.597,12.289)
            }
        },
        [11] = {
            eventTrigger = v3(-3137.5437,1055.0897,19.3245), spawns = {
                v3(-3282.778,958.951,7.352),
                v3(-3265.664,1044.001,7.576),
                v3(-3239.802,929.082,16.155)
            }
        },
        [12] = {
            eventTrigger = v3(-965.4027,-2608.117,12.981),   spawns = {
                v3(-1080.298,-2724.85,13.403),
                v3(-1034.329,-2732.601,19.169),
                v3(-1042.707,-2767.282,3.64)
            }
        },
        [13] = {
            eventTrigger = v3(219.8501,284.7484,104.4699),   spawns = {
                v3(300.654,200.117,103.343),
                v3(331.197,180.506,102.145),
                v3(286.791,139.467,103.304)
            }
        },
        [14] = {
            eventTrigger = v3(116.2243,3401.1082,36.7988),   spawns = {
                v3(53.43,3635.643,38.684),
                v3(65.875,3606.092,38.809),
                v3(97.385,3602.565,38.764)
            }
        },
        [15] = {
            eventTrigger = v3(-559.1921,175.2093,67.6451),   spawns = {
                v3(-597.305,244.634,81.202),
                v3(-596.452,322.896,83.015),
                v3(-510.926,301.11,82.315)
            }
        }
    }
}
local others = {
    -- Gun Van Week: January 12, 2023
    gunVans = {
        [1]  = {coords = v3(-29.532,6435.136,31.162)},
        [2]  = {coords = v3(1705.214,4819.167,41.75)},
        [3]  = {coords = v3(1795.522,3899.753,33.869)},
        [4]  = {coords = v3(1335.536,2758.746,51.099)},
        [5]  = {coords = v3(795.583,1210.78,338.962)},
        [6]  = {coords = v3(-3192.67,1077.205,20.594)},
        [7]  = {coords = v3(-789.719,5400.921,33.915)},
        [8]  = {coords = v3(-24.384,3048.167,40.703)},
        [9]  = {coords = v3(2666.786,1469.324,24.237)},
        [10] = {coords = v3(-1454.966,2667.503,3.2)},
        [11] = {coords = v3(2340.418,3054.188,47.888)},
        [12] = {coords = v3(1509.183,-2146.795,76.853)},
        [13] = {coords = v3(1137.404,-1358.654,34.322)},
        [14] = {coords = v3(-57.208,-2658.793,5.737)},
        [15] = {coords = v3(1905.017,565.222,175.558)},
        [16] = {coords = v3(974.484,-1718.798,30.296)},
        [17] = {coords = v3(779.077,-3266.297,5.719)},
        [18] = {coords = v3(-587.728,-1637.208,19.611)},
        [19] = {coords = v3(733.99,-736.803,26.165)},
        [20] = {coords = v3(-1694.632,-454.082,40.712)},
        [21] = {coords = v3(-1330.726,-1163.948,4.313)},
        [22] = {coords = v3(-496.618,40.231,52.316)},
        [23] = {coords = v3(275.527,66.509,94.108)},
        [24] = {coords = v3(260.928,-763.35,30.559)},
        [25] = {coords = v3(-478.025,-741.45,30.299)},
        [26] = {coords = v3(894.94,3603.911,32.56)},
        [27] = {coords = v3(-2166.511,4289.503,48.733)},
        [28] = {coords = v3(1465.633,6553.67,13.771)},
        [29] = {coords = v3(1101.032,-335.172,66.944)},
        [30] = {coords = v3(149.683,-1655.674,29.028)}
    },
    -- Eclipse Blvd Garage Week: February 16, 2023
    streetDealers = {
        [1] = {coords = v3(550.8953,-1774.5175,28.3121)},
        [2] = {coords = v3(-154.924,6434.428,30.916)},
        [3] = {coords = v3(400.9768,2635.3691,43.5045)},
        [4] = {coords = v3(1533.846,3796.837,33.456)},
        [5] = {coords = v3(-1666.642,-1080.0201,12.1537)},
        [6] = {coords = v3(-1560.6105,-413.3221,37.1001)},
        [7] = {coords = v3(819.2939,-2988.8562,5.0209)},
        [8] = {coords = v3(1001.701,-2162.448,29.567)},
        [9] = {coords = v3(1388.9678,-1506.0815,57.0407)},
        [10] = {coords = v3(-3054.574,556.711,0.661)},
        [11] = {coords = v3(-72.8903,80.717,70.6161)},
        [12] = {coords = v3(198.6676,-167.0663,55.3187)},
        [13] = {coords = v3(814.636,-280.109,65.463)},
        [14] = {coords = v3(-237.004,-256.513,38.122)},
        [15] = {coords = v3(-493.654,-720.734,22.921)},
        [16] = {coords = v3(156.1586,6656.525,30.5882)},
        [17] = {coords = v3(1986.3129,3786.75,31.2791)},
        [18] = {coords = v3(-685.5629,5762.8706,16.511)},
        [19] = {coords = v3(1707.703,4924.311,41.078)},
        [20] = {coords = v3(1195.3047,2630.4685,36.81)},
        [21] = {coords = v3(167.0163,2228.922,89.7867)},
        [22] = {coords = v3(2724.0076,1483.066,23.5007)},
        [23] = {coords = v3(1594.9329,6452.817,24.3172)},
        [24] = {coords = v3(-2177.397,4275.945,48.12)},
        [25] = {coords = v3(-2521.249,2311.794,32.216)},
        [26] = {coords = v3(-3162.873,1115.6418,19.8526)},
        [27] = {coords = v3(-1145.026,-2048.466,12.218)},
        [28] = {coords = v3(-1304.321,-1318.848,3.88)},
        [29] = {coords = v3(-946.727,322.081,70.357)},
        [30] = {coords = v3(-895.112,-776.624,14.91)},
        [31] = {coords = v3(-250.614,-1527.617,30.561)},
        [32] = {coords = v3(-601.639,-1026.49,21.55)},
        [33] = {coords = v3(2712.9868,4324.1157,44.8521)},
        [34] = {coords = v3(726.772,4169.101,39.709)},
        [35] = {coords = v3(178.3272,3086.2603,42.0742)},
        [36] = {coords = v3(2351.592,2524.249,46.694)},
        [37] = {coords = v3(388.9941,799.6882,186.6764)},
        [38] = {coords = v3(2587.9822,433.6803,107.6139)},
        [39] = {coords = v3(830.2875,-1052.7747,27.6666)},
        [40] = {coords = v3(-759.662,-208.396,36.271)},
        [41] = {coords = v3(-43.7171,-2015.22,17.017)},
        [42] = {coords = v3(124.02,-1039.884,28.213)},
        [43] = {coords = v3(479.0473,-597.5507,27.4996)},
        [44] = {coords = v3(959.67,3619.036,31.668)},
        [45] = {coords = v3(2375.8994,3162.9954,47.2087)},
        [46] = {coords = v3(-1505.687,1526.558,114.257)},
        [47] = {coords = v3(645.737,242.173,101.153)},
        [48] = {coords = v3(1173.1378,-388.2896,70.5896)},
        [49] = {coords = v3(-1801.85,172.49,67.771)},
        [50] = {coords = v3(3729.2568,4524.872,21.4755)}
    }
}


local function has_all_bools(packedStatBoolCodesTable)
    for _, packedStatBoolCode in pairs(packedStatBoolCodesTable) do
        if not NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(packedStatBoolCode, -1) then
            return false
        end
    end
    return true
end

local function has_action_figure(actionFigureId)
    return is_in_range(actionFigureId, 0, 99) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(26811 + actionFigureId, -1) or false
end
local function has_ghost_exposed(ghostExposedId)
    return is_in_range(ghostExposedId, 0, 9) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(41316 + ghostExposedId, -1) or false
end
local function has_ld_organic_product(ldOrganicProductId)
    return is_in_range(ldOrganicProductId, 0, 99) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(34262 + ldOrganicProductId, -1) or false
end
local function has_movie_prop(moviePropId)
    return is_in_range(moviePropId, 0, 9) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(30241 + moviePropId, -1) or false
end
local function has_playing_card(playingCardId)
    return is_in_range(playingCardId, 0, 53) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(26911 + playingCardId, -1) or false
end
local function has_signal_jammer(signalJammerId)
    return is_in_range(signalJammerId, 0, 49) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(28099 + signalJammerId, -1) or false
end
local function has_snowman(snowmanId)
    return is_in_range(snowmanId, 0, 24) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(36630 + snowmanId, -1) or false
end
local function has_epsilon_robe(epsilonRobeId)
    return is_in_range(epsilonRobeId, 0, 2) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(25003 + epsilonRobeId, -1) or false
end
local function has_weapon_component(weaponComponentId)
    return is_in_range(weaponComponentId, 0, 4) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(32319 + weaponComponentId, -1) or false
end
local function has_buried_stash(buriedStashId)
    return is_in_range(buriedStashId, 0, 1) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(25522 + buriedStashId, -1) or false
end
local function has_hidden_cache(hiddenCacheId)
    return is_in_range(hiddenCacheId, 0, 9) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(30297 + hiddenCacheId, -1) or false
end
local function has_junk_energy_skydive(junkEnergySkydiveId)
    --[[
    ChatGPT + decompiled script enginered, I have done nothing but copy paste decompiled and asked GPT to make the working algorythm.
    Expect the code to be buggy / I didn't make it, but it worked so far on my own testings.
    ]]
    if not is_in_range(junkEnergySkydiveId, 0, 9) then
        return false
    end

    -- Calculate the base stat IDs for the specific skydive ID
    local statId1 = 34837 + junkEnergySkydiveId * 4
    local statId2 = 34839 + junkEnergySkydiveId * 4
    local statId3 = 34838 + junkEnergySkydiveId * 4

    -- Check if any of the stats indicate the skydive has been collected
    return NATIVES.STATS.GET_PACKED_STAT_INT_CODE(statId1, -1) ~= 255
        or NATIVES.STATS.GET_PACKED_STAT_INT_CODE(statId2, -1) ~= 255
        or NATIVES.STATS.GET_PACKED_STAT_INT_CODE(statId3, -1) ~= 255
end
local function has_shipwreck(shipwreckId)
    return is_in_range(shipwreckId, 0, 0) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(31734 + shipwreckId, -1) or false
end
local function has_treasure_chest(treasureChestId)
    return is_in_range(treasureChestId, 0, 1) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(30307 + treasureChestId, -1) or false
end
local function has_ls_tag(lsTagId)
    return is_in_range(lsTagId, 0, 4) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(42252 + lsTagId, -1) or false
end
local function has_trick_or_treat(trickOrTreatId)
    local packedStatId = false
    if is_in_range(trickOrTreatId, 0, 9) then
        packedStatId = 34252 + trickOrTreatId
    elseif is_in_range(trickOrTreatId, 10, 199) then
        packedStatId = 34512 + (trickOrTreatId - 10)
    end
    return packedStatId and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(packedStatId, -1) or false
end

-- (this function is not from R* source code)
local function GET_LOCAL_PLAYER_NUM_EPSILON_ROBES_COLLECTED()
    local count = 0
    for i = 1, 3 do
        if has_epsilon_robe(i - 1) then
            count = count + 1
        end
    end
    return count
end

-- (this function is not from R* source code)
local function GET_LOCAL_PLAYER_NUM_USB_RADIO_COLLECTED_COLLECTED()
    --[[
    There is a bug (with R* games) where collecting: group = "Permanent Locations (Chop Shop DLC)" artist = "DâM-FunK", title = "Even the Score
    After going to Singleplayer and going back online, it does not count that one as collected anymore.
    That's the reason I've made this function here.
    The following line is what I'd use if R* didn't fucked up:
    local count = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_USB_RADIO_COLLECTED"), -1) -- Global_2708057.f_425 - v1.69 (b3258)
    ]]
    --
    local count = 0
    for i, mediaStickGroup in ipairs(collectibles.mediaSticks) do
        for i2, location in ipairs(mediaStickGroup.locations) do
            if has_all_bools(location.bools) then
                count = count + 1
            end

            if mediaStickGroup.group == "Nightclub" or mediaStickGroup.group == "Arcade" or mediaStickGroup.group == "Agency" or mediaStickGroup.group == "Permanent Locations (Chop Shop DLC)" then
                break
            end
        end
    end
    return count
end

-- This is the same code as the leaked source code, couldn't find a stat for it.
local function GET_LOCAL_PLAYER_NUM_TACTICAL_RIFLE_COMPONENTS_COLLECTED()
    local count = 0
    for i = 1, 5 do
        if has_weapon_component(i - 1) then
            count = count + 1
        end
    end
    return count
end

-- This is the same code as the leaked source code.
local function is_stunt_jump_completed(stuntJumpId, lastMpChar)
    local invalidstuntJumpId = -1

    if stuntJumpId ~= invalidstuntJumpId then
        local stat = gameplay.get_hash_key("MP" .. lastMpChar .. "_USJS_COMPLETED_MASK")
        local stuntJumpsFoundMask = stats.stat_get_u64(stat)
        return (stuntJumpsFoundMask & (1 << stuntJumpId)) ~= 0
    end

    return false
end

local function auto_mode_pickup(feat, pickup_Table, pickupHashes_Table, collectibleTypeName)
    local collectibleHandlers_Table = {
        ["Action Figures"] = has_action_figure,
        ["Movie Props"]    = has_movie_prop,
        ["Playing Cards"]  = has_playing_card,
    }

    -- Iterate through all pickups
    for i, pickup in ipairs(pickup_Table) do
        if not feat.on then
            break
        end

        -- Skips teleports related to random events.
        if collectibleTypeName == "Movie Props" then
            if i > 7 then
                return
            end
        end

        -- Checks if we didn't already collected that one, if so skip.
        if not collectibleHandlers_Table[collectibleTypeName](i-1) then
            local initialWait_Time = 4
            if pickup["extraWait_Time"] then
                initialWait_Time = pickup["extraWait_Time"]
            end

            if pickup["notification"] then
                menu.notify(pickup["notification"], SCRIPT_TITLE, initialWait_Time, COLOR.BLUE.int)
            end

            menu.notify("Auto Mode (" .. collectibleTypeName .. ") progress: " .. i .. "/" .. #pickup_Table, SCRIPT_TITLE, initialWait_Time, COLOR.BLUE.int)

            teleport_myself(pickup[1], pickup[2], pickup[3])

            -- If this flag is set, it means we must wait a lil longer after a teleport, ex: loading the Casino building.
            if pickup["extraWait_Time"] then
                local start_Time = os.clock()
                while (os.clock() - start_Time) < initialWait_Time do
                    system.yield()
                    teleport_myself(pickup[1], pickup[2], pickup[3])
                    system.yield(100)
                end
            end

            local start_Time = os.clock()
            local foundPickupNearby = false
            local verifyPickup_Time = nil

            -- Check for any matching collectibles for up to 4 seconds
            while (os.clock() - start_Time) < 4 do -- Going under that makes it not collect 100% of them.
                system.yield()

                if foundPickupNearby and (os.clock() - verifyPickup_Time) > 3 then
                    break -- Timeout of 3 seconds if a matched pickup was found, but still not collected
                end

                local nearbyPickups_Table = object.get_all_pickups() -- OBJECT::HAS_PICKUP_BEEN_COLLECTED, OBJECT::DOES_PICKUP_EXIST, OBJECT::DOES_PICKUP_OBJECT_EXIST
                for _, nearbyPickup in pairs(nearbyPickups_Table) do
                    local entityHash = entity.get_entity_model_hash(nearbyPickup)
                    if table_contains(pickupHashes_Table, entityHash) then
                        foundPickupNearby = true
                        verifyPickup_Time = os.clock() -- Init verification time
                        local pickupEntityPos = entity.get_entity_coords(nearbyPickup)
                        teleport_myself(pickupEntityPos.x, pickupEntityPos.y, pickupEntityPos.z)
                        system.yield(1000) -- Wait 1 second before rechecking, I do that in case the player as to "fall" on the ground, in order to collect the pickup.
                        break -- Exit the inner loop to recheck the list of pickups
                    end
                end

                -- Exit the loop if no pickup is found after checking
                if verifyPickup_Time and not foundPickupNearby then
                    break
                end
            end
        end
    end
end

local function auto_mode_e(feat, collectible_Table, collectibleHashes_Table, collectibleTypeName)
    local function start_auto_mode(noClip_Feat)
        local initialWait_Time = 4

        local function try_and_collect_it(collectible)
            local function rotate_around_entity(targetEntity, radius, stepAngle)
                local entityPos = entity.get_entity_coords(targetEntity)
                local startAngle = 0
                local endAngle = 360
                local lookFront_Time = os.clock()
                local lookBehind_Time = nil
                local e_Time = os.clock()
                local e_State = true

                -- Perform the 360-degree rotation
                for angle = startAngle, endAngle - stepAngle, stepAngle do
                    if not feat.on then
                        return
                    end

                    if e_State then
                        if (os.clock() - e_Time) > 0.053 then
                            controls.set_control_normal(0, 51, 0.0)
                            e_State = false
                            e_Time = os.clock()
                        end
                    else
                        if (os.clock() - e_Time) > 0.053 then
                            controls.set_control_normal(0, 51, 1.0)
                            e_State = true
                            e_Time = os.clock()
                        end
                    end

                    if lookFront_Time then
                        lookBehind_Time = nil
                        if (os.clock() - lookFront_Time) > 0.15 then
                            lookFront_Time = nil
                            lookBehind_Time = os.clock()
                        end
                        controls.set_control_normal(0, 26, 0.0)
                    elseif lookBehind_Time then
                        lookFront_Time = nil
                        if (os.clock() - lookBehind_Time) > 0.15 then
                            lookBehind_Time = nil
                            lookFront_Time = os.clock()
                        end
                        controls.set_control_normal(0, 26, 1.0)
                    end

                    system.yield()

                    -- Convert angle to radians
                    local radians = math.rad(angle)

                    -- Calculate the new position based on the angle
                    local xOffset = radius * math.cos(radians)
                    local yOffset = radius * math.sin(radians)

                    -- Calculate the new position
                    local newPos = {
                        x = entityPos.x + xOffset,
                        y = entityPos.y + yOffset,
                        z = entityPos.z
                    }

                    teleport_myself(newPos.x, newPos.y, newPos.z)
                end
            end

            local start_Time = os.clock()
            local verifyCollectible_Time = nil
            local checkNearbyCollectibles_Time = nil
            local collectibleEntity = 0

            -- Check for any matching collectibles for up to {initialWait_Time} seconds
            while (os.clock() - start_Time) < initialWait_Time do -- Going under {initialWait_Time} will makes it not collect 100% of the time depending how fast the world generates on TP.
                if not feat.on then
                    return
                end
                system.yield()

                -- Timeout of 6 seconds if a matched collectible was found, but still not collected
                if verifyCollectible_Time and (os.clock() - verifyCollectible_Time) > 6 then
                    return
                end

                local foundCollectibleThisFrame = false

                -- Update player's nearby collectibles every 0.1 second to reduce CPU usage.
                if not checkNearbyCollectibles_Time or (os.clock() - checkNearbyCollectibles_Time) > 0.1 then
                    for _, collectibleHash in ipairs(collectibleHashes_Table) do
                        collectibleEntity = NATIVES.OBJECT.GET_CLOSEST_OBJECT_OF_TYPE(collectible[1], collectible[2], collectible[3], 0.01, collectibleHash, false, false, false)
                        if collectibleEntity ~= 0 then
                            break
                        end
                    end

                    checkNearbyCollectibles_Time = os.clock()
                end

                if collectibleEntity ~= 0 then
                    foundCollectibleThisFrame = true
                    verifyCollectible_Time = os.clock() -- Init verification time

                    local entityMaxSizeY = get_entity_max_size(collectibleEntity).y
                    local radius = (entityMaxSizeY > 1.0 and entityMaxSizeY) or 1.0
                    local stepAngle = 6 -- Define the angle increment for each step
                    rotate_around_entity(collectibleEntity, radius, stepAngle)
                end

                -- Exit the loop if no collectibles are found after checking
                if verifyCollectible_Time and not foundCollectibleThisFrame then
                    return true
                end
            end

            return false
        end

        local collectibleHandlers_Table = {
            ["LD Organics Product"] = has_ld_organic_product,
        }
        local foundPreviousCollectible = false

        -- Iterate through all collectibles
        for i, collectible in ipairs(collectible_Table) do
            if not feat.on then
                return
            end

            -- Checks if we didn't already collected that one, if so skip.
            if not collectibleHandlers_Table[collectibleTypeName](i-1) then
                menu.notify("Auto Mode (" .. collectibleTypeName .. ") progress: " .. i .. "/" .. #collectible_Table, SCRIPT_TITLE, initialWait_Time, COLOR.BLUE.int)

                if collectible["notification"] then
                    menu.notify(collectible["notification"], SCRIPT_TITLE, initialWait_Time, COLOR.BLUE.int)
                end


                teleport_myself(collectible[1], collectible[2], collectible[3])
                if foundPreviousCollectible then
                    system.yield(3000) -- For 100% it's just requiered.
                end
                foundPreviousCollectible = try_and_collect_it(collectible, initialWait_Time)
            end
        end
    end

    local noClip_Feat = menu.get_feature_by_hierarchy_key("local.misc.no_clip")
    local noClipState = noClip_Feat.on

    start_auto_mode(noClip_Feat)

    -- Restore player/ped settings
    if not noClipState then
        noClip_Feat.on = false
    end
    controls.set_control_normal(0, 26, 0.0)
    controls.set_control_normal(0, 51, 0.0)
    system.yield()
end

local function auto_mode_destroyable(feat, collectible_Table, collectibleHashes_Table, collectibleTypeName)
    local function start_auto_mode(noClip_Feat)
        local function try_and_collect_it(collectible, initialWait_Time)
            local start_Time = os.clock()
            local verifyCollectible_Time = nil

            -- Check for any matching collectibles for up to {initialWait_Time} seconds
            while (os.clock() - start_Time) < initialWait_Time do -- Going under {initialWait_Time} will makes it not collect 100% of the time depending how fast the world generates on TP.
                if not feat.on then
                    return
                end
                system.yield()

                if verifyCollectible_Time and (os.clock() - verifyCollectible_Time) > 3 then
                    return -- Timeout of 3 seconds if a matched collectible to shoot was found, but still not collected
                end

                local foundCollectibleNearby = false
                local nearbyObjects_Table = object.get_all_objects()
                for _, nearbyObject in pairs(nearbyObjects_Table) do
                    local entityHash = entity.get_entity_model_hash(nearbyObject)
                    if table_contains(collectibleHashes_Table, entityHash) then
                        foundCollectibleNearby = true
                        verifyCollectible_Time = os.clock() -- Init verification time
                        local playerPed = player.player_ped()
                        local playerPos = entity.get_entity_coords(playerPed)
                        local collectibleEntity = nearbyObject
                        local collectibleEntityPos = entity.get_entity_coords(collectibleEntity)
                        if NATIVES.SYSTEM.VDIST(collectible[1], collectible[2], collectible[3], collectibleEntityPos.x, collectibleEntityPos.y, collectibleEntityPos.z) <= 0.01 then
                            teleport_myself(collectibleEntityPos.x - 2, collectibleEntityPos.y - 2, collectibleEntityPos.z)
                            NATIVES.FIRE.ADD_OWNED_EXPLOSION(playerPed, collectibleEntityPos.x, collectibleEntityPos.y, collectibleEntityPos.z, 36, 0.2, false, true, 0.0) -- 36 = railgun
                            NATIVES.ENTITY.SET_ENTITY_HEALTH(collectibleEntity, 0, 0, 0) -- not needed but it doesn't hurt
                            --gameplay.shoot_single_bullet_between_coords(playerPos, collectibleEntityPos, 0, gameplay.get_hash_key("weapon_pistol"), playerPed, false, true, 100000.0)
                            break -- Exit the inner loop to recheck the list of collectibles
                        end
                    end
                end

                -- Exit the loop if no collectibles to shoot is found after checking
                if verifyCollectible_Time and not foundCollectibleNearby then
                    system.yield(1000) -- It just depends if you want it to be fast or not. I personally don't like it being too fast.
                    return
                end
            end
        end

        local collectibleHandlers_Table = {
            ["Signal Jammers"] = has_signal_jammer,
            ["Snowmen"] = has_snowman,
        }
        local initialWait_Time = 8

        -- Iterate through all collectibles to shoot
        for i, collectible in ipairs(collectible_Table) do
            if not feat.on then
                return
            end

            -- Checks if we didn't already collected that one, if so skip.
            if not collectibleHandlers_Table[collectibleTypeName](i-1) then
                menu.notify("Auto Mode (" .. collectibleTypeName .. ") progress: " .. i .. "/" .. #collectible_Table, SCRIPT_TITLE, initialWait_Time, COLOR.BLUE.int)

                if collectible["notification"] then
                    menu.notify(collectible["notification"], SCRIPT_TITLE, initialWait_Time, COLOR.BLUE.int)
                end

                if not noClip_Feat.on then
                    noClip_Feat.on = true
                end

                teleport_myself(collectible[1], collectible[2], collectible[3])
                try_and_collect_it(collectible, initialWait_Time)
            end
        end
    end

    local noClip_Feat = menu.get_feature_by_hierarchy_key("local.misc.no_clip")
    local noClipState = noClip_Feat.on

    start_auto_mode(noClip_Feat)

    -- Restore player/ped settings
    if not noClipState then
        noClip_Feat.on = false
    end
end

local function remove_event_listener(eventType, listener)
    if listener and event.remove_event_listener(eventType, listener) then
        return
    end

    return listener
end

local function handle_script_exit(params)
    params = params or {}
    if params.clearAllNotifications == nil then
        params.clearAllNotifications = false
    end
    if params.hasScriptCrashed == nil then
        params.hasScriptCrashed = false
    end

    scriptExitEventListener = remove_event_listener("exit", scriptExitEventListener)

    -- This will delete notifications from other scripts too.
    -- Suggestion is open: https://discord.com/channels/1088976448452304957/1092480948353904752/1253065431720394842
    if params.clearAllNotifications then
        menu.clear_all_notifications()
    end

    if params.hasScriptCrashed then
        menu.notify("Oh no... Script crashed:(\nYou gotta restart it manually.", SCRIPT_NAME, 12, COLOR.RED.int)
    end

    menu.exit()
end
---- Global functions 2/2 END

---- Global event listeners START
scriptExitEventListener = event.add_event_listener("exit", function()
    handle_script_exit()
end)
---- Global event listeners END
-- Globals END


-- Permissions Startup Checking START
local unnecessaryPermissions = {}
local missingPermissions = {}

for _, flag in ipairs(TRUSTED_FLAGS) do
    if menu.is_trusted_mode_enabled(flag.bitValue) then
        if not flag.isRequiered then
            table.insert(unnecessaryPermissions, flag.menuName)
        end
    else
        if flag.isRequiered then
            table.insert(missingPermissions, flag.menuName)
        end
    end
end

if #unnecessaryPermissions > 0 then
    menu.notify("You do not require the following " .. pluralize("permission", #unnecessaryPermissions) .. ":\n" .. table.concat(unnecessaryPermissions, "\n"),
        SCRIPT_NAME, 6, COLOR.ORANGE.int)
end
if #missingPermissions > 0 then
    menu.notify(
        "You need to enable the following " .. pluralize("permission", #missingPermissions) .. ":\n" .. table.concat(missingPermissions, "\n"),
        SCRIPT_NAME, 6, COLOR.RED.int)
    handle_script_exit()
end
-- Permissions Startup Checking END


-- === Main Menu Features === --
local myRootMenu_Feat = menu.add_feature(SCRIPT_TITLE, "parent", 0)

local exitScript_Feat = menu.add_feature("#FF0000DD#Stop Script#DEFAULT#", "action", myRootMenu_Feat.id, function()
    handle_script_exit()
end)
exitScript_Feat.hint = 'Stop "' .. SCRIPT_NAME .. '"'

menu.add_feature("<- - - -  Collectibles by IB_U_Z_Z_A_R_Dl  - - - - ->", "action", myRootMenu_Feat.id)

local collectiblesVMenu_Feat = menu.add_feature("Grand Theft Auto V - [COMING SOON]", "parent", myRootMenu_Feat.id, function(feat)
    feat.parent:toggle()
    feat:select()
end)
collectiblesVMenu_Feat.hint = "This feature will be added later."

local collectiblesOnlineParentMenu_Feat = menu.add_feature("Grand Theft Auto Online", "parent", myRootMenu_Feat.id)

local collectiblesOnlineMenu_Feat = menu.add_feature("Collectibles", "parent", collectiblesOnlineParentMenu_Feat.id)

local seasonalCollectiblesOnlineMenu_Feat = menu.add_feature("[Seasonals]", "parent", collectiblesOnlineMenu_Feat.id)

local randomEventCollectiblesOnlineMenu_Feat = menu.add_feature("[Random Events]", "parent", collectiblesOnlineMenu_Feat.id)


local dailyCollectiblesOnlineMenu_Feat = menu.add_feature("Daily Collectibles", "parent", collectiblesOnlineParentMenu_Feat.id)

local seasonalDailyCollectiblesOnlineMenu_Feat = menu.add_feature("[Seasonal Daily Collectibles]", "parent", dailyCollectiblesOnlineMenu_Feat.id)

local gunVansOnlineMenu_Feat = menu.add_feature("Gun Vans", "parent", collectiblesOnlineParentMenu_Feat.id)

local streetDealersOnlineMenu_Feat = menu.add_feature("Street Dealers", "parent", collectiblesOnlineParentMenu_Feat.id)

------------------------ Action Figures (100)      ------------------------
    local actionFiguresMenu_Feat = menu.add_feature("Action Figures (-1/100)", "parent", collectiblesOnlineMenu_Feat.id, function()
        menu.notify("99 and 100 will only appear after you've collected all the others.", SCRIPT_TITLE, 8, COLOR.BLUE.int)
    end)

    local autoActionFigures_Feat = menu.add_feature("Auto Mode (Invite Only Session recommended)", "toggle", actionFiguresMenu_Feat.id, function(feat)
        if feat.on then
            local actionFiguresHashes_Table = {
                gameplay.get_hash_key("vw_prop_vw_colle_alien"),
                gameplay.get_hash_key("vw_prop_vw_colle_beast"),
                gameplay.get_hash_key("vw_prop_vw_colle_imporage"),
                gameplay.get_hash_key("vw_prop_vw_colle_pogo"),
                gameplay.get_hash_key("vw_prop_vw_colle_prbubble"),
                gameplay.get_hash_key("vw_prop_vw_colle_rsrcomm"),
                gameplay.get_hash_key("vw_prop_vw_colle_rsrgeneric"),
                gameplay.get_hash_key("vw_prop_vw_colle_sasquatch")
            }
            auto_mode_pickup(feat, collectibles.actionFigures, actionFiguresHashes_Table, "Action Figures")
            feat.on = false
        end
    end)
    autoActionFigures_Feat.hint = "This will automatically collect the 100 Action Figures for you, allowing you to go AFK.\n\nFor performance reasons, it is highly recommended to do this in an invite-only session."

    for i, actionFigure in ipairs(collectibles.actionFigures) do
        actionFigure.feat = menu.add_feature("Action Figure " .. i .. " (" .. actionFigure.name .. ")", "action", actionFiguresMenu_Feat.id, function()
            teleport_myself(actionFigure[1], actionFigure[2], actionFigure[3])
        end)
        if actionFigure.hint then
            actionFigure.feat.hint = actionFigure.hint
        end
    end
--
------------------------ Ghosts Exposed (10)       ------------------------
    local ghostsExposedMenu_Feat = menu.add_feature("Ghosts Exposed (-1/25)", "parent", collectiblesOnlineMenu_Feat.id)

    local ghostsExposedTimeOverride_Feat = menu.add_feature("Override Time On Teleport", "toggle", ghostsExposedMenu_Feat.id)
    ghostsExposedTimeOverride_Feat.hint = "Automatically sets the correct in-game time for each ghost's apparition."

    local pauseClock_Feat = menu.get_feature_by_hierarchy_key("local.weather_and_time.pause_clock")
    local setHour_Feat = menu.get_feature_by_hierarchy_key("local.weather_and_time.set_hour")
    local setMinute_Feat = menu.get_feature_by_hierarchy_key("local.weather_and_time.set_minute")

    for i, ghostExposed in ipairs(collectibles.ghostsExposed) do
        ghostExposed.feat = menu.add_feature("Ghosts Exposed " .. i .. " (" .. ghostExposed.name .. ")", "action_value_i", ghostsExposedMenu_Feat.id, function(feat)
            local function extract_first_time(time_range)
                local hour, minute = time_range:match("%[(%d%d):(%d%d) %-")
                return tonumber(hour), tonumber(minute)
            end

            local index = (feat.value == 1 and 1) or 4

            if ghostsExposedTimeOverride_Feat.on then
                if pauseClock_Feat.on then
                    pauseClock_Feat.on = false
                end
                local hour, minute = extract_first_time(ghostExposed.hint)
                setHour_Feat.value = hour
                setHour_Feat:toggle()
                setMinute_Feat.value = minute
                setMinute_Feat:toggle()
            end

            teleport_myself(ghostExposed[index], ghostExposed[index + 1], ghostExposed[index + 2])
        end)
        ghostExposed.feat.min = 1
        ghostExposed.feat.max = 2
        ghostExposed.feat.hint = ghostExposed.hint
    end
--
------------------------ LD Organics Product (100) ------------------------
    local ldOrganicsProductMenu_Feat = menu.add_feature("LD Organics Product (-1/25)", "parent", collectiblesOnlineMenu_Feat.id)

    local autoLdOrganicsProduct_Feat = menu.add_feature("Auto Mode (Invite Only Session recommended)", "toggle", ldOrganicsProductMenu_Feat.id, function(feat)
        if feat.on then
            local ldOrganicsProductHashes_Table = {
                gameplay.get_hash_key("reh_prop_reh_bag_weed_01a")
            }
            auto_mode_e(feat, collectibles.ldOrganicsProduct, ldOrganicsProductHashes_Table, "LD Organics Product")
            feat.on = false
        end
    end)
    autoLdOrganicsProduct_Feat.hint = "This will automatically collect the 100 LD Organics Product for you, allowing you to go AFK.\n\nFor performance reasons, it is highly recommended to do this in an invite-only session."

    for i, ldOrganicProduct in ipairs(collectibles.ldOrganicsProduct) do
        ldOrganicProduct.feat = menu.add_feature("LD Organic Product " .. i, "action", ldOrganicsProductMenu_Feat.id, function()
            teleport_myself(ldOrganicProduct[1], ldOrganicProduct[2], ldOrganicProduct[3])
        end)
    end
--
------------------------ Movie Props (10)          ------------------------
    local moviePropsMenu_Feat = menu.add_feature("Movie Props (-1/10)", "parent", collectiblesOnlineMenu_Feat.id, function()
        menu.notify("There are 10 movie props in total, but 7 of them are fixed.\nThe remaining 3 are random events, such as cars spawning randomly, so I can't assist you with those.", SCRIPT_TITLE, 10, COLOR.BLUE.int)
    end)

    local autoMovieProps_Feat = menu.add_feature("Auto Mode (Invite Only Session recommended)", "toggle", moviePropsMenu_Feat.id, function(feat)
        if feat.on then
            local moviePropsHashes_Table = {
                gameplay.get_hash_key("sum_prop_ac_alienhead_01a"),
                gameplay.get_hash_key("sum_prop_ac_clapperboard_01a"),
                gameplay.get_hash_key("sum_prop_ac_filmreel_01a"),
                gameplay.get_hash_key("sum_prop_ac_headdress_01a"),
                gameplay.get_hash_key("sum_prop_ac_monstermask_01a"),
                gameplay.get_hash_key("sum_prop_ac_mummyhead_01a"),
                gameplay.get_hash_key("sum_prop_ac_wifaaward_01a"),
            }
            auto_mode_pickup(feat, collectibles.movieProps, moviePropsHashes_Table, "Movie Props")
            feat.on = false
        end
    end)
    autoMovieProps_Feat.hint = "This will automatically collect the first 7 Movie Props for you, allowing you to go AFK.\n\nFor performance reasons, it is highly recommended to do this in an invite-only session."

    for i, movieProp in ipairs(collectibles.movieProps) do
        if i <= 7 then
            movieProp.feat = menu.add_feature("Movie Prop " .. i, "action", moviePropsMenu_Feat.id, function()
                teleport_myself(movieProp[1], movieProp[2], movieProp[3])
            end)
        else
            movieProp.feat = menu.add_feature("Movie Prop " .. i .. " (" .. movieProp.name .. ")", "action_value_i", moviePropsMenu_Feat.id, function(feat)
                local index = (feat.value == 1 and 1) or (feat.value == 2 and 4) or 7
                teleport_myself(movieProp[index], movieProp[index + 1], movieProp[index + 2])
            end)
            movieProp.feat.min = 1
            movieProp.feat.max = 3
            movieProp.feat.hint = movieProp.hint
        end
    end
--
------------------------ Playing Cards (54)        ------------------------
    local playingCardsMenu_Feat = menu.add_feature("Playing Cards (-1/54)", "parent", collectiblesOnlineMenu_Feat.id)

    local autoPlayingCards_Feat = menu.add_feature("Auto Mode (Invite Only Session recommended)", "toggle", playingCardsMenu_Feat.id, function(feat)
        if feat.on then
            local playingCardsHashes_Table = {
                gameplay.get_hash_key("vw_prop_vw_lux_card_01a")
            }
            auto_mode_pickup(feat, collectibles.playingCards, playingCardsHashes_Table, "Playing Cards")
            feat.on = false
        end
    end)
    autoPlayingCards_Feat.hint = "This will automatically collect the 54 Playing Cards for you, allowing you to go AFK.\n\nFor performance reasons, it is highly recommended to do this in an invite-only session."


    for i, playingCard in ipairs(collectibles.playingCards) do
        playingCard.feat = menu.add_feature("Playing Card " .. i, "action", playingCardsMenu_Feat.id, function()
            teleport_myself(playingCard[1], playingCard[2], playingCard[3])
        end)
    end
--
------------------------ Signal Jammers (50)       ------------------------
    local signalJammersMenu_Feat = menu.add_feature("Signal Jammers (-1/50)", "parent", collectiblesOnlineMenu_Feat.id)

    local autoSignalJammers_Feat = menu.add_feature("Auto Mode (Invite Only Session recommended)", "toggle", signalJammersMenu_Feat.id, function(feat)
        if feat.on then
            local signalJammersHashes_Table = {
                gameplay.get_hash_key("ch_prop_ch_mobile_jammer_01x")
            }
            auto_mode_destroyable(feat, collectibles.signalJammers, signalJammersHashes_Table, "Signal Jammers")
            feat.on = false
        end
    end)
    autoSignalJammers_Feat.hint = "This will automatically destroy the 50 Signal Jammers for you, allowing you to go AFK.\n\nFor performance reasons, it is highly recommended to do this in an invite-only session."

    for i, signalJammer in ipairs(collectibles.signalJammers) do
        signalJammer.feat = menu.add_feature("Signal Jammer " .. i, "action", signalJammersMenu_Feat.id, function()
            teleport_myself(signalJammer[1], signalJammer[2], signalJammer[3])
        end)
    end
--
------------------------ Snowmen (25)              ------------------------
    local snowmenMenu_Feat = menu.add_feature("Snowmen (-1/25)", "parent", seasonalCollectiblesOnlineMenu_Feat.id)

    local autoSnowmen_Feat = menu.add_feature("Auto Mode (Invite Only Session recommended)", "toggle", snowmenMenu_Feat.id, function(feat)
        if feat.on then
            local snowmenHashes_Table = {
                gameplay.get_hash_key("xm3_prop_xm3_snowman_01a"),
                gameplay.get_hash_key("xm3_prop_xm3_snowman_01b"),
                gameplay.get_hash_key("xm3_prop_xm3_snowman_01c")
            }
            auto_mode_destroyable(feat, collectibles.snowmen, snowmenHashes_Table, "Snowmen")
            feat.on = false
        end
    end)
    autoSnowmen_Feat.hint = "This will automatically destroy the 25 Snowmen for you, allowing you to go AFK.\n\nFor performance reasons, it is highly recommended to do this in an invite-only session."

    for i, snowman in ipairs(collectibles.snowmen) do
        snowman.feat = menu.add_feature("Snowman " .. i, "action", snowmenMenu_Feat.id, function()
            teleport_myself(snowman[1], snowman[2], snowman[3])
        end)
    end
--
------------------------ Stunt Jumps (50)          ------------------------
    local stuntJumpsMenu_Feat = menu.add_feature("Stunt Jumps (-1/50)", "parent", collectiblesOnlineMenu_Feat.id)
    for i, stuntJumpGroup in ipairs(collectibles.stuntJumps) do
        stuntJumpGroup.feat = menu.add_feature("Stunt Jump " .. i, "action_value_i", stuntJumpsMenu_Feat.id, function(feat)
            local selectedCoords = nil
            if feat.value == 1 then
                selectedCoords = stuntJumpGroup.coords._start
            elseif feat.value == 2 then
                selectedCoords = stuntJumpGroup.coords._end
            end
            if selectedCoords then
                teleport_myself(selectedCoords.x, selectedCoords.y, selectedCoords.z, true)
            end
        end)
        stuntJumpGroup.feat.min = 1
        stuntJumpGroup.feat.max = 2
    end
--
------------------------ Epsilon Robes (3)         ------------------------
    local epsilonRobesMenu_Feat = menu.add_feature("Epsilon Robes (-1/3)", "parent", collectiblesOnlineMenu_Feat.id)

    local autoEpsilonRobesMenu_Feat = menu.add_feature("Auto Mode", "toggle", epsilonRobesMenu_Feat.id, function(feat)
        local playerNextToAttendantCoords = v3(-1611.39, -3009.97, -79.01)

        while feat.on and GET_LOCAL_PLAYER_NUM_EPSILON_ROBES_COLLECTED() < 3 do
            local playerCoords = player.get_player_coords(player.player_id())

            if NATIVES.SYSTEM.VDIST(playerCoords.x, playerCoords.y, playerCoords.z, playerNextToAttendantCoords.x, playerNextToAttendantCoords.y, playerNextToAttendantCoords.z) > 0.01 then
                teleport_myself(playerNextToAttendantCoords.x, playerNextToAttendantCoords.y, playerNextToAttendantCoords.z)
            end
            entity.set_entity_heading(player.player_ped(), 40.0)

            controls.set_control_normal(0, 51, 1.0)
            system.yield()
            controls.set_control_normal(0, 51, 0.0)
            system.yield()
        end
        feat.on = false

        controls.set_control_normal(0, 51, 0.0)
        system.yield()
    end)
    autoEpsilonRobesMenu_Feat.hint = "This will automatically spam [E] (INPUT_CONTEXT) to collect all 3 Epsilon Robes, allowing you to go AFK.\n\nIMPORTANT:\n1. You must be in front of the nightclub toilet attendant and have them in view with the camera, or it won't work.\n2. Don't forget that the nightclub toilet attendant only accepts wallet money."

    for i, epsilonRobeGroup in ipairs(collectibles.epsilonRobes) do
        epsilonRobeGroup.feat = menu.add_feature(epsilonRobeGroup.name, "action_value_i", epsilonRobesMenu_Feat.id, function(feat)
            local selectedCoords = nightclubs[feat.value]
            teleport_myself(selectedCoords.x, selectedCoords.y, selectedCoords.z)
        end)
        epsilonRobeGroup.feat.min = 1
        epsilonRobeGroup.feat.max = #nightclubs
        epsilonRobeGroup.feat.hint = "Need help?\nCheck out the guide on GTA Wiki:\nhttps://gta.fandom.com/wiki/Epsilon_Robes"
    end
--
------------------------ Media Sticks (9)          ------------------------
    local mediaSticksMenu_Feat = menu.add_feature("Media Sticks (-1/9)", "parent", collectiblesOnlineMenu_Feat.id)

    for i, mediaStickGroup in ipairs(collectibles.mediaSticks) do
        mediaStickGroup.feat = menu.add_feature(mediaStickGroup.group, "parent", mediaSticksMenu_Feat.id)
        for i2, location in ipairs(mediaStickGroup.locations) do
            location.feat = menu.add_feature("Media Stick: " .. location.artist .. (location.title and " (" .. location.title .. ")" or ""), "action", mediaStickGroup.feat.id, function()
                teleport_myself(location.coords.x, location.coords.y, location.coords.z)
            end)
            location.feat.hint = location.hint or ""
        end
    end
--
------------------------ Metal Detectors (1)       ------------------------
    local metalDetectorsMenu_Feat = menu.add_feature("Metal Detectors (-1/10)", "parent", randomEventCollectiblesOnlineMenu_Feat.id)

    local metalDetectors_Feat = menu.add_feature("Metal Detector", "action_value_i", metalDetectorsMenu_Feat.id, function(feat)
        local index = feat.value
        local selectedMetalDetector = collectibles.metalDetectors[index]
        teleport_myself(selectedMetalDetector.coords.x, selectedMetalDetector.coords.y, selectedMetalDetector.coords.z)
    end)
    metalDetectors_Feat.min = 1
    metalDetectors_Feat.max = #collectibles.metalDetectors
    metalDetectors_Feat.hint = 'Note:\nOnce you collect a "Metal Detector", it will no longer appear on Skeletons. However, you\'ll unlock the "Burried Stashes" Daily Collectible in Cayo Perico.'
--
------------------------ Weapon Components (5)     ------------------------
    local weaponComponentsMenu_Feat = menu.add_feature("Weapon Components (-1/5)", "parent", randomEventCollectiblesOnlineMenu_Feat.id)

    local weaponComponents_Feat = menu.add_feature("Crime Scene (Search Area)", "action_value_i", weaponComponentsMenu_Feat.id, function(feat)
        local index = feat.value
        local selectedWeaponComponent = collectibles.weaponComponents[index]
        teleport_myself(selectedWeaponComponent.coords.x, selectedWeaponComponent.coords.y, selectedWeaponComponent.coords.z)
    end)
    weaponComponents_Feat.min = 1
    weaponComponents_Feat.max = #collectibles.weaponComponents
--
------------------------ Spray Cans (1)            ------------------------
    local sprayCansMenu_Feat = menu.add_feature("Spray Can (-1/1)", "parent", collectiblesOnlineMenu_Feat.id)

    local sprayCans_Feat = menu.add_feature("Spray Can", "action_value_i", sprayCansMenu_Feat.id, function(feat)
        local index = feat.value
        local selectedSprayCan = collectibles.sprayCans[index]
        teleport_myself(selectedSprayCan.coords.x, selectedSprayCan.coords.y, selectedSprayCan.coords.z)
    end)
    sprayCans_Feat.min = 1
    sprayCans_Feat.max = #collectibles.sprayCans
    sprayCans_Feat.hint = 'Note:\nOnce you collect a spray can, no more spray can crates will appear on your map. However, you\'ll unlock the "Ls Tags" collectible, allowing you to spray tags around Los Santos.'
--

------------------------ Buried Stashes (2)        ------------------------
    local buriedStashesMenu_Feat = menu.add_feature("Buried Stashes (-1/2)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, buriedStashGroup in ipairs(dailyCollectibles.buriedStashes) do
        buriedStashGroup.feat = menu.add_feature("Buried Stash " .. i, "action", buriedStashesMenu_Feat.id, function()
            teleport_myself(buriedStashGroup.coords.x, buriedStashGroup.coords.y, buriedStashGroup.coords.z)
        end)
    end
--
------------------------ Hidden Caches (10)        ------------------------
    local hiddenCachesMenu_Feat = menu.add_feature("Hidden Caches (-1/10)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, hiddenCacheGroup in ipairs(dailyCollectibles.hiddenCaches) do
        hiddenCacheGroup.feat = menu.add_feature("Hidden Cache " .. i, "action", hiddenCachesMenu_Feat.id, function()
            teleport_myself(hiddenCacheGroup.coords.x, hiddenCacheGroup.coords.y, hiddenCacheGroup.coords.z)
        end)
    end
--
------------------------ Junk Energy Skydives (10) ------------------------
    local junkEnergySkydivesMenu_Feat = menu.add_feature("Junk Energy Skydives (-1/10)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, junkEnergySkydiveGroup in ipairs(dailyCollectibles.junkEnergySkydives) do
        junkEnergySkydiveGroup.feat = menu.add_feature("Junk Energy Skydive " .. i .. " (" .. junkEnergySkydiveGroup.location .. ")", "action", junkEnergySkydivesMenu_Feat.id, function()
            teleport_myself(junkEnergySkydiveGroup.coords.x, junkEnergySkydiveGroup.coords.y, junkEnergySkydiveGroup.coords.z)
        end)
    end
--
------------------------ Shipwreck (1)             ------------------------
    local shipwreckMenu_Feat = menu.add_feature("Shipwreck (-1/1)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, shipwreckGroup in ipairs(dailyCollectibles.shipwreck) do
        shipwreckGroup.feat = menu.add_feature("Shipwreck " .. i, "action", shipwreckMenu_Feat.id, function()
            teleport_myself(shipwreckGroup.coords.x, shipwreckGroup.coords.y, shipwreckGroup.coords.z)
        end)
    end
--
------------------------ Treasure Chests (2)       ------------------------
    local treasureChestsMenu_Feat = menu.add_feature("Treasure Chests (-1/2)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, treasureChestGroup in ipairs(dailyCollectibles.treasureChests) do
        treasureChestGroup.feat = menu.add_feature("Treasure Chest (" .. treasureChestGroup.name .. ")", "action_value_i", treasureChestsMenu_Feat.id, function(feat)
            local index = feat.value
            if treasureChestGroup.name == "underwater" and index >= 6 then
                index = index + 1
            end
            local selectedTreasureChest = treasureChestGroup.spawns[index]
            teleport_myself(selectedTreasureChest.coords.x, selectedTreasureChest.coords.y, selectedTreasureChest.coords.z)
        end)
        treasureChestGroup.feat.min = 1
        if treasureChestGroup.name == "underwater" then
            treasureChestGroup.feat.max = #treasureChestGroup.spawns - 1
        else
            treasureChestGroup.feat.max = #treasureChestGroup.spawns
        end
    end
--
------------------------ Trick Or Treat (10)       ------------------------
    local trickOrTreatMenu_Feat = menu.add_feature("Trick Or Treat (-1/10)", "parent", seasonalDailyCollectiblesOnlineMenu_Feat.id)

    --local autoTrickOrTreat_Feat = menu.add_feature("Auto Mode (Invite Only Session recommended)", "toggle", trickOrTreatMenu_Feat.id, function(feat)
    --    if feat.on then
    --        local trickOrTreatHashes_Table = {
    --            gameplay.get_hash_key("reh_prop_reh_lantern_pk_01a"),
    --            gameplay.get_hash_key("reh_prop_reh_lantern_pk_01b"),
    --            gameplay.get_hash_key("reh_prop_reh_lantern_pk_01c")
    --        }
    --        auto_mode_e(feat, dailyCollectibles.trickOrTreats, trickOrTreatHashes_Table, "Trick Or Treat")
    --        feat.on = false
    --    end
    --end)
    --autoTrickOrTreat_Feat.hint = "This will automatically collect the 10 Jack O'Lantern for you, allowing you to go AFK.\n\nFor performance reasons, it is highly recommended to do this in an invite-only session."

    for i, trickOrTreatGroup in ipairs(dailyCollectibles.trickOrTreats) do
        trickOrTreatGroup.feat = menu.add_feature("Jack O'Lantern " .. i, "action", trickOrTreatMenu_Feat.id, function()
            teleport_myself(trickOrTreatGroup.coords.x, trickOrTreatGroup.coords.y, trickOrTreatGroup.coords.z)
        end)
    end
--
------------------------ LS Tags (5)               ------------------------
    local lsTagsMenu_Feat = menu.add_feature("LS Tags (-1/5)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, lsTagGroup in ipairs(dailyCollectibles.lsTags) do
        lsTagGroup.feat = menu.add_feature("LS Tag " .. i, "action", lsTagsMenu_Feat.id, function()
            teleport_myself(lsTagGroup.coords.x, lsTagGroup.coords.y, lsTagGroup.coords.z)
        end)
        lsTagGroup.feat.hint = "Note:\nYou must first collect a spray can in order to spray tags around Los Santos."
    end
--
------------------------ G's Cache (1)             ------------------------
    local gCachesMenu_Feat = menu.add_feature("G's Cache (-1/1)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, gCacheGroup in ipairs(dailyCollectibles.gCaches) do
        gCacheGroup.feat = menu.add_feature("G's Cache" .. " (" .. "Search Area " .. i .. ")", "action_value_i", gCachesMenu_Feat.id, function(feat)
            local index = feat.value
            local selectedGCache = gCacheGroup.spawns[index]
            teleport_myself(selectedGCache.x, selectedGCache.y, selectedGCache.z)
        end)
        gCacheGroup.feat.min = 1
        gCacheGroup.feat.max = #gCacheGroup.spawns
    end
--
------------------------ Stash House (1)           ------------------------
    local stashHousesMenu_Feat = menu.add_feature("Stash House (-1/1)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    local stashHouse_Feat = menu.add_feature("Stash House", "action_value_i", stashHousesMenu_Feat.id, function(feat)
        local index = feat.value
        local selectedStashHouse = dailyCollectibles.stashHouses[index]
        teleport_myself(selectedStashHouse.coords.x, selectedStashHouse.coords.y, selectedStashHouse.coords.z)
    end)
    stashHouse_Feat.min = 1
    stashHouse_Feat.max = #dailyCollectibles.stashHouses
--
------------------------ Madrazo Hit (1)           ------------------------
    local madrazoHitsMenu_Feat = menu.add_feature("Madrazo Hit (-1/1)", "parent", dailyCollectiblesOnlineMenu_Feat.id)

    for i, madrazoHitGroup in ipairs(dailyCollectibles.madrazoHits) do
        madrazoHitGroup.feat = menu.add_feature("Madrazo Hit " .. i, "action_value_i", madrazoHitsMenu_Feat.id, function(feat)
            local selectedCoords = nil
            if feat.value == 1 then
                selectedCoords = madrazoHitGroup.eventTrigger
            elseif feat.value >= 2 and feat.value <= 4 then
                selectedCoords = madrazoHitGroup.spawns[feat.value - 1]
            end
            if selectedCoords then
                teleport_myself(selectedCoords.x, selectedCoords.y, selectedCoords.z)
            end
        end)
        madrazoHitGroup.feat.min = 1
        madrazoHitGroup.feat.max = 1 + #madrazoHitGroup.spawns
        madrazoHitGroup.feat.hint = 'Note:\nYou must first buy a "Bail Office", for the "Madrazo Hit" trigger event to spawn in the map.\n\n< 1 > Is the trigger event;\nthe following values are their possible spawns.'
    end
--
------------------------ Gun Van (1)               ------------------------
    local gunVansMenu_Feat = menu.add_feature("Gun Vans (-1/1)", "parent", gunVansOnlineMenu_Feat.id)

    local gunVan_Feat = menu.add_feature("Gun Van", "action_value_i", gunVansMenu_Feat.id, function(feat)
        local index = feat.value
        local selectedGunVan = others.gunVans[index]
        teleport_myself(selectedGunVan.coords.x, selectedGunVan.coords.y, selectedGunVan.coords.z)
    end)
    gunVan_Feat.min = 1
    gunVan_Feat.max = #others.gunVans
--
------------------------ Street Dealers (3)        ------------------------
    local streetDealersMenu_Feat = menu.add_feature("Street Dealers (-1/3)", "parent", streetDealersOnlineMenu_Feat.id)

    local streetDealers_Feat = menu.add_feature("Street Dealer", "action_value_i", streetDealersMenu_Feat.id, function(feat)
        local index = feat.value
        local selectedStreetDealer = others.streetDealers[index]
        teleport_myself(selectedStreetDealer.coords.x, selectedStreetDealer.coords.y, selectedStreetDealer.coords.z)
    end)
    streetDealers_Feat.min = 1
    streetDealers_Feat.max = #others.streetDealers
--

-- Function to remove any color codes from a feat name
local function removeFeatNameColorCodes(featName)
    featName = featName:gsub("^" .. COLOR.COLLECTED.hex, "")
    featName = featName:gsub("^" .. COLOR.FOUND.hex, "")
    featName = featName:gsub("#DEFAULT#$", "")
    return featName
end

local function update_feat_name__collectibles__state(has_collectible__Func, collectiblesTable)
    for i = 1, #collectiblesTable do
        local feat = collectiblesTable[i].feat
        local hasCollectible = has_collectible__Func(i - 1)

        local updatedName = removeFeatNameColorCodes(feat.name)
        if hasCollectible then
            updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
        end
        feat.name = updatedName
    end
end

local function update_feat_name__stunt_jumps__state(is_stunt_jump_completed, lastMpChar)
    for i, stuntJumpGroup in ipairs(collectibles.stuntJumps) do
        local updatedName = removeFeatNameColorCodes(stuntJumpGroup.feat.name)

        if is_stunt_jump_completed(i-1, lastMpChar) then
            updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
        end

        stuntJumpGroup.feat.name = updatedName
    end
end

local function update_feat_name__epsilon_robes__state(has_epsilon_robe, lastMpChar)
    local selectedMaxProgress = {
        [1] = 12,
        [2] = 157,
        [3] = 577
    }

    for i, epsilonRobeGroup in ipairs(collectibles.epsilonRobes) do
        local updatedName = removeFeatNameColorCodes(epsilonRobeGroup.feat.name)

        if has_epsilon_robe(i-1, lastMpChar) then
            updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
        end

        local maxProgressNum = -1
        local currentProgressNum = script.get_global_i(Global.numberOfNightclubToiletAttendantTipped)
        if epsilonRobeGroup.name == "Seeking the Truth" then
            maxProgressNum = 12
            if currentProgressNum >= maxProgressNum then
                currentProgressNum = maxProgressNum
            end
        elseif epsilonRobeGroup.name == "Chasing the Truth" then
            maxProgressNum = 157
            if currentProgressNum >= maxProgressNum then
                currentProgressNum = maxProgressNum
            end
        elseif epsilonRobeGroup.name == "Bearing the Truth" then
            maxProgressNum = 577
            if currentProgressNum >= maxProgressNum then
                currentProgressNum = maxProgressNum
            end
        end

        epsilonRobeGroup.feat.name = updatedName
        epsilonRobeGroup.feat.hint = epsilonRobeGroup.hint .. "\n\nCurrent progress:\n" .. currentProgressNum .. "/" .. maxProgressNum
    end
end

local function update_feat_name__media_sticks__state(resolvedLocationsIds)
    for i, mediaStickGroup in ipairs(collectibles.mediaSticks) do
        local updatedParentFeatName = removeFeatNameColorCodes(mediaStickGroup.feat.name)
        local hasCollectedAllMediaSticks = true

        for i2, location in ipairs(mediaStickGroup.locations) do
            local updatedFeatName = removeFeatNameColorCodes(location.feat.name)

            if has_all_bools(location.bools) then
                updatedFeatName = COLOR.COLLECTED.hex .. updatedFeatName .. "#DEFAULT#"
            else
                if
                    is_session_started()
                    and mediaStickGroup.group == "Permanent Locations (Chop Shop DLC)"
                    and location.artist == "DâM-FunK"
                    and location.title == "Even the Score"
                    and i2 == resolvedLocationsIds.mediaStick_DamFunk_EvenTheScore
                then
                    updatedFeatName = COLOR.FOUND.hex .. updatedFeatName .. "#DEFAULT#"
                end

                hasCollectedAllMediaSticks = false
            end

            location.feat.name = updatedFeatName
        end

        if hasCollectedAllMediaSticks then
            updatedParentFeatName = COLOR.COLLECTED.hex .. updatedParentFeatName .. "#DEFAULT#"
        end

        mediaStickGroup.feat.name = updatedParentFeatName
    end
end

local function update_feat_name__metal_detector__state(hasPlayerCollectedMetalDetectorForBuriedStashes)
    metalDetectors_Feat.name = removeFeatNameColorCodes(metalDetectors_Feat.name)

    if hasPlayerCollectedMetalDetectorForBuriedStashes then
        metalDetectors_Feat.name = COLOR.COLLECTED.hex .. metalDetectors_Feat.name .. "#DEFAULT#"
    end
end

-- weaponComponents goes here

local function update_feat_name__spray_can__state(hasPlayerCollectedSprayCanForPosterTagging)
    sprayCans_Feat.name = removeFeatNameColorCodes(sprayCans_Feat.name)

    if hasPlayerCollectedSprayCanForPosterTagging then
        sprayCans_Feat.name = COLOR.COLLECTED.hex .. sprayCans_Feat.name .. "#DEFAULT#"
    end
end

local function update_feat_name__buried_stashes__state(resolvedLocationsIds)
    local resolvedLocationsSet = {}
    for i, resolvedLocationId in pairs(resolvedLocationsIds.buriedStashes) do
        resolvedLocationsSet[resolvedLocationId] = i
    end

    for i, buriedStashGroup in ipairs(dailyCollectibles.buriedStashes) do
        local updatedName = removeFeatNameColorCodes(buriedStashGroup.feat.name)

        if
            is_session_started()
            and resolvedLocationsSet[i]
        then
            if has_buried_stash(resolvedLocationsSet[i] - 1) then
                updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
            else
                updatedName = COLOR.FOUND.hex .. updatedName .. "#DEFAULT#"
            end
        end

        buriedStashGroup.feat.name = updatedName
        buriedStashGroup.feat.hint = 'Note:\nYou must first collect a "Metal Detector" from a Skeleton in [Collectibles > Random Events], for the chests to spawn in Cayo Perico.'
    end
end

local function update_feat_name__hidden_caches__state(resolvedLocationsIds)
    local resolvedLocationsSet = {}
    for i, resolvedLocationId in pairs(resolvedLocationsIds.hiddenCaches) do
        resolvedLocationsSet[resolvedLocationId] = i
    end

    for i, hiddenCacheGroup in ipairs(dailyCollectibles.hiddenCaches) do
        local updatedName = removeFeatNameColorCodes(hiddenCacheGroup.feat.name)

        if
            is_session_started()
            and resolvedLocationsSet[i]
        then
            if has_hidden_cache(resolvedLocationsSet[i] - 1) then
                updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
            else
                updatedName = COLOR.FOUND.hex .. updatedName .. "#DEFAULT#"
            end
        end

        hiddenCacheGroup.feat.name = updatedName
    end
end

local function update_feat_name__junk_energy_skydives__state(resolvedLocationsIds)
    local resolvedLocationsSet = {}
    for i, resolvedLocationId in pairs(resolvedLocationsIds.junkEnergySkydives) do
        resolvedLocationsSet[resolvedLocationId] = i
    end

    for i, junkEnergySkydiveGroup in ipairs(dailyCollectibles.junkEnergySkydives) do
        local updatedName = removeFeatNameColorCodes(junkEnergySkydiveGroup.feat.name)

        if
            is_session_started()
            and resolvedLocationsSet[i]
        then
            if has_junk_energy_skydive(resolvedLocationsSet[i] - 1) then
                updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
            else
                updatedName = COLOR.FOUND.hex .. updatedName .. "#DEFAULT#"
            end
        end

        junkEnergySkydiveGroup.feat.name = updatedName
    end
end

local function update_feat_name__shipwreck__state(resolvedLocationsIds)
    local resolvedLocationsSet = {}
    for i, resolvedLocationId in pairs(resolvedLocationsIds.shipwreck) do
        resolvedLocationsSet[resolvedLocationId] = i
    end

    for i, shipwreckGroup in ipairs(dailyCollectibles.shipwreck) do
        local updatedName = removeFeatNameColorCodes(shipwreckGroup.feat.name)

        if
            is_session_started()
            and resolvedLocationsSet[i]
        then
            if has_shipwreck(resolvedLocationsSet[i] - 1) then
                updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
            else
                updatedName = COLOR.FOUND.hex .. updatedName .. "#DEFAULT#"
            end
        end

        shipwreckGroup.feat.name = updatedName
    end
end

local function update_feat_name__treasure_chests__state(resolvedLocationsIds)
    local resolvedLocationsSet = {}
    for i, resolvedLocationId in pairs(resolvedLocationsIds.treasureChests) do
        resolvedLocationsSet[resolvedLocationId] = i
    end

    -- I still have to iterate all of em one by one for the hint to update.
    for i, treasureChestGroup in ipairs(dailyCollectibles.treasureChests) do
        local feat = treasureChestGroup.feat
        local selectedChestIndex = feat.value
        if treasureChestGroup.name == "underwater" and selectedChestIndex >= 6 then
            selectedChestIndex = selectedChestIndex + 1
        end
        local updatedName = removeFeatNameColorCodes(treasureChestGroup.feat.name)
        local updatedHint = "This is Treasure Chest #" .. treasureChestGroup.spawns[selectedChestIndex].id
        if treasureChestGroup.name == "underwater" then
            updatedHint = "Note:\nTreasure Chest (underwater) #16 is the same location then #12 so I removed it.\n\n" .. updatedHint
        end
        local foundAt = {}

        for i2, treasureChest in ipairs(treasureChestGroup.spawns) do
            local resolvedFeatIndexFound = i2

            if treasureChestGroup.name == "underwater" then
                if resolvedFeatIndexFound >= 6 then
                    if resolvedFeatIndexFound == 6 then
                        resolvedFeatIndexFound = 2
                    else
                        resolvedFeatIndexFound = resolvedFeatIndexFound - 1
                    end
                end
            end

            if
                is_session_started()
                and resolvedLocationsSet[treasureChest.id]
            then
                if has_treasure_chest(i - 1) then
                    updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
                    table.insert(foundAt, (#foundAt == 0 and "\n\n" or "\n") .. "Collected at: < " .. resolvedFeatIndexFound .. " >")
                else
                    updatedName = COLOR.FOUND.hex .. updatedName .. "#DEFAULT#"
                    table.insert(foundAt, (#foundAt == 0 and "\n\n" or "\n") .. "Found at: < " .. resolvedFeatIndexFound .. " >")
                end
            end
        end

        treasureChestGroup.feat.name = updatedName
        treasureChestGroup.feat.hint = updatedHint .. table.concat(foundAt)
    end
end

local function update_feat_name__ls_tags__state(resolvedLocationsIds)
    local resolvedLocationsSet = {}
    for i, resolvedLocationId in pairs(resolvedLocationsIds.lsTags) do
        resolvedLocationsSet[resolvedLocationId] = i
    end

    for i, lsTagGroup in ipairs(dailyCollectibles.lsTags) do
        local updatedName = removeFeatNameColorCodes(lsTagGroup.feat.name)

        if
            is_session_started()
            and resolvedLocationsSet[i]
        then
            if has_ls_tag(resolvedLocationsSet[i] - 1) then
                updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
            else
                updatedName = COLOR.FOUND.hex .. updatedName .. "#DEFAULT#"
            end
        end

        lsTagGroup.feat.name = updatedName
    end
end

local function update_feat_name__g_caches__state(resolvedLocationsIds, hasPlayerCollectedGCache)
    for i, gCacheGroup in ipairs(dailyCollectibles.gCaches) do
        gCacheGroup.feat.name = removeFeatNameColorCodes(gCacheGroup.feat.name)
        gCacheGroup.feat.hint = ""

        if
            is_session_started()
            and resolvedLocationsIds.gCache.searchArea >= 1
            and resolvedLocationsIds.gCache.searchArea <= #dailyCollectibles.gCaches
            and resolvedLocationsIds.gCache.spawn >= 1
            and resolvedLocationsIds.gCache.spawn <= #dailyCollectibles.gCaches[i].spawns
        then
            if i == resolvedLocationsIds.gCache.searchArea then
                if hasPlayerCollectedGCache then
                    gCacheGroup.feat.name = COLOR.COLLECTED.hex .. gCacheGroup.feat.name .. "#DEFAULT#"
                    gCacheGroup.feat.hint = "Collected at:\n< " .. resolvedLocationsIds.gCache.spawn .. " >"
                else
                    gCacheGroup.feat.name = COLOR.FOUND.hex .. gCacheGroup.feat.name .. "#DEFAULT#"
                    gCacheGroup.feat.hint = "Found at:\n< " .. resolvedLocationsIds.gCache.spawn .. " >"
                end
            end
        end
    end
end

local function update_feat_name__stash_house__state(resolvedLocationsIds, hasPlayerCollectedStashHouse)
    stashHouse_Feat.name = removeFeatNameColorCodes(stashHouse_Feat.name)
    stashHouse_Feat.hint = ""

    if
        is_session_started()
        and resolvedLocationsIds.stashHouse.marker >= 1
        and resolvedLocationsIds.stashHouse.marker <= #dailyCollectibles.stashHouses
    then
        if hasPlayerCollectedStashHouse then
            stashHouse_Feat.name = COLOR.COLLECTED.hex .. stashHouse_Feat.name .. "#DEFAULT#"
            stashHouse_Feat.hint = "Collected at:\n< " .. resolvedLocationsIds.stashHouse.marker .. " >"
        else
            stashHouse_Feat.name = COLOR.FOUND.hex .. stashHouse_Feat.name .. "#DEFAULT#"
            stashHouse_Feat.hint = "Found at:\n< " .. resolvedLocationsIds.stashHouse.marker .. " >"
        end
    end
end

local function update_feat_name__madrazo_hits__state(resolvedLocationsIds, hasPlayerKilledMadrazoHit)
    for i, madrazoHitGroup in ipairs(dailyCollectibles.madrazoHits) do
        local updatedName = removeFeatNameColorCodes(madrazoHitGroup.feat.name)

        if
            is_session_started()
            and i == resolvedLocationsIds.madrazoHits
        then
            if hasPlayerKilledMadrazoHit then
                updatedName = COLOR.COLLECTED.hex .. updatedName .. "#DEFAULT#"
            else
                updatedName = COLOR.FOUND.hex .. updatedName .. "#DEFAULT#"
            end
        end

        madrazoHitGroup.feat.name = updatedName
    end
end

local function update_feat_name__gun_van__state(resolvedLocationsIds, isGunVanAvailable)
    gunVan_Feat.name = removeFeatNameColorCodes(gunVan_Feat.name)
    gunVan_Feat.hint = ""

    if
        is_session_started()
        and isGunVanAvailable
        and resolvedLocationsIds.gunVan.spawn >= 1
        and resolvedLocationsIds.gunVan.spawn <= #others.gunVans
    then
        gunVan_Feat.name = COLOR.FOUND.hex .. gunVan_Feat.name .. "#DEFAULT#"
        gunVan_Feat.hint = "Found at:\n< " .. resolvedLocationsIds.gunVan.spawn .. " >"
    end
end

local function update_feat_name__street_dealers__state(resolvedLocationsIds, areStreetDealersAvailable)
    local function areStreetDealersResolvedLocationsValid(streetDealersResolvedLocationsIds)
        for i = 1, 3 do
            if streetDealersResolvedLocationsIds[i] < 1 or streetDealersResolvedLocationsIds[i] > #others.streetDealers then
                return false
            end
        end
        return true
    end

    streetDealers_Feat.name = removeFeatNameColorCodes(streetDealers_Feat.name)
    streetDealers_Feat.hint = ""

    if
        is_session_started()
        and areStreetDealersAvailable
        and areStreetDealersResolvedLocationsValid(resolvedLocationsIds.streetDealers)
    then
        streetDealers_Feat.name = COLOR.FOUND.hex .. streetDealers_Feat.name .. "#DEFAULT#"
        streetDealers_Feat.hint = "Found at:\n< " .. table.concat(resolvedLocationsIds.streetDealers, " >\n< ") .. " >"
    end
end


-- === Main Loop === --
mainLoop_Thread = create_tick_handler(function()
    local lastMpChar = stats.stat_get_int(gameplay.get_hash_key("MPPLY_LAST_MP_CHAR"), -1)

    local isGunVanAvailable = script.get_global_i(Global.isGunVanAvailable) == 1
    local areStreetDealersAvailable = script.get_global_i(Global.areStreetDealersAvailable) == 1
    local hasPlayerCollectedStashHouse = NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(36657, -1)
    local hasPlayerCollectedSprayCanForPosterTagging = NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(51189, -1)
    local hasPlayerCollectedMetalDetectorForBuriedStashes = NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(25520, -1) and NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(25521, -1) -- TODO: idk exactly which one is the actual one, but wathever I just assumed both.
    local hasPlayerCollectedGCache = NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(36628, -1)
    local hasPlayerCollectedShipwreck = NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(31734, -1)
    local hasPlayerKilledMadrazoHit = NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(42269, -1)
    local localPlayerNumEpsilonRobesCollected = GET_LOCAL_PLAYER_NUM_EPSILON_ROBES_COLLECTED()
    local localPlayerNumTacticalRifleComponentsCollected = GET_LOCAL_PLAYER_NUM_TACTICAL_RIFLE_COMPONENTS_COLLECTED()
    local localPlayerNumUsbRadioCollected = GET_LOCAL_PLAYER_NUM_USB_RADIO_COLLECTED_COLLECTED()

    local resolvedLocationsIds = {
        mediaStick_DamFunk_EvenTheScore = script.get_global_i(Global.activeMediaStick_DamFunk_EvenTheScore) + 1,
        madrazoHits = script.get_global_i(Global.activeMadrazoHits) + 1,
        buriedStashes = {
            [1] =  stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_BURIEDSTASH0"), -1) + 1,
            [2] =  stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_BURIEDSTASH1"), -1) + 1
        },
        shipwreck = {
            [1] =  stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SHIPWRECKED0"), -1) + 1,
            --[2] =  stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SHIPWRECKED1"), -1) + 1 -- I think R* originally planned 2, but for now it's /1 max.
        },
        hiddenCaches = {
            [1]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH0"), -1) + 1,
            [2]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH1"), -1) + 1,
            [3]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH2"), -1) + 1,
            [4]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH3"), -1) + 1,
            [5]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH4"), -1) + 1,
            [6]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH5"), -1) + 1,
            [7]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH6"), -1) + 1,
            [8]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH7"), -1) + 1,
            [9]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH8"), -1) + 1,
            [10] = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_HIDECACH9"), -1) + 1
        },
        junkEnergySkydives = {
            [1]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES0"), -1) + 1,
            [2]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES1"), -1) + 1,
            [3]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES2"), -1) + 1,
            [4]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES3"), -1) + 1,
            [5]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES4"), -1) + 1,
            [6]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES5"), -1) + 1,
            [7]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES6"), -1) + 1,
            [8]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES7"), -1) + 1,
            [9]  = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES8"), -1) + 1,
            [10] = stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECT_SKYDIVES9"), -1) + 1
        },
        treasureChests = {
            [1] =  stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_TREASURE0"), -1) + 1,
            [2] =  stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYCOLLECTABLES_TREASURE1"), -1) + 1
        },
        lsTags = {
            [1] = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(51546, -1) + 1,
            [2] = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(51547, -1) + 1,
            [3] = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(51548, -1) + 1,
            [4] = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(51549, -1) + 1,
            [5] = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(51550, -1) + 1
        },
        streetDealers = {
            [1] = script.get_global_i(Global.activeStreetDealer1) + 1,
            [2] = script.get_global_i(Global.activeStreetDealer2) + 1,
            [3] = script.get_global_i(Global.activeStreetDealer3) + 1
        },
        gCache = {
            searchArea = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(41214, -1) + 1,
            spawn = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(41213, -1) + 1
        },
        stashHouse = {
            marker = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(36623, -1) + 1
        },
        gunVan = {
            spawn = NATIVES.STATS.GET_PACKED_STAT_INT_CODE(41239, -1) + 1
        }
    }

    -- Known bug: in SP globals dont reset to 0 so... will have to fix that
    actionFiguresMenu_Feat.name        = "Action Figures ("       .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_ACTION_FIG_COLLECTED"),      -1)  .. "/100)"
    ghostsExposedMenu_Feat.name        = "Ghosts Exposed ("       .. script.get_global_i(Global.numberOfGhostsExposedCollected)                                         .. "/10)"
    ldOrganicsProductMenu_Feat.name    = "LD Organics Product ("  .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_LDORGANICS_COLLECTED"),      -1)  .. "/100)"
    moviePropsMenu_Feat.name           = "Movie Props ("          .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_MOVIE_PROPS_COLLECTED"),     -1)  .. "/10)"
    playingCardsMenu_Feat.name         = "Playing Cards ("        .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_PLAYING_CARD_COLLECTED"),    -1)  .. "/54)"
    signalJammersMenu_Feat.name        = "Signal Jammers ("       .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_SIGNAL_JAMMERS_COLLECTED"),  -1)  .. "/50)"
    snowmenMenu_Feat.name              = "Snowmen ("              .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_SNOWMEN_COLLECTED"),         -1)  .. "/25)"

    stuntJumpsMenu_Feat.name           = "Stunt Jumps ("          .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_USJS_COMPLETED"),            -1)  .. "/50)" -- CREDIT: Thanks @doctorflexochan for the stat name.
    epsilonRobesMenu_Feat.name         = "Epsilon Robes ("        .. localPlayerNumEpsilonRobesCollected                                                                .. "/3)"
    mediaSticksMenu_Feat.name          = "Media Sticks ("         .. localPlayerNumUsbRadioCollected                                                                    .. "/9)"
    weaponComponentsMenu_Feat.name     = "Weapon Components ("    .. localPlayerNumTacticalRifleComponentsCollected                                                     .. "/5)"
    metalDetectorsMenu_Feat.name       = "Metal Detectors ("      .. tostring(hasPlayerCollectedMetalDetectorForBuriedStashes and 1 or 0)                               .. "/1)"
    sprayCansMenu_Feat.name            = "Spray Cans ("           .. tostring(hasPlayerCollectedSprayCanForPosterTagging and 1 or 0)                                    .. "/1)"

    buriedStashesMenu_Feat.name        = "Buried Stashes ("       .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_BURIED_STASH_COLLECTED"),    -1)  .. "/2)" -- TODO: 2/1, 3/1 !? i MUST stop using this method then.
    hiddenCachesMenu_Feat.name         = "Hidden Caches ("        .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_UNDERWATRPACK_COLLECTED"),   -1)  .. "/10)"
    junkEnergySkydivesMenu_Feat.name   = "Junk Energy Skydives (" .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_SKYDIVES_COLLECTED"),        -1)  .. "/10)" -- script.get_global_i(Global.numberOfJunkEnergySkydivesCollected)                                    .. "/10)" -- stats.stat_get_int(NATIVES.STATS._GET_STAT_HASH_FOR_CHARACTER_STAT(0, 10378, lastMpChar), -1) (not working when I tested it)
    shipwreckMenu_Feat.name            = "Shipwreck ("           .. tostring(hasPlayerCollectedShipwreck and 1 or 0)                                                    .. "/1)" -- This isn't working, it's the total number count from the begining lol: stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_SHIPWRECKED_COLLECTED"),     -1)
    treasureChestsMenu_Feat.name       = "Treasure Chests ("      .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_TREASURECHEST_COLLECTED"),   -1)  .. "/2)"
    trickOrTreatMenu_Feat.name         = "Trick Or Treat ("       .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_TRICKORTREAT_COLLECTED"),    -1)  .. "/10)"
    lsTagsMenu_Feat.name               = "LS Tags ("              .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_TAGGING_COLLECTED"),         -1)  .. "/5)" -- stats.stat_get_int(NATIVES.STATS._GET_STAT_HASH_FOR_CHARACTER_STAT(0, 12310, lastMpChar), -1) --[[script.get_global_i(Global.numberOfLsTagCollected)]]
    gCachesMenu_Feat.name              = "G's Cache ("            .. stats.stat_get_int(gameplay.get_hash_key("MP" .. lastMpChar .. "_DAILYDEADDROP_COLLECTED"),   -1)  .. "/1)"
    stashHousesMenu_Feat.name          = "Stash House ("          .. tostring(hasPlayerCollectedStashHouse and 1 or 0)                                                  .. "/1)"
    madrazoHitsMenu_Feat.name          = "Madrazo Hit ("          .. tostring(hasPlayerKilledMadrazoHit and 1 or 0)                                                     .. "/1)"

    gunVansMenu_Feat.name              = "Gun Vans ("             .. tostring(isGunVanAvailable and 1 or 0)                                                             .. "/1)"
    streetDealersMenu_Feat.name        = "Street Dealers ("       .. tostring(areStreetDealersAvailable and 3 or 0)                                                     .. "/3)"

    update_feat_name__collectibles__state(has_action_figure,      collectibles.actionFigures)
    update_feat_name__collectibles__state(has_ghost_exposed,      collectibles.ghostsExposed)
    update_feat_name__collectibles__state(has_ld_organic_product, collectibles.ldOrganicsProduct)
    update_feat_name__collectibles__state(has_movie_prop,         collectibles.movieProps)
    update_feat_name__collectibles__state(has_playing_card,       collectibles.playingCards)
    update_feat_name__collectibles__state(has_signal_jammer,      collectibles.signalJammers)
    update_feat_name__collectibles__state(has_snowman,            collectibles.snowmen)

    update_feat_name__stunt_jumps__state(is_stunt_jump_completed, lastMpChar)
    update_feat_name__epsilon_robes__state(has_epsilon_robe, lastMpChar)
    update_feat_name__media_sticks__state(resolvedLocationsIds)
    -- TODO: Misses weaponComponents here
    update_feat_name__metal_detector__state(hasPlayerCollectedMetalDetectorForBuriedStashes)
    update_feat_name__spray_can__state(hasPlayerCollectedSprayCanForPosterTagging)

    update_feat_name__buried_stashes__state(resolvedLocationsIds)
    update_feat_name__hidden_caches__state(resolvedLocationsIds)
    update_feat_name__junk_energy_skydives__state(resolvedLocationsIds)
    update_feat_name__shipwreck__state(resolvedLocationsIds)
    update_feat_name__treasure_chests__state(resolvedLocationsIds)
    update_feat_name__ls_tags__state(resolvedLocationsIds)
    update_feat_name__collectibles__state(has_trick_or_treat,     dailyCollectibles.trickOrTreats)
    update_feat_name__g_caches__state(resolvedLocationsIds, hasPlayerCollectedGCache)
    update_feat_name__stash_house__state(resolvedLocationsIds, hasPlayerCollectedStashHouse)
    update_feat_name__madrazo_hits__state(resolvedLocationsIds, hasPlayerKilledMadrazoHit)

    update_feat_name__gun_van__state(resolvedLocationsIds, isGunVanAvailable)
    update_feat_name__street_dealers__state(resolvedLocationsIds, areStreetDealersAvailable)
end, 1000)


--[[ TODO:
    Collectibles:
    Peyote Plants
    Convenience Stores
    Gang Attacks
    Arm Wrestling
    Darts (unsure)
    Tenis (unsure)
    Golf  (unsure)
    San Andreas Flight School

    Daily Collectibles:
    Junk Energy Time Trial
    Casino Lucky Wheel
    RC Bandito Time Trial
    Time Trial

    Add Green color to all collected MenuFeat's
    make snowmens, jack o lanters etc .. blue when they are available otherwite remove color
    maybe make note hints green when done
    make a protection for globals when running on the wrong version of the game.
    I really need to find out when to tp with vehicles or not, make a setting for each probably.
]]

--[[ DEV NOTES:
    maybe for all "Note:\nIt only spawns in one of them." make them action_value_i

    Weapon Components:
    so far 3/3 results shows that the weapon components are progressively unlocked as in the V3's order.
    NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(51556, -1) -- as not unlocked any/as all weapon component?
    NATIVES.STATS.GET_PACKED_STAT_BOOL_CODE(41942, -1) -- something related with `case joaat("police5"):` / bareel (1/5) component
]]
