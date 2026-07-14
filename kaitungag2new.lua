-- Ronix GaG2 (Kaitun) | edit the settings below, then execute

getgenv().Settings = {

    AutoHarvest = true,
    AutoPlant = true,
    AntiAfk = true,
    HarvestMutationOnly = false,         -- true = only harvest mutated fruit, leave plain growing
    AutoWater = false,
    HarvestDelay = 0,                    -- seconds between collects; 0 = burst (no delay)
    PlantDelay = 0,                      -- seconds between plants; 0 = burst (no delay)
    PlantSpacing = 3.0,                  -- studs between planted seeds
    WaterInterval = 20,                  -- seconds between watering passes
    WaterCan = "",                       -- "Any" = any owned can; else a specific can name
    PlantSeeds = {},                     -- {} = all; else seed names to plant
    ActiveSlots = {},                    -- {} = all beds; else slot names e.g. {"Slot 1"}
    HarvestMutations = {},               -- {} = any mutation; else names (needs Only Mutated)
    HarvestWhitelist = {},               -- {} = none; plant types auto-harvest never touches
    HarvestMinValue = 0,                 -- skip fruit worth less than this $ (0 = no min)
    -- HarvestNow = true,                -- harvests all matching fruit once on click
    -- PlantNow = true,                  -- plants selected seeds once on click
    -- WaterNow = true,                  -- waters all plants once on click

    AutoSell = false,
    TpToSell = true,                     -- true = teleport to Steven to sell; false = sell in place
    SellWhenFull = false,                -- true = also sell when inventory hits the % full below
    AutoDoubleOrNothing = false,         -- true = auto-gamble whole fruit inventory 50/50 at Steven
    OnlyInStock = true,                  -- true = only buy seeds currently in stock; false = always try
    AutoBuySeed = false,
    SellInterval = 15,                   -- seconds between auto-sells
    SellFullPct = 100,                   -- percent full that triggers sell-when-full (50-100)
    DonCashoutWins = 1,                  -- cash out after this many 50/50 wins in a row (1-10)
    DonInterval = 30,                    -- seconds between auto double-or-nothing rolls
    BuyInterval = 5,                     -- seconds between auto seed buys
    SellWhitelist = {},                  -- {} = sell all; else fruit names to keep (favorited, never sold)
    BuySeeds = {},                       -- {} = none; else seed names to buy e.g. {"Carrot"}
    -- SellAllNow = true,                -- sells entire fruit inventory once on launch
    -- GambleNowDoubleOrNothing = true,  -- gambles whole fruit inventory 50/50 once on launch
    -- ProtectWhitelistedNow = true,     -- favorites whitelisted fruit once so it won't be sold
    -- BuySeedsNow = true,               -- buys the selected seeds once on launch

    GrabSeeds = false,
    GrabGold = true,                     -- true = also claim gold seed drops
    GrabRainbow = true,                  -- true = also claim rainbow seed drops
    GrabPacks = false,                   -- true = also claim seed pack drops
    GrabReturn = true,                   -- true = teleport back to start after grabbing
    -- GrabNow = true,                   -- claims all wanted seed drops once on launch

    AutoClaimMail = false,
    UseDailyDeal = true,                 -- true = use daily 5x-sell deal when available, else normal sell
    AutoPickup = false,
    PickupReturn = true,                 -- true = teleport back to start position after each pickup
    MailInterval = 30,                   -- seconds between mailbox checks (min 10)
    CodesText = "",                      -- comma-separated extra codes added to built-in list
    -- ClaimMailboxNow = true,           -- claims all mailbox rewards once
    -- RedeemALLCodes = true,            -- redeems built-in + extra codes once
    -- PickupNow = true,                 -- collects all ground drops once

    AutoBuyGear = false,
    AutoBuyCrate = false,
    BuyGear = {},                        -- {} = none; else gear names to auto-buy from shop
    BuyCrate = {},                       -- {} = none; else crate names to auto-buy from shop
    -- BuyGearNow = true,                -- buys your selected gear once
    -- BuyCratesNow = true,              -- buys your selected crates once

    AutoOpenCrate = false,
    AutoOpenEgg = false,
    AutoOpenPack = false,
    AutoUseGears = false,                -- auto-uses owned gear tools (sprinklers etc.)
    AutoExpand = false,
    OpenInterval = 4,                    -- seconds between crate/egg/pack open cycles
    GearInterval = 8,                    -- seconds between auto gear uses
    ExpandInterval = 8,                  -- seconds between plot-expand retries
    -- OpenCratesNow = true,             -- opens all owned crates once
    -- OpenEggsNow = true,               -- opens all owned eggs once
    -- OpenSeedPacksNow = true,          -- opens all owned seed packs once
    -- UseGearsNow = true,               -- uses owned gear tools once
    -- ExpandPlotNow = true,             -- tries to expand plot once
    -- PreviewSellValue = true,          -- shows inventory item count + total value

    PetOnlyRainbow = false,              -- true = only tame/buy rainbow-variant pets
    PetBuyBig = false,                   -- true = grab any BIG (2x) pet, ignoring species + price
    PetBuyHuge = false,                  -- true = grab any HUGE (4x) pet, ignoring species + price
    AutoBuyPet = false,
    AutoEquipBest = false,               -- keeps highest sell-value species equipped
    AutoSellPets = false,                -- sells pets below PetSellMax value
    PetFind = false,                     -- server-hops + re-runs until a wanted wild pet is found
    UsePetTeleporter = true,             -- true = use owned pet teleporters to reach spawns
    PetInterval = 3,                     -- seconds between wild-pet scans (lower = faster/heavier)
    EquipInterval = 10,                  -- seconds between equip/sell/slot management passes
    BuyPetSpecies = {},                  -- {} = any species; else names to buy
    FindPets = {},                       -- {} = none; pet species to hop-search for
    PetMaxPrice = 0,                     -- sheckles cap per pet; 0 = any price
    PetSellMax = 0,                      -- sell pets worth less than this; 0 = off
    -- BuyPetsNow = true,                -- tames matching wild pets once
    -- EquipBestNow = true,              -- equips highest-value pets once
    -- BuyPetSlot = true,                -- buys one extra pet slot
    -- SellJunkNow = true,               -- sells junk pets once
    -- CheckThisServer = true,           -- scans current server for wanted pets once

    StealNightOnly = false,               -- true = only steal at night; false = any time of day
    StealTp = true,                      -- true = teleport onto target; false = steal only what's in range
    StealReturn = false,                 -- true = return home when nothing left to steal
    AutoSteal = false,
    StealEvade = false,                  -- true = dash away from hitters after grabbing fruit
    AutoHopNight = false,                -- true = server-hop until a night server is found
    AntiSteal = false,
    AntiStealHighlight = true,           -- true = outline thieves red in your garden
    AntiStealReturn = true,              -- true = return home after the last thief is gone
    StealInterval = 0,                   -- seconds between steals; 0 = burst (no wait)
    EvadeDist = 11.5,                    -- studs to a hitter that triggers an evade dash
    HitDelay = 0.25,                     -- seconds between shovel swings per thief (min ~0.45)
    AntiStealMaxChase = 12,              -- studs you'll chase a thief before giving up
    StealMode = "Any",                   -- "Any" | "Valuable Only" (>= Min Value)
    StealMinValue = 100,                 -- $ threshold; only used when mode = Valuable Only
    -- StealNow = true,
    -- StealDiagnoseCopy = true,         -- (action) dumps steal internals to clipboard + console
    -- HitNearestThiefNow = true,        -- (action) shovels the closest active thief once

    AntiFling = false,
    AntiRagdoll = false,
    AntiFreeze = false,
    AntiFlash = false,                   -- true = kill flashbang white-screen
    AutoFlingPlayer = false,
    AutoFlingAll = false,
    FlingPower = 18,                     -- fling velocity magnitude (higher = harder launch)
    FlingHold = 0.12,                    -- seconds to hold the fling before tp-back
    FlingInterval = 0.5,                 -- seconds between auto-fling repeats
    HitSwings = 3,                       -- crowbar swings per hit
    -- FlingPlayer = true,               -- flings the selected Target Player once
    -- FlingALLPlayers = true,           -- flings every other player once
    -- CrowbarHitNearest = true,         -- crowbar-hits nearest player once (needs crowbar)
    FlingTarget = "",                    -- player that Fling Player targets

    WebhookEnabled = false,              -- true = post periodic farm reports to the webhook url
    WebhookEvents = true,                -- true = ping on bloodmoon / rainbow moon events
    WebhookInterval = 300,               -- seconds between farm reports (min 60)
    WebhookUrl = "",                     -- discord webhook url; required for any reports
    -- SendTestReport = true,            -- (action) posts a farm report now to test the url

    FpsBoost = true,                    -- arms all strips below in one tap; uncomment a strip = false to keep it
    -- FlatMaterials = false,
    -- NoTextures = false,
    -- NoShadows = true,
    -- KillParticles = false,
    -- HidePlayers = false,
    -- HideGardens = true,
    -- HideWorldUI = false,
    -- CleanFx = false,
    AutoSaveConfig = false,              -- true = write settings to file on every change
    AutoRejoin = false,                  -- true = auto rejoin the server on kick/disconnect
    AutoSkipLoad = true,                 -- true = skip the in-game loading screen
    FpsCap = 240,                        -- max fps (frames/sec); only applied while FPS Boost on
    -- SaveConfig = true,                -- writes current settings to file once
    -- LoadConfig = true,                -- loads saved file; reload script to apply to all toggles
    -- ResetConfigDeleteFile = true,     -- deletes the config file; defaults next launch
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/c88b0392344ce0e5253711d56f3e88fc.lua"))()
