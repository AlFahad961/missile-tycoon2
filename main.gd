extends Node3D
# =====================================================================
#  WORLD COMMANDER  (v10)  -  top-down grand strategy, endless sandbox
#  9 nations, diplomacy, policies, research, air/naval/missile war
# =====================================================================

const LAND := 150.0            # half size of a country's land (300 x 300)
const SEA_Y := -1.6
const TICK := 4.0              # one "month" in seconds (at 1x)
const PEACE_TIME := 150.0
const SAVE_PATH := "user://world_commander_v10.json"
const MAX_JETS := 56
const MAX_PROJ := 160
const MAX_SHIPS := 48
const GRID := 2.0

# ---- nations: index = id ------------------------------------------------
const COUNTRIES := [
    {"id": "usa", "name": "United States", "short": "USA", "pos": Vector2(-2400.0, 0.0), "col": Color(0.18, 0.32, 0.8),
     "pop": 335.0, "econ": 1.5, "nuke": true, "title": "President", "cap": "Washington", "aggr": 0.55,
     "air": ["F-16 Fighting Falcon", "F-15EX Eagle II", "F-22 Raptor", "F-35A Lightning II"],
     "def": ["Phalanx CIWS", "NASAMS", "Patriot PAC-3", "Aegis Ashore SM-6", "THAAD"],
     "msl": ["Tomahawk", "Switchblade drone", "Minuteman ballistic", "Dark Eagle (LRHW)", "Minuteman III ICBM", "W87 nuclear ICBM"],
     "blurb": "Super-power. Rich economy, global navy, huge alliance network."},
    {"id": "uk", "name": "United Kingdom", "short": "UK", "pos": Vector2(-1250.0, -520.0), "col": Color(0.75, 0.12, 0.2),
     "pop": 68.0, "econ": 1.0, "nuke": true, "title": "Prime Minister", "cap": "London", "aggr": 0.3,
     "air": ["Typhoon FGR4", "Typhoon Tranche 4", "F-35B Lightning II", "F-35B Block 4"],
     "def": ["Sea Ceptor CAMM", "CAMM-ER", "Patriot PAC-2", "SAMP/T", "THAAD"],
     "msl": ["Storm Shadow", "Brimstone drone", "Trident II (ballistic)", "Hypersonic HCSW", "Trident ICBM", "Trident nuclear"],
     "blurb": "Naval tradition, strong ally of USA, nuclear deterrent."},
    {"id": "eu", "name": "Europe (EU)", "short": "EU", "pos": Vector2(-720.0, -110.0), "col": Color(0.1, 0.25, 0.7),
     "pop": 450.0, "econ": 1.3, "nuke": true, "title": "Commission President", "cap": "Brussels", "aggr": 0.2,
     "air": ["Rafale F3-R", "Eurofighter Typhoon", "Rafale F4", "Rafale F5 / FCAS"],
     "def": ["Mistral CIWS", "SAMP/T Mamba", "Aster-30", "SAMP/T NG", "Arrow-3 (ESSI)"],
     "msl": ["SCALP-EG", "Harpy drone", "M51 ballistic", "ASN4G hypersonic", "M51 ICBM", "M51 nuclear"],
     "blurb": "Wealthy union. Peaceful by nature, hard to provoke, good diplomacy."},
    {"id": "rus", "name": "Russia", "short": "RUS", "pos": Vector2(300.0, -760.0), "col": Color(0.78, 0.8, 0.9),
     "pop": 144.0, "econ": 0.95, "nuke": true, "title": "President", "cap": "Moscow", "aggr": 0.7,
     "air": ["Su-30SM", "Su-35S", "Su-57 Felon", "Su-57M"],
     "def": ["Pantsir-S1", "Tor-M2", "S-300V4", "S-400 Triumf", "S-500 Prometey"],
     "msl": ["Kalibr", "Geran-2 drone", "Iskander-M", "Kinzhal / Zircon", "RS-28 Sarmat ICBM", "Sarmat nuclear"],
     "blurb": "Huge nuclear arsenal and strong air defence. Aggressive posture."},
    {"id": "isr", "name": "Israel", "short": "ISR", "pos": Vector2(-160.0, 520.0), "col": Color(0.2, 0.5, 0.9),
     "pop": 9.8, "econ": 1.0, "nuke": true, "title": "Prime Minister", "cap": "Jerusalem", "aggr": 0.6,
     "air": ["F-16I Sufa", "F-15I Ra'am", "F-35I Adir", "F-35I Adir Block 4"],
     "def": ["Iron Beam", "Iron Dome", "David's Sling", "Arrow-2", "Arrow-3"],
     "msl": ["Delilah", "Harop drone", "Jericho II", "Rampage hypersonic", "Jericho III ICBM", "Jericho nuclear"],
     "blurb": "Small, tech-rich, best layered air defence in the world."},
    {"id": "irn", "name": "Iran", "short": "IRN", "pos": Vector2(360.0, 370.0), "col": Color(0.1, 0.6, 0.25),
     "pop": 89.0, "econ": 0.8, "nuke": false, "title": "President", "cap": "Tehran", "aggr": 0.65,
     "air": ["F-14A Tomcat", "MiG-29A", "Su-35 (import)", "Su-35 (import)"],
     "def": ["Mersad", "Bavar-373", "Bavar-373", "S-300PMU2", "Bavar-373"],
     "msl": ["Soumar cruise", "Shahed-136 drone", "Fateh-110 / Sejjil", "Fattah hypersonic", "Khorramshahr", "Nuclear warhead"],
     "blurb": "Sanctioned but defiant. Strong missiles and drones, no nuclear weapon yet."},
    {"id": "pak", "name": "Pakistan", "short": "PAK", "pos": Vector2(860.0, 330.0), "col": Color(0.05, 0.45, 0.2),
     "pop": 240.0, "econ": 0.7, "nuke": true, "title": "Prime Minister", "cap": "Islamabad", "aggr": 0.5,
     "air": ["JF-17 Thunder", "F-16 Block 52", "J-10C Vigorous Dragon", "J-35A (planned)"],
     "def": ["Anza-III", "FM-90", "HQ-16FE", "HQ-9/P", "HQ-9B"],
     "msl": ["Babur cruise", "Burraq drone", "Shaheen-II", "Ababeel MIRV", "Shaheen-III", "Shaheen nuclear"],
     "blurb": "Nuclear-armed, close to China. Tough on a small budget."},
    {"id": "ind", "name": "India", "short": "IND", "pos": Vector2(1000.0, 800.0), "col": Color(0.95, 0.55, 0.1),
     "pop": 1430.0, "econ": 1.0, "nuke": true, "title": "Prime Minister", "cap": "New Delhi", "aggr": 0.5,
     "air": ["Tejas Mk1A", "Su-30MKI", "Rafale", "AMCA (5th gen)"],
     "def": ["Akash-NG", "QRSAM", "Barak-8 MR-SAM", "S-400 Triumf", "Project Kusha"],
     "msl": ["BrahMos", "SkyStriker drone", "Prithvi-II / Agni-II", "BrahMos-II hypersonic", "Agni-V ICBM", "Agni nuclear"],
     "blurb": "Biggest population, growing economy, balanced alliances."},
    {"id": "chn", "name": "China", "short": "CHN", "pos": Vector2(1750.0, 100.0), "col": Color(0.85, 0.12, 0.1),
     "pop": 1410.0, "econ": 1.35, "nuke": true, "title": "President", "cap": "Beijing", "aggr": 0.55,
     "air": ["J-10C", "J-16", "J-20 Mighty Dragon", "J-35A"],
     "def": ["Type 730 CIWS", "HQ-16", "HQ-9B", "HQ-22", "HQ-19"],
     "msl": ["CJ-10 cruise", "WZ-7 drone", "DF-21D", "DF-17 hypersonic", "DF-41 ICBM", "DF-41 nuclear"],
     "blurb": "Industrial giant. Massive missile force and growing navy."},
]

# diplomatic starting relations (symmetric), order: usa uk eu rus isr irn pak ind chn
const REL0 := [
    [0, 85, 60, -70, 80, -85, -5, 30, -50],
    [85, 0, 55, -80, 40, -45, 5, 35, -35],
    [60, 55, 0, -70, 20, -30, 0, 20, -20],
    [-70, -80, -70, 0, -30, 30, 0, 40, 50],
    [80, 40, 20, -30, 0, -90, -60, 60, 0],
    [-85, -45, -30, 30, -90, 0, 25, 10, 30],
    [-5, 5, 0, 0, -60, 25, 0, -75, 85],
    [30, 35, 20, 40, 60, 10, -75, 0, -55],
    [-50, -35, -20, 50, 0, 30, 85, -55, 0],
]

# ---- buildings -----------------------------------------------------------
# cat: city / service / mil / air / navy
const BDEFS := {
    "house": {"name": "House", "cat": "city", "w": 10, "d": 10, "cost": 900, "inc": 30, "hp": 100, "up": 0, "time": 5, "unlock": 0,
              "desc": "Citizens live here. Pays taxes.", "pop": 0.15},
    "apartment": {"name": "Apartment Block", "cat": "city", "w": 16, "d": 16, "cost": 4200, "inc": 190, "hp": 260, "up": 0, "time": 14, "unlock": 6000,
              "desc": "Dense housing, much more tax.", "pop": 1.2},
    "commerce": {"name": "Shopping Mall", "cat": "city", "w": 28, "d": 20, "cost": 7500, "inc": 380, "hp": 300, "up": 10, "time": 18, "unlock": 14000,
              "desc": "Shops and jobs.", "pop": 0.0},
    "office": {"name": "Office Tower", "cat": "city", "w": 18, "d": 18, "cost": 16000, "inc": 900, "hp": 500, "up": 20, "time": 30, "unlock": 40000,
              "desc": "Finance and business district.", "pop": 0.0},
    "factory": {"name": "Factory", "cat": "city", "w": 30, "d": 22, "cost": 9000, "inc": 520, "hp": 360, "up": 20, "time": 20, "unlock": 12000,
              "desc": "Industry. Each factory makes weapons 2% cheaper (max 20%).", "pop": 0.0},
    "park": {"name": "Park", "cat": "service", "w": 22, "d": 22, "cost": 1800, "inc": 0, "hp": 60, "up": 0, "time": 4, "unlock": 0,
              "desc": "Keeps people happy.", "happy": 1.2},
    "stadium": {"name": "Stadium", "cat": "service", "w": 38, "d": 30, "cost": 12000, "inc": 120, "hp": 400, "up": 30, "time": 26, "unlock": 30000,
              "desc": "Big happiness boost.", "happy": 3.0},
    "hospital": {"name": "Hospital", "cat": "service", "w": 24, "d": 18, "cost": 6000, "inc": 0, "hp": 300, "up": 60, "time": 16, "unlock": 4000,
              "desc": "Health care. Happier people, population grows.", "happy": 3.5},
    "university": {"name": "University", "cat": "service", "w": 28, "d": 20, "cost": 8000, "inc": 0, "hp": 320, "up": 80, "time": 20, "unlock": 10000,
              "desc": "Education. +1 research point per month.", "happy": 1.5, "rp": 1.0},
    "police": {"name": "Police HQ", "cat": "service", "w": 14, "d": 12, "cost": 3000, "inc": 0, "hp": 160, "up": 40, "time": 8, "unlock": 2000,
              "desc": "Reduces protests and unrest.", "stab": 3.0},
    "embassy": {"name": "Embassy Quarter", "cat": "service", "w": 18, "d": 16, "cost": 5000, "inc": 0, "hp": 200, "up": 30, "time": 12, "unlock": 8000,
              "desc": "Relations with everyone improve slowly.", "dip": 1.0},
    "parliament": {"name": "Parliament", "cat": "service", "w": 40, "d": 26, "cost": 0, "inc": 100, "hp": 700, "up": 0, "time": 1, "unlock": 0,
              "desc": "Seat of government.", "hidden": true},
    "armybase": {"name": "Engineer Army Base", "cat": "mil", "w": 34, "d": 26, "cost": 10000, "inc": 0, "hp": 400, "up": 90, "time": 20, "unlock": 10000,
              "desc": "Troops and engineers. Auto-repairs buildings nearby.", "rep": 2.0},
    "missilebase": {"name": "Missile Base", "cat": "mil", "w": 28, "d": 28, "cost": 15000, "inc": 0, "hp": 420, "up": 120, "time": 24, "unlock": 14000,
              "desc": "Stores and launches missiles (30 per level)."},
    "radar": {"name": "Radar Station", "cat": "mil", "w": 12, "d": 12, "cost": 4000, "inc": 0, "hp": 130, "up": 30, "time": 10, "unlock": 6000,
              "desc": "Early warning (range 300). Scrambles jets, boosts nearby air defence."},
    "airbase": {"name": "Air Force Base", "cat": "air", "w": 100, "d": 42, "cost": 30000, "inc": 0, "hp": 700, "up": 250, "time": 40, "unlock": 25000,
              "desc": "Runway, hangars, jets (6 per level)."},
    "lab": {"name": "Research Lab", "cat": "mil", "w": 30, "d": 24, "cost": 20000, "inc": 0, "hp": 360, "up": 150, "time": 24, "unlock": 18000,
              "desc": "Unlocks new technology, including the atomic bomb.", "rp": 3.0},
    "enrich": {"name": "Nuclear Complex", "cat": "mil", "w": 38, "d": 32, "cost": 120000, "inc": 0, "hp": 520, "up": 600, "time": 60, "unlock": 0,
              "desc": "Uranium enrichment and warhead assembly. Needed for nuclear weapons.", "tech": "nuc2"},
    "port": {"name": "Naval Port", "cat": "navy", "w": 56, "d": 30, "cost": 25000, "inc": 0, "hp": 600, "up": 200, "time": 30, "unlock": 20000,
              "desc": "Build ships (8 per level). Must be on the coast."},
}
# AA buildings are generated from tiers 0..4 below
const AA_COST := [600, 2500, 9000, 22000, 50000]
const AA_RANGE := [30.0, 58.0, 100.0, 150.0, 230.0]
const AA_SIZE := [8, 12, 15, 19, 24]
const AA_HP := [140, 200, 280, 360, 460]
const AA_UNLOCK := [3000, 12000, 30000, 70000, 150000]
const AA_TECH := ["", "ad2", "ad3", "ad4", "ad5"]
const AA_UP := [10, 30, 70, 130, 220]
const AA_INTERVAL := [2.2, 3.0, 4.0, 4.5, 5.0]

# ---- missiles --------------------------------------------------------------
const MSL := [
    {"short": "Cruise", "price": 450, "unlock": 8000, "tech": "", "range": 900.0, "speed": 150.0, "dmg": 120.0, "rad": 14.0, "apex": 0.04, "nuke": false},
    {"short": "Drone", "price": 120, "unlock": 4000, "tech": "drone", "range": 700.0, "speed": 55.0, "dmg": 60.0, "rad": 9.0, "apex": 0.02, "nuke": false},
    {"short": "Ballistic", "price": 900, "unlock": 25000, "tech": "ballistic", "range": 1800.0, "speed": 240.0, "dmg": 230.0, "rad": 20.0, "apex": 0.3, "nuke": false},
    {"short": "Hypersonic", "price": 3200, "unlock": 90000, "tech": "hyper", "range": 2700.0, "speed": 420.0, "dmg": 320.0, "rad": 22.0, "apex": 0.12, "nuke": false},
    {"short": "ICBM", "price": 8000, "unlock": 160000, "tech": "icbm", "range": 99999.0, "speed": 360.0, "dmg": 720.0, "rad": 38.0, "apex": 0.4, "nuke": false},
    {"short": "NUCLEAR", "price": 120000, "unlock": 0, "tech": "nuc3", "range": 99999.0, "speed": 340.0, "dmg": 99999.0, "rad": 105.0, "apex": 0.4, "nuke": true},
]
const DEF_TABLE := [
    [0.55, 0.65, 0.08, 0.0, 0.0, 0.0],
    [0.75, 0.85, 0.30, 0.04, 0.08, 0.0],
    [0.85, 0.90, 0.60, 0.18, 0.35, 0.05],
    [0.90, 0.92, 0.78, 0.42, 0.55, 0.18],
    [0.93, 0.95, 0.90, 0.68, 0.80, 0.42],
]
const JET_DEF := [0.22, 0.34, 0.55, 0.68, 0.80]

# ---- jets (4 tiers; real names come from COUNTRIES[].air) -----------------
const JET_T := [
    {"price": 9000, "unlock": 0, "tech": "", "speed": 85.0, "shots": 2, "dmg": 55.0, "evade": 0.05, "skill": 1.0},
    {"price": 17000, "unlock": 30000, "tech": "", "speed": 95.0, "shots": 3, "dmg": 65.0, "evade": 0.12, "skill": 1.25},
    {"price": 36000, "unlock": 90000, "tech": "avionics", "speed": 105.0, "shots": 3, "dmg": 80.0, "evade": 0.3, "skill": 1.6},
    {"price": 80000, "unlock": 220000, "tech": "stealth", "speed": 118.0, "shots": 4, "dmg": 95.0, "evade": 0.6, "skill": 2.1},
]

# ---- ships ----------------------------------------------------------------
const SHIPS := [
    {"id": "patrol", "name": "Patrol Boat", "real": "Fast attack craft", "price": 4000, "unlock": 6000, "tech": "", "hp": 120.0, "speed": 24.0,
     "rng": 55.0, "dmg": 14.0, "interval": 1.4, "len": 14.0, "up": 20, "aa": 0.1},
    {"id": "frigate", "name": "Frigate", "real": "Multi-role escort", "price": 14000, "unlock": 30000, "tech": "", "hp": 260.0, "speed": 20.0,
     "rng": 90.0, "dmg": 28.0, "interval": 1.8, "len": 26.0, "up": 50, "aa": 0.35},
    {"id": "destroyer", "name": "Destroyer", "real": "Guided-missile destroyer (VLS)", "price": 36000, "unlock": 80000, "tech": "", "hp": 520.0, "speed": 18.0,
     "rng": 330.0, "dmg": 90.0, "interval": 5.0, "len": 34.0, "up": 110, "aa": 0.6},
    {"id": "sub", "name": "Submarine", "real": "Nuclear attack submarine", "price": 48000, "unlock": 130000, "tech": "sub", "hp": 300.0, "speed": 15.0,
     "rng": 500.0, "dmg": 140.0, "interval": 8.0, "len": 30.0, "up": 130, "aa": 0.0},
    {"id": "carrier", "name": "Aircraft Carrier", "real": "Supercarrier with air wing", "price": 160000, "unlock": 350000, "tech": "carrier", "hp": 1500.0, "speed": 11.0,
     "rng": 0.0, "dmg": 0.0, "interval": 99.0, "len": 70.0, "up": 450, "aa": 0.5},
]

# ---- research ---------------------------------------------------------------
const TECHS := {
    "drone": {"name": "Loitering Drones", "cost": 40, "lab": 1, "req": "", "desc": "Cheap long-range drones (Shahed / Harop style)."},
    "ad2": {"name": "Short-range SAM (Iron Dome class)", "cost": 60, "lab": 1, "req": "", "desc": "Unlocks tier-2 air defence."},
    "ballistic": {"name": "Ballistic Missiles", "cost": 100, "lab": 1, "req": "", "desc": "Fast missiles, range 1800."},
    "ad3": {"name": "Long-range SAM (Patriot / HQ-9)", "cost": 160, "lab": 1, "req": "ad2", "desc": "Unlocks tier-3 air defence."},
    "avionics": {"name": "Advanced Avionics", "cost": 150, "lab": 1, "req": "", "desc": "4.5-generation fighters (tier 3 jets)."},
    "sub": {"name": "Submarine Technology", "cost": 180, "lab": 1, "req": "", "desc": "Unlocks submarines."},
    "eco1": {"name": "Industrial Automation", "cost": 120, "lab": 1, "req": "", "desc": "+10% income from all buildings."},
    "ad4": {"name": "Strategic SAM (S-400 class)", "cost": 350, "lab": 2, "req": "ad3", "desc": "Unlocks tier-4 air defence."},
    "hyper": {"name": "Hypersonic Weapons", "cost": 450, "lab": 2, "req": "ballistic", "desc": "Mach 10+ missiles, hard to stop."},
    "icbm": {"name": "Intercontinental Missiles", "cost": 400, "lab": 2, "req": "ballistic", "desc": "Unlimited range missiles."},
    "carrier": {"name": "Naval Aviation", "cost": 300, "lab": 2, "req": "sub", "desc": "Unlocks aircraft carriers."},
    "eco2": {"name": "Digital Economy", "cost": 320, "lab": 2, "req": "eco1", "desc": "+12% income."},
    "sat": {"name": "Satellite Network", "cost": 380, "lab": 2, "req": "", "desc": "Global early warning, shows incoming missiles worldwide."},
    "stealth": {"name": "Stealth Technology", "cost": 520, "lab": 2, "req": "avionics", "desc": "5th generation stealth fighters."},
    "nuc1": {"name": "Nuclear Physics", "cost": 200, "lab": 2, "req": "", "desc": "First step to the atomic bomb. The world will notice."},
    "nuc2": {"name": "Uranium Enrichment", "cost": 450, "lab": 2, "req": "nuc1", "desc": "Unlocks Nuclear Complex building."},
    "nuc3": {"name": "Warhead Design", "cost": 800, "lab": 3, "req": "nuc2", "desc": "Unlocks the atomic bomb (needs Nuclear Complex + delivery missile)."},
    "ad5": {"name": "Anti-ballistic Shield (THAAD / S-500)", "cost": 700, "lab": 3, "req": "ad4", "desc": "Unlocks tier-5 air defence, can stop nuclear missiles."},
    "cyber": {"name": "Cyber Warfare", "cost": 500, "lab": 3, "req": "", "desc": "Enables cyber attacks on enemy economy."},
}

# ---- policies: toggles with monthly effects --------------------------------
# keys: inc (income mult add), happy (target happiness add), mil (weapon price mult add), rp (research mult add),
# rep (reputation drift), cost (monthly money), stab (stability)
const POLICIES := {
    "conscript": {"name": "National Service (Conscription)", "inc": -0.04, "happy": -4.0, "mil": -0.12, "cost": 0,
        "desc": "Har jawan ki lazmi fauji training. Fauj sasti aur mazboot, lekin awam naraz aur maeeshat thori kamzor."},
    "martial": {"name": "Martial Law", "stab": 14.0, "happy": -6.0, "rep": -0.6, "cost": 0,
        "desc": "Fauj sheher sambhalti hai. Protests dab jate hain magar awam aur dunya dono kharab nazar se dekhte hain."},
    "health": {"name": "Universal Healthcare", "happy": 6.0, "cost": 220,
        "desc": "Sab ka ilaj muft. Awam bohat khush, abaadi barhti hai, lekin har mahine kharcha."},
    "edu": {"name": "Education Reform", "rp": 0.25, "happy": 2.0, "cost": 160,
        "desc": "School/universities par paisa. Research tez hoti hai aur awam khush."},
    "tariff": {"name": "Protectionist Tariffs", "inc": 0.07, "rep": -0.4, "cost": 0,
        "desc": "Bahar ke saman par tax. Apni income barhti hai magar tijarti dost naraz hote hain."},
    "freetrade": {"name": "Free Trade Zones", "inc": 0.06, "rep": 0.3, "cost": 60,
        "desc": "Tijarat ke liye khula darwaza. Income aur dosti dono behtar."},
    "subsidy": {"name": "Fuel & Food Subsidies", "happy": 5.0, "cost": 260,
        "desc": "Petrol aur ata sasta. Awam khush, lekin khazana khali hota hai."},
    "austerity": {"name": "Austerity Budget", "inc": 0.05, "happy": -5.0, "cost": -120,
        "desc": "Sarkari kharche kam. Bachat hoti hai magar awam ko takleef."},
    "wareco": {"name": "War Economy", "mil": -0.15, "inc": -0.05, "happy": -3.0, "cost": 0,
        "desc": "Karkhane jang ke liye. Hathiyar 15% sasty, aam economy 5% kamzor."},
    "npt": {"name": "Nuclear Non-Proliferation Treaty (NPT)", "rep": 0.8, "cost": 0,
        "desc": "Atomic hathiyar na banane ka wada. Dunya mein izzat barhti hai, lekin nuclear research band."},
    "censor": {"name": "Media Censorship", "stab": 8.0, "rep": -0.5, "cost": 0,
        "desc": "Akhbar aur social media par pabandi. Protests kam nazar aate hain, dunya ki nazar mein image kharab."},
    "spy": {"name": "Intelligence Agency (ISI/CIA/Mossad style)", "cost": 180, "stab": 2.0,
        "desc": "Jasoosi network. Dushman ke hamlon ki pehle se khabar aur sazishon ka tor."},
    "green": {"name": "Green Energy Programme", "happy": 2.0, "inc": -0.02, "rep": 0.3, "cost": 80,
        "desc": "Saaf bijli. Lambay arsay mein awam ki khushi aur izzat, abhi thora mehnga."},
    "arms": {"name": "Arms Exports", "cost": -200, "rep": -0.2,
        "desc": "Hathiyar bechnay se paisa aata hai, magar jang mein shamil mulkon se tension."},
}

const RANK_NAMES := ["Peace", "Ally", "Ceasefire", "War"]


# =====================================================================
#  SHADERS
# =====================================================================
const BLD_SHADER := """
shader_type spatial;
global uniform float night;
varying vec3 wp;
varying float vy;
varying vec3 vcol;
varying float vflag;
varying vec3 wnrm;
void vertex() {
    wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vy = VERTEX.y;
    vcol = COLOR.rgb;
    vflag = COLOR.a;
    wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}
float h21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void fragment() {
    vec3 col = vcol;
    float rough = 0.82;
    float metal = 0.0;
    vec3 em = vec3(0.0);
    vec2 uv = UV;
    if (vflag > 0.9) {
        vec2 cell = uv / vec2(3.1, 3.5);
        vec2 f = fract(cell);
        vec2 id = floor(cell);
        float win = step(0.16, f.x) * step(f.x, 0.84) * step(0.2, f.y) * step(f.y, 0.8);
        float lit = step(0.5, h21(id + vec2(3.0, 7.0)));
        float shade = h21(id);
        vec3 glass = mix(vec3(0.07, 0.12, 0.17), vec3(0.36, 0.5, 0.62), shade * 0.7);
        float frame = win * (1.0 - step(0.1, min(min(f.x - 0.16, 0.84 - f.x), min(f.y - 0.2, 0.8 - f.y))));
        col = mix(col, glass, win);
        col = mix(col, col * 0.55, frame * 0.0);
        rough = mix(0.8, 0.1, win);
        metal = win * 0.5;
        em = win * lit * night * vec3(1.0, 0.82, 0.45) * 1.5;
        float slab = 1.0 - step(0.07, f.y);
        col *= 1.0 - slab * 0.22;
    } else if (vflag > 0.4) {
        float t = fract(uv.y / 0.8);
        float t2 = fract(uv.x / 1.4 + floor(uv.y / 0.8) * 0.5);
        col *= 0.8 + 0.2 * step(0.1, t) * step(0.04, t2);
        rough = 0.9;
    } else if (vflag > 0.2) {
        float stripe = step(0.5, fract(uv.x * 0.5));
        col *= 0.9 + 0.1 * stripe;
        rough = 0.95;
    }
    float g = h21(floor(wp.xz * 3.0) + floor(wp.y * 2.0));
    col *= 0.93 + 0.07 * g;
    col *= mix(0.62, 1.0, clamp(vy * 0.35, 0.0, 1.0));
    // stylized grade: richer colour, bright tops, cool sides
    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(lum), col, 1.28);
    float top = smoothstep(0.55, 0.95, wnrm.y);
    col *= mix(vec3(0.96, 0.98, 1.04), vec3(1.1, 1.07, 1.0), top);
    ALBEDO = clamp(col, 0.0, 1.0);
    ROUGHNESS = rough;
    METALLIC = metal;
    EMISSION = em;
}
void light() {
    float nl = dot(NORMAL, LIGHT);
    float t = smoothstep(-0.2, 0.6, nl);
    t = mix(t, smoothstep(0.0, 0.35, nl), 0.35);
    DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * t / PI;
    vec3 hv = normalize(LIGHT + VIEW);
    float sp = pow(max(dot(NORMAL, hv), 0.0), mix(8.0, 90.0, 1.0 - ROUGHNESS));
    SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * sp * (1.0 - ROUGHNESS) * 0.5 / PI * step(0.0, nl);
}
"""

const GROUND_SHADER := """
shader_type spatial;
global uniform float night;
uniform vec2 center;
uniform float half_size = 150.0;
uniform float grid_on = 0.0;
uniform vec4 ghost = vec4(0.0, 0.0, 0.0, 0.0);
uniform float ghost_ok = 1.0;
uniform vec4 scorch[6];
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
varying vec3 wp;
varying vec3 wn;
void vertex() {
    wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}
float h21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float vn(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(h21(i), h21(i + vec2(1.0, 0.0)), f.x), mix(h21(i + vec2(0.0, 1.0)), h21(i + vec2(1.0, 1.0)), f.x), f.y);
}
float fbm(vec2 p) {
    float a = 0.5;
    float s = 0.0;
    for (int i = 0; i < 4; i++) {
        s += a * vn(p);
        p = p * 2.03 + vec2(1.7, 9.2);
        a *= 0.5;
    }
    return s;
}
void fragment() {
    vec2 lp = wp.xz - center;
    float d = max(abs(lp.x), abs(lp.y)) - half_size;
    vec3 col;
    float rough = 0.95;
    if (wn.y < 0.6) {
        float s = fbm(vec2(wp.x + wp.z, wp.y * 3.0) * 0.4);
        col = mix(vec3(0.26, 0.23, 0.2), vec3(0.45, 0.4, 0.34), s);
        col *= 0.75 + 0.25 * smoothstep(-4.0, 0.0, wp.y);
        ALBEDO = col;
        ROUGHNESS = 0.95;
    } else {
        float n1 = fbm(lp * 0.07);
        float n2 = fbm(lp * 0.6 + 4.0);
        float n3 = fbm(lp * 0.02 + 11.0);
        vec3 g1 = vec3(0.26, 0.6, 0.32);
        vec3 g2 = vec3(0.32, 0.67, 0.37);
        vec3 g3 = vec3(0.4, 0.74, 0.42);
        col = mix(g1, g2, n1);
        col = mix(col, g3, smoothstep(0.55, 0.8, n3) * 0.6);
        col *= 0.88 + 0.24 * n2;
        col *= 0.975 + 0.05 * step(0.5, fract(lp.x / 14.0 + floor(lp.y / 14.0) * 0.5));
        float dirt = smoothstep(0.62, 0.72, fbm(lp * 0.035 + 31.0));
        col = mix(col, vec3(0.5, 0.72, 0.45), dirt * 0.25);
        // roads
        float rx = abs(mod(lp.x + 32.0, 64.0) - 32.0);
        float rz = abs(mod(lp.y + 32.0, 64.0) - 32.0);
        float inside = 1.0 - smoothstep(-8.0, -5.0, d + 5.0 - 5.0);
        float roadm = max(1.0 - step(4.6, rx), 1.0 - step(4.6, rz));
        float walk = max(1.0 - step(6.3, rx), 1.0 - step(6.3, rz));
        float inland = 1.0 - step(-4.0, d);
        vec3 asph = vec3(0.27, 0.29, 0.34) * (0.8 + 0.5 * n2);
        col = mix(col, vec3(0.78, 0.8, 0.86), walk * inland);
        col = mix(col, asph, roadm * inland);
        float dash1 = (1.0 - step(0.18, rx)) * step(0.5, fract(lp.y / 7.0)) * (1.0 - step(4.6, rz));
        float dash2 = (1.0 - step(0.18, rz)) * step(0.5, fract(lp.x / 7.0)) * (1.0 - step(4.6, rx));
        col = mix(col, vec3(0.95, 0.95, 0.95), max(dash1, dash2) * inland * 0.9);
        // beach
        float beach = smoothstep(-6.0, 4.0, d);
        vec3 sand = mix(vec3(0.72, 0.65, 0.48), vec3(0.8, 0.74, 0.58), n2);
        col = mix(col, sand, beach);
        float wet = smoothstep(11.0, 17.0, d);
        col = mix(col, vec3(0.42, 0.38, 0.28), wet * 0.8);
        // editor grid + ghost
        if (grid_on > 0.5) {
            vec2 gl = abs(fract(lp / 10.0 + 0.5) - 0.5) * 10.0;
            float gline = (1.0 - step(0.12, min(gl.x, gl.y))) * inland;
            col = mix(col, vec3(1.0), gline * 0.18);
        }
        if (ghost.z > 0.0) {
            vec2 gp = abs(wp.xz - ghost.xy);
            float inr = (1.0 - step(ghost.z, gp.x)) * (1.0 - step(ghost.w, gp.y));
            vec3 gc = ghost_ok > 0.5 ? vec3(0.1, 1.0, 0.3) : vec3(1.0, 0.15, 0.1);
            col = mix(col, gc, inr * 0.55);
        }
        for (int i = 0; i < 6; i++) {
            vec4 sc = scorch[i];
            if (sc.w > 0.0) {
                float dd = length(wp.xz - sc.xy);
                float k = 1.0 - smoothstep(sc.z * 0.4, sc.z, dd + n2 * sc.z * 0.25);
                col = mix(col, vec3(0.03, 0.025, 0.02), k * sc.w);
            }
        }
        col *= tint;
        ALBEDO = col;
        ROUGHNESS = mix(0.95, 0.9, roadm * inland);
        float gx = fbm(lp * 0.9 + vec2(0.3, 0.0)) - fbm(lp * 0.9 - vec2(0.3, 0.0));
        float gz = fbm(lp * 0.9 + vec2(0.0, 0.3)) - fbm(lp * 0.9 - vec2(0.0, 0.3));
        vec3 nn = normalize(vec3(-gx * 0.9, 1.0, -gz * 0.9));
        NORMAL = normalize((VIEW_MATRIX * vec4(nn, 0.0)).xyz);
    }
}
"""

const WATER_SHADER := """
shader_type spatial;
global uniform float night;
uniform vec4 lands[9];
varying vec3 wpos;
void vertex() {
    wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
float hgt(vec2 p, float amp) {
    return (sin(p.x * 0.11 + TIME * 0.7) * 0.5 + sin(p.y * 0.09 - TIME * 0.55) * 0.5 + sin((p.x - p.y) * 0.21 + TIME) * 0.25
        + sin(p.x * 0.43 + p.y * 0.37 + TIME * 1.7) * 0.12 + sin(p.x * 0.8 - p.y * 0.6 - TIME * 2.2) * 0.06) * amp;
}
float h21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float vn(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(h21(i), h21(i + vec2(1.0, 0.0)), f.x), mix(h21(i + vec2(0.0, 1.0)), h21(i + vec2(1.0, 1.0)), f.x), f.y);
}
void fragment() {
    vec2 p = wpos.xz;
    float dist = length(CAMERA_POSITION_WORLD - wpos);
    float amp = 1.0 / (1.0 + dist * 0.0025);
    float e = 0.4;
    float h = hgt(p, amp);
    float hx = hgt(p + vec2(e, 0.0), amp);
    float hz = hgt(p + vec2(0.0, e), amp);
    vec3 n = normalize(vec3((h - hx) * 0.8, 1.0, (h - hz) * 0.8));
    NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
    float d = 9999.0;
    for (int i = 0; i < 9; i++) {
        vec4 l = lands[i];
        float dd = max(abs(p.x - l.x), abs(p.y - l.y)) - l.z;
        d = min(d, dd);
    }
    float shallow = 1.0 - smoothstep(0.0, 90.0, d);
    float fres = pow(1.0 - clamp(dot(NORMAL, normalize(VIEW)), 0.0, 1.0), 3.0);
    vec3 deep = vec3(0.01, 0.1, 0.2);
    vec3 shal = vec3(0.07, 0.42, 0.5);
    vec3 col = mix(deep, shal, shallow * 0.9 + 0.08 * h);
    col = mix(col, vec3(0.55, 0.75, 0.9), fres * 0.4);
    float fw = 7.0 + 3.0 * sin(p.x * 0.35 + p.y * 0.2 + TIME * 1.3);
    float foam = (1.0 - smoothstep(0.0, fw, d)) * (0.6 + 0.4 * vn(p * 0.5 + TIME * 0.6));
    float foam2 = (1.0 - smoothstep(fw, fw + 4.0, d)) * smoothstep(fw - 2.0, fw, d) * 0.5;
    col = mix(col, vec3(0.95, 0.98, 1.0), clamp(foam + foam2, 0.0, 1.0) * step(0.0, d + 1.0));
    ALBEDO = col * mix(1.0, 0.45, night);
    ROUGHNESS = 0.1;
    SPECULAR = 0.8;
}
"""

const CLOUD_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
global uniform float night;
varying vec3 wpos;
void vertex() {
    wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
float h21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float vn(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(h21(i), h21(i + vec2(1.0, 0.0)), f.x), mix(h21(i + vec2(0.0, 1.0)), h21(i + vec2(1.0, 1.0)), f.x), f.y);
}
void fragment() {
    vec2 p = wpos.xz * 0.0016 + vec2(TIME * 0.004, TIME * 0.002);
    float n = vn(p) * 0.55 + vn(p * 2.1 + 5.0) * 0.3 + vn(p * 4.3 + 9.0) * 0.15;
    float a = smoothstep(0.52, 0.8, n);
    float dist = length(CAMERA_POSITION_WORLD - wpos);
    a *= smoothstep(250.0, 900.0, dist) * 0.8;
    ALBEDO = mix(vec3(1.0), vec3(0.25, 0.28, 0.36), night);
    ALPHA = a;
}
"""

# =====================================================================
#  Mesh builder (merges many primitives into one ArrayMesh)
# =====================================================================
class MB:
    var surf := {}

    func _s(mat: String) -> Dictionary:
        if not surf.has(mat):
            surf[mat] = {"v": PackedVector3Array(), "n": PackedVector3Array(), "c": PackedColorArray(),
                "u": PackedVector2Array(), "i": PackedInt32Array()}
        return surf[mat]

    func _quad(mat: String, a: Vector3, b: Vector3, c: Vector3, d: Vector3, n: Vector3, col: Color,
            ua: Vector2, ub: Vector2, uc: Vector2, ud: Vector2) -> void:
        var s := _s(mat)
        var base: int = s["v"].size()
        s["v"].append(a); s["v"].append(b); s["v"].append(c); s["v"].append(d)
        for k in range(4):
            s["n"].append(n)
            s["c"].append(col)
        s["u"].append(ua); s["u"].append(ub); s["u"].append(uc); s["u"].append(ud)
        # input is counter-clockwise seen from outside; Godot front faces are clockwise
        s["i"].append(base); s["i"].append(base + 2); s["i"].append(base + 1)
        s["i"].append(base); s["i"].append(base + 3); s["i"].append(base + 2)

    func _tri(mat: String, a: Vector3, b: Vector3, c: Vector3, n: Vector3, col: Color) -> void:
        var s := _s(mat)
        var base: int = s["v"].size()
        s["v"].append(a); s["v"].append(b); s["v"].append(c)
        for k in range(3):
            s["n"].append(n)
            s["c"].append(col)
        s["u"].append(Vector2(a.x + a.z, a.y)); s["u"].append(Vector2(b.x + b.z, b.y)); s["u"].append(Vector2(c.x + c.z, c.y))
        s["i"].append(base); s["i"].append(base + 2); s["i"].append(base + 1)

    func box(c: Vector3, sz: Vector3, col: Color, flag: float = 0.0, rot: Vector3 = Vector3.ZERO, mat: String = "bld", skip_bottom: bool = true) -> void:
        var bas := Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)), EULER_ORDER_YXZ)
        var h := sz * 0.5
        var cc := Color(col.r, col.g, col.b, flag)
        var o := c
        # local corner helper
        var p := func(x: float, y: float, z: float) -> Vector3:
            return bas * Vector3(x * h.x, y * h.y, z * h.z) + o
        # +z
        _quad(mat, p.call(-1, -1, 1), p.call(1, -1, 1), p.call(1, 1, 1), p.call(-1, 1, 1), bas * Vector3(0, 0, 1), cc,
            Vector2(c.x - h.x, c.y - h.y), Vector2(c.x + h.x, c.y - h.y), Vector2(c.x + h.x, c.y + h.y), Vector2(c.x - h.x, c.y + h.y))
        # -z
        _quad(mat, p.call(1, -1, -1), p.call(-1, -1, -1), p.call(-1, 1, -1), p.call(1, 1, -1), bas * Vector3(0, 0, -1), cc,
            Vector2(c.x + h.x, c.y - h.y), Vector2(c.x - h.x, c.y - h.y), Vector2(c.x - h.x, c.y + h.y), Vector2(c.x + h.x, c.y + h.y))
        # +x
        _quad(mat, p.call(1, -1, 1), p.call(1, -1, -1), p.call(1, 1, -1), p.call(1, 1, 1), bas * Vector3(1, 0, 0), cc,
            Vector2(c.z + h.z, c.y - h.y), Vector2(c.z - h.z, c.y - h.y), Vector2(c.z - h.z, c.y + h.y), Vector2(c.z + h.z, c.y + h.y))
        # -x
        _quad(mat, p.call(-1, -1, -1), p.call(-1, -1, 1), p.call(-1, 1, 1), p.call(-1, 1, -1), bas * Vector3(-1, 0, 0), cc,
            Vector2(c.z - h.z, c.y - h.y), Vector2(c.z + h.z, c.y - h.y), Vector2(c.z + h.z, c.y + h.y), Vector2(c.z - h.z, c.y + h.y))
        # top (flag 0 for plain roofs unless roof tiles requested)
        var tc := Color(col.r, col.g, col.b, 0.0 if flag > 0.9 else flag)
        _quad(mat, p.call(-1, 1, 1), p.call(1, 1, 1), p.call(1, 1, -1), p.call(-1, 1, -1), bas * Vector3(0, 1, 0), tc,
            Vector2(c.x - h.x, c.z + h.z), Vector2(c.x + h.x, c.z + h.z), Vector2(c.x + h.x, c.z - h.z), Vector2(c.x - h.x, c.z - h.z))
        if not skip_bottom:
            _quad(mat, p.call(-1, -1, -1), p.call(1, -1, -1), p.call(1, -1, 1), p.call(-1, -1, 1), bas * Vector3(0, -1, 0), cc,
                Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1))

    func cyl(c: Vector3, r: float, h: float, col: Color, seg: int = 12, flag: float = 0.0, rot: Vector3 = Vector3.ZERO,
            mat: String = "bld", r2: float = -1.0, cap: bool = true) -> void:
        var bas := Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)), EULER_ORDER_YXZ)
        var rt := r if r2 < 0.0 else r2
        var cc := Color(col.r, col.g, col.b, flag)
        var hh := h * 0.5
        for k in range(seg):
            var a0 := TAU * float(k) / float(seg)
            var a1 := TAU * float(k + 1) / float(seg)
            var d0 := Vector3(cos(a0), 0, sin(a0))
            var d1 := Vector3(cos(a1), 0, sin(a1))
            var b0 := bas * (d0 * r + Vector3(0, -hh, 0)) + c
            var b1 := bas * (d1 * r + Vector3(0, -hh, 0)) + c
            var t1 := bas * (d1 * rt + Vector3(0, hh, 0)) + c
            var t0 := bas * (d0 * rt + Vector3(0, hh, 0)) + c
            var slope = (r - rt) / max(h, 0.001)
            var n0 := (bas * Vector3(d0.x, slope, d0.z)).normalized()
            var n1 := (bas * Vector3(d1.x, slope, d1.z)).normalized()
            var s := _s(mat)
            var base: int = s["v"].size()
            s["v"].append(b0); s["v"].append(b1); s["v"].append(t1); s["v"].append(t0)
            s["n"].append(n0); s["n"].append(n1); s["n"].append(n1); s["n"].append(n0)
            for q in range(4):
                s["c"].append(cc)
            var u0 := a0 * r
            var u1 := a1 * r
            s["u"].append(Vector2(u0, b0.y)); s["u"].append(Vector2(u1, b1.y)); s["u"].append(Vector2(u1, t1.y)); s["u"].append(Vector2(u0, t0.y))
            s["i"].append(base); s["i"].append(base + 2); s["i"].append(base + 1)
            s["i"].append(base); s["i"].append(base + 3); s["i"].append(base + 2)
            if cap and rt > 0.001:
                var tc := Color(col.r, col.g, col.b, 0.0)
                _tri(mat, bas * Vector3(0, hh, 0) + c, t1, t0, bas * Vector3(0, 1, 0), tc)

    func sph(c: Vector3, r: float, col: Color, seg: int = 10, rings: int = 6, sc: Vector3 = Vector3.ONE, mat: String = "bld", flag: float = 0.0, half: bool = false) -> void:
        var cc := Color(col.r, col.g, col.b, flag)
        var r_end := rings if not half else int(rings / 2)
        for j in range(r_end):
            var v0 := PI * float(j) / float(rings)
            var v1 := PI * float(j + 1) / float(rings)
            for k in range(seg):
                var a0 := TAU * float(k) / float(seg)
                var a1 := TAU * float(k + 1) / float(seg)
                var q := func(v: float, a: float) -> Vector3:
                    return Vector3(sin(v) * cos(a) * sc.x, cos(v) * sc.y, sin(v) * sin(a) * sc.z)
                var p00: Vector3 = q.call(v0, a0)
                var p01: Vector3 = q.call(v0, a1)
                var p10: Vector3 = q.call(v1, a0)
                var p11: Vector3 = q.call(v1, a1)
                var n00 := Vector3(sin(v0) * cos(a0), cos(v0), sin(v0) * sin(a0))
                var n01 := Vector3(sin(v0) * cos(a1), cos(v0), sin(v0) * sin(a1))
                var n10 := Vector3(sin(v1) * cos(a0), cos(v1), sin(v1) * sin(a0))
                var n11 := Vector3(sin(v1) * cos(a1), cos(v1), sin(v1) * sin(a1))
                var s := _s(mat)
                var base: int = s["v"].size()
                s["v"].append(c + p00 * r); s["v"].append(c + p01 * r); s["v"].append(c + p11 * r); s["v"].append(c + p10 * r)
                s["n"].append(n00); s["n"].append(n01); s["n"].append(n11); s["n"].append(n10)
                for z in range(4):
                    s["c"].append(cc)
                s["u"].append(Vector2(0, 0)); s["u"].append(Vector2(1, 0)); s["u"].append(Vector2(1, 1)); s["u"].append(Vector2(0, 1))
                s["i"].append(base); s["i"].append(base + 1); s["i"].append(base + 2)
                s["i"].append(base); s["i"].append(base + 2); s["i"].append(base + 3)

    # triangular prism roof: c = centre of base, sz = (width, ridge height, length), ridge along z
    func gable(c: Vector3, sz: Vector3, col: Color, rot: Vector3 = Vector3.ZERO, mat: String = "bld", wall_col: Color = Color(-1, 0, 0), over: float = 0.0) -> void:
        var bas := Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)), EULER_ORDER_YXZ)
        var hw := sz.x * 0.5 + over
        var hl := sz.z * 0.5
        var hgt := sz.y
        var cc := Color(col.r, col.g, col.b, 0.5)
        var wc := col if wall_col.r < 0.0 else wall_col
        wc = Color(wc.r, wc.g, wc.b, 0.0)
        var A := bas * Vector3(-hw, 0, hl) + c
        var B := bas * Vector3(hw, 0, hl) + c
        var C := bas * Vector3(0, hgt, hl) + c
        var D := bas * Vector3(-hw, 0, -hl) + c
        var E := bas * Vector3(hw, 0, -hl) + c
        var F := bas * Vector3(0, hgt, -hl) + c
        var nl := (bas * Vector3(-hgt, hw, 0)).normalized()
        var nr := (bas * Vector3(hgt, hw, 0)).normalized()
        _quad(mat, D, A, C, F, nl, cc, Vector2(0, 0), Vector2(sz.z, 0), Vector2(sz.z, hw), Vector2(0, hw))
        _quad(mat, B, E, F, C, nr, cc, Vector2(0, 0), Vector2(sz.z, 0), Vector2(sz.z, hw), Vector2(0, hw))
        _tri(mat, A, B, C, bas * Vector3(0, 0, 1), wc)
        _tri(mat, E, D, F, bas * Vector3(0, 0, -1), wc)

    # half cylinder arch (hangar roof) along z
    func arch(c: Vector3, r: float, length: float, col: Color, seg: int = 10, mat: String = "bld", rot: Vector3 = Vector3.ZERO, sy: float = 1.0) -> void:
        var bas := Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)), EULER_ORDER_YXZ)
        var cc := Color(col.r, col.g, col.b, 0.0)
        var hl := length * 0.5
        for k in range(seg):
            var a0 := PI * float(k) / float(seg)
            var a1 := PI * float(k + 1) / float(seg)
            var p0 := Vector3(cos(a0) * r, sin(a0) * r * sy, 0)
            var p1 := Vector3(cos(a1) * r, sin(a1) * r * sy, 0)
            var n0 := (bas * Vector3(cos(a0), sin(a0), 0)).normalized()
            var n1 := (bas * Vector3(cos(a1), sin(a1), 0)).normalized()
            var s := _s(mat)
            var base: int = s["v"].size()
            s["v"].append(bas * (p0 + Vector3(0, 0, hl)) + c); s["v"].append(bas * (p1 + Vector3(0, 0, hl)) + c)
            s["v"].append(bas * (p1 + Vector3(0, 0, -hl)) + c); s["v"].append(bas * (p0 + Vector3(0, 0, -hl)) + c)
            s["n"].append(n0); s["n"].append(n1); s["n"].append(n1); s["n"].append(n0)
            for q in range(4):
                s["c"].append(cc)
            s["u"].append(Vector2(0, 0)); s["u"].append(Vector2(1, 0)); s["u"].append(Vector2(1, 1)); s["u"].append(Vector2(0, 1))
            s["i"].append(base); s["i"].append(base + 1); s["i"].append(base + 2)
            s["i"].append(base); s["i"].append(base + 2); s["i"].append(base + 3)
            _tri(mat, bas * Vector3(0, 0, hl) + c, bas * p1 + bas * Vector3(0, 0, hl) + c, bas * p0 + bas * Vector3(0, 0, hl) + c, bas * Vector3(0, 0, 1), cc)
            _tri(mat, bas * Vector3(0, 0, -hl) + c, bas * p0 + bas * Vector3(0, 0, -hl) + c, bas * p1 + bas * Vector3(0, 0, -hl) + c, bas * Vector3(0, 0, -1), cc)

    # extruded convex polygon in XZ, from y0 to y1
    func poly(pts: PackedVector2Array, y0: float, y1: float, col: Color, mat: String = "bld", flag: float = 0.0, off: Vector3 = Vector3.ZERO) -> void:
        var area := 0.0
        for q in range(pts.size()):
            var qa := pts[q]
            var qb := pts[(q + 1) % pts.size()]
            area += qa.x * qb.y - qb.x * qa.y
        if area < 0.0:
            var rv := PackedVector2Array()
            for q in range(pts.size() - 1, -1, -1):
                rv.append(pts[q])
            pts = rv
        var n := pts.size()
        var cc := Color(col.r, col.g, col.b, flag)
        var tc := Color(col.r, col.g, col.b, 0.0)
        var cen := Vector2.ZERO
        for p in pts:
            cen += p
        cen /= float(n)
        for k in range(n):
            var a := pts[k]
            var b := pts[(k + 1) % n]
            # top fan triangle (points ordered CCW seen from above => clockwise from below)
            _tri(mat, Vector3(cen.x, y1, cen.y) + off, Vector3(b.x, y1, b.y) + off, Vector3(a.x, y1, a.y) + off, Vector3.UP, tc)
            var e := b - a
            var nrm := Vector3(e.y, 0, -e.x).normalized()
            _quad(mat, Vector3(a.x, y0, a.y) + off, Vector3(b.x, y0, b.y) + off, Vector3(b.x, y1, b.y) + off, Vector3(a.x, y1, a.y) + off, nrm, cc,
                Vector2(a.x + a.y, y0), Vector2(b.x + b.y, y0), Vector2(b.x + b.y, y1), Vector2(a.x + a.y, y1))

    func bake(mats: Dictionary) -> ArrayMesh:
        var m := ArrayMesh.new()
        for key in surf.keys():
            var s: Dictionary = surf[key]
            if s["v"].size() == 0:
                continue
            var arr := []
            arr.resize(Mesh.ARRAY_MAX)
            arr[Mesh.ARRAY_VERTEX] = s["v"]
            arr[Mesh.ARRAY_NORMAL] = s["n"]
            arr[Mesh.ARRAY_COLOR] = s["c"]
            arr[Mesh.ARRAY_TEX_UV] = s["u"]
            arr[Mesh.ARRAY_INDEX] = s["i"]
            m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
            m.surface_set_material(m.get_surface_count() - 1, mats[key])
        return m


# =====================================================================
#  MODELS - helpers
# =====================================================================
const C_CONC := Color(0.62, 0.62, 0.6)
const C_ASPH := Color(0.1, 0.105, 0.115)
const C_WHITE := Color(0.93, 0.93, 0.92)
const C_GRASS := Color(0.16, 0.34, 0.1)
const C_OLIVE := Color(0.3, 0.34, 0.2)
const C_DARK := Color(0.12, 0.13, 0.15)
const C_STEEL := Color(0.55, 0.58, 0.62)
const C_GLOW_Y := Color(1.0, 0.85, 0.45)

func _rng_for(seed_v: int) -> RandomNumberGenerator:
    var r := RandomNumberGenerator.new()
    r.seed = seed_v * 7919 + 13
    return r


func _lot(mb: MB, w: float, d: float, col: Color, h: float = 0.16, off: Vector3 = Vector3.ZERO) -> void:
    mb.box(Vector3(off.x, h * 0.5 + off.y, off.z), Vector3(w, h, d), col)


func _tree_m(mb: MB, x: float, z: float, s: float, kind: int = 0, y: float = 0.0) -> void:
    if kind == 0:
        mb.cyl(Vector3(x, y + 0.5 * s, z), 0.28 * s, 1.0 * s, Color(0.55, 0.38, 0.25), 6)
        mb.cyl(Vector3(x, y + 1.9 * s, z), 1.7 * s, 2.0 * s, Color(0.28, 0.72, 0.46), 8, 0.0, Vector3.ZERO, "bld", 0.15 * s)
        mb.cyl(Vector3(x, y + 3.3 * s, z), 1.3 * s, 1.8 * s, Color(0.34, 0.8, 0.52), 8, 0.0, Vector3.ZERO, "bld", 0.1 * s)
        mb.cyl(Vector3(x, y + 4.5 * s, z), 0.9 * s, 1.6 * s, Color(0.42, 0.86, 0.58), 8, 0.0, Vector3.ZERO, "bld", 0.0)
    else:
        mb.cyl(Vector3(x, y + 0.5 * s, z), 0.3 * s, 1.0 * s, Color(0.55, 0.38, 0.25), 6)
        mb.sph(Vector3(x, y + 2.4 * s, z), 1.6 * s, Color(0.3, 0.76, 0.48), 9, 6, Vector3(1.0, 1.1, 1.0))
        mb.sph(Vector3(x + 0.6 * s, y + 3.2 * s, z - 0.3 * s), 1.0 * s, Color(0.4, 0.84, 0.54), 8, 5)


const TRAFFIC_SHADER := """
shader_type spatial;
global uniform float night;
varying vec3 vc;
varying float vf;
void vertex() {
    float t = mod(INSTANCE_CUSTOM.y + TIME * INSTANCE_CUSTOM.x, 280.0) - 140.0;
    VERTEX.z += t;
    float h = INSTANCE_CUSTOM.z;
    vec3 pal = 0.5 + 0.5 * cos(6.2831 * (h + vec3(0.0, 0.33, 0.67)));
    vc = mix(pal, vec3(0.9), step(0.8, fract(h * 7.0)) * 0.7);
    vf = COLOR.a;
}
void fragment() {
    vec3 c = COLOR.rgb;
    if (COLOR.r > 0.95 && COLOR.g < 0.05 && COLOR.b > 0.95) {
        c = vc;
    }
    ALBEDO = c;
    ROUGHNESS = 0.4;
    METALLIC = 0.2;
    if (COLOR.r > 0.95 && COLOR.g > 0.95 && COLOR.b > 0.75 && COLOR.b < 0.85) {
        EMISSION = vec3(1.0, 0.9, 0.6) * (0.4 + night * 2.0);
    }
}
"""

var traffic_mat: ShaderMaterial = null
var traffic_mesh: ArrayMesh = null


func _make_traffic(node: Node3D) -> void:
    if traffic_mat == null:
        var sh := Shader.new()
        sh.code = TRAFFIC_SHADER
        traffic_mat = ShaderMaterial.new()
        traffic_mat.shader = sh
        var mb := MB.new()
        mb.box(Vector3(0, 0.55, 0), Vector3(1.8, 0.7, 4.0), Color(1, 0, 1), 0.0)
        mb.box(Vector3(0, 1.1, -0.2), Vector3(1.6, 0.55, 2.1), Color(0.08, 0.1, 0.14), 0.0)
        mb.box(Vector3(0, 0.2, 0), Vector3(1.7, 0.3, 3.6), Color(0.03, 0.03, 0.03), 0.0)
        mb.box(Vector3(-0.6, 0.6, 2.02), Vector3(0.4, 0.2, 0.06), Color(1, 1, 0.8), 2.0)
        mb.box(Vector3(0.6, 0.6, 2.02), Vector3(0.4, 0.2, 0.06), Color(1, 1, 0.8), 2.0)
        traffic_mesh = mb.bake(mats)
    var rng := RandomNumberGenerator.new()
    rng.seed = 777 + node.get_instance_id() % 1000
    var items := []
    for k in range(-2, 3):
        var rc := float(k) * 64.0
        for dir in range(2):
            for n in range(2):
                # along Z
                var sgn := 1.0 if dir == 0 else -1.0
                var lane := -1.6 * sgn
                var tz := Transform3D(Basis(Vector3.UP, 0.0 if dir == 0 else PI), Vector3(rc + lane, 0.05, 0))
                items.append([tz, rng.randf_range(7.0, 13.0), rng.randf_range(0.0, 280.0), rng.randf()])
                var tx := Transform3D(Basis(Vector3.UP, PI * 0.5 if dir == 0 else -PI * 0.5), Vector3(0, 0.05, rc + lane))
                items.append([tx, rng.randf_range(7.0, 13.0), rng.randf_range(0.0, 280.0), rng.randf()])
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.use_colors = true
    mm.use_custom_data = true
    mm.mesh = traffic_mesh
    mm.instance_count = items.size()
    for q in range(items.size()):
        mm.set_instance_transform(q, items[q][0])
        mm.set_instance_color(q, Color(1, 1, 1, 1))
        mm.set_instance_custom_data(q, Color(items[q][1], items[q][2], items[q][3], 0.0))
    var inst := MultiMeshInstance3D.new()
    inst.multimesh = mm
    inst.material_override = traffic_mat
    inst.custom_aabb = AABB(Vector3(-170, -2, -170), Vector3(340, 12, 340))
    inst.visibility_range_end = 420.0
    inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    node.add_child(inst)



func _car_m(mb: MB, x: float, z: float, rot: float, col: Color, y: float = 0.0) -> void:
    var r := Vector3(0, rot, 0)
    var bas := Basis.from_euler(Vector3(0, deg_to_rad(rot), 0))
    mb.box(Vector3(x, y + 0.55, z), Vector3(1.9, 0.7, 4.2), col, 0.0, r, "metal")
    var cab := bas * Vector3(0, 0, -0.2) + Vector3(x, y + 1.1, z)
    mb.box(cab, Vector3(1.7, 0.6, 2.2), Color(0.06, 0.09, 0.12), 0.0, r, "metal")
    mb.box(Vector3(x, y + 0.2, z), Vector3(1.8, 0.3, 3.8), Color(0.03, 0.03, 0.03), 0.0, r)


func _fence_m(mb: MB, w: float, d: float, col: Color, h: float = 0.9, gap: float = 0.0) -> void:
    mb.box(Vector3(0, h * 0.5, d * 0.5), Vector3(w, h, 0.12), col)
    mb.box(Vector3(0, h * 0.5, -d * 0.5), Vector3(w, h, 0.12), col)
    mb.box(Vector3(-w * 0.5, h * 0.5, 0), Vector3(0.12, h, d), col)
    mb.box(Vector3(w * 0.5, h * 0.5, 0), Vector3(0.12, h, d), col)


func _flagpole_m(mb: MB, x: float, z: float, h: float, col: Color, col2: Color = Color(1, 1, 1)) -> void:
    mb.cyl(Vector3(x, h * 0.5, z), 0.12, h, Color(0.8, 0.8, 0.82), 6, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(x + 1.0, h - 0.7, z), Vector3(1.8, 0.55, 0.06), col)
    mb.box(Vector3(x + 1.0, h - 1.25, z), Vector3(1.8, 0.55, 0.06), col2)


func _ac_m(mb: MB, x: float, y: float, z: float) -> void:
    mb.box(Vector3(x, y + 0.4, z), Vector3(1.6, 0.8, 1.2), Color(0.7, 0.72, 0.74), 0.0, Vector3.ZERO, "metal")
    mb.cyl(Vector3(x, y + 0.82, z), 0.45, 0.06, Color(0.15, 0.15, 0.16), 8)


# =====================================================================
#  MODELS - city buildings
# =====================================================================
func _m_house(mb: MB, lvl: int, v: int, acc: Color) -> void:
    var walls := [Color(0.9, 0.86, 0.76), Color(0.74, 0.42, 0.32), Color(0.93, 0.93, 0.9), Color(0.72, 0.76, 0.62)]
    var roofs := [Color(0.55, 0.22, 0.14), Color(0.2, 0.22, 0.27), Color(0.36, 0.2, 0.12), Color(0.45, 0.12, 0.1)]
    var w: Color = walls[v % 4]
    var rc: Color = roofs[(v + lvl) % 4]
    _lot(mb, 10.0, 10.0, C_GRASS, 0.12)
    mb.box(Vector3(1.2, 0.1, 4.2), Vector3(2.6, 0.2, 3.0), Color(0.38, 0.38, 0.4))
    var floors := 1 if lvl == 1 else 2
    var bh := 3.2 * float(floors)
    mb.box(Vector3(-0.4, bh * 0.5 + 0.12, -0.8), Vector3(6.6, bh, 5.2), w, 1.0)
    mb.gable(Vector3(-0.4, bh + 0.12, -0.8), Vector3(6.6, 2.0 + 0.4 * float(lvl), 5.4), rc, Vector3.ZERO, "bld", w, 0.35)
    mb.box(Vector3(-0.4, 1.1 + 0.12, 1.85), Vector3(1.1, 2.1, 0.25), Color(0.22, 0.12, 0.07))
    mb.box(Vector3(1.8, 0.3, 4.2), Vector3(0.1, 0.1, 0.1), w)
    mb.box(Vector3(-2.6, bh + 2.2, -1.6), Vector3(0.7, 1.6, 0.7), Color(0.55, 0.3, 0.22))
    if lvl >= 2:
        mb.box(Vector3(3.6, 1.35 + 0.12, -0.2), Vector3(3.2, 2.7, 4.6), w, 1.0)
        mb.box(Vector3(3.6, 2.8 + 0.12, -0.2), Vector3(3.4, 0.25, 4.8), Color(0.4, 0.4, 0.42))
        mb.box(Vector3(3.6, 1.0, 2.4), Vector3(2.6, 2.0, 0.15), Color(0.5, 0.52, 0.55), 0.0, Vector3.ZERO, "metal")
    if lvl >= 3:
        mb.box(Vector3(-3.4, 0.25, 3.6), Vector3(3.4, 0.3, 2.4), Color(0.75, 0.75, 0.72))
        mb.box(Vector3(-3.4, 0.33, 3.6), Vector3(2.8, 0.2, 1.8), Color(0.2, 0.62, 0.85), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(-0.4, bh + 0.2, 1.9), Vector3(5.0, 0.15, 1.4), Color(0.7, 0.7, 0.7))
    _fence_m(mb, 9.6, 9.6, Color(0.92, 0.92, 0.9), 0.8)
    _tree_m(mb, -4.0, 3.8, 0.8, v % 2)
    _tree_m(mb, 4.0, -3.9, 0.7, (v + 1) % 2)
    if lvl >= 2:
        _car_m(mb, 1.6, 3.2, 0.0, [Color(0.7, 0.1, 0.1), Color(0.15, 0.2, 0.5), Color(0.8, 0.8, 0.8), Color(0.1, 0.1, 0.1)][v % 4])


func _m_apartment(mb: MB, lvl: int, v: int, acc: Color) -> void:
    var cols := [Color(0.86, 0.82, 0.72), Color(0.78, 0.8, 0.84), Color(0.8, 0.66, 0.56), Color(0.9, 0.9, 0.88)]
    var c: Color = cols[v % 4]
    var floors := 4 + lvl * 2
    var h := 3.3 * float(floors)
    _lot(mb, 16.0, 16.0, Color(0.5, 0.5, 0.48), 0.14)
    mb.box(Vector3(0, h * 0.5 + 0.14, -0.6), Vector3(11.0, h, 10.0), c, 1.0)
    mb.box(Vector3(0, 1.8, 4.75), Vector3(10.6, 3.2, 1.0), Color(0.08, 0.1, 0.12), 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(0, 3.5, 5.0), Vector3(11.4, 0.3, 1.4), acc)
    for k in range(1, floors):
        var y := 3.3 * float(k) + 0.14
        mb.box(Vector3(0, y, 4.6), Vector3(9.2, 0.22, 1.1), Color(0.7, 0.7, 0.7))
        mb.box(Vector3(0, y + 0.5, 5.1), Vector3(9.2, 0.7, 0.08), Color(0.2, 0.3, 0.35), 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(0, h + 0.4, -0.6), Vector3(11.4, 0.8, 10.4), Color(0.55, 0.55, 0.55))
    mb.box(Vector3(0, h + 0.14, -0.6), Vector3(10.4, 0.5, 9.4), Color(0.28, 0.28, 0.3))
    mb.box(Vector3(-3.0, h + 1.6, -2.5), Vector3(2.6, 2.0, 2.6), Color(0.7, 0.7, 0.7))
    _ac_m(mb, 2.5, h + 0.8, 0.5)
    _ac_m(mb, 4.0, h + 0.8, -3.0)
    mb.cyl(Vector3(3.2, h + 3.0, 2.0), 0.09, 4.0, Color(0.7, 0.7, 0.72), 6, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(3.2, h + 5.1, 2.0), Vector3(0.25, 0.25, 0.25), Color(1.0, 0.1, 0.1), 0.0, Vector3.ZERO, "glow")
    if lvl >= 3:
        mb.box(Vector3(-5.8, h * 0.35, -0.6), Vector3(3.0, h * 0.7, 8.0), c, 1.0)
    _car_m(mb, -6.2, 6.0, 90.0, Color(0.7, 0.7, 0.72))
    _car_m(mb, 6.2, 6.4, 90.0, Color(0.15, 0.15, 0.4))
    _tree_m(mb, -7.0, -6.8, 0.9, 0)
    _tree_m(mb, 7.0, -6.8, 0.9, 1)


func _m_commerce(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 28.0, 20.0, C_ASPH, 0.14)
    var h := 6.0 + 1.5 * float(lvl)
    mb.box(Vector3(-2.0, h * 0.5 + 0.14, -3.5), Vector3(20.0, h, 12.0), Color(0.82, 0.82, 0.8), 1.0)
    mb.box(Vector3(-2.0, 2.0, 2.6), Vector3(18.0, 3.4, 0.4), Color(0.05, 0.12, 0.16), 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(-2.0, 4.2, 3.6), Vector3(19.0, 0.5, 2.8), acc)
    mb.box(Vector3(-2.0, h + 0.9, -3.5), Vector3(14.0, 1.4, 0.3), acc.lightened(0.2), 0.0, Vector3.ZERO, "glow")
    mb.box(Vector3(-2.0, h + 0.4, -3.5), Vector3(20.6, 0.8, 12.6), Color(0.5, 0.5, 0.52))
    _ac_m(mb, -8.0, h + 0.8, -5.0)
    _ac_m(mb, 3.0, h + 0.8, -6.0)
    _ac_m(mb, 5.0, h + 0.8, -2.0)
    if lvl >= 2:
        mb.cyl(Vector3(8.0, h + 1.5, -3.0), 2.4, 3.0, Color(0.7, 0.75, 0.8), 12, 1.0)
    for k in range(-5, 6):
        mb.box(Vector3(float(k) * 2.4 - 1.0, 0.2, 7.5), Vector3(0.12, 0.05, 3.6), Color(0.9, 0.9, 0.9))
    for k in range(7):
        var cc := [Color(0.7, 0.1, 0.1), Color(0.1, 0.2, 0.5), Color(0.85, 0.85, 0.85), Color(0.1, 0.1, 0.1), Color(0.8, 0.7, 0.1)]
        _car_m(mb, float(k) * 4.4 - 11.0, 7.8, 0.0, cc[(k + v) % 5])
    mb.cyl(Vector3(-13.0, 2.5, 8.0), 0.15, 5.0, Color(0.5, 0.5, 0.5), 6, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(-13.0, 5.1, 8.0), Vector3(1.4, 0.4, 0.8), C_GLOW_Y, 0.0, Vector3.ZERO, "glow")


func _m_office(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 18.0, 18.0, Color(0.55, 0.55, 0.54), 0.16)
    mb.box(Vector3(0, 2.4, 0), Vector3(16.0, 4.4, 16.0), Color(0.2, 0.26, 0.3), 1.0)
    mb.box(Vector3(0, 4.7, 0), Vector3(16.6, 0.5, 16.6), Color(0.7, 0.7, 0.72))
    var h1 := 18.0 + 8.0 * float(lvl)
    mb.box(Vector3(0, 4.9 + h1 * 0.5, 0), Vector3(12.0, h1, 12.0), Color(0.3, 0.42, 0.5), 1.0)
    var y := 4.9 + h1
    mb.box(Vector3(0, y + 0.3, 0), Vector3(12.4, 0.6, 12.4), Color(0.7, 0.7, 0.72))
    var h2 := 12.0 + 4.0 * float(lvl)
    mb.box(Vector3(0, y + 0.6 + h2 * 0.5, 0), Vector3(8.6, h2, 8.6), Color(0.34, 0.46, 0.55), 1.0)
    y += 0.6 + h2
    mb.box(Vector3(0, y + 0.3, 0), Vector3(9.0, 0.6, 9.0), Color(0.7, 0.7, 0.72))
    if lvl >= 2:
        var h3 := 9.0
        mb.box(Vector3(0, y + 0.6 + h3 * 0.5, 0), Vector3(5.2, h3, 5.2), Color(0.38, 0.5, 0.6), 1.0)
        y += 0.6 + h3
    mb.cyl(Vector3(0, y + 4.0, 0), 0.25, 8.0, Color(0.8, 0.8, 0.82), 6, 0.0, Vector3.ZERO, "metal", 0.04)
    mb.box(Vector3(0, y + 8.2, 0), Vector3(0.5, 0.5, 0.5), Color(1.0, 0.1, 0.1), 0.0, Vector3.ZERO, "glow")
    mb.box(Vector3(0, 0.9, 8.1), Vector3(14.0, 0.25, 1.0), acc.lightened(0.1), 0.0, Vector3.ZERO, "glow")
    _tree_m(mb, -8.0, 8.0, 0.8, 0)
    _tree_m(mb, 8.0, 8.0, 0.8, 0)
    _car_m(mb, -7.0, -8.6, 90.0, Color(0.1, 0.1, 0.1))


func _m_factory(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 30.0, 22.0, Color(0.45, 0.45, 0.43), 0.16)
    var sheds := 3 + lvl
    for k in range(sheds):
        var x := -12.0 + float(k) * (24.0 / float(sheds - 1)) * 1.0
        mb.box(Vector3(x, 3.0, -3.0), Vector3(6.2, 5.8, 12.0), Color(0.62, 0.64, 0.66), 0.35)
        mb.gable(Vector3(x, 5.9, -3.0), Vector3(6.2, 1.8, 12.0), Color(0.45, 0.47, 0.5), Vector3.ZERO, "bld", Color(0.62, 0.64, 0.66))
        mb.box(Vector3(x, 1.3, 3.05), Vector3(4.0, 2.6, 0.2), Color(0.18, 0.2, 0.25))
    for k in range(lvl + 1):
        var cx := 12.0 - float(k) * 3.6
        mb.cyl(Vector3(cx, 7.0, -9.0), 1.0, 14.0, Color(0.7, 0.3, 0.25), 10, 0.0, Vector3.ZERO, "bld", 0.8)
        mb.cyl(Vector3(cx, 11.5, -9.0), 1.02, 1.4, Color(0.92, 0.92, 0.92), 10, 0.0, Vector3.ZERO, "bld", 0.82)
        mb.box(Vector3(cx, 14.2, -9.0), Vector3(0.4, 0.4, 0.4), Color(1.0, 0.2, 0.1), 0.0, Vector3.ZERO, "glow")
    mb.cyl(Vector3(-11.0, 2.2, 8.0), 2.6, 4.4, Color(0.8, 0.8, 0.82), 12, 0.0, Vector3.ZERO, "metal")
    mb.cyl(Vector3(-5.5, 2.2, 8.0), 2.6, 4.4, Color(0.8, 0.8, 0.82), 12, 0.0, Vector3.ZERO, "metal")
    var cc := [Color(0.75, 0.2, 0.15), Color(0.15, 0.3, 0.6), Color(0.85, 0.65, 0.1), Color(0.2, 0.5, 0.3)]
    for k in range(6):
        mb.box(Vector3(4.0 + float(k % 3) * 6.2, 1.3 + float(k / 3) * 2.6, 8.2), Vector3(6.0, 2.5, 2.4), cc[(k + v) % 4], 0.0, Vector3.ZERO, "metal")


func _m_park(mb: MB, lvl: int, v: int, acc: Color) -> void:
    mb.box(Vector3(0, 0.1, 0), Vector3(22.0, 0.2, 22.0), Color(0.2, 0.46, 0.14))
    mb.box(Vector3(0, 0.23, 0), Vector3(2.0, 0.06, 22.0), Color(0.72, 0.68, 0.58))
    mb.box(Vector3(0, 0.24, 0), Vector3(22.0, 0.06, 2.0), Color(0.72, 0.68, 0.58))
    mb.cyl(Vector3(0, 0.22, 0), 3.4, 0.2, Color(0.65, 0.62, 0.55), 16)
    mb.cyl(Vector3(0, 0.32, 0), 2.6, 0.2, Color(0.2, 0.55, 0.8), 16, 0.0, Vector3.ZERO, "metal")
    mb.cyl(Vector3(0, 1.0, 0), 0.3, 1.4, Color(0.8, 0.8, 0.8), 8)
    mb.sph(Vector3(0, 1.8, 0), 0.5, Color(0.75, 0.9, 1.0), 8, 4, Vector3.ONE, "metal")
    var r := _rng_for(v + 5)
    for k in range(9 + lvl * 3):
        var x := r.randf_range(-9.5, 9.5)
        var z := r.randf_range(-9.5, 9.5)
        if abs(x) < 2.0 or abs(z) < 2.0 or (x * x + z * z) < 16.0:
            continue
        _tree_m(mb, x, z, r.randf_range(0.8, 1.3), r.randi() % 2)
    for k in range(4):
        var a := float(k) * PI * 0.5 + 0.8
        mb.box(Vector3(cos(a) * 5.0, 0.55, sin(a) * 5.0), Vector3(1.8, 0.1, 0.6), Color(0.45, 0.3, 0.15), 0.0, Vector3(0, -rad_to_deg(a), 0))
        mb.box(Vector3(cos(a) * 5.0, 0.3, sin(a) * 5.0), Vector3(1.6, 0.4, 0.12), Color(0.2, 0.2, 0.2))


func _ring(mb: MB, r_out: float, r_in: float, y0: float, y1: float, col: Color, seg: int = 24, sx: float = 1.0, sz: float = 1.0, flag: float = 0.0) -> void:
    var cc := Color(col.r, col.g, col.b, flag)
    var tc := Color(col.r, col.g, col.b, 0.0)
    for k in range(seg):
        var a0 := TAU * float(k) / float(seg)
        var a1 := TAU * float(k + 1) / float(seg)
        var o0 := Vector3(cos(a0) * r_out * sx, 0, sin(a0) * r_out * sz)
        var o1 := Vector3(cos(a1) * r_out * sx, 0, sin(a1) * r_out * sz)
        var i0 := Vector3(cos(a0) * r_in * sx, 0, sin(a0) * r_in * sz)
        var i1 := Vector3(cos(a1) * r_in * sx, 0, sin(a1) * r_in * sz)
        var n0 := Vector3(cos(a0), 0, sin(a0))
        var n1 := Vector3(cos(a1), 0, sin(a1))
        var up := Vector3(0, y1, 0)
        var dn := Vector3(0, y0, 0)
        mb._quad("bld", o1 + dn, o0 + dn, o0 + up, o1 + up, (n0 + n1).normalized(), cc, Vector2(0, y0), Vector2(1, y0), Vector2(1, y1), Vector2(0, y1))
        mb._quad("bld", i0 + dn, i1 + dn, i1 + up, i0 + up, -(n0 + n1).normalized(), cc, Vector2(0, y0), Vector2(1, y0), Vector2(1, y1), Vector2(0, y1))
        mb._quad("bld", i0 + up, i1 + up, o1 + up, o0 + up, Vector3.UP, tc, Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1))


func _m_stadium(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 38.0, 30.0, Color(0.5, 0.5, 0.5), 0.14)
    mb.box(Vector3(0, 0.3, 0), Vector3(22.0, 0.3, 14.0), Color(0.15, 0.5, 0.15))
    mb.box(Vector3(0, 0.46, 0), Vector3(0.25, 0.05, 14.0), Color(1, 1, 1))
    for t in range(3):
        _ring(mb, 17.0 + float(t) * 0.0, 9.0 + float(t) * 1.8, 0.2, 3.0 + float(t) * 2.4, [Color(0.75, 0.75, 0.72), Color(0.6, 0.62, 0.66), acc][t], 28, 1.0, 0.78)
    _ring(mb, 17.2, 16.6, 0.2, 10.5, Color(0.85, 0.85, 0.85), 28, 1.0, 0.78, 1.0)
    for k in range(4):
        var sx := -1.0 if k % 2 == 0 else 1.0
        var sz := -1.0 if k < 2 else 1.0
        mb.cyl(Vector3(sx * 15.0, 7.0, sz * 11.5), 0.3, 14.0, Color(0.7, 0.7, 0.72), 6, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(sx * 15.0, 14.2, sz * 11.5), Vector3(3.0, 1.6, 0.5), Color(1.0, 0.95, 0.8), 0.0, Vector3(-20.0, 0, 0), "glow")


func _m_hospital(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 24.0, 18.0, Color(0.55, 0.55, 0.55), 0.14)
    var h := 3.4 * float(3 + lvl)
    mb.box(Vector3(-2.0, h * 0.5 + 0.14, -1.5), Vector3(16.0, h, 9.0), Color(0.94, 0.94, 0.95), 1.0)
    mb.box(Vector3(6.5, h * 0.35 + 0.14, -1.5), Vector3(7.0, h * 0.7, 9.0), Color(0.9, 0.92, 0.94), 1.0)
    mb.box(Vector3(-2.0, h + 0.4, -1.5), Vector3(16.6, 0.5, 9.6), Color(0.7, 0.7, 0.72))
    mb.box(Vector3(-2.0, h + 1.0, -1.5), Vector3(4.2, 0.4, 1.2), Color(1.0, 0.1, 0.1), 0.0, Vector3.ZERO, "glow")
    mb.box(Vector3(-2.0, h + 1.0, -1.5), Vector3(1.2, 0.4, 4.2), Color(1.0, 0.1, 0.1), 0.0, Vector3.ZERO, "glow")
    mb.cyl(Vector3(6.5, h * 0.7 + 0.3, -1.5), 2.8, 0.2, Color(0.3, 0.3, 0.32), 14)
    mb.box(Vector3(6.5, h * 0.7 + 0.45, -1.5), Vector3(0.4, 0.05, 2.2), Color(1, 1, 1), 0.0, Vector3.ZERO, "glow")
    mb.box(Vector3(-2.0, 1.4, 4.0), Vector3(8.0, 2.6, 3.0), Color(0.85, 0.88, 0.9), 1.0)
    mb.box(Vector3(-2.0, 3.0, 5.0), Vector3(9.0, 0.3, 3.4), Color(0.1, 0.45, 0.8))
    _car_m(mb, 8.0, 6.5, 0.0, Color(0.95, 0.95, 0.95))
    _car_m(mb, 11.0, 6.5, 0.0, Color(0.95, 0.3, 0.2))
    _tree_m(mb, -10.0, 7.0, 0.8, 0)


func _m_university(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 28.0, 20.0, Color(0.2, 0.42, 0.14), 0.12)
    mb.box(Vector3(0, 0.18, 6.0), Vector3(4.0, 0.12, 8.0), Color(0.72, 0.68, 0.58))
    var c := Color(0.8, 0.72, 0.58)
    mb.box(Vector3(0, 3.0, -2.0), Vector3(14.0, 6.0, 8.0), c, 1.0)
    mb.box(Vector3(-10.0, 2.4, -2.0), Vector3(9.0, 4.8, 7.0), c, 1.0)
    mb.box(Vector3(10.0, 2.4, -2.0), Vector3(9.0, 4.8, 7.0), c, 1.0)
    mb.box(Vector3(0, 6.2, -2.0), Vector3(14.6, 0.5, 8.6), Color(0.55, 0.5, 0.42))
    for k in range(6):
        mb.cyl(Vector3(-5.0 + float(k) * 2.0, 2.4, 2.6), 0.4, 4.8, Color(0.92, 0.9, 0.85), 8)
    mb.box(Vector3(0, 5.1, 2.6), Vector3(13.0, 0.6, 1.6), Color(0.9, 0.88, 0.82))
    mb.gable(Vector3(0, 5.4, 2.7), Vector3(13.0, 1.8, 1.6), Color(0.8, 0.78, 0.72), Vector3(0, 90, 0), "bld", Color(0.9, 0.88, 0.82))
    mb.box(Vector3(0, 9.0, -2.0), Vector3(3.2, 5.6, 3.2), c, 1.0)
    mb.cyl(Vector3(0, 12.6, -2.0), 1.4, 1.6, Color(0.35, 0.5, 0.45), 8, 0.0, Vector3.ZERO, "metal", 0.1)
    mb.box(Vector3(0, 9.2, -0.35), Vector3(1.4, 1.4, 0.1), Color(1, 1, 0.9), 0.0, Vector3.ZERO, "glow")
    _tree_m(mb, -11.0, 7.0, 1.0, 0)
    _tree_m(mb, 11.0, 7.0, 1.0, 0)
    _tree_m(mb, -6.0, 8.0, 0.9, 1)
    _tree_m(mb, 6.0, 8.0, 0.9, 1)


func _m_police(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 14.0, 12.0, Color(0.45, 0.45, 0.46), 0.14)
    mb.box(Vector3(-1.0, 2.1, -1.0), Vector3(9.0, 4.0, 6.0), Color(0.55, 0.62, 0.72), 1.0)
    mb.box(Vector3(-1.0, 4.2, -1.0), Vector3(9.5, 0.4, 6.5), Color(0.2, 0.28, 0.45))
    mb.box(Vector3(-1.0, 4.8, 2.0), Vector3(3.0, 0.3, 0.3), Color(0.1, 0.3, 1.0), 0.0, Vector3.ZERO, "glow")
    mb.box(Vector3(0.6, 4.8, 2.0), Vector3(1.0, 0.3, 0.3), Color(1.0, 0.1, 0.1), 0.0, Vector3.ZERO, "glow")
    _car_m(mb, -4.0, 4.0, 0.0, Color(0.9, 0.9, 0.92))
    _car_m(mb, 0.0, 4.0, 0.0, Color(0.06, 0.07, 0.1))
    _flagpole_m(mb, 5.0, 3.0, 6.0, acc)


func _m_embassy(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 18.0, 16.0, Color(0.22, 0.45, 0.16), 0.12)
    mb.box(Vector3(0, 0.2, 5.0), Vector3(3.0, 0.2, 6.0), Color(0.75, 0.72, 0.65))
    mb.box(Vector3(0, 3.0, -1.0), Vector3(13.0, 6.0, 8.0), Color(0.9, 0.88, 0.84), 1.0)
    mb.box(Vector3(0, 6.2, -1.0), Vector3(13.6, 0.5, 8.6), Color(0.5, 0.45, 0.4))
    for k in range(6):
        mb.cyl(Vector3(-5.0 + float(k) * 2.0, 2.8, 3.8), 0.35, 5.6, Color(0.95, 0.94, 0.9), 8)
    mb.box(Vector3(0, 5.8, 3.8), Vector3(12.4, 0.5, 1.4), Color(0.95, 0.94, 0.9))
    _flagpole_m(mb, -7.0, 6.5, 9.0, acc, acc.lightened(0.5))
    _flagpole_m(mb, 7.0, 6.5, 9.0, Color(0.9, 0.9, 0.9), acc)
    _tree_m(mb, -8.0, -6.0, 1.0, 0)
    _tree_m(mb, 8.0, -6.0, 1.0, 0)


func _m_parliament(mb: MB, lvl: int, v: int, acc: Color) -> void:
    mb.box(Vector3(0, 0.1, 0), Vector3(40.0, 0.2, 26.0), Color(0.68, 0.66, 0.6))
    mb.box(Vector3(0, 0.5, 0), Vector3(30.0, 0.5, 16.0), Color(0.82, 0.8, 0.74))
    mb.box(Vector3(0, 4.5, -1.0), Vector3(28.0, 7.5, 12.0), Color(0.9, 0.88, 0.82), 1.0)
    mb.box(Vector3(0, 8.6, -1.0), Vector3(28.8, 0.7, 12.8), Color(0.7, 0.66, 0.6))
    for k in range(12):
        mb.cyl(Vector3(-11.0 + float(k) * 2.0, 4.5, 6.0), 0.5, 7.0, Color(0.96, 0.95, 0.9), 8)
    mb.box(Vector3(0, 8.4, 6.0), Vector3(25.0, 0.8, 2.0), Color(0.95, 0.94, 0.9))
    mb.gable(Vector3(0, 8.8, 6.1), Vector3(25.0, 2.6, 2.0), Color(0.88, 0.86, 0.8), Vector3(0, 90, 0), "bld", Color(0.95, 0.94, 0.9))
    mb.cyl(Vector3(0, 11.5, -1.0), 5.6, 5.0, Color(0.9, 0.88, 0.82), 20, 0.0, Vector3.ZERO, "bld", 5.2)
    mb.sph(Vector3(0, 14.0, -1.0), 5.4, Color(0.78, 0.66, 0.28), 20, 10, Vector3(1, 0.85, 1), "metal", 0.0, true)
    mb.cyl(Vector3(0, 19.4, -1.0), 0.15, 3.0, Color(0.9, 0.8, 0.3), 6, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(-17.0, 3.2, -1.0), Vector3(7.0, 5.4, 10.0), Color(0.88, 0.86, 0.8), 1.0)
    mb.box(Vector3(17.0, 3.2, -1.0), Vector3(7.0, 5.4, 10.0), Color(0.88, 0.86, 0.8), 1.0)
    _flagpole_m(mb, -14.0, 10.5, 12.0, acc, Color(1, 1, 1))
    _flagpole_m(mb, 14.0, 10.5, 12.0, acc, Color(1, 1, 1))


# =====================================================================
#  MODELS - military buildings
# =====================================================================
func _truck_m(mb: MB, x: float, z: float, rot: float, col: Color, len_z: float = 7.0, wheels: int = 3) -> void:
    var r := Vector3(0, rot, 0)
    var bas := Basis.from_euler(Vector3(0, deg_to_rad(rot), 0))
    mb.box(Vector3(x, 1.2, z) + bas * Vector3(0, 0, -len_z * 0.1), Vector3(2.6, 0.8, len_z), col.darkened(0.2), 0.0, r, "metal")
    mb.box(Vector3(x, 1.9, z) + bas * Vector3(0, 0, len_z * 0.38), Vector3(2.5, 1.9, 2.2), col, 0.0, r, "metal")
    mb.box(Vector3(x, 2.2, z) + bas * Vector3(0, 0, len_z * 0.5), Vector3(2.3, 0.8, 0.12), Color(0.05, 0.08, 0.1), 0.0, r, "metal")
    for k in range(wheels):
        var zz := len_z * 0.35 - float(k) * (len_z * 0.7 / float(max(wheels - 1, 1)))
        for sx in [-1.0, 1.0]:
            var wp := bas * Vector3(sx * 1.35, 0, zz) + Vector3(x, 0.65, z)
            mb.cyl(wp, 0.65, 0.5, Color(0.05, 0.05, 0.05), 8, 0.0, Vector3(0, rot, 90))


func _missile_m(mb: MB, p: Vector3, rot: Vector3, len: float, r: float, body: Color, nose: Color) -> void:
    var bas := Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z)), EULER_ORDER_YXZ)
    var up := bas * Vector3(0, 1, 0)
    mb.cyl(p + up * (len * 0.4), r, len * 0.8, body, 8, 0.0, rot, "metal")
    mb.cyl(p + up * (len * 0.9), r, len * 0.2, nose, 8, 0.0, rot, "metal", 0.02)


func _m_armybase(mb: MB, lvl: int, v: int, acc: Color) -> void:
    mb.box(Vector3(0, 0.1, 0), Vector3(34.0, 0.2, 26.0), Color(0.36, 0.34, 0.3))
    _fence_m(mb, 33.0, 25.0, Color(0.5, 0.52, 0.5), 1.4)
    for k in range(4):
        var sx := -1.0 if k % 2 == 0 else 1.0
        var sz := -1.0 if k < 2 else 1.0
        mb.box(Vector3(sx * 16.0, 2.5, sz * 12.0), Vector3(2.0, 5.0, 2.0), Color(0.4, 0.42, 0.36))
        mb.box(Vector3(sx * 16.0, 5.4, sz * 12.0), Vector3(3.0, 1.2, 3.0), Color(0.3, 0.34, 0.26))
    for k in range(3):
        var z := -8.0 + float(k) * 5.0
        mb.box(Vector3(-8.0, 1.6, z), Vector3(14.0, 3.0, 3.6), C_OLIVE, 1.0)
        mb.gable(Vector3(-8.0, 3.1, z), Vector3(3.8, 1.0, 14.2), Color(0.25, 0.3, 0.2), Vector3(0, 90, 0), "bld", C_OLIVE)
    mb.box(Vector3(9.0, 2.2, -6.0), Vector3(8.0, 4.0, 7.0), Color(0.5, 0.5, 0.46), 1.0)
    mb.box(Vector3(9.0, 4.3, -6.0), Vector3(8.4, 0.4, 7.4), Color(0.3, 0.32, 0.3))
    mb.cyl(Vector3(11.5, 6.0, -8.5), 1.4, 0.3, Color(0.7, 0.7, 0.72), 12, 0.0, Vector3(50, 0, 0), "metal")
    for k in range(3 + lvl):
        _truck_m(mb, 4.0 + float(k) * 3.6, 7.5, 0.0, C_OLIVE, 6.0, 2)
    _flagpole_m(mb, -14.0, 9.0, 10.0, acc, acc.lightened(0.5))
    mb.box(Vector3(-8.0, 0.25, 8.5), Vector3(14.0, 0.1, 6.0), Color(0.5, 0.48, 0.44))
    mb.cyl(Vector3(-4.0, 0.4, 9.5), 0.9, 0.7, Color(0.2, 0.22, 0.15), 8)


func _m_missilebase(mb: MB, lvl: int, v: int, acc: Color) -> void:
    mb.box(Vector3(0, 0.1, 0), Vector3(28.0, 0.2, 28.0), Color(0.5, 0.5, 0.48))
    _fence_m(mb, 27.5, 27.5, Color(0.45, 0.47, 0.45), 1.5)
    for k in range(4 + lvl):
        var x := -8.0 + float(k % 3) * 8.0
        var z := -8.0 + float(k / 3) * 7.0
        mb.cyl(Vector3(x, 0.28, z), 2.8, 0.24, Color(0.2, 0.22, 0.24), 14)
        mb.cyl(Vector3(x, 0.42, z), 2.1, 0.12, Color(0.1, 0.1, 0.12), 14, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(-6.0, 1.8, 9.0), Vector3(9.0, 3.4, 6.0), Color(0.55, 0.56, 0.54), 0.35)
    mb.box(Vector3(-6.0, 3.6, 9.0), Vector3(9.4, 0.4, 6.4), Color(0.3, 0.3, 0.3))
    for k in range(2):
        var x := 5.0 + float(k) * 5.5
        _truck_m(mb, x, 8.5, 0.0, C_OLIVE, 9.0, 3)
        _missile_m(mb, Vector3(x, 2.0, 7.2), Vector3(-55, 0, 0), 8.0, 0.55, Color(0.85, 0.85, 0.82), Color(0.2, 0.2, 0.22))
    for k in range(2):
        var sx := -1.0 if k == 0 else 1.0
        mb.cyl(Vector3(sx * 12.0, 4.0, -12.0), 0.2, 8.0, Color(0.6, 0.6, 0.62), 6, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(sx * 12.0, 8.2, -12.0), Vector3(1.6, 0.4, 0.8), Color(1.0, 0.95, 0.8), 0.0, Vector3.ZERO, "glow")


func _m_aa(mb: MB, tier: int, acc: Color) -> void:
    var s: float = float(AA_SIZE[tier])
    mb.box(Vector3(0, 0.1, 0), Vector3(s, 0.2, s), Color(0.42, 0.42, 0.4))
    if tier == 0:
        mb.cyl(Vector3(0, 0.9, 0), 1.4, 1.6, Color(0.5, 0.53, 0.55), 10, 0.0, Vector3.ZERO, "metal")
        mb.sph(Vector3(0, 2.4, 0), 1.2, Color(0.92, 0.92, 0.94), 10, 6, Vector3.ONE, "metal")
        mb.cyl(Vector3(1.0, 1.7, 1.2), 0.18, 2.2, Color(0.12, 0.12, 0.13), 6, 0.0, Vector3(-80, 0, 0), "metal")
        mb.cyl(Vector3(-0.6, 1.7, 1.2), 0.18, 2.2, Color(0.12, 0.12, 0.13), 6, 0.0, Vector3(-80, 0, 0), "metal")
    elif tier == 1:
        mb.box(Vector3(-1.5, 1.0, 2.0), Vector3(3.6, 1.4, 4.8), Color(0.3, 0.38, 0.28), 0.0, Vector3.ZERO, "metal")
        for r in range(2):
            for c in range(5):
                mb.cyl(Vector3(-3.4 + float(c) * 0.8, 2.5 + float(r) * 0.8, 1.2 - float(r) * 0.4), 0.28, 3.2, Color(0.82, 0.84, 0.86), 8, 0.0, Vector3(-60, 0, 0), "metal")
        mb.box(Vector3(3.0, 1.2, -2.5), Vector3(3.0, 1.6, 3.4), Color(0.3, 0.38, 0.28), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(3.0, 2.8, -2.5), Vector3(2.4, 1.6, 0.3), Color(0.2, 0.22, 0.25), 0.0, Vector3(-15, 0, 0), "metal")
    elif tier == 2:
        mb.box(Vector3(0, 1.0, 3.0), Vector3(3.2, 1.0, 6.5), Color(0.3, 0.36, 0.28), 0.0, Vector3.ZERO, "metal")
        for c in range(4):
            mb.box(Vector3(-1.2 + float(c) * 0.8, 3.0, 2.0), Vector3(0.7, 0.7, 5.0), Color(0.72, 0.74, 0.7), 0.0, Vector3(-55, 0, 0), "metal")
        mb.box(Vector3(-4.0, 1.2, -3.5), Vector3(3.2, 1.2, 5.0), Color(0.3, 0.36, 0.28), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(-4.0, 3.6, -4.5), Vector3(3.4, 3.4, 0.35), Color(0.35, 0.4, 0.45), 0.0, Vector3(-12, 0, 0), "metal")
    elif tier == 3:
        for k in range(3):
            var x := -5.0 + float(k) * 5.0
            _truck_m(mb, x, 2.0, 0.0, Color(0.3, 0.36, 0.26), 9.0, 4)
            for c in range(2):
                mb.cyl(Vector3(x - 0.5 + float(c) * 1.0, 3.4, 1.0), 0.45, 7.0, Color(0.72, 0.74, 0.7), 8, 0.0, Vector3(-62, 0, 0), "metal")
        _truck_m(mb, 0.0, -6.5, 180.0, Color(0.32, 0.38, 0.28), 8.0, 3)
        mb.box(Vector3(0, 4.2, -9.5), Vector3(5.2, 4.2, 0.4), Color(0.34, 0.38, 0.42), 0.0, Vector3(-18, 0, 0), "metal")
    else:
        mb.box(Vector3(-5.0, 1.0, 4.0), Vector3(5.0, 1.0, 10.0), Color(0.3, 0.34, 0.28), 0.0, Vector3.ZERO, "metal")
        for c in range(4):
            for r in range(2):
                mb.box(Vector3(-6.8 + float(c) * 1.2, 3.0 + float(r) * 1.1, 3.0), Vector3(1.0, 1.0, 8.0), Color(0.78, 0.8, 0.76), 0.0, Vector3(-50, 0, 0), "metal")
        mb.box(Vector3(6.0, 1.0, -4.0), Vector3(6.0, 1.0, 11.0), Color(0.3, 0.34, 0.28), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(6.0, 5.2, -5.5), Vector3(5.6, 6.0, 0.5), Color(0.38, 0.42, 0.48), 0.0, Vector3(-22, 0, 0), "metal")
        mb.box(Vector3(6.0, 0.4, 2.0), Vector3(4.0, 0.8, 3.0), Color(0.25, 0.28, 0.22), 0.0, Vector3.ZERO, "metal")


func _m_radar(mb: MB, lvl: int, v: int, acc: Color) -> void:
    mb.box(Vector3(0, 0.1, 0), Vector3(12.0, 0.2, 12.0), Color(0.45, 0.45, 0.43))
    mb.cyl(Vector3(0, 4.5, 0), 1.3, 9.0, Color(0.85, 0.85, 0.87), 10, 0.0, Vector3.ZERO, "metal", 0.9)
    mb.box(Vector3(0, 9.4, 0), Vector3(2.6, 0.6, 2.6), Color(0.3, 0.3, 0.32))
    mb.box(Vector3(4.0, 1.4, 3.0), Vector3(3.0, 2.4, 3.4), Color(0.5, 0.52, 0.5), 0.35)
    mb.box(Vector3(0, 9.9, 0), Vector3(0.4, 0.4, 0.4), Color(1.0, 0.1, 0.1), 0.0, Vector3.ZERO, "glow")


func _m_radar_dish(mb: MB) -> void:
    mb.box(Vector3(0, 0.9, 0), Vector3(7.0, 1.8, 0.5), Color(0.82, 0.84, 0.86), 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(0, 0.3, 0.6), Vector3(0.5, 1.2, 0.8), Color(0.4, 0.4, 0.42), 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(2.8, 0.9, -0.8), Vector3(1.0, 1.4, 1.2), Color(0.5, 0.5, 0.52), 0.0, Vector3.ZERO, "metal")


func _m_airbase(mb: MB, lvl: int, v: int, acc: Color) -> void:
    # footprint 100 x 42 (x along the runway)
    mb.box(Vector3(0, 0.08, 0), Vector3(100.0, 0.16, 42.0), Color(0.3, 0.42, 0.2))
    mb.box(Vector3(0, 0.2, 14.0), Vector3(100.0, 0.12, 12.0), Color(0.1, 0.1, 0.11))
    for k in range(20):
        mb.box(Vector3(-46.0 + float(k) * 4.8, 0.28, 14.0), Vector3(2.4, 0.04, 0.4), Color(0.95, 0.95, 0.95))
    for k in range(6):
        mb.box(Vector3(-47.5, 0.28, 10.6 + float(k) * 1.3), Vector3(3.0, 0.04, 0.5), Color(0.95, 0.95, 0.95))
        mb.box(Vector3(47.5, 0.28, 10.6 + float(k) * 1.3), Vector3(3.0, 0.04, 0.5), Color(0.95, 0.95, 0.95))
    mb.box(Vector3(0, 0.2, 5.0), Vector3(94.0, 0.12, 3.0), Color(0.16, 0.16, 0.17))
    mb.box(Vector3(-10.0, 0.2, -4.0), Vector3(60.0, 0.12, 18.0), Color(0.5, 0.5, 0.48))
    for k in range(3):
        var x := -30.0 + float(k) * 14.0
        mb.arch(Vector3(x, 0.16, -14.0), 6.0, 12.0, Color(0.55, 0.58, 0.55), 10, "bld", Vector3(0, 90, 0), 0.75)
        mb.box(Vector3(x - 6.0, 2.0, -14.0), Vector3(0.3, 4.0, 11.8), Color(0.5, 0.52, 0.5))
    mb.box(Vector3(30.0, 5.0, -10.0), Vector3(3.4, 10.0, 3.4), Color(0.8, 0.8, 0.8), 0.35)
    mb.box(Vector3(30.0, 10.8, -10.0), Vector3(5.4, 2.0, 5.4), Color(0.12, 0.22, 0.28), 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(30.0, 12.1, -10.0), Vector3(6.0, 0.4, 6.0), Color(0.5, 0.5, 0.5))
    mb.box(Vector3(30.0, 13.0, -10.0), Vector3(0.3, 1.6, 0.3), Color(1.0, 0.2, 0.1), 0.0, Vector3.ZERO, "glow")
    mb.box(Vector3(40.0, 3.0, -8.0), Vector3(14.0, 5.6, 8.0), Color(0.75, 0.76, 0.78), 1.0)
    mb.box(Vector3(40.0, 5.9, -8.0), Vector3(14.6, 0.4, 8.6), Color(0.4, 0.4, 0.42))
    for k in range(3):
        mb.cyl(Vector3(-40.0 + float(k) * 4.5, 1.6, -16.0), 2.0, 3.2, Color(0.75, 0.76, 0.74), 10, 0.0, Vector3.ZERO, "metal")
    for k in range(2 + lvl):
        mb.box(Vector3(-46.0 + float(k) * 2.2, 0.6, 14.0 - 12.0), Vector3(1.0, 1.0, 1.0), Color(1.0, 0.7, 0.1), 0.0, Vector3.ZERO, "glow")
    for k in range(10):
        mb.box(Vector3(-50.0 + float(k) * 11.0, 0.5, 20.4), Vector3(0.3, 0.8, 0.3), Color(1.0, 0.95, 0.7), 0.0, Vector3.ZERO, "glow")


func _m_lab(mb: MB, lvl: int, v: int, acc: Color) -> void:
    _lot(mb, 30.0, 24.0, Color(0.55, 0.57, 0.58), 0.14)
    mb.box(Vector3(-3.0, 3.5, -3.0), Vector3(20.0, 7.0, 12.0), Color(0.9, 0.92, 0.94), 1.0)
    mb.box(Vector3(-3.0, 7.2, -3.0), Vector3(20.6, 0.5, 12.6), Color(0.45, 0.48, 0.52))
    mb.cyl(Vector3(9.0, 4.5, 3.0), 5.0, 9.0, Color(0.25, 0.4, 0.5), 20, 1.0, Vector3.ZERO, "metal", 4.6)
    mb.sph(Vector3(9.0, 9.0, 3.0), 4.8, Color(0.3, 0.5, 0.62), 16, 8, Vector3(1, 0.4, 1), "metal", 0.0, true)
    mb.cyl(Vector3(-9.0, 9.5, -4.0), 2.4, 0.4, Color(0.85, 0.86, 0.88), 14, 0.0, Vector3(55, 0, 0), "metal")
    mb.cyl(Vector3(-9.0, 8.0, -4.0), 0.3, 1.6, Color(0.5, 0.5, 0.5), 6)
    mb.cyl(Vector3(0.0, 10.5, -3.0), 0.12, 6.0, Color(0.8, 0.8, 0.8), 6, 0.0, Vector3.ZERO, "metal")
    for k in range(3):
        mb.cyl(Vector3(-3.0 + 0.0, 7.7 + 0.0, -3.0), 3.4 + float(k) * 0.0, 0.14, Color(0.3, 0.8, 1.0), 20, 0.0, Vector3(0, 0, 0) if k == 0 else Vector3(60.0 * float(k), 0, 0), "glow")
    if lvl >= 2:
        mb.box(Vector3(-11.0, 2.0, 6.0), Vector3(8.0, 4.0, 6.0), Color(0.85, 0.87, 0.9), 1.0)
    if lvl >= 3:
        mb.box(Vector3(2.0, 1.5, 8.0), Vector3(10.0, 3.0, 5.0), Color(0.8, 0.82, 0.86), 1.0)
    _car_m(mb, -12.0, -10.0, 90.0, Color(0.9, 0.9, 0.92))
    _tree_m(mb, 13.0, -9.0, 0.9, 0)


func _m_enrich(mb: MB, lvl: int, v: int, acc: Color) -> void:
    mb.box(Vector3(0, 0.1, 0), Vector3(38.0, 0.2, 32.0), Color(0.45, 0.46, 0.45))
    _fence_m(mb, 37.0, 31.0, Color(0.4, 0.4, 0.4), 1.8)
    for k in range(2):
        var x := -9.0 + float(k) * 12.0
        mb.cyl(Vector3(x, 6.5, -8.0), 6.2, 3.0, Color(0.78, 0.78, 0.76), 20, 0.0, Vector3.ZERO, "bld", 6.2)
        mb.cyl(Vector3(x, 12.5, -8.0), 6.2, 9.0, Color(0.8, 0.8, 0.78), 20, 0.0, Vector3.ZERO, "bld", 4.2)
        mb.cyl(Vector3(x, 21.0, -8.0), 4.2, 8.0, Color(0.82, 0.82, 0.8), 20, 0.0, Vector3.ZERO, "bld", 4.8)
        mb.cyl(Vector3(x, 3.0, -8.0), 6.4, 6.0, Color(0.74, 0.74, 0.72), 20, 0.0, Vector3.ZERO, "bld", 6.2)
    mb.sph(Vector3(12.0, 5.0, 6.0), 6.0, Color(0.7, 0.72, 0.74), 18, 9, Vector3(1, 0.9, 1), "metal", 0.0, true)
    mb.cyl(Vector3(12.0, 2.5, 6.0), 6.0, 5.0, Color(0.7, 0.72, 0.74), 18, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(-8.0, 3.0, 8.0), Vector3(20.0, 5.6, 8.0), Color(0.62, 0.64, 0.66), 0.35)
    mb.box(Vector3(-8.0, 5.9, 8.0), Vector3(20.6, 0.4, 8.6), Color(0.35, 0.36, 0.38))
    mb.box(Vector3(0, 0.6, 14.0), Vector3(36.0, 1.0, 0.3), Color(1.0, 0.8, 0.1), 0.0, Vector3.ZERO, "glow")
    for k in range(4):
        var sx := -1.0 if k % 2 == 0 else 1.0
        var sz := -1.0 if k < 2 else 1.0
        mb.box(Vector3(sx * 18.0, 3.0, sz * 15.0), Vector3(2.4, 6.0, 2.4), Color(0.4, 0.42, 0.38))
        mb.box(Vector3(sx * 18.0, 6.4, sz * 15.0), Vector3(3.2, 1.2, 3.2), Color(0.25, 0.3, 0.22))


func _m_port(mb: MB, lvl: int, v: int, acc: Color) -> void:
    # +z side faces the sea (placement rotates the port so that it does)
    mb.box(Vector3(0, 0.12, -2.0), Vector3(56.0, 0.24, 24.0), Color(0.5, 0.5, 0.48))
    mb.box(Vector3(0, -0.3, 12.0), Vector3(56.0, 1.4, 6.0), Color(0.55, 0.55, 0.52))
    mb.box(Vector3(0, 0.45, 14.8), Vector3(56.0, 0.4, 0.5), Color(0.9, 0.8, 0.2))
    mb.box(Vector3(-16.0, 4.0, -9.0), Vector3(20.0, 7.0, 8.0), Color(0.68, 0.7, 0.72), 0.35)
    mb.box(Vector3(-16.0, 7.6, -9.0), Vector3(20.6, 0.4, 8.6), Color(0.35, 0.36, 0.38))
    for k in range(1 + lvl):
        var x := -6.0 + float(k) * 14.0
        mb.box(Vector3(x - 4.0, 8.0, 8.0), Vector3(0.7, 16.0, 0.7), Color(0.9, 0.3, 0.1), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(x + 4.0, 8.0, 8.0), Vector3(0.7, 16.0, 0.7), Color(0.9, 0.3, 0.1), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(x, 16.2, 8.0), Vector3(9.0, 0.8, 1.2), Color(0.9, 0.3, 0.1), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(x, 16.0, 13.0), Vector3(1.0, 0.6, 9.0), Color(0.9, 0.3, 0.1), 0.0, Vector3.ZERO, "metal")
    var cc := [Color(0.75, 0.2, 0.15), Color(0.15, 0.3, 0.6), Color(0.85, 0.65, 0.1), Color(0.2, 0.5, 0.3), Color(0.7, 0.7, 0.7)]
    for k in range(10):
        mb.box(Vector3(-2.0 + float(k % 5) * 6.2, 1.3 + float(k / 5) * 2.6, -1.0), Vector3(6.0, 2.5, 2.4), cc[(k + v) % 5], 0.0, Vector3.ZERO, "metal")
    mb.cyl(Vector3(22.0, 0.5, -3.0), 0.1, 1.0, Color(1, 1, 1), 6)
    mb.cyl(Vector3(24.0, 4.0, -9.0), 0.15, 8.0, Color(0.7, 0.7, 0.72), 6, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(24.0, 8.2, -9.0), Vector3(1.8, 0.4, 0.8), Color(1.0, 0.95, 0.8), 0.0, Vector3.ZERO, "glow")
    _flagpole_m(mb, 22.0, -10.0, 9.0, acc, acc.lightened(0.5))


# =====================================================================
#  MODELS - units (facing -Z)
# =====================================================================
func _mirror_poly(pts: Array) -> PackedVector2Array:
    var out := PackedVector2Array()
    for k in range(pts.size() - 1, -1, -1):
        var p: Vector2 = pts[k]
        out.append(Vector2(-p.x, p.y))
    return out


func _m_jet(mb: MB, tier: int, body: Color, acc: Color) -> void:
    var dark := body.darkened(0.35)
    # fuselage (axis along z): rotate cylinders by 90 on x
    mb.cyl(Vector3(0, 0, 0.5), 0.75, 8.0, body, 10, 0.0, Vector3(90, 0, 0), "metal", 0.6)
    mb.cyl(Vector3(0, 0, -4.8), 0.55, 3.4, body, 10, 0.0, Vector3(90, 0, 0), "metal", 0.06)
    var wing: Array = []
    match tier:
        0:
            wing = [Vector2(0.7, -0.5), Vector2(5.2, 1.8), Vector2(5.2, 2.7), Vector2(0.7, 3.4)]
        1:
            wing = [Vector2(0.7, -1.0), Vector2(5.0, 1.6), Vector2(5.0, 2.8), Vector2(0.7, 3.6)]
        2:
            wing = [Vector2(0.7, -2.4), Vector2(5.4, 3.0), Vector2(5.4, 3.8), Vector2(0.7, 3.6)]
        _:
            wing = [Vector2(0.7, -2.6), Vector2(5.6, 2.2), Vector2(5.6, 3.6), Vector2(2.0, 4.2), Vector2(0.7, 3.8)]
    var pr := PackedVector2Array()
    for p in wing:
        pr.append(p)
    mb.poly(pr, -0.08, 0.1, body.darkened(0.12), "metal")
    mb.poly(_mirror_poly(wing), -0.08, 0.1, body.darkened(0.12), "metal")
    # tail
    var tl := Color(body.r, body.g, body.b)
    if tier == 3:
        mb.box(Vector3(-0.9, 1.1, 3.7), Vector3(0.12, 1.8, 1.8), dark, 0.0, Vector3(0, 0, 22), "metal")
        mb.box(Vector3(0.9, 1.1, 3.7), Vector3(0.12, 1.8, 1.8), dark, 0.0, Vector3(0, 0, -22), "metal")
    else:
        mb.box(Vector3(0, 1.4, 3.6), Vector3(0.14, 2.4, 2.0), tl, 0.0, Vector3.ZERO, "metal")
        if tier == 1:
            mb.box(Vector3(0.9, 1.0, 3.6), Vector3(0.12, 1.8, 1.8), tl, 0.0, Vector3(0, 0, -12), "metal")
    var hs := PackedVector2Array([Vector2(0.5, 2.8), Vector2(2.6, 4.2), Vector2(2.6, 4.8), Vector2(0.5, 4.6)])
    mb.poly(hs, 0.0, 0.1, dark, "metal")
    mb.poly(_mirror_poly([Vector2(0.5, 2.8), Vector2(2.6, 4.2), Vector2(2.6, 4.8), Vector2(0.5, 4.6)]), 0.0, 0.1, dark, "metal")
    if tier == 2:
        mb.poly(PackedVector2Array([Vector2(0.5, -2.8), Vector2(2.0, -1.4), Vector2(2.0, -0.8), Vector2(0.5, -1.0)]), 0.0, 0.1, dark, "metal")
        mb.poly(_mirror_poly([Vector2(0.5, -2.8), Vector2(2.0, -1.4), Vector2(2.0, -0.8), Vector2(0.5, -1.0)]), 0.0, 0.1, dark, "metal")
    # canopy + engine
    mb.sph(Vector3(0, 0.55, -1.7), 0.6, Color(0.15, 0.25, 0.35), 8, 5, Vector3(0.8, 0.7, 2.2), "metal")
    mb.cyl(Vector3(0, 0, 4.7), 0.5, 0.5, Color(0.2, 0.2, 0.22), 8, 0.0, Vector3(90, 0, 0), "metal")
    mb.cyl(Vector3(0, 0, 5.1), 0.4, 0.5, Color(1.0, 0.55, 0.15), 8, 0.0, Vector3(90, 0, 0), "glow", 0.05)
    # roundels
    mb.box(Vector3(2.6, 0.12, 2.2), Vector3(0.9, 0.04, 0.9), acc, 0.0, Vector3.ZERO, "metal")
    mb.box(Vector3(-2.6, 0.12, 2.2), Vector3(0.9, 0.04, 0.9), acc, 0.0, Vector3.ZERO, "metal")
    if tier <= 1:
        mb.cyl(Vector3(2.4, -0.25, 0.6), 0.18, 1.4, Color(0.4, 0.45, 0.4), 6, 0.0, Vector3(90, 0, 0), "metal")
        mb.cyl(Vector3(-2.4, -0.25, 0.6), 0.18, 1.4, Color(0.4, 0.45, 0.4), 6, 0.0, Vector3(90, 0, 0), "metal")


func _m_airliner(mb: MB, acc: Color) -> void:
    mb.cyl(Vector3(0, 0, 0), 1.3, 18.0, Color(0.96, 0.96, 0.97), 12, 0.0, Vector3(90, 0, 0), "metal")
    mb.cyl(Vector3(0, 0, -9.6), 1.3, 2.6, Color(0.96, 0.96, 0.97), 12, 0.0, Vector3(90, 0, 0), "metal", 0.3)
    mb.cyl(Vector3(0, 0, 8.6), 1.2, 3.4, Color(0.96, 0.96, 0.97), 12, 0.0, Vector3(90, 0, 0), "metal", 0.4)
    mb.box(Vector3(0, 0.2, 0), Vector3(2.62, 0.35, 16.0), acc, 0.0, Vector3.ZERO, "metal")
    var wing := [Vector2(1.0, -1.5), Vector2(11.0, 3.0), Vector2(11.0, 4.2), Vector2(1.0, 3.5)]
    var pr := PackedVector2Array()
    for p in wing:
        pr.append(p)
    mb.poly(pr, -0.2, 0.15, Color(0.88, 0.9, 0.92), "metal")
    mb.poly(_mirror_poly(wing), -0.2, 0.15, Color(0.88, 0.9, 0.92), "metal")
    mb.box(Vector3(0, 3.2, 8.2), Vector3(0.2, 4.2, 3.0), acc, 0.0, Vector3(0, 0, 0), "metal")
    var th := [Vector2(0.8, 7.0), Vector2(4.6, 9.4), Vector2(4.6, 10.4), Vector2(0.8, 9.8)]
    var tp := PackedVector2Array()
    for p in th:
        tp.append(p)
    mb.poly(tp, 0.0, 0.12, Color(0.9, 0.92, 0.94), "metal")
    mb.poly(_mirror_poly(th), 0.0, 0.12, Color(0.9, 0.92, 0.94), "metal")
    for sx in [-4.2, 4.2]:
        mb.cyl(Vector3(sx, -0.9, 1.5), 0.85, 3.0, Color(0.8, 0.82, 0.84), 10, 0.0, Vector3(90, 0, 0), "metal")


func _m_missile_unit(mb: MB, kind: int, nuke: bool) -> void:
    var body := Color(0.9, 0.9, 0.88)
    var nose := Color(0.25, 0.25, 0.28)
    var r := 0.45
    var l := 7.0
    match kind:
        0:
            r = 0.4; l = 6.0
        1:
            r = 0.3; l = 4.0; body = Color(0.3, 0.36, 0.28)
        2:
            r = 0.8; l = 9.0; body = Color(0.85, 0.85, 0.82)
        3:
            r = 0.7; l = 8.0; body = Color(0.55, 0.58, 0.62); nose = Color(0.8, 0.3, 0.1)
        4:
            r = 1.0; l = 12.0; body = Color(0.92, 0.92, 0.9)
        _:
            r = 1.0; l = 12.0; body = Color(0.92, 0.92, 0.9); nose = Color(0.9, 0.1, 0.1)
    mb.cyl(Vector3(0, 0, 0.5), r, l, body, 10, 0.0, Vector3(90, 0, 0), "metal")
    mb.cyl(Vector3(0, 0, -l * 0.5 - 0.8), r, l * 0.35, nose, 10, 0.0, Vector3(90, 0, 0), "metal", 0.04)
    for k in range(4):
        mb.box(Vector3(0, 0, l * 0.5 - 0.5), Vector3(r * 3.4, 0.08, 1.6), body.darkened(0.2), 0.0, Vector3(0, 0, 90.0 * float(k)), "metal")
    mb.cyl(Vector3(0, 0, l * 0.5 + 1.1), r * 0.8, 0.9, Color(1.0, 0.6, 0.2), 8, 0.0, Vector3(90, 0, 0), "glow", 0.1)
    if nuke:
        mb.cyl(Vector3(0, 0, -1.0), r * 1.01, 1.2, Color(1.0, 0.85, 0.1), 10, 0.0, Vector3(90, 0, 0), "metal")


func _m_interceptor(mb: MB) -> void:
    mb.cyl(Vector3(0, 0, 0), 0.22, 3.2, Color(0.9, 0.9, 0.92), 8, 0.0, Vector3(90, 0, 0), "metal")
    mb.cyl(Vector3(0, 0, -1.9), 0.22, 0.8, Color(0.3, 0.3, 0.32), 8, 0.0, Vector3(90, 0, 0), "metal", 0.02)
    mb.cyl(Vector3(0, 0, 1.8), 0.17, 0.7, Color(1.0, 0.7, 0.3), 8, 0.0, Vector3(90, 0, 0), "glow", 0.05)


func _hull_pts(len: float, beam: float, bow: float = 0.28) -> PackedVector2Array:
    var hl := len * 0.5
    var hb := beam * 0.5
    var a := PackedVector2Array()
    a.append(Vector2(0, -hl))
    a.append(Vector2(hb * 0.55, -hl + len * bow * 0.6))
    a.append(Vector2(hb, -hl + len * bow * 1.4))
    a.append(Vector2(hb, hl - len * 0.12))
    a.append(Vector2(hb * 0.8, hl))
    a.append(Vector2(-hb * 0.8, hl))
    a.append(Vector2(-hb, hl - len * 0.12))
    a.append(Vector2(-hb, -hl + len * bow * 1.4))
    a.append(Vector2(-hb * 0.55, -hl + len * bow * 0.6))
    return a


func _gun_m(mb: MB, x: float, y: float, z: float, s: float = 1.0) -> void:
    mb.cyl(Vector3(x, y, z), 0.9 * s, 0.9 * s, Color(0.4, 0.43, 0.46), 8, 0.0, Vector3.ZERO, "metal")
    mb.cyl(Vector3(x, y + 0.5 * s, z - 1.3 * s), 0.15 * s, 2.4 * s, Color(0.2, 0.22, 0.24), 6, 0.0, Vector3(90, 0, 0), "metal")


func _m_ship(mb: MB, id: String, hullc: Color, acc: Color) -> void:
    var grey := Color(0.5, 0.54, 0.58)
    var lightg := Color(0.64, 0.67, 0.7)
    if id == "patrol":
        mb.poly(_hull_pts(14.0, 3.6, 0.34), -0.8, 1.0, hullc, "metal")
        mb.poly(_hull_pts(14.0, 3.7, 0.34), -0.9, -0.3, Color(0.4, 0.1, 0.08), "metal")
        mb.box(Vector3(0, 1.9, 1.5), Vector3(2.4, 1.8, 4.0), lightg, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 2.2, 0.3), Vector3(2.2, 0.8, 0.12), Color(0.1, 0.16, 0.2), 0.0, Vector3.ZERO, "metal")
        _gun_m(mb, 0, 1.4, -3.2, 0.9)
        mb.cyl(Vector3(0, 4.0, 2.0), 0.1, 3.0, Color(0.8, 0.8, 0.8), 6, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 2.2, 4.2), Vector3(1.6, 0.4, 1.2), Color(0.3, 0.3, 0.3), 0.0, Vector3.ZERO, "metal")
    elif id == "frigate":
        mb.poly(_hull_pts(26.0, 5.0), -1.1, 1.3, hullc, "metal")
        mb.poly(_hull_pts(26.0, 5.1), -1.2, -0.4, Color(0.4, 0.1, 0.08), "metal")
        mb.box(Vector3(0, 3.4, 1.0), Vector3(3.6, 3.4, 9.0), lightg, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 4.2, -3.4), Vector3(3.0, 1.6, 2.4), lightg, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 4.4, -4.65), Vector3(2.8, 0.7, 0.1), Color(0.1, 0.16, 0.2), 0.0, Vector3.ZERO, "metal")
        mb.cyl(Vector3(0, 6.5, 1.5), 0.16, 5.0, Color(0.8, 0.8, 0.8), 6, 0.0, Vector3.ZERO, "metal")
        mb.cyl(Vector3(0, 6.0, 3.5), 0.9, 1.8, Color(0.25, 0.25, 0.28), 8, 0.0, Vector3.ZERO, "metal")
        _gun_m(mb, 0, 1.8, -7.6, 1.2)
        mb.box(Vector3(0, 1.7, 8.0), Vector3(3.0, 0.5, 3.4), Color(0.3, 0.32, 0.34), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 2.1, 9.6), Vector3(2.6, 0.3, 2.4), Color(0.2, 0.2, 0.2), 0.0, Vector3.ZERO, "metal")
    elif id == "destroyer":
        mb.poly(_hull_pts(34.0, 6.0), -1.3, 1.6, hullc, "metal")
        mb.poly(_hull_pts(34.0, 6.1), -1.4, -0.5, Color(0.4, 0.1, 0.08), "metal")
        mb.box(Vector3(0, 4.2, 1.0), Vector3(4.4, 4.2, 12.0), lightg, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 7.0, 0.0), Vector3(3.4, 2.0, 5.0), lightg, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 7.2, -2.55), Vector3(3.2, 0.8, 0.1), Color(0.1, 0.16, 0.2), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 8.4, 0.0), Vector3(2.4, 1.8, 0.2), Color(0.3, 0.34, 0.4), 0.0, Vector3(-10, 0, 0), "metal")
        mb.cyl(Vector3(0, 10.5, 2.0), 0.18, 6.0, Color(0.8, 0.8, 0.8), 6, 0.0, Vector3.ZERO, "metal")
        _gun_m(mb, 0, 2.2, -10.0, 1.4)
        for k in range(8):
            mb.box(Vector3(-1.0 + float(k % 2) * 2.0, 1.9, 8.0 + float(k / 2) * 1.6), Vector3(0.9, 0.2, 0.9), Color(0.15, 0.16, 0.18), 0.0, Vector3.ZERO, "metal")
        mb.cyl(Vector3(0, 6.5, 6.0), 1.3, 2.4, Color(0.25, 0.25, 0.28), 8, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 1.9, 14.2), Vector3(3.6, 0.4, 3.0), Color(0.2, 0.2, 0.2), 0.0, Vector3.ZERO, "metal")
    elif id == "sub":
        mb.sph(Vector3(0, 0.0, 0), 1.0, Color(0.12, 0.13, 0.15), 12, 8, Vector3(2.6, 2.4, 15.0), "metal")
        mb.box(Vector3(0, 2.8, -1.0), Vector3(1.6, 3.0, 5.0), Color(0.1, 0.11, 0.13), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 1.8, 11.5), Vector3(0.3, 4.0, 2.4), Color(0.1, 0.11, 0.13), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(0, 0.0, 12.0), Vector3(6.0, 0.25, 2.2), Color(0.1, 0.11, 0.13), 0.0, Vector3.ZERO, "metal")
    else:  # carrier
        mb.poly(_hull_pts(70.0, 11.0, 0.2), -2.0, 3.0, hullc, "metal")
        mb.poly(_hull_pts(70.0, 11.1, 0.2), -2.2, -1.0, Color(0.4, 0.1, 0.08), "metal")
        var deck := PackedVector2Array([Vector2(0, -35.0), Vector2(9.5, -26.0), Vector2(11.0, -4.0), Vector2(11.0, 28.0), Vector2(8.0, 35.0),
            Vector2(-8.0, 35.0), Vector2(-11.0, 28.0), Vector2(-11.0, -4.0), Vector2(-9.5, -26.0)])
        mb.poly(deck, 2.9, 3.6, Color(0.24, 0.26, 0.28), "metal")
        mb.box(Vector3(-2.5, 3.65, 0), Vector3(0.4, 0.05, 56.0), Color(0.95, 0.95, 0.95), 0.0, Vector3(0, 7, 0), "metal")
        mb.box(Vector3(4.0, 3.65, 5.0), Vector3(0.3, 0.05, 40.0), Color(1.0, 0.9, 0.2), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(8.8, 6.5, 6.0), Vector3(3.6, 6.0, 12.0), lightg, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(8.8, 10.0, 6.0), Vector3(3.0, 1.5, 6.0), grey, 0.0, Vector3.ZERO, "metal")
        mb.cyl(Vector3(8.8, 13.5, 6.0), 0.2, 6.0, Color(0.8, 0.8, 0.8), 6, 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(8.8, 11.5, 6.0), Vector3(2.6, 1.4, 0.2), Color(0.3, 0.34, 0.4), 0.0, Vector3(-8, 0, 0), "metal")
        mb.box(Vector3(-8.5, 3.0, 8.0), Vector3(3.0, 0.5, 6.0), Color(0.34, 0.36, 0.38), 0.0, Vector3.ZERO, "metal")
        mb.box(Vector3(-8.5, 3.0, -8.0), Vector3(3.0, 0.5, 6.0), Color(0.34, 0.36, 0.38), 0.0, Vector3.ZERO, "metal")
        for k in range(4):
            mb.box(Vector3(-4.0 + float(k) * 2.4, 3.9, 20.0 + float(k % 2) * 3.0), Vector3(1.4, 0.4, 2.4), Color(0.45, 0.48, 0.5), 0.0, Vector3.ZERO, "metal")


func _m_crowd_person(mb: MB, col: Color) -> void:
    mb.cyl(Vector3(0, 0.9, 0), 0.34, 1.5, col, 6, 0.0, Vector3.ZERO, "bld", 0.28)
    mb.sph(Vector3(0, 1.85, 0), 0.28, Color(0.8, 0.62, 0.48), 6, 4)
    mb.cyl(Vector3(0.45, 2.0, 0), 0.04, 2.4, Color(0.4, 0.3, 0.2), 4)
    mb.box(Vector3(0.45, 3.1, 0), Vector3(1.3, 0.9, 0.06), Color(0.95, 0.95, 0.9))


func _m_tree_mesh(kind: int) -> ArrayMesh:
    var mb := MB.new()
    _tree_m(mb, 0.0, 0.0, 1.0, kind)
    return mb.bake(mats)


# =====================================================================
#  STATE
# =====================================================================
var mats := {}
var cs: Array = []              # per-country state dictionaries
var me := 5                     # player's country index
var game_state := "menu"        # menu / playing
var gtime := 0.0
var tick_t := 0.0
var month := 0
var speed := 1
var day_t := 0.32
var uid_counter := 1
var bmap := {}                  # building id -> building dict
var flights: Array = []         # jets and other aircraft
var projs: Array = []           # missiles, shells, interceptors
var ships: Array = []
var fxs: Array = []             # timed effects
var news_log: Array = []
var rng := RandomNumberGenerator.new()
var mesh_cache := {}
var args_shot := ""
var args_selftest := false
var args_cam := ""
var args_gui := ""
var peace_left := PEACE_TIME

var camera: Camera3D
var sun: DirectionalLight3D
var env: Environment
var sky_mat: ProceduralSkyMaterial
var water_mat: ShaderMaterial
var cam_target := Vector3.ZERO
var cam_goal := Vector3.ZERO
var cam_dist := 420.0
var cam_goal_dist := 420.0
var cam_yaw := 0.0
var land_nodes: Array = []
var ground_mats: Array = []
var tree_mm: Array = []
var lod_mm: Array = []
var lod_dirty: Array = []
var labels3d: Array = []

# input
var touches := {}
var press_pos := Vector2.ZERO
var press_t := 0.0
var press_moved := 0.0
var pressing := false
var pinch_d := 0.0
var pinch_a := 0.0
var ui_block := false

# interaction mode
var mode := "none"              # none / place / shipdest / strike / airtarget
var place_type := ""
var place_x := 0.0
var place_z := 0.0
var place_r := 0
var place_move_id := -1
var ghost_node: Node3D
var sel_b := -1                 # selected building id
var sel_ship := -1
var sel_country := -1           # country being inspected on the map
var strike_target_c := -1
var air_pick_group := {}


func _ready() -> void:
    rng.randomize()
    for a in OS.get_cmdline_user_args():
        if a == "--selftest":
            args_selftest = true
        elif a.begins_with("--shot="):
            args_shot = a.substr(7)
        elif a.begins_with("--cam="):
            args_cam = a.substr(6)
        elif a.begins_with("--gui="):
            args_gui = a.substr(6)
    RenderingServer.global_shader_parameter_add("night", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.0)
    _make_mats()
    _build_environment()
    _make_sounds()
    _make_world()
    _build_ui()
    if args_selftest:
        call_deferred("_selftest")
        return
    if args_shot != "" or args_gui != "":
        call_deferred("_shot_setup")
        return
    if _has_save():
        _show_menu(true)
    else:
        _show_menu(false)


func _make_mats() -> void:
    var sh := Shader.new()
    sh.code = BLD_SHADER
    var m := ShaderMaterial.new()
    m.shader = sh
    mats["bld"] = m
    var mm := StandardMaterial3D.new()
    mm.vertex_color_use_as_albedo = true
    mm.metallic = 0.55
    mm.roughness = 0.38
    mats["metal"] = mm
    var gm := StandardMaterial3D.new()
    gm.vertex_color_use_as_albedo = true
    gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mats["glow"] = gm
    var lm := StandardMaterial3D.new()
    lm.vertex_color_use_as_albedo = true
    lm.roughness = 0.9
    mats["lod"] = lm


func _build_environment() -> void:
    env = Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    sky_mat = ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.1, 0.34, 0.8)
    sky_mat.sky_horizon_color = Color(0.7, 0.82, 0.95)
    sky_mat.ground_horizon_color = Color(0.7, 0.82, 0.95)
    sky_mat.ground_bottom_color = Color(0.25, 0.4, 0.55)
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_energy = 1.05
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.tonemap_white = 6.0
    env.adjustment_enabled = true
    env.adjustment_saturation = 1.05
    env.adjustment_contrast = 1.05
    env.glow_enabled = true
    env.glow_intensity = 0.6
    env.glow_bloom = 0.08
    env.glow_hdr_threshold = 1.1
    env.fog_enabled = true
    env.fog_light_color = Color(0.7, 0.82, 0.95)
    env.fog_density = 0.00005
    var we := WorldEnvironment.new()
    we.environment = env
    add_child(we)

    sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-52.0, -35.0, 0.0)
    sun.light_energy = 1.45
    sun.light_color = Color(1.0, 0.96, 0.88)
    sun.shadow_enabled = true
    sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
    sun.light_angular_distance = 1.2
    sun.shadow_blur = 1.6
    sun.directional_shadow_max_distance = 500.0
    sun.shadow_bias = 0.08
    add_child(sun)

    var water := MeshInstance3D.new()
    var pm := PlaneMesh.new()
    pm.size = Vector2(12000.0, 8000.0)
    water.mesh = pm
    water.position = Vector3(-300.0, SEA_Y, 150.0)
    var shader := Shader.new()
    shader.code = WATER_SHADER
    water_mat = ShaderMaterial.new()
    water_mat.shader = shader
    var lands := []
    for i in range(9):
        var p: Vector2 = COUNTRIES[i]["pos"]
        lands.append(Vector4(p.x, p.y, LAND + 18.0, 0.0))
    water_mat.set_shader_parameter("lands", lands)
    water.material_override = water_mat
    water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(water)

    var cl := MeshInstance3D.new()
    var cpm := PlaneMesh.new()
    cpm.size = Vector2(12000.0, 8000.0)
    cl.mesh = cpm
    cl.position = Vector3(-300.0, 380.0, 150.0)
    var csh := Shader.new()
    csh.code = CLOUD_SHADER
    var cmat := ShaderMaterial.new()
    cmat.shader = csh
    cl.material_override = cmat
    cl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(cl)

    get_viewport().msaa_3d = Viewport.MSAA_4X
    RenderingServer.directional_shadow_atlas_set_size(4096, true)
    camera = Camera3D.new()
    camera.fov = 48.0
    camera.near = 2.0
    camera.far = 9000.0
    camera.current = true
    add_child(camera)


# =====================================================================
#  WORLD (islands, trees, far-LOD blobs)
# =====================================================================
func _make_world() -> void:
    for i in range(9):
        var p: Vector2 = COUNTRIES[i]["pos"]
        var node := Node3D.new()
        node.position = Vector3(p.x, 0.0, p.y)
        add_child(node)
        land_nodes.append(node)
        var slab := MeshInstance3D.new()
        var bm := BoxMesh.new()
        bm.size = Vector3(LAND * 2.0 + 44.0, 12.0, LAND * 2.0 + 44.0)
        slab.mesh = bm
        slab.position = Vector3(0, -6.0, 0)
        var gsh := Shader.new()
        gsh.code = GROUND_SHADER
        var gm := ShaderMaterial.new()
        gm.shader = gsh
        gm.set_shader_parameter("center", p)
        gm.set_shader_parameter("half_size", LAND)
        var sc := []
        for k in range(6):
            sc.append(Vector4(0, 0, 0, 0))
        gm.set_shader_parameter("scorch", sc)
        slab.material_override = gm
        node.add_child(slab)
        ground_mats.append(gm)
        _make_traffic(node)
        # trees
        var trs := []
        for kind in range(2):
            var mm := MultiMesh.new()
            mm.transform_format = MultiMesh.TRANSFORM_3D
            mm.mesh = _m_tree_mesh(kind)
            mm.instance_count = 90
            var inst := MultiMeshInstance3D.new()
            inst.multimesh = mm
            inst.visibility_range_end = 900.0
            node.add_child(inst)
            trs.append(mm)
        tree_mm.append(trs)
        var tr := RandomNumberGenerator.new()
        tr.seed = 1000 + i
        for kind in range(2):
            var mm: MultiMesh = tree_mm[i][kind]
            for k in range(90):
                var lx := 0.0
                var lz := 0.0
                for tries in range(20):
                    lx = tr.randf_range(-LAND + 6.0, LAND - 6.0)
                    lz = tr.randf_range(-LAND + 6.0, LAND - 6.0)
                    if abs(fposmod(lx + 32.0, 64.0) - 32.0) > 9.0 and abs(fposmod(lz + 32.0, 64.0) - 32.0) > 9.0 and (abs(lx) > 24.0 or abs(lz) > 18.0):
                        break
                var s := tr.randf_range(0.8, 1.5)
                var t := Transform3D(Basis(Vector3.UP, tr.randf() * TAU).scaled(Vector3(s, s * tr.randf_range(0.9, 1.3), s)), Vector3(lx, 0, lz))
                mm.set_instance_transform(k, t)
        # far LOD blob multimesh
        var lm := MultiMesh.new()
        lm.transform_format = MultiMesh.TRANSFORM_3D
        lm.use_colors = true
        var lbm := BoxMesh.new()
        lbm.size = Vector3(1, 1, 1)
        lm.mesh = lbm
        lm.instance_count = 0
        var li := MultiMeshInstance3D.new()
        li.multimesh = lm
        li.material_override = mats["lod"]
        li.visibility_range_begin = 880.0
        li.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        add_child(li)
        lod_mm.append(lm)
        lod_dirty.append(true)
        # country label (visible from far)
        var lab := Label3D.new()
        lab.text = String(COUNTRIES[i]["short"])
        lab.font_size = 64
        lab.outline_size = 14
        lab.modulate = Color(1, 1, 1)
        lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        lab.no_depth_test = true
        lab.fixed_size = true
        lab.pixel_size = 0.0007
        lab.position = Vector3(p.x, 60.0, p.y - LAND - 30.0)
        lab.visibility_range_begin = 700.0
        add_child(lab)
        labels3d.append(lab)


func _land_center(i: int) -> Vector3:
    var p: Vector2 = COUNTRIES[i]["pos"]
    return Vector3(p.x, 0.0, p.y)


func _country_at(x: float, z: float, margin: float = 30.0) -> int:
    for i in range(9):
        var p: Vector2 = COUNTRIES[i]["pos"]
        if abs(x - p.x) <= LAND + margin and abs(z - p.y) <= LAND + margin:
            return i
    return -1


# =====================================================================
#  COUNTRY STATE
# =====================================================================
func _new_country(i: int) -> Dictionary:
    var cd: Dictionary = COUNTRIES[i]
    var rel := []
    var st := []
    for j in range(9):
        rel.append(float(REL0[i][j]))
        st.append("peace")
    return {
        "i": i, "money": 40000.0, "peak": 40000.0, "pop": float(cd["pop"]), "happy": 62.0, "tax": 0.20,
        "bl": [], "rel": rel, "st": st, "cease_t": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        "trade": [false, false, false, false, false, false, false, false, false],
        "sanc": [false, false, false, false, false, false, false, false, false],
        "pol": {}, "rp": 0.0, "tech": {}, "cur": "", "unl": {}, "ammo": [0, 0, 0, 0, 0, 0],
        "war_w": 0.0, "rep": 0.0, "ai": true, "nuke": false, "income": 0.0, "upkeep": 0.0,
        "next_elec": 40, "think": rng.randf_range(2.0, 6.0), "ops": rng.randf_range(10.0, 25.0),
        "prot": 0.0, "stab": 0.0, "casual": 0.0, "dead_pop": 0.0, "aggr": float(cd["aggr"]),
        "pm_away": false, "pm_t": 0.0, "alert": 0.0, "last_inc": 0.0, "cap_b": -1,
        "hist": [], "diaspora": 0.0, "nuke_prog": 0.0, "wars_won": 0,
        "dmg_taken": 0.0, "dmg_dealt": 0.0, "ships_lost": 0, "jets_lost": 0, "planes_down": 0,
    }


func _start_game(player: int) -> void:
    me = player
    for c in cs:
        _clear_country_nodes(c)
    cs = []
    flights.clear()
    for p in projs:
        if is_instance_valid(p["node"]):
            p["node"].queue_free()
    projs.clear()
    for s in ships:
        if is_instance_valid(s["node"]):
            s["node"].queue_free()
    ships.clear()
    bmap.clear()
    news_log.clear()
    uid_counter = 1
    gtime = 0.0
    tick_t = 0.0
    month = 0
    peace_left = PEACE_TIME
    for i in range(9):
        var c := _new_country(i)
        c["ai"] = (i != player)
        cs.append(c)
        _reset_trees(i)
        var cd: Dictionary = COUNTRIES[i]
        var pc := _land_center(i)
        var cap := _add_building(i, "parliament", pc.x, pc.z, 0, true)
        c["cap_b"] = cap["id"]
        # a few starting homes make the capital feel alive
        _add_building(i, "house", pc.x - 52.0, pc.z + 46.0, 0, true)
        _add_building(i, "house", pc.x - 40.0, pc.z + 46.0, 0, true)
        _add_building(i, "park", pc.x + 48.0, pc.z + 20.0, 0, true)
    cs[player]["money"] = 45000.0
    cs[player]["peak"] = 45000.0
    for i in range(9):
        if i != player:
            cs[i]["money"] = 38000.0 * float(COUNTRIES[i]["econ"])
            cs[i]["peak"] = cs[i]["money"]
    game_state = "playing"
    speed = 1
    cam_target = _land_center(player) + Vector3(0, 0, 40)
    cam_goal = cam_target
    cam_dist = 300.0
    cam_goal_dist = 300.0
    cam_yaw = 0.0
    _news("You lead " + String(COUNTRIES[player]["name"]) + ". Build your nation, protect your people, and rule the world.", "good")
    _refresh_hud()
    if menu_root:
        menu_root.visible = false
    _hide_all_windows()


func _clear_country_nodes(c: Dictionary) -> void:
    for b in c["bl"]:
        if is_instance_valid(b["node"]):
            b["node"].queue_free()


func _reset_trees(i: int) -> void:
    var tr := RandomNumberGenerator.new()
    tr.seed = 1000 + i
    for kind in range(2):
        var mm: MultiMesh = tree_mm[i][kind]
        for k in range(90):
            var lx := 0.0
            var lz := 0.0
            for tries in range(20):
                lx = tr.randf_range(-LAND + 6.0, LAND - 6.0)
                lz = tr.randf_range(-LAND + 6.0, LAND - 6.0)
                if abs(fposmod(lx + 32.0, 64.0) - 32.0) > 9.0 and abs(fposmod(lz + 32.0, 64.0) - 32.0) > 9.0 and (abs(lx) > 24.0 or abs(lz) > 18.0):
                    break
            var s := tr.randf_range(0.8, 1.5)
            var t := Transform3D(Basis(Vector3.UP, tr.randf() * TAU).scaled(Vector3(s, s * tr.randf_range(0.9, 1.3), s)), Vector3(lx, 0, lz))
            mm.set_instance_transform(k, t)
    lod_dirty[i] = true


func _clear_trees_rect(i: int, x: float, z: float, hw: float, hd: float) -> void:
    var p: Vector2 = COUNTRIES[i]["pos"]
    for kind in range(2):
        var mm: MultiMesh = tree_mm[i][kind]
        for k in range(mm.instance_count):
            var t: Transform3D = mm.get_instance_transform(k)
            var gx: float = t.origin.x + p.x
            var gz: float = t.origin.z + p.y
            if abs(gx - x) < hw + 2.5 and abs(gz - z) < hd + 2.5:
                mm.set_instance_transform(k, Transform3D(Basis().scaled(Vector3(0.001, 0.001, 0.001)), Vector3(0, -50, 0)))


# =====================================================================
#  BUILDINGS
# =====================================================================
func _bdef(t: String, c: int = -1) -> Dictionary:
    if BDEFS.has(t):
        return BDEFS[t]
    if t.begins_with("aa"):
        var k := int(t.substr(2))
        var nm := "Air Defence"
        if c >= 0:
            nm = String(COUNTRIES[c]["def"][k])
        return {"name": nm, "cat": "mil", "w": AA_SIZE[k], "d": AA_SIZE[k], "cost": AA_COST[k], "inc": 0, "hp": AA_HP[k], "up": AA_UP[k],
            "time": 8 + k * 6, "unlock": AA_UNLOCK[k], "tech": AA_TECH[k], "desc": "Shoots down missiles and aircraft. Range " + str(int(AA_RANGE[k])), "aa": k}
    return {"name": t, "cat": "city", "w": 10, "d": 10, "cost": 1000, "inc": 0, "hp": 100, "up": 0, "time": 5, "unlock": 0, "desc": ""}


func _all_types() -> Array:
    var out := []
    for k in BDEFS.keys():
        if not BDEFS[k].get("hidden", false):
            out.append(k)
    for k in range(5):
        out.append("aa" + str(k))
    return out


func _is_aa(b: Dictionary) -> bool:
    return String(b["t"]).begins_with("aa")


func _aa_tier(b: Dictionary) -> int:
    return int(String(b["t"]).substr(2))


func _fp_half(t: String, r: int, c: int = -1) -> Vector2:
    var d := _bdef(t, c)
    var w := float(d["w"])
    var dd := float(d["d"])
    if r % 2 == 1:
        return Vector2(dd * 0.5, w * 0.5)
    return Vector2(w * 0.5, dd * 0.5)


func _road_overlap(c: int, x: float, z: float, hw: float, hd: float) -> bool:
    var p: Vector2 = COUNTRIES[c]["pos"]
    var lx := x - p.x
    var lz := z - p.y
    # nearest road centre lines at 32 + 64k
    var kx := floorf((lx - 32.0) / 64.0 + 0.5)
    var rx := 32.0 + 64.0 * kx
    if abs(lx - rx) < hw + 6.2:
        return true
    var kz := floorf((lz - 32.0) / 64.0 + 0.5)
    var rz := 32.0 + 64.0 * kz
    if abs(lz - rz) < hd + 6.2:
        return true
    # also the neighbouring line (big footprints)
    if abs(lx - (rx + 64.0)) < hw + 6.2 or abs(lx - (rx - 64.0)) < hw + 6.2:
        return true
    if abs(lz - (rz + 64.0)) < hd + 6.2 or abs(lz - (rz - 64.0)) < hd + 6.2:
        return true
    return false


func _can_place(c: int, t: String, x: float, z: float, r: int, ignore_id: int = -1) -> String:
    var d := _bdef(t, c)
    var h := _fp_half(t, r, c)
    var p: Vector2 = COUNTRIES[c]["pos"]
    var lx := x - p.x
    var lz := z - p.y
    var lim := LAND - 4.0
    if t == "port":
        r = _port_rot(c, x, z)
        h = _fp_half(t, r, c)
        var axial: float = max(abs(lx), abs(lz))
        var lat: float = min(abs(lx), abs(lz)) if false else (abs(lz) if abs(lx) > abs(lz) else abs(lx))
        if axial < LAND - 12.0:
            return "Port must be on the coast"
        if axial > LAND + 6.0:
            return "Too far into the sea"
        if lat + (h.y if abs(lx) > abs(lz) else h.x) > LAND - 4.0:
            return "Too close to the corner"
    else:
        if abs(lx) + h.x > lim or abs(lz) + h.y > lim:
            return "Outside your land"
    var big := float(d["w"]) > 40.0 or float(d["d"]) > 40.0 or String(d["cat"]) in ["mil", "air", "navy"]
    if not big:
        var rr := _road_overlap(c, x, z, h.x, h.y)
        if rr:
            return "Blocked by road"
    for b in cs[c]["bl"]:
        if b["id"] == ignore_id or b["st"] == "ruin":
            continue
        var bh := _fp_half(b["t"], b["r"], c)
        if abs(x - b["x"]) < h.x + bh.x + 0.6 and abs(z - b["z"]) < h.y + bh.y + 0.6:
            return "Overlaps another building"
    return ""


func _port_rot(c: int, x: float, z: float) -> int:
    var p: Vector2 = COUNTRIES[c]["pos"]
    var lx := x - p.x
    var lz := z - p.y
    if abs(lx) > abs(lz):
        return 1 if lx > 0.0 else 3
    return 0 if lz > 0.0 else 2


func _snap(v: float) -> float:
    return roundf(v / GRID) * GRID


var kn_cache := {}
# type -> [model, width factor, height multiplier on width, depth factor]
const KN_MAP := {
    "house": ["building-small-a", 0.86, 0.86, 0.86],
    "apartment": ["building-small-b", 0.86, 0.86, 0.86],
    "office": ["building-small-c", 0.86, 1.1, 0.86],
    "commerce": ["building-small-d", 0.86, 0.5, 0.86],
    "factory": ["building-garage", 0.86, 0.7, 0.86],
}


func _kn_mesh(nm: String) -> Mesh:
    if kn_cache.has(nm):
        return kn_cache[nm]
    var m: Mesh = null
    var path := "res://assets/" + nm + ".glb"
    if ResourceLoader.exists(path):
        var ps = load(path)
        if ps is PackedScene:
            var inst: Node = ps.instantiate()
            var stack := [inst]
            while stack.size() > 0 and m == null:
                var cur: Node = stack.pop_back()
                if cur is MeshInstance3D and cur.mesh != null:
                    m = cur.mesh
                for ch in cur.get_children():
                    stack.append(ch)
            inst.free()
    kn_cache[nm] = m
    return m


func _apply_kenney(mi: MeshInstance3D, b: Dictionary, d: Dictionary) -> void:
    if not KN_MAP.has(b["t"]):
        return
    var info: Array = KN_MAP[b["t"]]
    var km := _kn_mesh(String(info[0]))
    if km == null:
        return
    var w := float(d["w"])
    var dd := float(d["d"])
    var sx := w * float(info[1])
    var sz := dd * float(info[3])
    var sy := w * float(info[2]) * (1.0 + 0.08 * float(int(b["lvl"]) - 1))
    mi.mesh = km
    mi.scale = Vector3(sx, sy, sz)



func _building_mesh(t: String, lvl: int, v: int, c: int) -> ArrayMesh:
    var key := t + "_" + str(lvl) + "_" + str(v) + "_" + str(c)
    if mesh_cache.has(key):
        return mesh_cache[key]
    var mb := MB.new()
    var acc: Color = COUNTRIES[c]["col"]
    match t:
        "house": _m_house(mb, lvl, v, acc)
        "apartment": _m_apartment(mb, lvl, v, acc)
        "commerce": _m_commerce(mb, lvl, v, acc)
        "office": _m_office(mb, lvl, v, acc)
        "factory": _m_factory(mb, lvl, v, acc)
        "park": _m_park(mb, lvl, v, acc)
        "stadium": _m_stadium(mb, lvl, v, acc)
        "hospital": _m_hospital(mb, lvl, v, acc)
        "university": _m_university(mb, lvl, v, acc)
        "police": _m_police(mb, lvl, v, acc)
        "embassy": _m_embassy(mb, lvl, v, acc)
        "parliament": _m_parliament(mb, lvl, v, acc)
        "armybase": _m_armybase(mb, lvl, v, acc)
        "missilebase": _m_missilebase(mb, lvl, v, acc)
        "radar": _m_radar(mb, lvl, v, acc)
        "airbase": _m_airbase(mb, lvl, v, acc)
        "lab": _m_lab(mb, lvl, v, acc)
        "enrich": _m_enrich(mb, lvl, v, acc)
        "port": _m_port(mb, lvl, v, acc)
        _:
            if t.begins_with("aa"):
                _m_aa(mb, int(t.substr(2)), acc)
    var m := mb.bake(mats)
    mesh_cache[key] = m
    return m


func _ruin_mesh(w: float, d: float) -> ArrayMesh:
    var key := "ruin_" + str(int(w)) + "_" + str(int(d))
    if mesh_cache.has(key):
        return mesh_cache[key]
    var mb := MB.new()
    var r := _rng_for(int(w * 7.0 + d))
    mb.box(Vector3(0, 0.15, 0), Vector3(w, 0.3, d), Color(0.12, 0.11, 0.1))
    for k in range(int(w * d / 14.0) + 4):
        var s := r.randf_range(0.8, 2.6)
        mb.box(Vector3(r.randf_range(-w * 0.45, w * 0.45), s * 0.4, r.randf_range(-d * 0.45, d * 0.45)), Vector3(s, s * r.randf_range(0.4, 1.4), s * r.randf_range(0.6, 1.6)),
            Color(0.22, 0.2, 0.18).lerp(Color(0.35, 0.3, 0.26), r.randf()), 0.0, Vector3(r.randf_range(-20, 20), r.randf() * 180.0, r.randf_range(-20, 20)))
    var m := mb.bake(mats)
    mesh_cache[key] = m
    return m


func _add_building(c: int, t: String, x: float, z: float, r: int, instant: bool = false) -> Dictionary:
    var d := _bdef(t, c)
    if t == "port":
        r = _port_rot(c, x, z)
    var b := {"id": uid_counter, "t": t, "c": c, "x": x, "z": z, "r": r, "lvl": 1, "hp": float(d["hp"]), "mhp": float(d["hp"]),
        "st": "ok" if instant else "build", "prog": 1.0 if instant else 0.0, "v": rng.randi() % 4, "node": null,
        "jets": [], "cap": 0, "cool": 0.0, "ammo_c": 0.0, "queue": [], "face": 0.0, "shots": 0, "spin": null, "parked": []}
    uid_counter += 1
    bmap[b["id"]] = b
    cs[c]["bl"].append(b)
    _make_node(b)
    var h := _fp_half(t, r, c)
    _clear_trees_rect(c, x, z, h.x, h.y)
    lod_dirty[c] = true
    if t == "airbase":
        b["jets"] = []
    return b


func _make_node(b: Dictionary) -> void:
    if is_instance_valid(b["node"]):
        b["node"].queue_free()
    var n := Node3D.new()
    n.position = Vector3(b["x"], 0.0, b["z"])
    n.rotation.y = deg_to_rad(90.0 * float(b["r"]))
    add_child(n)
    b["node"] = n
    var d := _bdef(b["t"], b["c"])
    var mi := MeshInstance3D.new()
    if b["st"] == "ruin":
        mi.mesh = _ruin_mesh(float(d["w"]), float(d["d"]))
    else:
        mi.mesh = _building_mesh(b["t"], b["lvl"], b["v"], b["c"])
    mi.visibility_range_end = 1000.0
    mi.name = "mesh"
    if b["st"] != "ruin":
        _apply_kenney(mi, b, d)
    n.add_child(mi)
    b["spin"] = null
    b["parked"] = []
    if b["st"] == "ok":
        if b["t"] == "radar":
            var sm := MB.new()
            _m_radar_dish(sm)
            var spin := MeshInstance3D.new()
            spin.mesh = sm.bake(mats)
            spin.position = Vector3(0, 10.4, 0)
            spin.visibility_range_end = 700.0
            n.add_child(spin)
            b["spin"] = spin
        if b["t"] == "airbase":
            for k in range(6 * b["lvl"]):
                var jm := MB.new()
                _m_jet(jm, 1, Color(0.55, 0.58, 0.6), COUNTRIES[b["c"]]["col"])
                var pj := MeshInstance3D.new()
                pj.mesh = jm.bake(mats)
                pj.scale = Vector3(0.7, 0.7, 0.7)
                var col := k % 9
                var row := k / 9
                pj.position = Vector3(-34.0 + float(col) * 7.2, 0.5, -5.0 + float(row) * 9.0)
                pj.rotation.y = PI * 0.5
                pj.visibility_range_end = 450.0
                pj.visible = false
                n.add_child(pj)
                b["parked"].append(pj)
    if b["st"] == "build":
        n.scale = Vector3(1, 0.05, 1)


func _refresh_airbase_parked(b: Dictionary) -> void:
    if b["t"] != "airbase" or b["st"] != "ok":
        return
    var ready := 0
    for j in b["jets"]:
        if j["state"] == "ready":
            ready += 1
    for k in range(b["parked"].size()):
        if is_instance_valid(b["parked"][k]):
            b["parked"][k].visible = k < ready


func _remove_building(b: Dictionary) -> void:
    if is_instance_valid(b["node"]):
        b["node"].queue_free()
    cs[b["c"]]["bl"].erase(b)
    bmap.erase(b["id"])
    lod_dirty[b["c"]] = true
    if sel_b == b["id"]:
        sel_b = -1


func _upgrade_cost(b: Dictionary) -> float:
    var d := _bdef(b["t"], b["c"])
    return float(d["cost"]) * pow(1.9, float(b["lvl"]))


func _max_level(b: Dictionary) -> int:
    var t: String = b["t"]
    if t in ["house", "apartment", "commerce", "office", "factory", "hospital", "university", "lab", "airbase", "port", "missilebase", "armybase", "radar", "park", "police"]:
        return 3
    return 1


func _damage_building(b: Dictionary, dmg: float, attacker: int) -> void:
    if b["st"] == "ruin":
        return
    b["hp"] = b["hp"] - dmg
    var c: int = b["c"]
    cs[c]["dmg_taken"] += dmg
    if attacker >= 0 and attacker < 9:
        cs[attacker]["dmg_dealt"] += dmg
    if b["hp"] <= 0.0:
        _destroy_building(b, attacker)


func _destroy_building(b: Dictionary, attacker: int) -> void:
    var c: int = b["c"]
    b["hp"] = 0.0
    var wasst: String = b["st"]
    b["st"] = "ruin"
    var t: String = b["t"]
    _make_node(b)
    lod_dirty[c] = true
    _fx_explosion(Vector3(b["x"], 3.0, b["z"]), 14.0, false)
    if t == "airbase":
        for j in b["jets"]:
            cs[c]["jets_lost"] += 1
        b["jets"] = []
    var pop_loss := 0.0
    if t == "house":
        pop_loss = 0.02
    elif t == "apartment":
        pop_loss = 0.12
    cs[c]["pop"] = max(0.5, cs[c]["pop"] - pop_loss * 0.3)
    cs[c]["casual"] += pop_loss * 60.0
    if t == "parliament":
        _news(String(COUNTRIES[c]["cap"]) + ": the government quarter has been destroyed!", "bad")
        cs[c]["money"] = cs[c]["money"] * 0.85
        cs[c]["happy"] = max(5.0, cs[c]["happy"] - 12.0)
    if attacker >= 0 and attacker != c and (c == me or attacker == me):
        _news(String(COUNTRIES[attacker]["short"]) + " destroyed a " + String(_bdef(t, c)["name"]) + " in " + String(COUNTRIES[c]["short"]) + ".", "bad" if c == me else "good")


func _repair_cost(b: Dictionary) -> float:
    var d := _bdef(b["t"], b["c"])
    if b["st"] == "ruin":
        return float(d["cost"]) * 0.6
    return float(d["cost"]) * 0.25 * (1.0 - b["hp"] / b["mhp"]) + 1.0


func _building_update(delta: float) -> void:
    for c in cs:
        for b in c["bl"]:
            if b["st"] == "build":
                var d := _bdef(b["t"], b["c"])
                b["prog"] = b["prog"] + delta / float(d["time"])
                if b["prog"] >= 1.0:
                    b["prog"] = 1.0
                    b["st"] = "ok"
                    _make_node(b)
                    _on_built(b)
                else:
                    b["node"].scale = Vector3(1, max(0.05, b["prog"]), 1)
            elif b["st"] == "ok" and b["spin"] != null and is_instance_valid(b["spin"]):
                b["spin"].rotation.y += delta * 1.4


func _on_built(b: Dictionary) -> void:
    lod_dirty[b["c"]] = true
    if b["c"] == me:
        _snd("build")
    if b["t"] == "airbase":
        _refresh_airbase_parked(b)


func _lod_rebuild() -> void:
    if cs.size() < 9 or lod_mm.size() < 9:
        return
    for i in range(9):
        if not lod_dirty[i]:
            continue
        lod_dirty[i] = false
        var lm: MultiMesh = lod_mm[i]
        var list := []
        for b in cs[i]["bl"]:
            list.append(b)
        lm.instance_count = list.size() + 1
        var col: Color = COUNTRIES[i]["col"]
        var p: Vector2 = COUNTRIES[i]["pos"]
        for k in range(list.size()):
            var b: Dictionary = list[k]
            var h := _fp_half(b["t"], b["r"], i)
            var hh := 7.0
            var cc := Color(0.55, 0.55, 0.55)
            match String(_bdef(b["t"], i)["cat"]):
                "city": cc = Color(0.7, 0.68, 0.62); hh = 9.0
                "service": cc = Color(0.4, 0.6, 0.8); hh = 8.0
                "mil": cc = Color(0.3, 0.4, 0.25); hh = 7.0
                "air": cc = Color(0.45, 0.5, 0.55); hh = 5.0
                "navy": cc = Color(0.25, 0.4, 0.55); hh = 6.0
            if b["t"] == "apartment" or b["t"] == "office":
                hh = 26.0
            if b["st"] == "ruin":
                cc = Color(0.12, 0.1, 0.1)
                hh = 2.0
            var tr := Transform3D(Basis().scaled(Vector3(h.x * 2.0, hh, h.y * 2.0)), Vector3(b["x"], hh * 0.5, b["z"]))
            lm.set_instance_transform(k, tr)
            lm.set_instance_color(k, cc)
        # country marker block (shows ownership at strategic zoom)
        var tr2 := Transform3D(Basis().scaled(Vector3(LAND * 2.0, 2.0, LAND * 2.0)), Vector3(p.x, 1.0, p.y))
        lm.set_instance_transform(list.size(), tr2)
        lm.set_instance_color(list.size(), Color(col.r * 0.55, col.g * 0.55, col.b * 0.55))


# =====================================================================
#  CAMERA + INPUT
# =====================================================================
func _update_camera(delta: float) -> void:
    var k = min(1.0, delta * 9.0)
    cam_target = cam_target.lerp(cam_goal, k)
    cam_dist = lerp(cam_dist, cam_goal_dist, k)
    var pitch := deg_to_rad(lerp(50.0, 82.0, clamp((cam_dist - 90.0) / 1500.0, 0.0, 1.0)))
    var off := Vector3(sin(cam_yaw) * cos(pitch), sin(pitch), cos(cam_yaw) * cos(pitch)) * cam_dist
    camera.position = cam_target + off
    camera.look_at(cam_target, Vector3.UP)
    sun.directional_shadow_max_distance = clamp(cam_dist * 1.6, 200.0, 1500.0)
    camera.far = max(9000.0, cam_dist * 4.0)


func _pan(dx: float, dy: float) -> void:
    var vh := float(get_viewport().get_visible_rect().size.y)
    var u := 2.0 * cam_dist * tan(deg_to_rad(camera.fov) * 0.5) / vh
    var right := Vector3(cos(cam_yaw), 0, -sin(cam_yaw))
    var fwd := Vector3(-sin(cam_yaw), 0, -cos(cam_yaw))
    var pitch := deg_to_rad(lerp(50.0, 82.0, clamp((cam_dist - 90.0) / 1500.0, 0.0, 1.0)))
    cam_goal -= right * dx * u
    cam_goal += fwd * dy * u / max(sin(pitch), 0.3)
    cam_goal.x = clamp(cam_goal.x, -2900.0, 2200.0)
    cam_goal.z = clamp(cam_goal.z, -1100.0, 1200.0)
    cam_target = cam_goal


func _zoom(f: float) -> void:
    cam_goal_dist = clamp(cam_goal_dist * f, 45.0, 3900.0)


func _focus(p: Vector3, dist: float = -1.0) -> void:
    cam_goal = Vector3(p.x, 0, p.z)
    if dist > 0.0:
        cam_goal_dist = dist


func _focus_country(i: int, dist: float = 380.0) -> void:
    _focus(_land_center(i), dist)


func _screen_to_ground(pos: Vector2) -> Vector3:
    var o := camera.project_ray_origin(pos)
    var dv := camera.project_ray_normal(pos)
    if abs(dv.y) < 0.001:
        return Vector3.ZERO
    var t := -o.y / dv.y
    return o + dv * t


func _unhandled_input(event: InputEvent) -> void:
    if game_state != "playing" and not args_selftest:
        if event is InputEventMouseButton or event is InputEventScreenTouch:
            pass
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            touches[event.index] = event.position
            if touches.size() == 2:
                var ks := touches.keys()
                var a: Vector2 = touches[ks[0]]
                var b: Vector2 = touches[ks[1]]
                pinch_d = a.distance_to(b)
                pinch_a = (b - a).angle()
        else:
            touches.erase(event.index)
    elif event is InputEventScreenDrag:
        touches[event.index] = event.position
        if touches.size() >= 2:
            var ks := touches.keys()
            var a: Vector2 = touches[ks[0]]
            var b: Vector2 = touches[ks[1]]
            var d := a.distance_to(b)
            if pinch_d > 10.0 and d > 10.0:
                _zoom(pinch_d / d)
            var ang := (b - a).angle()
            var da := wrapf(ang - pinch_a, -PI, PI)
            cam_yaw -= da
            pinch_d = d
            pinch_a = ang
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            _zoom(0.88)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            _zoom(1.14)
        elif event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                pressing = true
                press_pos = event.position
                press_t = Time.get_ticks_msec() / 1000.0
                press_moved = 0.0
            else:
                if pressing and press_moved < 14.0 and touches.size() < 2:
                    _on_tap(event.position)
                pressing = false
    elif event is InputEventMouseMotion:
        if pressing and touches.size() < 2:
            if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
                press_moved += event.relative.length()
                if press_moved > 8.0:
                    _pan(event.relative.x, event.relative.y)
        if event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
            cam_yaw -= event.relative.x * 0.006
    elif event is InputEventKey and event.pressed:
        if event.keycode == KEY_SPACE:
            speed = 0 if speed > 0 else 1
            _refresh_hud()


func _on_tap(pos: Vector2) -> void:
    var g := _screen_to_ground(pos)
    if mode == "place":
        place_x = _snap(g.x)
        place_z = _snap(g.z)
        _update_ghost()
        return
    if mode == "shipdest":
        _order_ship_to(sel_ship, g)
        mode = "none"
        return
    if mode == "strike" or mode == "airtarget":
        var c := _country_at(g.x, g.z, 10.0)
        var tb = _building_at(g.x, g.z, c if c >= 0 else -1)
        if c >= 0 and tb != null:
            _target_picked(tb)
        else:
            _toast("Tap an enemy building", "warn")
        return
    # selection: ships / aircraft first
    var best := -1
    var bd := 34.0
    for s in ships:
        if s["own"] != me or not is_instance_valid(s["node"]):
            continue
        var sp := camera.unproject_position(s["node"].global_position)
        var d := sp.distance_to(pos)
        if d < bd:
            bd = d
            best = s["id"]
    if best >= 0:
        sel_ship = best
        sel_b = -1
        _show_ship_panel()
        return
    var c := _country_at(g.x, g.z, 24.0)
    var tb = _building_at(g.x, g.z, c if c >= 0 else -1)
    if tb != null:
        sel_b = tb["id"]
        sel_ship = -1
        _show_building_panel(tb)
        return
    sel_b = -1
    sel_ship = -1
    _hide_side_panel()
    if c >= 0 and c != me:
        sel_country = c
        _show_country_panel(c)


func _building_at(x: float, z: float, c: int) -> Variant:
    if c < 0:
        return null
    var best: Variant = null
    var bd := 99999.0
    for b in cs[c]["bl"]:
        var h := _fp_half(b["t"], b["r"], c)
        if abs(x - b["x"]) <= h.x + 1.0 and abs(z - b["z"]) <= h.y + 1.0:
            var d := Vector2(x - b["x"], z - b["z"]).length()
            if d < bd:
                bd = d
                best = b
    return best


# =====================================================================
#  DAYLIGHT
# =====================================================================
func _update_daylight() -> void:
    var el := cos((day_t - 0.5) * TAU)
    var nightk: float = clamp(smoothstep(0.12, -0.25, el), 0.0, 1.0)
    RenderingServer.global_shader_parameter_set("night", nightk)
    sun.rotation_degrees = Vector3(-lerp(6.0, 66.0, clamp(el, 0.0, 1.0)) if el > 0.0 else -12.0, lerp(-130.0, 130.0, day_t), 0.0)
    var day_e: float = clamp(el * 2.0 + 0.25, 0.0, 1.0)
    sun.light_energy = lerp(0.14, 1.15, day_e)
    sun.light_color = Color(0.55, 0.65, 0.95).lerp(Color(1.0, 0.96, 0.88), day_e)
    if el > 0.0 and el < 0.3:
        sun.light_color = Color(1.0, 0.7, 0.45).lerp(Color(1.0, 0.96, 0.88), el / 0.3)
    env.ambient_light_energy = lerp(0.42, 0.72, day_e)
    sky_mat.sky_top_color = Color(0.02, 0.03, 0.1).lerp(Color(0.36, 0.6, 0.92), day_e)
    sky_mat.sky_horizon_color = Color(0.06, 0.07, 0.14).lerp(Color(0.82, 0.9, 0.97), day_e)
    sky_mat.ground_horizon_color = sky_mat.sky_horizon_color
    sky_mat.ground_bottom_color = Color(0.03, 0.04, 0.08).lerp(Color(0.6, 0.7, 0.8), day_e)
    env.fog_light_color = sky_mat.sky_horizon_color
    for gm in ground_mats:
        gm.set_shader_parameter("tint", Vector3(1, 1, 1).lerp(Vector3(0.55, 0.62, 0.85), nightk * 0.8))


# =====================================================================
#  SOUND (all generated in code)
# =====================================================================
var sounds := {}
var snd_players: Array = []
var snd_idx := 0

func _mk_wav(samples: PackedFloat32Array, rate: int = 22050) -> AudioStreamWAV:
    var bytes := PackedByteArray()
    bytes.resize(samples.size() * 2)
    for i in range(samples.size()):
        bytes.encode_s16(i * 2, int(clamp(samples[i], -1.0, 1.0) * 30000.0))
    var w := AudioStreamWAV.new()
    w.format = AudioStreamWAV.FORMAT_16_BITS
    w.mix_rate = rate
    w.stereo = false
    w.data = bytes
    return w


func _gen(dur: float, fn: Callable) -> AudioStreamWAV:
    var n := int(dur * 22050.0)
    var s := PackedFloat32Array()
    s.resize(n)
    var st := {"y": 0.0, "y2": 0.0}
    for i in range(n):
        s[i] = fn.call(float(i) / 22050.0, st)
    return _mk_wav(s)


func _make_sounds() -> void:
    var r := RandomNumberGenerator.new()
    r.seed = 77
    sounds["click"] = _gen(0.05, func(t: float, st: Dictionary) -> float: return sin(t * 2.0 * PI * 900.0) * exp(-t * 60.0) * 0.6)
    sounds["msg"] = _gen(0.35, func(t: float, st: Dictionary) -> float:
        return (sin(t * 2.0 * PI * 660.0) * exp(-t * 9.0) + sin(t * 2.0 * PI * 880.0) * exp(-(t - 0.12) * 10.0) * (1.0 if t > 0.12 else 0.0)) * 0.4)
    sounds["build"] = _gen(0.3, func(t: float, st: Dictionary) -> float: return (sin(t * 2.0 * PI * 440.0) * exp(-t * 8.0) + sin(t * 2.0 * PI * 660.0) * exp(-t * 8.0)) * 0.4)
    sounds["explode"] = _gen(1.6, func(t: float, st: Dictionary) -> float:
        var nz := r.randf_range(-1.0, 1.0)
        st["y"] += 0.12 * (nz - st["y"])
        return (st["y"] * 2.4 + sin(t * 2.0 * PI * (60.0 - t * 20.0)) * 0.8) * exp(-t * 3.0))
    sounds["boom"] = _gen(3.5, func(t: float, st: Dictionary) -> float:
        var nz := r.randf_range(-1.0, 1.0)
        st["y"] += 0.05 * (nz - st["y"])
        return (st["y"] * 3.0 + sin(t * 2.0 * PI * (40.0 - t * 6.0)) * 1.0) * exp(-t * 1.1))
    sounds["launch"] = _gen(1.8, func(t: float, st: Dictionary) -> float:
        var nz := r.randf_range(-1.0, 1.0)
        st["y"] += 0.3 * (nz - st["y"])
        return st["y"] * min(t * 4.0, 1.0) * exp(-t * 1.2) * 0.9)
    sounds["gun"] = _gen(0.18, func(t: float, st: Dictionary) -> float:
        var nz := r.randf_range(-1.0, 1.0)
        st["y"] += 0.5 * (nz - st["y"])
        return st["y"] * exp(-t * 28.0) * 0.8)
    sounds["siren"] = _gen(2.4, func(t: float, st: Dictionary) -> float:
        var f := 700.0 + 250.0 * sin(t * 2.0 * PI * 0.6)
        st["y"] += f / 22050.0
        return sin(st["y"] * 2.0 * PI) * 0.35 * min(t * 4.0, 1.0) * min((2.4 - t) * 4.0, 1.0))
    sounds["alarm"] = _gen(0.7, func(t: float, st: Dictionary) -> float:
        return (1.0 if sin(t * 2.0 * PI * 5.0) > 0.0 else 0.0) * sin(t * 2.0 * PI * 880.0) * 0.35)
    sounds["jet"] = _gen(2.0, func(t: float, st: Dictionary) -> float:
        var nz := r.randf_range(-1.0, 1.0)
        st["y"] += 0.08 * (nz - st["y"])
        return st["y"] * 1.8 * sin(t * PI / 2.0) * 0.8)
    for k in range(10):
        var p := AudioStreamPlayer.new()
        p.volume_db = -4.0
        add_child(p)
        snd_players.append(p)


func _snd(name: String, vol: float = 0.0) -> void:
    if not sounds.has(name) or snd_players.is_empty():
        return
    var p: AudioStreamPlayer = snd_players[snd_idx % snd_players.size()]
    snd_idx += 1
    p.stream = sounds[name]
    p.volume_db = vol - 4.0
    p.pitch_scale = rng.randf_range(0.92, 1.08)
    p.play()


func _snd_at(name: String, pos: Vector3, vol: float = 0.0) -> void:
    var d := camera.global_position.distance_to(pos)
    var att := -8.0 * log(1.0 + d / 250.0)
    if att < -30.0:
        return
    _snd(name, vol + att)


# =====================================================================
#  EFFECTS
# =====================================================================
func _fx_add(node: Node3D, life: float, kind: String, data: Dictionary = {}) -> Dictionary:
    var f := {"node": node, "t": 0.0, "life": life, "kind": kind, "d": data}
    fxs.append(f)
    if fxs.size() > 90:
        var old: Dictionary = fxs.pop_front()
        if is_instance_valid(old["node"]):
            old["node"].queue_free()
    return f


var fire_mat: StandardMaterial3D
var smoke_mat: StandardMaterial3D

func _fx_mats() -> void:
    if fire_mat != null:
        return
    fire_mat = StandardMaterial3D.new()
    fire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    fire_mat.albedo_color = Color(1.0, 0.55, 0.12, 0.9)
    fire_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    fire_mat.emission_enabled = true
    fire_mat.emission = Color(1.0, 0.4, 0.05)
    fire_mat.emission_energy_multiplier = 2.5
    smoke_mat = StandardMaterial3D.new()
    smoke_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    smoke_mat.vertex_color_use_as_albedo = true
    smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    smoke_mat.albedo_color = Color(1, 1, 1, 1)


func _fx_explosion(pos: Vector3, radius: float, big: bool) -> void:
    _fx_mats()
    var fb := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 1.0
    sm.height = 2.0
    sm.radial_segments = 14
    sm.rings = 8
    fb.mesh = sm
    fb.material_override = fire_mat.duplicate()
    fb.position = pos
    fb.scale = Vector3.ONE * radius * 0.3
    fb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(fb)
    _fx_add(fb, 0.9 if not big else 3.0, "fire", {"r": radius})
    var sp := CPUParticles3D.new()
    sp.position = pos
    sp.amount = 18 if not big else 70
    sp.lifetime = 4.0 if not big else 10.0
    sp.one_shot = true
    sp.explosiveness = 0.9
    sp.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
    sp.emission_sphere_radius = radius * 0.4
    sp.direction = Vector3.UP
    sp.spread = 40.0
    sp.initial_velocity_min = radius * 0.2
    sp.initial_velocity_max = radius * 0.7
    sp.gravity = Vector3(0, 2.5, 0)
    sp.scale_amount_min = radius * 0.25
    sp.scale_amount_max = radius * 0.55
    var grad := Gradient.new()
    grad.set_color(0, Color(0.25, 0.22, 0.2, 0.85))
    grad.set_color(1, Color(0.35, 0.35, 0.35, 0.0))
    sp.color_ramp = grad
    var pm := SphereMesh.new()
    pm.radius = 1.0
    pm.height = 2.0
    pm.radial_segments = 6
    pm.rings = 3
    sp.mesh = pm
    sp.material_override = smoke_mat
    sp.emitting = true
    sp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(sp)
    _fx_add(sp, sp.lifetime + 1.0, "free")
    var lt := OmniLight3D.new()
    lt.position = pos + Vector3(0, 6, 0)
    lt.light_color = Color(1.0, 0.6, 0.25)
    lt.light_energy = 5.0 if not big else 14.0
    lt.omni_range = radius * 4.0
    lt.shadow_enabled = false
    add_child(lt)
    _fx_add(lt, 0.6 if not big else 2.0, "light", {"e": lt.light_energy})
    _snd_at("boom" if big else "explode", pos, 4.0 if big else 0.0)
    # scorch decal
    var ci := _country_at(pos.x, pos.z, 4.0)
    if ci >= 0 and radius >= 8.0:
        _add_scorch(ci, pos, radius * (1.8 if big else 1.0))


var scorch_idx := [0, 0, 0, 0, 0, 0, 0, 0, 0]

func _add_scorch(ci: int, pos: Vector3, rad: float) -> void:
    var gm: ShaderMaterial = ground_mats[ci]
    var arr: Array = gm.get_shader_parameter("scorch")
    if arr == null or arr.size() < 6:
        return
    var k: int = scorch_idx[ci] % 6
    scorch_idx[ci] += 1
    arr[k] = Vector4(pos.x, pos.z, rad, 0.9)
    gm.set_shader_parameter("scorch", arr)


func _fx_nuke(pos: Vector3) -> void:
    _fx_mats()
    _fx_explosion(pos, 60.0, true)
    var stem := MeshInstance3D.new()
    var cm := CylinderMesh.new()
    cm.top_radius = 6.0
    cm.bottom_radius = 10.0
    cm.height = 1.0
    stem.mesh = cm
    stem.material_override = fire_mat.duplicate()
    stem.position = pos
    add_child(stem)
    _fx_add(stem, 9.0, "stem")
    var cap := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 1.0
    sm.height = 2.0
    cap.mesh = sm
    cap.material_override = fire_mat.duplicate()
    cap.position = pos
    cap.scale = Vector3(1, 0.7, 1)
    add_child(cap)
    _fx_add(cap, 9.0, "cap")
    var ring := MeshInstance3D.new()
    var tm := CylinderMesh.new()
    tm.top_radius = 1.0
    tm.bottom_radius = 1.0
    tm.height = 0.5
    ring.mesh = tm
    var rm := StandardMaterial3D.new()
    rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    rm.albedo_color = Color(1.0, 0.95, 0.8, 0.5)
    rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    ring.material_override = rm
    ring.position = pos + Vector3(0, 1.0, 0)
    add_child(ring)
    _fx_add(ring, 3.5, "shock")
    if flash_rect:
        flash_rect.color = Color(1, 1, 1, 0.95)
        flash_rect.visible = true
        flash_t = 1.0


func _fx_update(delta: float) -> void:
    var keep := []
    for f in fxs:
        f["t"] += delta
        var n = f["node"]
        if not is_instance_valid(n):
            continue
        var k: float = f["t"] / f["life"]
        if k >= 1.0:
            n.queue_free()
            continue
        match f["kind"]:
            "fire":
                var r: float = f["d"]["r"]
                n.scale = Vector3.ONE * r * lerp(0.3, 1.2, sqrt(k))
                n.material_override.albedo_color = Color(1.0, lerp(0.6, 0.15, k), 0.05, (1.0 - k) * 0.9)
                n.position.y += delta * r * 0.12
            "light":
                n.light_energy = f["d"]["e"] * (1.0 - k)
            "stem":
                n.scale = Vector3(1, 130.0 * min(k * 3.0, 1.0) + 1.0, 1) * 1.0
                n.position.y = 1.0 + n.scale.y * 0.5
                n.material_override.albedo_color = Color(1.0, lerp(0.55, 0.2, k), 0.05, (1.0 - k) * 0.85)
            "cap":
                var s = 30.0 + 40.0 * min(k * 2.5, 1.0)
                n.scale = Vector3(s, s * 0.7, s)
                n.position.y = 10.0 + 130.0 * min(k * 3.0, 1.0)
                n.material_override.albedo_color = Color(1.0, lerp(0.5, 0.18, k), 0.05, (1.0 - k) * 0.85)
            "shock":
                var s := 8.0 + 230.0 * k
                n.scale = Vector3(s, 1.0, s)
                n.material_override.albedo_color = Color(1.0, 0.95, 0.8, 0.5 * (1.0 - k))
            "puff":
                n.scale = Vector3.ONE * (1.0 + 4.0 * k) * f["d"].get("s", 1.0)
                n.material_override.albedo_color = Color(0.3, 0.3, 0.3, 0.6 * (1.0 - k))
            _:
                pass
        keep.append(f)
    fxs = keep
    if flash_t > 0.0:
        flash_t -= delta * 0.5
        if flash_rect:
            flash_rect.color = Color(1, 1, 1, clamp(flash_t, 0.0, 1.0) * 0.9)
            if flash_t <= 0.0:
                flash_rect.visible = false

var flash_rect: ColorRect
var flash_t := 0.0


# =====================================================================
#  ECONOMY / GOVERNMENT / RESEARCH
# =====================================================================
func _fmt(v: float) -> String:
    var a: float = abs(v)
    var sgn := "-" if v < 0.0 else ""
    if a >= 1000000.0:
        return sgn + "$" + String.num(a / 1000000.0, 2) + "M"
    if a >= 10000.0:
        return sgn + "$" + String.num(a / 1000.0, 1) + "K"
    return sgn + "$" + str(int(a))


func _has_tech(c: int, k: String) -> bool:
    return k == "" or cs[c]["tech"].has(k)


func _pol_sum(c: int, key: String) -> float:
    var s := 0.0
    for k in cs[c]["pol"].keys():
        if cs[c]["pol"][k]:
            s += float(POLICIES[k].get(key, 0.0))
    return s


func _count_b(c: int, t: String, only_ok: bool = true) -> int:
    var n := 0
    for b in cs[c]["bl"]:
        if b["t"] == t and (b["st"] == "ok" or not only_ok):
            n += 1
    return n


func _lab_level(c: int) -> int:
    var m := 0
    for b in cs[c]["bl"]:
        if b["t"] == "lab" and b["st"] == "ok":
            m = max(m, b["lvl"])
    return m


func _unlocked(c: int, t: String) -> bool:
    var d := _bdef(t, c)
    if cs[c]["unl"].has(t):
        return true
    if t == "enrich":
        return _has_tech(c, "nuc2") and not cs[c]["pol"].get("npt", false)
    if float(d["unlock"]) > cs[c]["peak"]:
        return false
    return _has_tech(c, String(d.get("tech", "")))


func _unlock_reason(c: int, t: String) -> String:
    var d := _bdef(t, c)
    var tech := String(d.get("tech", ""))
    if tech != "" and not _has_tech(c, tech):
        return "Research: " + String(TECHS[tech]["name"])
    if t == "enrich" and cs[c]["pol"].get("npt", false):
        return "Withdraw from NPT first"
    if float(d["unlock"]) > cs[c]["peak"]:
        return "Reach " + _fmt(float(d["unlock"])) + " treasury"
    return ""


func _wmult(c: int) -> float:
    var m := 1.0 + _pol_sum(c, "mil")
    var fac = min(0.2, 0.02 * float(_count_b(c, "factory")))
    return max(0.4, m - fac)


func _econ_mult(c: int) -> float:
    var m := 1.0 + _pol_sum(c, "inc")
    if cs[c]["tech"].has("eco1"):
        m += 0.1
    if cs[c]["tech"].has("eco2"):
        m += 0.12
    var tr := 0
    var sn := 0
    for j in range(9):
        if j == c:
            continue
        if cs[c]["trade"][j] and cs[c]["st"][j] != "war":
            tr += 1
        if cs[j]["sanc"][c]:
            sn += 1
    m += 0.035 * float(tr) - 0.05 * float(sn)
    return max(0.3, m)


func _compute_income(c: int) -> Dictionary:
    var cd: Dictionary = COUNTRIES[c]
    var s: Dictionary = cs[c]
    var inc := 100.0
    var up := 0.0
    var hap := 0.0
    var stab := 0.0
    var rp := 0.0
    for b in s["bl"]:
        if b["st"] == "ruin":
            continue
        var d := _bdef(b["t"], c)
        if b["st"] == "ok":
            var hpf: float = clamp(b["hp"] / b["mhp"], 0.2, 1.0)
            inc += float(d["inc"]) * (1.0 + 0.6 * float(b["lvl"] - 1)) * hpf
            hap += float(d.get("happy", 0.0)) * float(b["lvl"])
            stab += float(d.get("stab", 0.0)) * float(b["lvl"])
            rp += float(d.get("rp", 0.0)) * float(b["lvl"])
        up += float(d["up"]) * float(b["lvl"])
        if b["t"] == "airbase":
            up += 35.0 * float(b["jets"].size())
    for sh in ships:
        if sh["own"] == c:
            up += float(SHIPS[sh["k"]]["up"]) * 0.5
    var tx: float = s["tax"]
    var taxm := pow(max(tx, 0.02) / 0.20, 0.85)
    inc *= float(cd["econ"]) * _econ_mult(c) * taxm
    inc *= (1.0 - s["prot"] * 0.35)
    var polc := _pol_sum(c, "cost")
    return {"inc": inc, "up": up + polc, "hap": min(hap, 28.0), "stab": stab + _pol_sum(c, "stab"), "rp": rp}


func _economy_tick() -> void:
    month += 1
    for c in range(9):
        var s: Dictionary = cs[c]
        var r := _compute_income(c)
        var net: float = float(r["inc"]) - float(r["up"])
        s["income"] = r["inc"]
        s["upkeep"] = r["up"]
        s["last_inc"] = net
        s["money"] = s["money"] + net
        if s["money"] < -20000.0:
            s["money"] = -20000.0
        s["peak"] = max(s["peak"], s["money"])
        # war weariness
        var wars := 0
        for j in range(9):
            if s["st"][j] == "war":
                wars += 1
        if wars > 0:
            s["war_w"] = min(100.0, s["war_w"] + 0.8 * float(wars) + s["casual"] * 0.15)
        else:
            s["war_w"] = max(0.0, s["war_w"] - 1.5)
        s["casual"] = s["casual"] * 0.6
        # happiness
        var tgt = 56.0 + float(r["hap"]) + _pol_sum(c, "happy") - (s["tax"] - 0.20) * 60.0 - s["war_w"] * 0.3
        if s["money"] < 0.0:
            tgt -= 10.0
        if s["cur"] == "" and false:
            tgt += 0.0
        s["happy"] = clamp(s["happy"] + (tgt - s["happy"]) * 0.15, 0.0, 100.0)
        s["stab"] = r["stab"]
        var raw: float = clamp((42.0 - s["happy"]) / 42.0, 0.0, 1.0)
        s["prot"] = clamp(raw * (1.0 - min(0.9, float(r["stab"]) / 30.0)), 0.0, 1.0)
        # reputation
        s["rep"] = clamp(s["rep"] * 0.97 + _pol_sum(c, "rep") * 0.5, -100.0, 100.0)
        # population
        var gr = 0.0008 * (s["happy"] - 35.0) / 50.0
        if s["pol"].get("health", false):
            gr += 0.0004
        s["pop"] = max(0.5, s["pop"] * (1.0 + gr))
        # research
        var rpt: float = float(r["rp"]) * (1.0 + _pol_sum(c, "rp"))
        if s["cur"] != "" and _lab_level(c) > 0:
            s["rp"] = s["rp"] + rpt
            var t: Dictionary = TECHS[s["cur"]]
            if s["rp"] >= float(t["cost"]):
                _complete_tech(c, s["cur"])
        # unlock notices (player)
        if c == me:
            _check_unlock_notices()
        # ceasefire expiry
        for j in range(9):
            if s["st"][j] == "cease":
                s["cease_t"][j] = s["cease_t"][j] - 1.0
                if s["cease_t"][j] <= 0.0:
                    s["st"][j] = "peace"
                    cs[j]["st"][c] = "peace"
                    if c == me or j == me:
                        _news("Ceasefire between " + String(COUNTRIES[c]["short"]) + " and " + String(COUNTRIES[j]["short"]) + " became a lasting peace.", "good")
        # relations drift
        var emb := float(_count_b(c, "embassy")) * 0.25
        for j in range(9):
            if j == c:
                continue
            var rel: float = s["rel"][j]
            var base: float = float(REL0[c][j])
            var drift := (base - rel) * 0.01 + emb * 0.4 + _pol_sum(c, "rep") * 0.15
            if s["st"][j] == "ally":
                drift += 0.6
            if s["trade"][j]:
                drift += 0.25
            if s["st"][j] == "war":
                drift -= 0.8
            if cs[j]["pol"].get("npt", false) and false:
                drift += 0.0
            s["rel"][j] = clamp(rel + drift, -100.0, 100.0)
        # election
        if month >= s["next_elec"]:
            _election(c)
    _events_tick()


func _complete_tech(c: int, k: String) -> void:
    cs[c]["tech"][k] = true
    cs[c]["rp"] = 0.0
    cs[c]["cur"] = ""
    if c == me:
        _news("Research complete: " + String(TECHS[k]["name"]), "good")
        _snd("msg")
    if k == "nuc1" or k == "nuc2":
        # the world notices
        for j in range(9):
            if j != c:
                var dd: float = -6.0 if k == "nuc1" else -12.0
                if cs[j]["nuke"] or j == 0 or j == 4:
                    dd *= 2.0
                cs[j]["rel"][c] = clamp(cs[j]["rel"][c] + dd, -100.0, 100.0)
        _news(String(COUNTRIES[c]["name"]) + " is developing a nuclear programme. The world is alarmed.", "warn")
    if k == "nuc3":
        cs[c]["nuke"] = true
        _news(String(COUNTRIES[c]["name"]) + " has mastered the atomic bomb!", "warn")
        for j in range(9):
            if j != c:
                cs[j]["rel"][c] = clamp(cs[j]["rel"][c] - 10.0, -100.0, 100.0)


var unl_notified := {}

func _check_unlock_notices() -> void:
    for t in _all_types():
        var key = str(me) + t
        if not unl_notified.has(key) and _unlocked(me, t) and float(_bdef(t, me)["unlock"]) > 0.0:
            unl_notified[key] = true
            _toast("Unlocked: " + String(_bdef(t, me)["name"]), "good")
    for k in range(MSL.size() - 1):
        var key := str(me) + "m" + str(k)
        if not unl_notified.has(key) and cs[me]["peak"] >= float(MSL[k]["unlock"]) and _has_tech(me, String(MSL[k]["tech"])) and float(MSL[k]["unlock"]) > 0.0:
            unl_notified[key] = true
            _toast("New weapon available: " + _msl_name(me, k), "good")


func _election(c: int) -> void:
    var s: Dictionary = cs[c]
    s["next_elec"] = month + 99999
    return
    var h: float = s["happy"]
    if h >= 45.0:
        if c == me:
            _news("ELECTION: " + String(COUNTRIES[c]["title"]) + " re-elected with " + str(int(h)) + "% approval.", "good")
            s["happy"] = min(100.0, s["happy"] + 5.0)
        return
    # government falls
    s["happy"] = 52.0
    s["tax"] = 0.20
    s["war_w"] = s["war_w"] * 0.5
    s["pol"] = {}
    if c == me:
        _news("ELECTION: the people rejected you (approval " + str(int(h)) + "%). A new government took office. Policies were reset.", "bad")
        _popup("Government Changed", "People voted out the government. Policies were reset and tax returned to 20%. Keep citizens happy to stay in power.", [["OK", ""]])
    else:
        _news(String(COUNTRIES[c]["short"]) + ": new government after unrest.", "info")
        for j in range(9):
            if s["st"][j] == "war" and rng.randf() < 0.6:
                _make_peace(c, j, "new government")


func _complete_choice(c: int, k: String) -> void:
    pass


func _toggle_policy(c: int, k: String) -> void:
    var on: bool = cs[c]["pol"].get(k, false)
    if k == "npt" and on:
        # withdrawing is a big diplomatic event
        for j in range(9):
            if j != c:
                cs[j]["rel"][c] = clamp(cs[j]["rel"][c] - 12.0, -100.0, 100.0)
        _news(String(COUNTRIES[c]["name"]) + " withdrew from the NPT!", "warn")
    if k == "npt" and not on and cs[c]["nuke"]:
        _toast("You already have nuclear weapons. Joining NPT only improves reputation.", "info")
    cs[c]["pol"][k] = not on
    if c == me:
        _snd("click")


func _start_research(c: int, k: String) -> String:
    if _lab_level(c) <= 0:
        return "Build a Research Lab first"
    var t: Dictionary = TECHS[k]
    if cs[c]["tech"].has(k):
        return "Already researched"
    if int(t["lab"]) > _lab_level(c):
        return "Needs Research Lab level " + str(t["lab"])
    if String(t["req"]) != "" and not cs[c]["tech"].has(t["req"]):
        return "Needs: " + String(TECHS[t["req"]]["name"])
    if k.begins_with("nuc") and cs[c]["pol"].get("npt", false):
        return "Withdraw from the NPT to research nuclear technology"
    cs[c]["cur"] = k
    cs[c]["rp"] = 0.0
    return ""


# ---------------- events (random world/home events) -------------------
var ev_timer := 14

func _events_tick() -> void:
    return
    ev_timer -= 1
    if ev_timer > 0 or game_state != "playing":
        return
    ev_timer = rng.randi_range(14, 28)
    var pick := rng.randi() % 9
    var s: Dictionary = cs[me]
    match pick:
        0:
            _popup("Oil Price Spike", "Global oil prices jumped. Citizens are angry about fuel costs.", [["Subsidise fuel (-" + _fmt(3000.0) + ", +happy)", "oil_sub"], ["Let the market decide (-5 happiness)", "oil_no"]])
        1:
            _popup("Earthquake", "A strong earthquake hit one of your cities. Buildings are damaged.", [["Send emergency aid (" + _fmt(4000.0) + ")", "quake_aid"], ["Rely on local services", "quake_no"]])
        2:
            _popup("Trade Offer", "A foreign company offers to invest in your economy.", [["Accept (+" + _fmt(9000.0) + ")", "invest"], ["Decline", ""]])
        3:
            _popup("Student Protests", "Students are protesting about tuition and jobs.", [["Increase education spending (" + _fmt(2500.0) + ")", "edu_sp"], ["Send police to disperse them", "protest_pol"]])
        4:
            _popup("Spy Scandal", "Your intelligence service caught a foreign spy ring.", [["Expose them publicly", "spy_pub"], ["Quietly expel them", "spy_quiet"]])
        5:
            _popup("Terror Attack", "A terror attack shook the capital.", [["Boost security (" + _fmt(3000.0) + ")", "terror_sec"], ["Do nothing", "terror_no"]])
        6:
            _popup("Currency Crisis", "Your currency lost value in markets.", [["Raise interest rates (+3% tax)", "cur_tax"], ["Print money (+" + _fmt(8000.0) + ", unrest)", "cur_print"]])
        7:
            _popup("Pandemic Scare", "A flu outbreak spread in your cities.", [["Emergency healthcare (" + _fmt(5000.0) + ")", "pan_hc"], ["Ignore", "pan_no"]])
        _:
            _popup("Global Summit", "World leaders invite you to a climate and trade summit.", [["Attend (+reputation)", "summit"], ["Skip", ""]])


func _event_choice(code: String) -> void:
    var s: Dictionary = cs[me]
    match code:
        "oil_sub":
            s["money"] -= 3000.0
            s["happy"] = min(100.0, s["happy"] + 3.0)
        "oil_no":
            s["happy"] = max(0.0, s["happy"] - 5.0)
        "quake_aid":
            s["money"] -= 4000.0
            _quake(false)
        "quake_no":
            _quake(true)
        "invest":
            s["money"] += 9000.0
        "edu_sp":
            s["money"] -= 2500.0
            s["happy"] = min(100.0, s["happy"] + 4.0)
        "protest_pol":
            s["happy"] = max(0.0, s["happy"] - 4.0)
            s["rep"] = max(-100.0, s["rep"] - 4.0)
        "spy_pub":
            for j in range(9):
                if j != me and cs[j]["rel"][me] < 0.0:
                    cs[j]["rel"][me] = max(-100.0, cs[j]["rel"][me] - 5.0)
            s["happy"] = min(100.0, s["happy"] + 3.0)
        "spy_quiet":
            s["rep"] = min(100.0, s["rep"] + 2.0)
        "terror_sec":
            s["money"] -= 3000.0
            s["happy"] = min(100.0, s["happy"] + 2.0)
        "terror_no":
            s["happy"] = max(0.0, s["happy"] - 6.0)
        "cur_tax":
            s["tax"] = min(0.5, s["tax"] + 0.03)
        "cur_print":
            s["money"] += 8000.0
            s["happy"] = max(0.0, s["happy"] - 4.0)
        "pan_hc":
            s["money"] -= 5000.0
        "pan_no":
            s["pop"] = s["pop"] * 0.998
            s["happy"] = max(0.0, s["happy"] - 5.0)
        "summit":
            s["rep"] = min(100.0, s["rep"] + 6.0)
            for j in range(9):
                if j != me:
                    cs[me]["rel"][j] = min(100.0, cs[me]["rel"][j] + 3.0)
                    cs[j]["rel"][me] = min(100.0, cs[j]["rel"][me] + 3.0)
        _:
            if code.begins_with("prop:"):
                _handle_prop(code)
            elif code.begins_with("war:"):
                _declare_war_player(int(code.substr(4)))
                _win_refresh()
            elif code.begins_with("nuke:"):
                var nb: Variant = bmap.get(int(code.substr(5)), null)
                if nb != null:
                    _fire_salvo(me, 5, 1, nb)
    _refresh_hud()


func _quake(ignore: bool) -> void:
    var list := []
    for b in cs[me]["bl"]:
        if b["st"] == "ok":
            list.append(b)
    list.shuffle()
    var n: int = min(list.size(), 4 if ignore else 2)
    for k in range(n):
        _damage_building(list[k], list[k]["mhp"] * (0.7 if ignore else 0.35), -1)
    _news("The earthquake damaged " + str(n) + " buildings.", "bad")


# =====================================================================
#  WAR: helpers
# =====================================================================
func _at_war(a: int, b: int) -> bool:
    return a != b and cs[a]["st"][b] == "war"


func _allied(a: int, b: int) -> bool:
    return a != b and cs[a]["st"][b] == "ally"


func _msl_name(c: int, k: int) -> String:
    return String(COUNTRIES[c]["msl"][k])


func _jet_name(c: int, t: int) -> String:
    return String(COUNTRIES[c]["air"][t])


func _dist2(a: Vector3, b: Vector3) -> float:
    return Vector2(a.x - b.x, a.z - b.z).length()


func _sea_rects() -> Array:
    var out := []
    for i in range(9):
        var p: Vector2 = COUNTRIES[i]["pos"]
        out.append(Rect2(p.x - LAND - 22.0, p.y - LAND - 22.0, (LAND + 22.0) * 2.0, (LAND + 22.0) * 2.0))
    return out


func _seg_hits_rect(a: Vector2, b: Vector2, r: Rect2) -> bool:
    if r.has_point(a) or r.has_point(b):
        return true
    var ps := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
    for k in range(4):
        if Geometry2D.segment_intersects_segment(a, b, ps[k], ps[(k + 1) % 4]) != null:
            return true
    return false


func _sea_path(from: Vector3, to: Vector3, ignore_land: int = -1) -> Array:
    var pts := [Vector3(to.x, 0, to.z)]
    var cur := Vector2(from.x, from.z)
    var goal := Vector2(to.x, to.z)
    var result := []
    var rects := _sea_rects()
    for iter in range(8):
        var hit := -1
        var hd := 1e9
        for i in range(9):
            if i == ignore_land:
                continue
            var r: Rect2 = rects[i]
            if r.has_point(cur):
                continue
            if _seg_hits_rect(cur, goal, r):
                var d := cur.distance_to(r.get_center())
                if d < hd:
                    hd = d
                    hit = i
        if hit < 0:
            break
        var r2: Rect2 = rects[hit]
        var m := 14.0
        var corners := [Vector2(r2.position.x - m, r2.position.y - m), Vector2(r2.end.x + m, r2.position.y - m),
            Vector2(r2.end.x + m, r2.end.y + m), Vector2(r2.position.x - m, r2.end.y + m)]
        var bestc = corners[0]
        var bl := 1e9
        for cn in corners:
            var cv: Vector2 = cn
            if _seg_hits_rect(cur, cv, r2.grow(-6.0)) or _seg_hits_rect(cv, goal, r2.grow(-6.0)):
                continue
            var l := cur.distance_to(cv) + cv.distance_to(goal)
            if l < bl:
                bl = l
                bestc = cv
        if bl > 1e8:
            break
        result.append(Vector3(bestc.x, 0, bestc.y))
        cur = bestc
    result.append(Vector3(to.x, 0, to.z))
    return result


func _marker(col: Color, s: float) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 1.0
    sm.height = 2.0
    sm.radial_segments = 8
    sm.rings = 4
    m.mesh = sm
    var mt := StandardMaterial3D.new()
    mt.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mt.albedo_color = col
    mt.no_depth_test = false
    m.material_override = mt
    m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    m.visibility_range_begin = 350.0
    m.set_meta("base", s)
    return m


func _update_markers() -> void:
    var f: float = cam_dist * 0.011
    for fl in flights:
        if is_instance_valid(fl["mk"]):
            var s: float = clamp(f * float(fl["mk"].get_meta("base")), 0.5, 40.0)
            fl["mk"].scale = Vector3.ONE * s / max(fl["node"].scale.x, 0.1)
    for sh in ships:
        if is_instance_valid(sh["mk"]):
            var s2: float = clamp(f * float(sh["mk"].get_meta("base")), 0.5, 40.0)
            sh["mk"].scale = Vector3.ONE * s2
    for p in projs:
        if is_instance_valid(p["mk"]):
            var s3: float = clamp(f * float(p["mk"].get_meta("base")), 0.4, 30.0)
            p["mk"].scale = Vector3.ONE * s3


# =====================================================================
#  JETS
# =====================================================================
func _jet_mesh(tier: int, own: int) -> ArrayMesh:
    var key := "jet_" + str(tier) + "_" + str(own)
    if mesh_cache.has(key):
        return mesh_cache[key]
    var mb := MB.new()
    var base := Color(0.55, 0.58, 0.6)
    if tier == 3:
        base = Color(0.3, 0.32, 0.35)
    _m_jet(mb, tier, base, COUNTRIES[own]["col"])
    var m := mb.bake(mats)
    mesh_cache[key] = m
    return m


func _jet_ready_count(c: int) -> int:
    var n := 0
    for b in cs[c]["bl"]:
        if b["t"] == "airbase" and b["st"] == "ok":
            for j in b["jets"]:
                if j["state"] == "ready":
                    n += 1
    for sh in ships:
        if sh["own"] == c and sh["k"] == 4:
            for j in sh["jets"]:
                if j["state"] == "ready":
                    n += 1
    return n


func _jet_total(c: int) -> int:
    var n := 0
    for b in cs[c]["bl"]:
        if b["t"] == "airbase":
            n += b["jets"].size()
    for sh in ships:
        if sh["own"] == c and sh["k"] == 4:
            n += sh["jets"].size()
    return n


func _spawn_flight(own: int, tier: int, pos: Vector3, yaw: float, mission: String, home: Dictionary, jref: Variant) -> Variant:
    if flights.size() >= MAX_JETS:
        return null
    var node := Node3D.new()
    node.position = pos
    node.rotation.y = yaw
    var mi := MeshInstance3D.new()
    if mission == "pm":
        var mb := MB.new()
        _m_airliner(mb, COUNTRIES[own]["col"])
        mi.mesh = mb.bake(mats)
        mi.scale = Vector3.ONE * 1.3
    else:
        mi.mesh = _jet_mesh(tier, own)
        mi.scale = Vector3.ONE * 2.2
    node.add_child(mi)
    var mk := _marker(COUNTRIES[own]["col"].lightened(0.3), 1.0 if mission != "pm" else 1.4)
    node.add_child(mk)
    # afterburner / contrail
    var tr := CPUParticles3D.new()
    tr.amount = 26
    tr.lifetime = 2.4
    tr.local_coords = false
    tr.emission_shape = CPUParticles3D.EMISSION_SHAPE_POINT
    tr.direction = Vector3(0, 0, 1)
    tr.spread = 3.0
    tr.initial_velocity_min = 0.5
    tr.initial_velocity_max = 1.5
    tr.scale_amount_min = 0.9
    tr.scale_amount_max = 1.3
    var grad := Gradient.new()
    grad.set_color(0, Color(1, 1, 1, 0.55))
    grad.set_color(1, Color(1, 1, 1, 0.0))
    tr.color_ramp = grad
    var pm := SphereMesh.new()
    pm.radius = 0.7
    pm.height = 1.4
    pm.radial_segments = 5
    pm.rings = 3
    tr.mesh = pm
    _fx_mats()
    tr.material_override = smoke_mat
    tr.position = Vector3(0, 0, 9.0)
    tr.visibility_range_end = 1400.0
    tr.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    node.add_child(tr)
    add_child(node)
    var spd := 90.0
    if mission != "pm":
        spd = float(JET_T[tier]["speed"])
    else:
        spd = 100.0
    var f := {"id": uid_counter, "own": own, "tier": tier, "node": node, "mk": mk, "trail": tr, "yaw": yaw, "speed": spd, "cur": 0.0,
        "state": "takeoff", "mission": mission, "tgt": null, "tgt_c": -1, "home": home, "ref": jref, "ammo": 0, "alt": 40.0, "t": 0.0,
        "df": null, "scr": 0, "aa_cd": 0.0, "dest": Vector3.ZERO, "hp": 1.0, "chase": -1, "warned": false, "dead": false, "loiter": 0.0, "bank": 0.0}
    uid_counter += 1
    if mission != "pm":
        f["ammo"] = int(JET_T[tier]["shots"])
    flights.append(f)
    return f


func _flight_by_id(id: int) -> Variant:
    for f in flights:
        if f["id"] == id and not f["dead"]:
            return f
    return null


func _home_pos(f: Dictionary) -> Vector3:
    var h: Variant = f["home"]
    if h is Dictionary and h.has("node") and is_instance_valid(h["node"]):
        if h.has("pos"):
            return h["pos"]
        return Vector3(h["x"], 0, h["z"])
    return f["node"].position


func _jets_launch_from(c: int, n: int, tx: Vector3) -> Array:
    # returns list of [home, jref] picking the nearest launch sites first
    var sites := []
    for b in cs[c]["bl"]:
        if b["t"] == "airbase" and b["st"] == "ok":
            sites.append({"home": b, "list": b["jets"], "pos": Vector3(b["x"], 0, b["z"])})
    for sh in ships:
        if sh["own"] == c and sh["k"] == 4:
            sites.append({"home": sh, "list": sh["jets"], "pos": sh["pos"]})
    sites.sort_custom(func(a, b): return _dist2(a["pos"], tx) < _dist2(b["pos"], tx))
    var out := []
    for s in sites:
        for j in s["list"]:
            if j["state"] == "ready" and out.size() < n:
                out.append([s["home"], j])
    return out


func _launch_pos_yaw(home: Dictionary, tx: Vector3) -> Array:
    var pos := Vector3.ZERO
    var yaw := 0.0
    if home.has("x") and home.has("t"):  # building
        pos = Vector3(home["x"], 1.0, home["z"])
        var ang := deg_to_rad(90.0 * float(home["r"]))
        var along := Vector3(cos(ang), 0, -sin(ang))
        pos += along * (-36.0 if along.dot(tx - pos) > 0.0 else 36.0)
        var dirv: Vector3 = (tx - pos)
        dirv.y = 0
        yaw = atan2(-dirv.x, -dirv.z) if dirv.length() > 1.0 else 0.0
    else:  # ship
        pos = home["pos"] + Vector3(0, 4.0, 0)
        yaw = home["yaw"]
    return [pos, yaw]


func _launch_strike(c: int, tb: Dictionary, n: int) -> int:
    var tx := Vector3(tb["x"], 0, tb["z"])
    var picks := _jets_launch_from(c, n, tx)
    var launched := 0
    for pk in picks:
        var home: Dictionary = pk[0]
        var j: Dictionary = pk[1]
        var py := _launch_pos_yaw(home, tx)
        var f: Variant = _spawn_flight(c, j["tier"], py[0], py[1], "strike", home, j)
        if f == null:
            break
        j["state"] = "out"
        f["tgt"] = tb
        f["tgt_c"] = tb["c"]
        f["dest"] = tx
        f["state"] = "takeoff"
        launched += 1
        if home.has("t") and home["t"] == "airbase":
            _refresh_airbase_parked(home)
    if launched > 0:
        _snd_at("jet", Vector3(tb["x"], 0, tb["z"]), 0.0)
        if c == me:
            _news(str(launched) + " " + _jet_name(c, 0).split(" ")[0] + "-class aircraft airborne towards " + String(COUNTRIES[tb["c"]]["short"]) + ".", "info")
    return launched


func _launch_sweep(c: int, tc: int, n: int) -> int:
    var tx := _land_center(tc)
    var picks := _jets_launch_from(c, n, tx)
    var launched := 0
    for pk in picks:
        var home: Dictionary = pk[0]
        var j: Dictionary = pk[1]
        var py := _launch_pos_yaw(home, tx)
        var f: Variant = _spawn_flight(c, j["tier"], py[0], py[1], "sweep", home, j)
        if f == null:
            break
        j["state"] = "out"
        f["tgt_c"] = tc
        f["dest"] = tx + Vector3(rng.randf_range(-60, 60), 0, rng.randf_range(-60, 60))
        launched += 1
        if home.has("t") and home["t"] == "airbase":
            _refresh_airbase_parked(home)
    if launched > 0 and c == me:
        _news("Fighter sweep of " + str(launched) + " jets heading for " + String(COUNTRIES[tc]["short"]) + " airspace.", "info")
    return launched


func _scramble(c: int, intruder: Dictionary, n: int) -> int:
    var tx: Vector3 = intruder["node"].position
    var picks := _jets_launch_from(c, n, tx)
    var launched := 0
    for pk in picks:
        var home: Dictionary = pk[0]
        var j: Dictionary = pk[1]
        var py := _launch_pos_yaw(home, tx)
        var f: Variant = _spawn_flight(c, j["tier"], py[0], py[1], "intercept", home, j)
        if f == null:
            break
        j["state"] = "out"
        f["chase"] = intruder["id"]
        launched += 1
        intruder["scr"] += 1
        if home.has("t") and home["t"] == "airbase":
            _refresh_airbase_parked(home)
    if launched > 0:
        _snd_at("siren", Vector3(tx.x, 0, tx.z), -6.0)
        if c == me or intruder["own"] == me:
            _news(String(COUNTRIES[c]["short"]) + " scrambled " + str(launched) + " fighters against intruders.", "warn" if c != me else "info")
    return launched


func _steer(f: Dictionary, tgt: Vector3, dt: float, rate: float = 1.4) -> float:
    var n: Node3D = f["node"]
    var d := tgt - n.position
    d.y = 0
    if d.length() < 0.5:
        return 0.0
    var want := atan2(-d.x, -d.z)
    var diff := wrapf(want - f["yaw"], -PI, PI)
    var step: float = clamp(diff, -rate * dt, rate * dt)
    f["yaw"] += step
    f["bank"] = lerp(f["bank"], clamp(step / max(dt, 0.001) * 0.5, -0.9, 0.9), min(1.0, dt * 6.0))
    return abs(diff)


func _move_flight(f: Dictionary, dt: float, spd_mult: float = 1.0) -> void:
    var n: Node3D = f["node"]
    var fwd := Vector3(-sin(f["yaw"]), 0, -cos(f["yaw"]))
    var spd: float = f["speed"] * spd_mult
    n.position += fwd * spd * dt
    var dy: float = clamp(f["alt"] - n.position.y, -22.0 * dt, 22.0 * dt)
    n.position.y += dy
    n.rotation.y = f["yaw"]
    n.rotation.x = lerp(n.rotation.x, clamp(dy / max(dt, 0.001) / spd * 1.5, -0.4, 0.4), min(1.0, dt * 4.0))
    n.rotation.z = -f["bank"]


func _remove_flight(f: Dictionary) -> void:
    f["dead"] = true
    if is_instance_valid(f["node"]):
        var tr = f["trail"]
        if is_instance_valid(tr):
            f["node"].remove_child(tr)
            add_child(tr)
            tr.global_position = f["node"].global_position
            tr.emitting = false
            _fx_add(tr, 3.0, "free")
        f["node"].queue_free()


func _kill_flight(f: Dictionary, by: int, why: String) -> void:
    if f["dead"] or f["state"] == "dying":
        return
    f["state"] = "dying"
    f["t"] = 0.0
    f["df"] = null
    var own: int = f["own"]
    cs[own]["jets_lost"] += 1
    if by >= 0:
        cs[by]["planes_down"] += 1
    # remove from inventory
    var home: Variant = f["home"]
    if f["ref"] != null and home is Dictionary:
        var lst: Array = home["jets"]
        lst.erase(f["ref"])
        if home.has("t"):
            _refresh_airbase_parked(home)
    if f["mission"] == "pm":
        cs[own]["pm_away"] = false
    if own == me or by == me:
        var nm := "PM aircraft" if f["mission"] == "pm" else _jet_name(own, f["tier"])
        _news(String(COUNTRIES[own]["short"]) + " " + nm + " shot down (" + why + ").", "good" if own != me else "bad")
    _snd_at("explode", f["node"].position, -4.0)
    if is_instance_valid(f["trail"]):
        f["trail"].lifetime = 3.0
        f["trail"].amount = 40


func _tracer(a: Vector3, b: Vector3, col: Color = Color(1.0, 0.85, 0.4)) -> void:
    var m := MeshInstance3D.new()
    var bm := BoxMesh.new()
    var d := b - a
    var l := d.length()
    bm.size = Vector3(0.35, 0.35, max(l, 0.5))
    m.mesh = bm
    var mt := StandardMaterial3D.new()
    mt.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mt.albedo_color = col
    m.material_override = mt
    m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(m)
    m.position = (a + b) * 0.5
    if l > 0.1:
        m.look_at(b, Vector3.UP)
    _fx_add(m, 0.22, "free")


func _start_dogfight(a: Dictionary, b: Dictionary) -> void:
    var center: Vector3 = (a["node"].position + b["node"].position) * 0.5
    var dur := rng.randf_range(5.0, 8.0)
    var ang := rng.randf() * TAU
    a["df"] = {"with": b["id"], "t": 0.0, "dur": dur, "c": center, "ang": ang, "lead": true, "tr": 0.0}
    b["df"] = {"with": a["id"], "t": 0.0, "dur": dur, "c": center, "ang": ang + PI, "lead": false, "tr": 0.0}
    a["prev_state"] = a["state"]
    b["prev_state"] = b["state"]
    a["state"] = "dogfight"
    b["state"] = "dogfight"
    if a["own"] == me or b["own"] == me:
        _news("DOGFIGHT over " + _where(center) + ": " + String(COUNTRIES[a["own"]]["short"]) + " vs " + String(COUNTRIES[b["own"]]["short"]) + "!", "warn")
        _snd("alarm")


func _where(p: Vector3) -> String:
    var c := _country_at(p.x, p.z, 120.0)
    if c >= 0:
        return String(COUNTRIES[c]["short"]) + " airspace"
    return "open sea"


func _dogfight_step(f: Dictionary, dt: float) -> void:
    var df: Dictionary = f["df"]
    var other: Variant = _flight_by_id(df["with"])
    if other == null or other["state"] == "dying":
        f["df"] = null
        f["state"] = f.get("prev_state", "return")
        if f["state"] == "dogfight":
            f["state"] = "return"
        return
    df["t"] += dt
    df["ang"] += (2.6 if df["lead"] else 2.6) * dt
    df["c"] += Vector3(-sin(f["yaw"]), 0, -cos(f["yaw"])) * 6.0 * dt * (1.0 if df["lead"] else 0.0)
    var r := 15.0
    var tgt: Vector3 = df["c"] + Vector3(cos(df["ang"]) * r, 0, sin(df["ang"]) * r)
    tgt.y = f["node"].position.y + (40.0 - f["node"].position.y) * 0.02
    var n: Node3D = f["node"]
    var old := n.position
    n.position = old.lerp(tgt, min(1.0, dt * 4.0))
    var mv := n.position - old
    if mv.length() > 0.01:
        f["yaw"] = atan2(-mv.x, -mv.z)
    f["bank"] = 0.9
    n.rotation.y = f["yaw"]
    n.rotation.z = -0.9
    df["tr"] += dt
    if df["tr"] > 0.28 and other != null:
        df["tr"] = 0.0
        _tracer(n.position, other["node"].position + Vector3(rng.randf_range(-2, 2), 0, rng.randf_range(-2, 2)))
        if rng.randf() < 0.3:
            _snd_at("gun", n.position, -10.0)
    if df["t"] >= df["dur"] and df["lead"]:
        _resolve_dogfight(f, other)


func _resolve_dogfight(a: Dictionary, b: Dictionary) -> void:
    var sa: float = float(JET_T[a["tier"]]["skill"]) * (1.0 - 0.4 * float(JET_T[b["tier"]]["evade"]))
    var sb: float = float(JET_T[b["tier"]]["skill"]) * (1.0 - 0.4 * float(JET_T[a["tier"]]["evade"]))
    var roll := rng.randf()
    var inter: bool = a["mission"] == "intercept"
    var w: Dictionary = a
    var l: Dictionary = b
    if rng.randf() < 0.14:
        # both disengage
        for f in [a, b]:
            f["df"] = null
            f["state"] = f.get("prev_state", "return")
            if f["state"] == "dogfight":
                f["state"] = "return"
            if f["mission"] == "strike":
                f["state"] = "return"
        return
    if roll > sa / (sa + sb):
        w = b
        l = a
    _kill_flight(l, w["own"], "dogfight")
    w["df"] = null
    w["state"] = w.get("prev_state", "return")
    if w["state"] == "dogfight":
        w["state"] = "return"
    if w["mission"] == "strike" and rng.randf() < 0.45:
        w["state"] = "return"


func _flight_update(f: Dictionary, dt: float) -> void:
    var n: Node3D = f["node"]
    f["t"] += dt
    var st: String = f["state"]
    match st:
        "takeoff":
            f["alt"] = 38.0
            var acc: float = clamp(f["t"] / 3.0, 0.15, 1.0)
            _move_flight(f, dt, acc)
            if f["t"] > 4.0:
                f["state"] = "scramble" if f["mission"] == "intercept" else "ingress"
                if f["mission"] == "pm":
                    f["state"] = "ingress"
        "ingress":
            var dest: Vector3 = f["dest"]
            if f["mission"] == "strike" and f["tgt"] != null and f["tgt"]["st"] != "ruin":
                dest = Vector3(f["tgt"]["x"], 0, f["tgt"]["z"])
            f["alt"] = 45.0 if f["mission"] != "pm" else 55.0
            _steer(f, dest, dt)
            _move_flight(f, dt)
            var d := _dist2(n.position, dest)
            if f["mission"] == "strike" and d < 85.0:
                f["state"] = "attack"
                f["t"] = 0.0
                f["fire_t"] = 0.0
            elif f["mission"] == "sweep" and d < 40.0:
                f["state"] = "loiter"
                f["loiter"] = 28.0
            elif f["mission"] == "pm" and d < 60.0:
                f["state"] = "land_pm"
        "attack":
            f["alt"] = 30.0
            var tb: Variant = f["tgt"]
            if tb == null or tb["st"] == "ruin":
                tb = _retarget(f)
                f["tgt"] = tb
            if tb == null:
                f["state"] = "return"
            else:
                _steer(f, Vector3(tb["x"], 0, tb["z"]), dt, 2.0)
                _move_flight(f, dt)
                f["fire_t"] = f.get("fire_t", 0.0) + dt
                if f["ammo"] > 0 and f["fire_t"] > 0.5:
                    f["fire_t"] = 0.0
                    f["ammo"] -= 1
                    _spawn_jet_missile(f, tb)
                if f["ammo"] <= 0 and f["t"] > 1.5:
                    f["state"] = "return"
        "loiter":
            f["alt"] = 45.0
            var dest2: Vector3 = f["dest"]
            f["loiter"] -= dt
            var center := _land_center(f["tgt_c"])
            var ang = f["t"] * 0.5
            var wp := center + Vector3(cos(ang), 0, sin(ang)) * 130.0
            _steer(f, wp, dt)
            _move_flight(f, dt)
            f["aa_cd"] -= dt
            if f["aa_cd"] <= 0.0:
                f["aa_cd"] = 1.5
                var e = _nearest_enemy_flight(f, 260.0)
                if e != null:
                    f["chase"] = e["id"]
                    f["state"] = "scramble"
            if f["loiter"] <= 0.0:
                f["state"] = "return"
        "scramble":
            f["alt"] = 40.0
            var tgt: Variant = _flight_by_id(f["chase"])
            if tgt == null or tgt["state"] == "dying":
                var e2: Variant = null
                if f["mission"] != "intercept" or true:
                    e2 = _nearest_enemy_flight(f, 300.0 if f["mission"] != "intercept" else 600.0)
                if e2 != null:
                    f["chase"] = e2["id"]
                    tgt = e2
                else:
                    f["state"] = "loiter" if f["mission"] == "sweep" else "return"
                    return
            # pursuit with lead
            var tp: Vector3 = tgt["node"].position
            var aim: Vector3 = tp + Vector3(-sin(tgt["yaw"]), 0, -cos(tgt["yaw"])) * tgt["speed"] * 0.6
            _steer(f, aim, dt, 1.8)
            _move_flight(f, dt, 1.15)
            if _dist2(n.position, tp) < 34.0 and tgt["state"] != "dogfight" and f["state"] == "scramble" and abs(n.position.y - tp.y) < 25.0:
                _start_dogfight(f, tgt)
        "dogfight":
            _dogfight_step(f, dt)
        "return":
            f["alt"] = 45.0
            var hp := _home_pos(f)
            if f["home"] is Dictionary and not is_instance_valid(f["home"].get("node", null)):
                _remove_flight(f)
                return
            if f["home"] is Dictionary and f["home"].has("st") and f["home"]["st"] == "ruin":
                var alt_home: Variant = _any_base(f["own"], n.position)
                if alt_home == null:
                    _remove_flight(f)
                    return
                f["home"] = alt_home
            _steer(f, hp, dt)
            _move_flight(f, dt)
            if _dist2(n.position, hp) < 120.0:
                f["state"] = "land"
        "land":
            var hp2 := _home_pos(f)
            f["alt"] = 2.0
            var d2 := _dist2(n.position, hp2)
            _steer(f, hp2, dt, 2.0)
            _move_flight(f, dt, clamp(d2 / 120.0, 0.35, 1.0))
            if d2 < 14.0 or n.position.y < 2.5 and d2 < 40.0:
                _land_flight(f)
        "land_pm":
            f["alt"] = 4.0
            _steer(f, f["dest"], dt, 2.0)
            _move_flight(f, dt, 0.5)
            if _dist2(n.position, f["dest"]) < 22.0:
                _pm_arrived(f)
        "dying":
            n.position.y -= dt * (20.0 + f["t"] * 25.0)
            n.position += Vector3(-sin(f["yaw"]), 0, -cos(f["yaw"])) * 25.0 * dt
            n.rotation.z += dt * 5.0
            n.rotation.x -= dt * 1.2
            if n.position.y <= 0.5:
                _fx_explosion(Vector3(n.position.x, 1.0, n.position.z), 12.0, false)
                _remove_flight(f)


func _any_base(c: int, from: Vector3) -> Variant:
    var best: Variant = null
    var bd := 1e9
    for b in cs[c]["bl"]:
        if b["t"] == "airbase" and b["st"] == "ok":
            var d := _dist2(from, Vector3(b["x"], 0, b["z"]))
            if d < bd:
                bd = d
                best = b
    for sh in ships:
        if sh["own"] == c and sh["k"] == 4:
            var d2 := _dist2(from, sh["pos"])
            if d2 < bd:
                bd = d2
                best = sh
    return best


func _land_flight(f: Dictionary) -> void:
    var j: Variant = f["ref"]
    var home: Variant = f["home"]
    if j != null and home is Dictionary and home["jets"].has(j):
        j["state"] = "rearm"
        j["t"] = 16.0
    elif j != null and home is Dictionary:
        j["state"] = "rearm"
        j["t"] = 16.0
        home["jets"].append(j)
    _remove_flight(f)


func _retarget(f: Dictionary) -> Variant:
    var tc: int = f["tgt_c"]
    if tc < 0:
        return null
    var best: Variant = null
    var bd := 1e9
    var np: Vector3 = f["node"].position
    for b in cs[tc]["bl"]:
        if b["st"] == "ruin":
            continue
        var d := _dist2(np, Vector3(b["x"], 0, b["z"]))
        if d < bd and d < 140.0:
            bd = d
            best = b
    return best


func _nearest_enemy_flight(f: Dictionary, r: float) -> Variant:
    var best: Variant = null
    var bd := r
    for g in flights:
        if g["dead"] or g["state"] == "dying" or g["own"] == f["own"]:
            continue
        if not _at_war(f["own"], g["own"]):
            continue
        if g["mission"] == "pm":
            continue
        var d := _dist2(f["node"].position, g["node"].position)
        if d < bd:
            bd = d
            best = g
    return best


func _spawn_jet_missile(f: Dictionary, tb: Dictionary) -> void:
    if projs.size() >= MAX_PROJ:
        return
    var from: Vector3 = f["node"].position
    var to := Vector3(tb["x"] + rng.randf_range(-3, 3), 2.0, tb["z"] + rng.randf_range(-3, 3))
    var node := Node3D.new()
    var mb := MB.new()
    _m_missile_unit(mb, 1, false)
    var mi := MeshInstance3D.new()
    mi.mesh = mb.bake(mats)
    mi.scale = Vector3.ONE * 0.9
    node.add_child(mi)
    node.position = from
    add_child(node)
    var mk := _marker(Color(1.0, 0.8, 0.3), 0.45)
    node.add_child(mk)
    projs.append({"kind": "jmsl", "own": f["own"], "node": node, "mk": mk, "from": from, "to": to, "t": 0.0, "len": from.distance_to(to),
        "speed": 210.0, "dmg": float(JET_T[f["tier"]]["dmg"]), "tb": tb, "trail": null, "dead": false})
    _snd_at("launch", from, -8.0)


# =====================================================================
#  STRATEGIC MISSILES
# =====================================================================
func _msl_mesh(k: int) -> ArrayMesh:
    var key := "msl_" + str(k)
    if mesh_cache.has(key):
        return mesh_cache[key]
    var mb := MB.new()
    _m_missile_unit(mb, k, MSL[k]["nuke"])
    var m := mb.bake(mats)
    mesh_cache[key] = m
    return m


func _trail_node(big: bool) -> CPUParticles3D:
    _fx_mats()
    var tr := CPUParticles3D.new()
    tr.amount = 40 if big else 28
    tr.lifetime = 3.2
    tr.local_coords = false
    tr.direction = Vector3(0, 0, 1)
    tr.spread = 6.0
    tr.initial_velocity_min = 0.2
    tr.initial_velocity_max = 1.0
    tr.scale_amount_min = 1.0
    tr.scale_amount_max = 2.0 if big else 1.4
    var grad := Gradient.new()
    grad.set_color(0, Color(1.0, 0.85, 0.6, 0.85))
    grad.set_color(1, Color(0.8, 0.8, 0.8, 0.0))
    tr.color_ramp = grad
    var pm := SphereMesh.new()
    pm.radius = 0.8
    pm.height = 1.6
    pm.radial_segments = 5
    pm.rings = 3
    tr.mesh = pm
    tr.material_override = smoke_mat
    tr.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    return tr


func _launch_missile(own: int, k: int, from: Vector3, tb_pos: Vector3, tb: Variant, dmg_scale: float = 1.0, tgt_c: int = -1) -> bool:
    if projs.size() >= MAX_PROJ:
        return false
    var md: Dictionary = MSL[k]
    var node := Node3D.new()
    var mi := MeshInstance3D.new()
    mi.mesh = _msl_mesh(k)
    mi.scale = Vector3.ONE * (1.6 if k >= 2 else 1.3)
    node.add_child(mi)
    var big := k >= 2
    var tr := _trail_node(big)
    tr.position = Vector3(0, 0, 8.0)
    node.add_child(tr)
    var mk := _marker(Color(1.0, 0.35, 0.2) if not md["nuke"] else Color(1.0, 0.0, 0.0), 1.0 if k < 4 else 1.7)
    node.add_child(mk)
    node.position = from
    add_child(node)
    var to := Vector3(tb_pos.x + rng.randf_range(-4, 4), 1.0, tb_pos.z + rng.randf_range(-4, 4))
    var len := _dist2(from, to)
    var spd: float = float(md["speed"])
    var apex: float = min(len * float(md["apex"]) + 25.0, 900.0)
    projs.append({"kind": "msl", "own": own, "k": k, "node": node, "mk": mk, "trail": tr, "from": Vector3(from.x, 3.0, from.z), "to": to, "t": 0.0,
        "len": max(len, 10.0), "speed": spd, "apex": apex, "dmg": float(md["dmg"]) * dmg_scale, "rad": float(md["rad"]), "nuke": md["nuke"],
        "tb": tb, "tgt_c": tgt_c if tgt_c >= 0 else _country_at(to.x, to.z, 20.0), "rolled": {}, "doomed": false, "kill_t": 0.0, "dead": false})
    _snd_at("launch", from, 0.0)
    var cvic: int = projs[projs.size() - 1]["tgt_c"]
    if cvic >= 0:
        _note_attack(own, cvic, md["nuke"], true)
    return true


func _missile_origins(c: int, k: int, tx: Vector3) -> Array:
    var out := []
    var rng_k: float = float(MSL[k]["range"])
    for b in cs[c]["bl"]:
        if b["t"] == "missilebase" and b["st"] == "ok":
            var d := _dist2(Vector3(b["x"], 0, b["z"]), tx)
            if d <= rng_k:
                out.append(b)
    return out


func _ammo_cap(c: int) -> int:
    var cap := 0
    for b in cs[c]["bl"]:
        if b["t"] == "missilebase" and b["st"] == "ok":
            cap += 30 * b["lvl"]
    return cap


func _ammo_total(c: int) -> int:
    var s := 0
    for a in cs[c]["ammo"]:
        s += int(a)
    return s


func _fire_salvo(c: int, k: int, n: int, tb: Dictionary) -> int:
    var tx := Vector3(tb["x"], 0, tb["z"])
    var origins := _missile_origins(c, k, tx)
    if origins.is_empty():
        return 0
    var fired := 0
    var have: int = cs[c]["ammo"][k]
    n = min(n, have)
    for i in range(n):
        var ob: Dictionary = origins[i % origins.size()]
        var from := Vector3(ob["x"] + rng.randf_range(-8, 8), 2.0, ob["z"] + rng.randf_range(-8, 8))
        # stagger launches slightly via queue time
        var ok := _launch_missile(c, k, from, tx, tb, 1.0, tb["c"])
        if ok:
            cs[c]["ammo"][k] -= 1
            fired += 1
            if projs.size() > 0:
                projs[projs.size() - 1]["t"] = -float(i) * 0.02
    if fired > 0 and c == me:
        _news("Launched " + str(fired) + " x " + _msl_name(c, k) + " at " + String(COUNTRIES[tb["c"]]["short"]) + ".", "info")
    return fired


func _aa_sources() -> Array:
    var out := []
    for c in range(9):
        for b in cs[c]["bl"]:
            if b["st"] == "ok" and _is_aa(b):
                var k := _aa_tier(b)
                out.append({"pos": Vector3(b["x"], 0, b["z"]), "r": AA_RANGE[k], "tier": k, "own": c, "b": b, "ship": null})
        for sh in ships:
            if sh["own"] == c:
                var tk := 0
                match int(sh["k"]):
                    0: tk = 0
                    1: tk = 1
                    2: tk = 3
                    4: tk = 2
                    _: tk = -1
                if tk >= 0:
                    out.append({"pos": sh["pos"], "r": AA_RANGE[tk] * 0.7, "tier": tk, "own": c, "b": null, "ship": sh})
    return out


var aa_cache: Array = []
var aa_cache_t := 0.0

func _radar_near(c: int, p: Vector3) -> bool:
    for b in cs[c]["bl"]:
        if b["t"] == "radar" and b["st"] == "ok" and _dist2(Vector3(b["x"], 0, b["z"]), p) < 320.0:
            return true
    return false


func _spawn_interceptor(from: Vector3, to: Vector3, life: float) -> void:
    if projs.size() >= MAX_PROJ:
        return
    var node := Node3D.new()
    var mb := MB.new()
    _m_interceptor(mb)
    var mi := MeshInstance3D.new()
    mi.mesh = mb.bake(mats)
    mi.scale = Vector3.ONE * 2.0
    node.add_child(mi)
    var tr := _trail_node(false)
    tr.position = Vector3(0, 0, 2.0)
    node.add_child(tr)
    var mk := _marker(Color(0.4, 0.8, 1.0), 0.5)
    node.add_child(mk)
    node.position = from + Vector3(0, 2, 0)
    add_child(node)
    projs.append({"kind": "int", "own": -1, "node": node, "mk": mk, "trail": tr, "from": from + Vector3(0, 2, 0), "to": to, "t": 0.0,
        "len": max(from.distance_to(to), 5.0), "speed": max(from.distance_to(to) / max(life, 0.3), 40.0), "dead": false, "tb": null})
    _snd_at("launch", from, -10.0)


func _aa_missiles_step(dt: float) -> void:
    for p in projs:
        if p["dead"] or p["kind"] != "msl" or p["doomed"] or p["t"] < 0.0 or p["t"] > 0.97:
            continue
        var pos: Vector3 = p["node"].position
        for a in aa_cache:
            if a["own"] == p["own"] or not (_at_war(a["own"], p["own"]) or (p["tgt_c"] == a["own"] and not _allied(a["own"], p["own"]))):
                continue
            if _dist2(a["pos"], pos) > a["r"]:
                continue
            var key := str(a["b"]["id"]) if a["b"] != null else "s" + str(a["ship"]["id"])
            if p["rolled"].has(key):
                continue
            p["rolled"][key] = true
            var prob: float = DEF_TABLE[a["tier"]][p["k"]]
            if _radar_near(a["own"], a["pos"]):
                prob *= 1.12
            if cs[a["own"]]["tech"].has("sat"):
                prob *= 1.05
            if a["ship"] != null:
                prob *= 0.8
            # missile on the way to impact: interceptor leaves AA site towards a point ahead
            var ahead: float = min(0.97, p["t"] + 0.08)
            var ipos := _msl_pos(p, ahead)
            var life: float = 1.2 + a["pos"].distance_to(ipos) / 260.0
            _spawn_interceptor(a["pos"], ipos, life)
            if rng.randf() < prob:
                p["doomed"] = true
                p["kill_t"] = min(0.97, p["t"] + (life * p["speed"]) / p["len"])
                p["kill_by"] = a["own"]
                break


func _msl_pos(p: Dictionary, t: float) -> Vector3:
    var a: Vector3 = p["from"]
    var b: Vector3 = p["to"]
    var pos := a.lerp(b, t)
    pos.y = lerp(a.y, b.y, t) + p["apex"] * 4.0 * t * (1.0 - t)
    return pos


func _projs_update(dt: float) -> void:
    for p in projs:
        if p["dead"]:
            continue
        var node: Node3D = p["node"]
        match p["kind"]:
            "msl":
                if p["t"] < 0.0:
                    p["t"] += dt
                    node.visible = false
                    continue
                node.visible = true
                var prev: Vector3 = node.position
                p["t"] += p["speed"] * dt / p["len"]
                var t: float = min(p["t"], 1.0)
                node.position = _msl_pos(p, t)
                var dv: Vector3 = node.position - prev
                if dv.length() > 0.01:
                    node.look_at(node.position + dv, Vector3.UP)
                if p["doomed"] and p["t"] >= p["kill_t"]:
                    _fx_explosion(node.position, 10.0, false)
                    _msl_note_intercept(p)
                    _end_proj(p)
                elif p["t"] >= 1.0:
                    _missile_impact(p)
                    _end_proj(p)
            "jmsl":
                p["t"] += p["speed"] * dt / p["len"]
                var t2: float = min(p["t"], 1.0)
                var pos: Vector3 = p["from"].lerp(p["to"], t2)
                var prev2: Vector3 = node.position
                node.position = pos
                var dv2: Vector3 = pos - prev2
                if dv2.length() > 0.01:
                    node.look_at(pos + dv2, Vector3.UP)
                if p["t"] >= 1.0:
                    var tb: Variant = p["tb"]
                    _explode_at(Vector3(p["to"].x, 1.0, p["to"].z), 9.0, p["dmg"], p["own"], 9.0)
                    _end_proj(p)
            "int":
                p["t"] += p["speed"] * dt / p["len"]
                var t3: float = min(p["t"], 1.0)
                var pos3: Vector3 = p["from"].lerp(p["to"], t3)
                var pv: Vector3 = node.position
                node.position = pos3
                var d3: Vector3 = pos3 - pv
                if d3.length() > 0.01:
                    node.look_at(pos3 + d3, Vector3.UP)
                if p["t"] >= 1.0:
                    _fx_explosion(pos3, 5.0, false)
                    _end_proj(p)
            "sam":
                var tg: Variant = _flight_by_id(p["fid"])
                p["t"] += dt
                var to: Vector3 = p["to"]
                if tg != null:
                    to = tg["node"].position
                var d4 := to - node.position
                var step: float = p["speed"] * dt
                if d4.length() <= step + 3.0 or p["t"] > p["life"]:
                    if tg != null and p["hit"] and tg["state"] != "dying":
                        _fx_explosion(tg["node"].position, 9.0, false)
                        _kill_flight(tg, p["own"], "air defence")
                    else:
                        _fx_explosion(node.position, 4.0, false)
                    _end_proj(p)
                else:
                    node.position += d4.normalized() * step
                    node.look_at(node.position + d4, Vector3.UP)
            "shell":
                p["t"] += p["speed"] * dt / p["len"]
                var t5: float = min(p["t"], 1.0)
                var ps: Vector3 = p["from"].lerp(p["to"], t5)
                ps.y += sin(t5 * PI) * 8.0
                node.position = ps
                if p["t"] >= 1.0:
                    _explode_at(Vector3(p["to"].x, 1.0, p["to"].z), 5.0, p["dmg"], p["own"], 6.0, p.get("ship_t", -1))
                    _end_proj(p)
            "torp":
                p["t"] += p["speed"] * dt / p["len"]
                var t6: float = min(p["t"], 1.0)
                node.position = p["from"].lerp(p["to"], t6)
                if p["t"] >= 1.0:
                    _explode_at(Vector3(p["to"].x, 0.5, p["to"].z), 8.0, p["dmg"], p["own"], 10.0, p.get("ship_t", -1))
                    _end_proj(p)
    var keep := []
    for p in projs:
        if not p["dead"]:
            keep.append(p)
    projs = keep


func _msl_note_intercept(p: Dictionary) -> void:
    var by: int = p.get("kill_by", -1)
    if p["own"] == me or by == me or p["tgt_c"] == me:
        _news(_msl_name(p["own"], p["k"]) + " from " + String(COUNTRIES[p["own"]]["short"]) + " was intercepted!", "good" if p["own"] != me else "bad")
    _snd_at("explode", p["node"].position, -6.0)


func _end_proj(p: Dictionary) -> void:
    p["dead"] = true
    if is_instance_valid(p["node"]):
        var tr = p.get("trail", null)
        if tr != null and is_instance_valid(tr):
            p["node"].remove_child(tr)
            add_child(tr)
            tr.global_position = p["node"].global_position
            tr.emitting = false
            _fx_add(tr, 3.2, "free")
        p["node"].queue_free()


func _missile_impact(p: Dictionary) -> void:
    var pos := Vector3(p["to"].x, 1.0, p["to"].z)
    if p["nuke"]:
        _nuke_explode(pos, p["own"])
    else:
        _explode_at(pos, p["rad"], p["dmg"], p["own"], p["rad"])


func _explode_at(pos: Vector3, rad: float, dmg: float, attacker: int, vis_r: float, ship_t: int = -1) -> void:
    _fx_explosion(pos, vis_r, false)
    # damage buildings
    var ci := _country_at(pos.x, pos.z, 12.0)
    if ci >= 0:
        var hits := []
        for b in cs[ci]["bl"]:
            if b["st"] == "ruin":
                continue
            var h := _fp_half(b["t"], b["r"], ci)
            var dx: float = max(abs(pos.x - b["x"]) - h.x, 0.0)
            var dz: float = max(abs(pos.z - b["z"]) - h.y, 0.0)
            var d: float = sqrt(dx * dx + dz * dz)
            if d <= rad:
                hits.append([b, dmg * (1.0 - 0.6 * d / max(rad, 1.0))])
        for h in hits:
            _damage_building(h[0], h[1], attacker)
        if hits.size() > 0 and attacker >= 0:
            _note_attack(attacker, ci, false, false)
    # damage ships
    for s in ships:
        if s["own"] != attacker and not s["dead"]:
            if _dist2(pos, s["pos"]) < rad + float(SHIPS[s["k"]]["len"]) * 0.5:
                _damage_ship(s, dmg * 0.8, attacker)


func _nuke_explode(pos: Vector3, attacker: int) -> void:
    _fx_nuke(pos)
    var ci := _country_at(pos.x, pos.z, 20.0)
    var rad := 105.0
    var killed := 0
    if ci >= 0:
        var list := []
        for b in cs[ci]["bl"]:
            if b["st"] == "ruin":
                continue
            var d := _dist2(pos, Vector3(b["x"], 0, b["z"]))
            if d <= rad:
                list.append([b, d])
        for e in list:
            var b: Dictionary = e[0]
            var d2: float = e[1]
            if d2 < rad * 0.6:
                _damage_building(b, 99999.0, attacker)
                killed += 1
            else:
                _damage_building(b, b["mhp"] * 0.7, attacker)
        var pl: float = cs[ci]["pop"] * (0.015 + 0.002 * float(killed))
        cs[ci]["pop"] = max(0.5, cs[ci]["pop"] - pl)
        cs[ci]["casual"] += pl * 100.0
        cs[ci]["happy"] = max(0.0, cs[ci]["happy"] - 18.0)
        _news("NUCLEAR EXPLOSION in " + String(COUNTRIES[ci]["name"]) + "! Approximately " + String.num(pl, 1) + " million casualties.", "bad")
        _note_attack(attacker, ci, true, false)
    for s in ships:
        if not s["dead"] and _dist2(pos, s["pos"]) < rad:
            _damage_ship(s, 99999.0, attacker)
    for f in flights:
        if not f["dead"] and _dist2(pos, f["node"].position) < rad * 1.2:
            _kill_flight(f, attacker, "nuclear blast")



# =====================================================================
#  SHIPS
# =====================================================================
func _ship_mesh(k: int, own: int) -> ArrayMesh:
    var key := "ship_" + str(k) + "_" + str(own)
    if mesh_cache.has(key):
        return mesh_cache[key]
    var mb := MB.new()
    var col := Color(0.42, 0.46, 0.5)
    _m_ship(mb, String(SHIPS[k]["id"]), col, COUNTRIES[own]["col"])
    var m := mb.bake(mats)
    mesh_cache[key] = m
    return m


func _ship_cap(c: int) -> int:
    var cap := 0
    for b in cs[c]["bl"]:
        if b["t"] == "port" and b["st"] == "ok":
            cap += 8 * b["lvl"]
    return cap


func _ship_count(c: int) -> int:
    var n := 0
    for s in ships:
        if s["own"] == c and not s["dead"]:
            n += 1
    return n


func _port_spawn(port: Dictionary) -> Vector3:
    var c: int = port["c"]
    var p: Vector2 = COUNTRIES[c]["pos"]
    var rr: int = port["r"] % 4
    var lat := 0.0
    var out := Vector3.ZERO
    var lx: float = port["x"] - p.x
    var lz: float = port["z"] - p.y
    match rr:
        0:
            out = Vector3(lx + rng.randf_range(-6, 6), 0, p.y + LAND + 48.0)
        1:
            out = Vector3(p.x + LAND + 48.0, 0, port["z"] + rng.randf_range(-6, 6))
        2:
            out = Vector3(lx + rng.randf_range(-6, 6) + p.x - lx + lx, 0, p.y - LAND - 48.0)
        _:
            out = Vector3(p.x - LAND - 48.0, 0, port["z"] + rng.randf_range(-6, 6))
    if rr == 0 or rr == 2:
        out.x = port["x"] + rng.randf_range(-6, 6)
    return out


func _spawn_ship(own: int, k: int, at: Vector3, yaw: float = 0.0) -> Variant:
    if ships.size() >= MAX_SHIPS:
        return null
    var sd: Dictionary = SHIPS[k]
    var node := Node3D.new()
    node.position = at
    var mi := MeshInstance3D.new()
    mi.mesh = _ship_mesh(k, own)
    mi.name = "hull"
    node.add_child(mi)
    var mk := _marker(COUNTRIES[own]["col"].lightened(0.25), 1.1 if k < 4 else 1.6)
    node.add_child(mk)
    var wake := CPUParticles3D.new()
    wake.amount = 24
    wake.lifetime = 3.0
    wake.local_coords = false
    wake.direction = Vector3(0, 0, 1)
    wake.spread = 12.0
    wake.initial_velocity_min = 0.5
    wake.initial_velocity_max = 2.0
    wake.scale_amount_min = 1.0
    wake.scale_amount_max = 2.0
    var grad := Gradient.new()
    grad.set_color(0, Color(1, 1, 1, 0.7))
    grad.set_color(1, Color(0.8, 0.9, 1, 0.0))
    wake.color_ramp = grad
    var pm := SphereMesh.new()
    pm.radius = 1.0
    pm.height = 0.5
    pm.radial_segments = 6
    pm.rings = 2
    wake.mesh = pm
    _fx_mats()
    wake.material_override = smoke_mat
    wake.position = Vector3(0, 0.2, float(sd["len"]) * 0.45)
    wake.visibility_range_end = 900.0
    wake.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    node.add_child(wake)
    add_child(node)
    var s := {"id": uid_counter, "own": own, "k": k, "node": node, "mk": mk, "wake": wake, "pos": at, "yaw": yaw, "hp": float(sd["hp"]), "mhp": float(sd["hp"]),
        "wp": [], "cd": rng.randf_range(0.5, 3.0), "jets": [], "dead": false, "sink": 0.0, "aacd": 0.0, "speed_cur": 0.0, "stance": "attack", "t": 0.0}
    uid_counter += 1
    node.rotation.y = yaw
    if k == 4:
        for q in range(8):
            s["jets"].append({"tier": min(3, 1 + (q % 3)), "state": "ready", "t": 0.0})
    ships.append(s)
    return s


func _order_ship_to(id: int, g: Vector3) -> void:
    for s in ships:
        if s["id"] == id and not s["dead"]:
            if _country_at(g.x, g.z, 8.0) >= 0:
                _toast("Ships can only sail on water", "warn")
                return
            s["wp"] = _sea_path(s["pos"], g)
            _snd("click")
            return


func _damage_ship(s: Dictionary, dmg: float, attacker: int) -> void:
    if s["dead"]:
        return
    s["hp"] -= dmg
    if attacker >= 0:
        cs[attacker]["dmg_dealt"] += dmg * 0.5
    if s["hp"] <= 0.0:
        s["dead"] = true
        s["sink"] = 0.01
        cs[s["own"]]["ships_lost"] += 1
        _fx_explosion(s["node"].position + Vector3(0, 4, 0), 16.0, false)
        if s["own"] == me or attacker == me:
            _news(String(COUNTRIES[s["own"]]["short"]) + " " + String(SHIPS[s["k"]]["name"]) + " sunk!", "good" if s["own"] != me else "bad")
        if s["k"] == 4:
            for j in s["jets"]:
                cs[s["own"]]["jets_lost"] += 1
            s["jets"] = []
            for f in flights:
                if f["home"] is Dictionary and f["home"] == s:
                    f["home"] = {}


func _ship_steer(s: Dictionary, dt: float) -> void:
    var sd: Dictionary = SHIPS[s["k"]]
    var n: Node3D = s["node"]
    var moving: bool = s["wp"].size() > 0
    if moving:
        var wpv: Vector3 = s["wp"][0]
        var d = wpv - s["pos"]
        d.y = 0
        if d.length() < 10.0:
            s["wp"].pop_front()
        else:
            var want := atan2(-d.x, -d.z)
            var diff := wrapf(want - s["yaw"], -PI, PI)
            s["yaw"] += clamp(diff, -0.45 * dt, 0.45 * dt)
            s["speed_cur"] = min(float(sd["speed"]), s["speed_cur"] + 6.0 * dt)
    else:
        s["speed_cur"] = max(0.0, s["speed_cur"] - 5.0 * dt)
    if s["speed_cur"] > 0.05:
        var fwd := Vector3(-sin(s["yaw"]), 0, -cos(s["yaw"]))
        var np: Vector3 = s["pos"] + fwd * s["speed_cur"] * dt
        # never sail over land
        var land := _country_at(np.x, np.z, 8.0)
        if land >= 0:
            s["wp"] = []
            s["speed_cur"] = 0.0
        else:
            s["pos"] = np
    s["t"] += dt
    var y := sin(s["t"] * 1.3 + float(s["id"])) * 0.25
    if s["k"] == 3:
        y = -1.8
    n.position = Vector3(s["pos"].x, y, s["pos"].z)
    n.rotation.y = s["yaw"]
    n.rotation.z = sin(s["t"] * 0.9 + float(s["id"])) * 0.03
    s["wake"].emitting = s["speed_cur"] > 1.0 and s["k"] != 3


func _ship_combat(s: Dictionary, dt: float) -> void:
    var sd: Dictionary = SHIPS[s["k"]]
    if s["k"] == 4 or float(sd["rng"]) <= 0.0:
        return
    s["cd"] -= dt
    if s["cd"] > 0.0:
        return
    var own: int = s["own"]
    var rng_: float = float(sd["rng"])
    # enemy ships first
    var best: Variant = null
    var bd := 1e9
    for o in ships:
        if o["dead"] or o["own"] == own or not _at_war(own, o["own"]):
            continue
        var d := _dist2(s["pos"], o["pos"])
        var lim: float = rng_ if s["k"] >= 2 else rng_
        if s["k"] == 2:
            lim = 110.0
        if s["k"] == 3:
            lim = 130.0
        if d < lim and d < bd:
            bd = d
            best = o
    if best != null:
        s["cd"] = float(sd["interval"]) * rng.randf_range(0.8, 1.2)
        if s["k"] == 3:
            _spawn_torp(s, best)
        else:
            _spawn_shell(s, best["pos"], best["id"])
        return
    # coastal targets
    var tb: Variant = null
    var bd2 := 1e9
    var gun_r := rng_ if s["k"] <= 1 else 95.0
    for c in range(9):
        if c == own or not _at_war(own, c):
            continue
        var pcen := _land_center(c)
        if _dist2(s["pos"], pcen) > LAND + rng_ + 40.0:
            continue
        for b in cs[c]["bl"]:
            if b["st"] == "ruin":
                continue
            var d2 := _dist2(s["pos"], Vector3(b["x"], 0, b["z"]))
            var pri := 0.0
            match String(b["t"]):
                "airbase": pri = -60.0
                "missilebase": pri = -60.0
                "port": pri = -40.0
                "parliament": pri = -20.0
                _:
                    if _is_aa(b):
                        pri = -80.0
            if d2 + pri < bd2 and d2 <= rng_:
                bd2 = d2 + pri
                tb = b
    if tb != null:
        var dd := _dist2(s["pos"], Vector3(tb["x"], 0, tb["z"]))
        s["cd"] = float(sd["interval"]) * rng.randf_range(0.9, 1.3)
        if s["k"] >= 2 and dd > 100.0:
            _launch_missile(own, 0, s["pos"] + Vector3(0, 6, 0), Vector3(tb["x"], 0, tb["z"]), tb, 0.8, tb["c"])
        else:
            _spawn_shell(s, Vector3(tb["x"], 0, tb["z"]), -1)
    else:
        s["cd"] = 1.0


func _spawn_shell(s: Dictionary, to: Vector3, ship_t: int) -> void:
    if projs.size() >= MAX_PROJ:
        return
    var node := Node3D.new()
    var m := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 0.5
    sm.height = 1.0
    sm.radial_segments = 5
    sm.rings = 3
    m.mesh = sm
    var mt := StandardMaterial3D.new()
    mt.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mt.albedo_color = Color(1.0, 0.8, 0.3)
    m.material_override = mt
    node.add_child(m)
    var mk := _marker(Color(1, 0.85, 0.3), 0.25)
    node.add_child(mk)
    var from: Vector3 = s["pos"] + Vector3(0, 6, 0)
    node.position = from
    add_child(node)
    var dmg: float = float(SHIPS[s["k"]]["dmg"])
    projs.append({"kind": "shell", "own": s["own"], "node": node, "mk": mk, "from": from, "to": Vector3(to.x + rng.randf_range(-3, 3), 1.0, to.z + rng.randf_range(-3, 3)),
        "t": 0.0, "len": max(from.distance_to(to), 5.0), "speed": 160.0, "dmg": dmg, "dead": false, "ship_t": ship_t, "tb": null})
    _snd_at("gun", from, -4.0)


func _spawn_torp(s: Dictionary, target: Dictionary) -> void:
    if projs.size() >= MAX_PROJ:
        return
    var node := Node3D.new()
    var m := MeshInstance3D.new()
    var cm := CylinderMesh.new()
    cm.top_radius = 0.3
    cm.bottom_radius = 0.3
    cm.height = 4.0
    m.mesh = cm
    m.rotation.x = PI * 0.5
    var mt := StandardMaterial3D.new()
    mt.albedo_color = Color(0.2, 0.2, 0.22)
    m.material_override = mt
    node.add_child(m)
    var mk := _marker(Color(0.8, 0.9, 1.0), 0.25)
    node.add_child(mk)
    var from: Vector3 = s["pos"] + Vector3(0, -1.0, 0)
    node.position = from
    add_child(node)
    projs.append({"kind": "torp", "own": s["own"], "node": node, "mk": mk, "from": from, "to": target["pos"] + Vector3(0, -1.0, 0), "t": 0.0,
        "len": max(from.distance_to(target["pos"]), 5.0), "speed": 42.0, "dmg": float(SHIPS[s["k"]]["dmg"]) * 1.4, "dead": false, "ship_t": target["id"], "tb": null})


func _ships_update(dt: float) -> void:
    for s in ships:
        if s["dead"]:
            s["sink"] += dt
            var n: Node3D = s["node"]
            n.position.y -= dt * 2.2
            n.rotation.z += dt * 0.25
            n.rotation.x += dt * 0.06
            s["wake"].emitting = false
            if s["sink"] > 7.0:
                n.queue_free()
            continue
        _ship_steer(s, dt)
        _ship_combat(s, dt)
    var keep := []
    for s in ships:
        if not (s["dead"] and s["sink"] > 7.0):
            keep.append(s)
    ships = keep


# =====================================================================
#  AIR DEFENCE vs AIRCRAFT, AIRSPACE, ALERTS
# =====================================================================
var aa_t := 0.0
var air_t := 0.0
var alert_cd := {"air": 0.0, "msl": 0.0, "fleet": 0.0}

func _aa_flights_step(dt: float) -> void:
    for a in aa_cache:
        var holder: Dictionary = a["b"] if a["b"] != null else a["ship"]
        var cd: float = holder.get("aacd", 0.0) if a["b"] == null else holder["cool"]
        cd -= dt
        if cd > 0.0:
            if a["b"] != null:
                holder["cool"] = cd
            else:
                holder["aacd"] = cd
            continue
        var best: Variant = null
        var bd: float = a["r"]
        for f in flights:
            if f["dead"] or f["state"] == "dying" or f["mission"] == "pm":
                continue
            if not _at_war(a["own"], f["own"]):
                continue
            var d := _dist2(a["pos"], f["node"].position)
            if d < bd:
                bd = d
                best = f
        var newcd := cd
        if best != null:
            newcd = float(AA_INTERVAL[a["tier"]]) * rng.randf_range(0.8, 1.3)
            var ev: float = float(JET_T[best["tier"]]["evade"])
            var prob: float = float(JET_DEF[a["tier"]]) * (1.0 - ev * 0.8)
            if _radar_near(a["own"], a["pos"]):
                prob *= 1.15
            if a["ship"] != null:
                prob *= 0.7
            _spawn_sam(a, best, rng.randf() < prob)
            if a["b"] != null:
                var dv: Vector3 = best["node"].position - a["pos"]
                a["b"]["face"] = atan2(dv.x, dv.z)
        if a["b"] != null:
            holder["cool"] = newcd
        else:
            holder["aacd"] = newcd


func _spawn_sam(a: Dictionary, f: Dictionary, hit: bool) -> void:
    if projs.size() >= MAX_PROJ:
        return
    var node := Node3D.new()
    var mb := MB.new()
    _m_interceptor(mb)
    var mi := MeshInstance3D.new()
    mi.mesh = mb.bake(mats)
    mi.scale = Vector3.ONE * 2.0
    node.add_child(mi)
    var tr := _trail_node(false)
    tr.position = Vector3(0, 0, 2.0)
    node.add_child(tr)
    var mk := _marker(Color(0.4, 0.8, 1.0), 0.5)
    node.add_child(mk)
    node.position = a["pos"] + Vector3(0, 3, 0)
    add_child(node)
    projs.append({"kind": "sam", "own": a["own"], "node": node, "mk": mk, "trail": tr, "fid": f["id"], "to": f["node"].position, "t": 0.0, "life": 7.0,
        "speed": 240.0 + 40.0 * float(a["tier"]), "hit": hit, "dead": false, "tb": null})
    _snd_at("launch", a["pos"], -8.0)


func _land_dist(c: int, p: Vector3) -> float:
    var cen := _land_center(c)
    return max(abs(p.x - cen.x), abs(p.z - cen.z)) - LAND


func _banner_air(text: String, kind: String, snd: String) -> void:
    _banner(text, kind)
    _snd(snd)


func _airspace_step(dt: float) -> void:
    # 1) intruders trigger scrambles; peacetime violations create incidents
    for f in flights:
        if f["dead"] or f["state"] == "dying" or f["mission"] == "pm" or f["mission"] == "intercept":
            continue
        for x in range(9):
            if x == f["own"] or _allied(x, f["own"]):
                continue
            var det := 110.0
            if _count_b(x, "radar") > 0:
                det = 340.0
            if cs[x]["tech"].has("sat"):
                det = max(det, 400.0)
            var ld := _land_dist(x, f["node"].position)
            if ld > det:
                continue
            var war := _at_war(x, f["own"])
            var hostile: bool = cs[x]["rel"][f["own"]] < -25.0
            if not war and not hostile and ld > 0.0:
                continue
            if f["scr"] < 3:
                var need := 2 if war else 1
                # at most one scramble per second per intruder
                var last: float = f.get("last_scr", -99.0)
                if gtime - last > 6.0:
                    f["last_scr"] = gtime
                    _scramble(x, f, need)
            if not war and ld < 40.0 and not f["warned"]:
                f["warned"] = true
                cs[x]["rel"][f["own"]] = max(-100.0, cs[x]["rel"][f["own"]] - 10.0)
                if x == me or f["own"] == me:
                    _news("AIRSPACE VIOLATION: " + String(COUNTRIES[f["own"]]["short"]) + " aircraft entered " + String(COUNTRIES[x]["short"]) + " airspace.", "warn")
                if x == me:
                    _banner("AIRSPACE VIOLATION by " + String(COUNTRIES[f["own"]]["name"]), "warn")
    # 2) alerts for the player
    for k in alert_cd.keys():
        alert_cd[k] = max(0.0, alert_cd[k] - dt)
    var det_me := 150.0
    if _count_b(me, "radar") > 0:
        det_me = 420.0
    if cs[me]["tech"].has("sat"):
        det_me = 700.0
    var na := 0
    var from_c := -1
    for f in flights:
        if f["dead"] or f["own"] == me or f["mission"] == "pm":
            continue
        if _at_war(me, f["own"]) and _land_dist(me, f["node"].position) < det_me and f["tgt_c"] == me:
            na += 1
            from_c = f["own"]
    if na > 0 and alert_cd["air"] <= 0.0:
        alert_cd["air"] = 14.0
        _banner_air("AIR RAID WARNING: " + str(na) + " enemy aircraft approaching (" + String(COUNTRIES[from_c]["short"]) + ")", "bad", "siren")
    var best_t := 1e9
    var from_m := -1
    var nm := 0
    for p in projs:
        if p["dead"] or p["kind"] != "msl" or p["tgt_c"] != me or p["own"] == me:
            continue
        if p["t"] < 0.0 and false:
            continue
        nm += 1
        var eta: float = max(0.0, (1.0 - p["t"]) * p["len"] / p["speed"])
        if eta < best_t:
            best_t = eta
            from_m = p["own"]
    if nm > 0 and alert_cd["msl"] <= 0.0:
        alert_cd["msl"] = 8.0
        var nk := false
        for p in projs:
            if p["kind"] == "msl" and p["tgt_c"] == me and p["nuke"] and p["own"] != me:
                nk = true
        _banner_air(("NUCLEAR " if nk else "") + "MISSILE LAUNCH DETECTED: " + str(nm) + " incoming from " + String(COUNTRIES[from_m]["short"]) + ", impact in " + str(int(best_t)) + "s", "bad", "alarm")
    var nf := 0
    var ff := -1
    for s in ships:
        if s["dead"] or s["own"] == me:
            continue
        if _at_war(me, s["own"]) and _land_dist(me, s["pos"]) < 280.0:
            nf += 1
            ff = s["own"]
    if nf > 0 and alert_cd["fleet"] <= 0.0:
        alert_cd["fleet"] = 20.0
        _banner_air("ENEMY FLEET: " + str(nf) + " " + String(COUNTRIES[ff]["short"]) + " warships near your coast", "bad", "alarm")


func _rearm_step(dt: float) -> void:
    for c in range(9):
        for b in cs[c]["bl"]:
            if b["t"] == "airbase" and b["st"] == "ok":
                for j in b["jets"]:
                    if j["state"] == "rearm":
                        j["t"] -= dt
                        if j["t"] <= 0.0:
                            j["state"] = "ready"
                _refresh_airbase_parked(b)
    for s in ships:
        if s["k"] == 4 and not s["dead"]:
            for j in s["jets"]:
                if j["state"] == "rearm":
                    j["t"] -= dt
                    if j["t"] <= 0.0:
                        j["state"] = "ready"


func _repair_step(dt: float) -> void:
    # army bases auto-repair nearby buildings, parliament slowly self-repairs
    for c in range(9):
        for b in cs[c]["bl"]:
            if b["st"] == "ok" and b["t"] == "armybase":
                var rate: float = 2.0 * float(b["lvl"])
                for o in cs[c]["bl"]:
                    if o["st"] == "ok" and o["hp"] < o["mhp"] and _dist2(Vector3(o["x"], 0, o["z"]), Vector3(b["x"], 0, b["z"])) < 110.0:
                        o["hp"] = min(o["mhp"], o["hp"] + rate * dt)


func _war_update(dt: float) -> void:
    aa_t += dt
    if aa_t > 0.5:
        aa_cache = _aa_sources()
        _aa_flights_step(aa_t)
        aa_t = 0.0
    _aa_missiles_step(dt)
    air_t += dt
    if air_t > 0.5:
        _airspace_step(air_t)
        air_t = 0.0
    for f in flights:
        if not f["dead"]:
            _flight_update(f, dt)
    var keep := []
    for f in flights:
        if not f["dead"]:
            keep.append(f)
    flights = keep
    _projs_update(dt)
    _ships_update(dt)
    _rearm_step(dt)
    _repair_step(dt)
    for b in cs[me]["bl"]:
        pass
    _aa_face_update(dt)


func _aa_face_update(dt: float) -> void:
    for c in range(9):
        for b in cs[c]["bl"]:
            if b["st"] == "ok" and _is_aa(b) and b["node"] != null and abs(b["face"]) > 0.0001:
                var n: Node3D = b["node"]
                var want: float = b["face"]
                n.rotation.y = lerp_angle(n.rotation.y, want, min(1.0, dt * 3.0))


# =====================================================================
#  NEWS + DIPLOMACY
# =====================================================================
func _news(text: String, kind: String = "info") -> void:
    news_log.push_front({"m": month, "text": text, "kind": kind})
    if news_log.size() > 90:
        news_log.pop_back()
    _ticker(text, kind)


func _rel(a: int, b: int) -> float:
    return cs[a]["rel"][b]


func _add_rel(a: int, b: int, d: float, both: bool = true) -> void:
    cs[a]["rel"][b] = clamp(cs[a]["rel"][b] + d, -100.0, 100.0)
    if both:
        cs[b]["rel"][a] = clamp(cs[b]["rel"][a] + d, -100.0, 100.0)


func _wars_of(c: int) -> Array:
    var out := []
    for j in range(9):
        if cs[c]["st"][j] == "war":
            out.append(j)
    return out


func _status_text(c: int, j: int) -> String:
    match String(cs[c]["st"][j]):
        "war": return "AT WAR"
        "ally": return "ALLIED"
        "cease": return "CEASEFIRE"
    if cs[c]["trade"][j]:
        return "TRADE PARTNER"
    return "PEACE"


func _declare_war(a: int, b: int, why: String = "", depth: int = 0) -> void:
    if a == b or cs[a]["st"][b] == "war" or depth > 3:
        return
    cs[a]["st"][b] = "war"
    cs[b]["st"][a] = "war"
    cs[a]["cease_t"][b] = 0.0
    cs[b]["cease_t"][a] = 0.0
    cs[a]["trade"][b] = false
    cs[b]["trade"][a] = false
    cs[a]["war_start_" + str(b)] = gtime
    cs[b]["war_start_" + str(a)] = gtime
    cs[a]["dmg_taken"] = 0.0
    cs[b]["dmg_taken"] = 0.0
    cs[a]["dmg_dealt"] = 0.0
    cs[b]["dmg_dealt"] = 0.0
    _add_rel(a, b, -40.0)
    var txt := String(COUNTRIES[a]["name"]) + " declared WAR on " + String(COUNTRIES[b]["name"]) + "!" + ((" (" + why + ")") if why != "" else "")
    _news(txt, "bad")
    if b == me or a == me:
        _snd("siren")
    if b == me:
        _popup("WAR!", String(COUNTRIES[a]["name"]) + " has declared war on you!\n\nExpect air raids, missiles and warships. Build air defence and call allies.", [["To arms!", ""]])
    # allies react
    for x in range(9):
        if x == a or x == b:
            continue
        if cs[b]["st"][x] == "ally" and cs[x]["st"][a] != "war":
            if x == me:
                _popup("Your ally is under attack", String(COUNTRIES[b]["name"]) + " was attacked by " + String(COUNTRIES[a]["name"]) + ". Join the war?",
                    [["Join the war", "prop:joinwar:" + str(a)], ["Stay out (relations -15)", "prop:stayout:" + str(b)]])
            elif rng.randf() < 0.8:
                _declare_war(x, a, "defending ally " + String(COUNTRIES[b]["short"]), depth + 1)
        elif cs[a]["st"][x] == "ally" and cs[x]["st"][b] != "war" and x != me:
            if rng.randf() < 0.65 and cs[x]["rel"][b] < 25.0:
                _declare_war(x, b, "backing ally " + String(COUNTRIES[a]["short"]), depth + 1)
        # neutral reactions
        if cs[x]["st"][a] != "ally" and cs[x]["st"][b] != "ally" and x != a and x != b:
            if cs[x]["rel"][b] > 45.0 and cs[x]["rel"][a] < 10.0:
                _add_rel(x, a, -12.0, false)
                if x != me and rng.randf() < 0.35:
                    cs[x]["sanc"][a] = true
                    _news(String(COUNTRIES[x]["short"]) + " imposed sanctions on " + String(COUNTRIES[a]["short"]) + ".", "warn")
    cs[a]["aggr"] = min(1.0, cs[a]["aggr"] + 0.05)


func _make_peace(a: int, b: int, why: String = "") -> void:
    if cs[a]["st"][b] != "war":
        return
    cs[a]["st"][b] = "cease"
    cs[b]["st"][a] = "cease"
    cs[a]["cease_t"][b] = 20.0
    cs[b]["cease_t"][a] = 20.0
    cs[a]["war_w"] = cs[a]["war_w"] * 0.5
    cs[b]["war_w"] = cs[b]["war_w"] * 0.5
    _add_rel(a, b, 22.0)
    _news("CEASEFIRE: " + String(COUNTRIES[a]["name"]) + " and " + String(COUNTRIES[b]["name"]) + " stopped fighting" + ((" (" + why + ")") if why != "" else "") + ".", "good")
    if a == me or b == me:
        _snd("msg")
    # recall offensive flights
    for f in flights:
        if f["dead"] or f["state"] == "dying":
            continue
        if (f["own"] == a and f["tgt_c"] == b) or (f["own"] == b and f["tgt_c"] == a):
            if f["state"] in ["ingress", "attack", "loiter", "scramble", "takeoff"]:
                f["state"] = "return"


func _declare_war_player(b: int) -> void:
    if cs[me]["st"][b] == "ally":
        cs[me]["st"][b] = "peace"
        cs[b]["st"][me] = "peace"
    _declare_war(me, b, "your decision")
    cs[me]["rep"] = max(-100.0, cs[me]["rep"] - 6.0)
    for x in range(9):
        if x != me and x != b:
            _add_rel(x, me, -4.0, false)


func _note_attack(att: int, vic: int, nuke: bool, launched: bool) -> void:
    if att == vic:
        return
    if nuke and not launched:
        _news("The world condemns " + String(COUNTRIES[att]["name"]) + " for using a nuclear weapon!", "bad")
        for j in range(9):
            if j != att:
                _add_rel(j, att, -28.0, false)
                cs[j]["happy"] = max(0.0, cs[j]["happy"] - 2.0)
                if j != me:
                    cs[j]["protest_vis"] = 40.0
        cs[att]["rep"] = max(-100.0, cs[att]["rep"] - 35.0)
        cs[att]["happy"] = max(0.0, cs[att]["happy"] - 6.0)
        cs[me]["protest_vis"] = 30.0
        # allies of victim declare war on the nuclear attacker
        for x in range(9):
            if x != att and x != vic and cs[vic]["st"][x] == "ally" and cs[x]["st"][att] != "war" and x != me:
                _declare_war(x, att, "nuclear attack on ally")
    elif not launched:
        _add_rel(vic, att, -0.8, false)
        cs[att]["rep"] = max(-100.0, cs[att]["rep"] - 0.05)
        # civilians killed => people abroad protest
        if rng.randf() < 0.05:
            for j in range(9):
                if j != att and j != vic and cs[j]["rel"][vic] > 40.0 and j != me:
                    cs[j]["protest_vis"] = 25.0


func _war_age(a: int, b: int) -> float:
    return gtime - float(cs[a].get("war_start_" + str(b), gtime))


func _power(c: int) -> float:
    var p := 0.0
    p += float(_jet_total(c)) * 3.0
    for s in ships:
        if s["own"] == c and not s["dead"]:
            p += float(s["k"] + 1) * 4.0
    for k in range(6):
        p += float(cs[c]["ammo"][k]) * (1.0 + float(k) * 0.8)
    for b in cs[c]["bl"]:
        if b["st"] == "ok" and _is_aa(b):
            p += float(_aa_tier(b) + 1) * 2.0
    p += float(cs[c]["income"]) * 0.01
    return p


const REFUSE := ["Our people would never accept this.", "Not at this time.", "Your offer is rejected.", "We are not interested.", "The parliament voted against it.", "You are in no position to ask."]
const ACCEPT := ["We accept. A new chapter begins.", "Agreed. Let history remember this day.", "Deal. Our governments will sign today."]

func _accept_prob(b: int, a: int, kind: String, bonus: float) -> float:
    var rel: float = cs[b]["rel"][a]
    var p := 0.0
    match kind:
        "ceasefire":
            var losing: float = cs[b]["dmg_taken"] - cs[b]["dmg_dealt"]
            p = 0.28 + cs[b]["war_w"] / 140.0 + losing / 5000.0 - cs[b]["aggr"] * 0.22 + cs[b]["prot"] * 0.3
            if _war_age(a, b) < 30.0:
                p = min(p, 0.05)
        "alliance":
            p = (rel - 30.0) / 70.0
            for x in range(9):
                if cs[b]["st"][x] == "ally" and cs[a]["st"][x] == "war":
                    p = 0.0
                if cs[b]["st"][x] == "war" and cs[a]["st"][x] == "ally":
                    p -= 0.5
        "trade":
            p = (rel + 10.0) / 70.0
        "peace":
            p = (rel + 40.0) / 100.0
        "aid":
            p = 1.0
    return clamp(p + bonus, 0.0, 0.95)


func _propose(a: int, b: int, kind: String, bonus: float = 0.0) -> Dictionary:
    var res := {"ok": false, "msg": ""}
    if kind == "sanction":
        cs[a]["sanc"][b] = true
        _add_rel(b, a, -15.0, false)
        _add_rel(a, b, -5.0, false)
        res["ok"] = true
        res["msg"] = "Sanctions imposed on " + String(COUNTRIES[b]["name"]) + ". Their income will fall."
        _news(String(COUNTRIES[a]["short"]) + " sanctioned " + String(COUNTRIES[b]["short"]) + ".", "warn")
        return res
    if kind == "unsanction":
        cs[a]["sanc"][b] = false
        _add_rel(b, a, 6.0, false)
        res["ok"] = true
        res["msg"] = "Sanctions lifted."
        return res
    if kind == "aid":
        if cs[a]["money"] < 5000.0:
            res["msg"] = "Not enough money."
            return res
        cs[a]["money"] -= 5000.0
        cs[b]["money"] += 5000.0
        _add_rel(a, b, 9.0)
        cs[a]["rep"] = min(100.0, cs[a]["rep"] + 1.5)
        res["ok"] = true
        res["msg"] = "Aid delivered. " + String(COUNTRIES[b]["name"]) + " is grateful."
        return res
    # real proposals need a decision from b
    var last: float = cs[b].get("ref_" + str(a) + kind, -999.0)
    if gtime - last < 22.0 and bonus <= 0.0:
        res["msg"] = String(COUNTRIES[b]["name"]) + " refuses to discuss this again so soon."
        return res
    if kind == "ceasefire" and cs[a]["st"][b] != "war":
        res["msg"] = "You are not at war."
        return res
    if kind in ["alliance", "trade", "peace"] and cs[a]["st"][b] == "war":
        res["msg"] = "You are at war. Ask for a ceasefire first."
        return res
    if kind == "alliance" and cs[a]["st"][b] == "ally":
        res["msg"] = "Already allies."
        return res
    if kind == "trade" and cs[a]["trade"][b]:
        res["msg"] = "Trade agreement already exists."
        return res
    var p := _accept_prob(b, a, kind, bonus)
    var ok := rng.randf() < p
    if ok:
        res["ok"] = true
        res["msg"] = ACCEPT[rng.randi() % ACCEPT.size()]
        match kind:
            "ceasefire":
                _make_peace(a, b, "agreement")
            "alliance":
                cs[a]["st"][b] = "ally"
                cs[b]["st"][a] = "ally"
                _add_rel(a, b, 15.0)
                _news("ALLIANCE: " + String(COUNTRIES[a]["name"]) + " and " + String(COUNTRIES[b]["name"]) + " signed a defence pact.", "good")
            "trade":
                cs[a]["trade"][b] = true
                cs[b]["trade"][a] = true
                _add_rel(a, b, 8.0)
                _news("TRADE DEAL: " + String(COUNTRIES[a]["short"]) + " and " + String(COUNTRIES[b]["short"]) + " agreed to trade freely.", "good")
            "peace":
                _add_rel(a, b, 12.0)
    else:
        cs[b]["ref_" + str(a) + kind] = gtime
        res["msg"] = REFUSE[rng.randi() % REFUSE.size()]
        if kind == "ceasefire":
            res["msg"] = "We will not stop until our demands are met. (" + String(COUNTRIES[b]["short"]) + " rejected the ceasefire)"
        _add_rel(b, a, -1.0, false)
    return res


# ---------------- prime minister visits -----------------------------------
func _send_pm(a: int, b: int) -> String:
    if cs[a]["pm_away"]:
        return "Your PM is already travelling."
    if cs[a]["st"][b] == "war":
        return "You cannot visit a country you are at war with. Ask for a ceasefire first."
    if cs[a]["money"] < 1500.0:
        return "Not enough money for the trip (" + _fmt(1500.0) + ")."
    var cap_a: Variant = bmap.get(cs[a]["cap_b"], null)
    var cap_b: Variant = bmap.get(cs[b]["cap_b"], null)
    var pa := _land_center(a)
    var pb := _land_center(b)
    if cap_a != null:
        pa = Vector3(cap_a["x"], 0, cap_a["z"])
    if cap_b != null:
        pb = Vector3(cap_b["x"], 0, cap_b["z"] + 30.0)
    var yaw := atan2(-(pb.x - pa.x), -(pb.z - pa.z))
    var f: Variant = _spawn_flight(a, 0, pa + Vector3(0, 2, 40), yaw, "pm", {}, null)
    if f == null:
        return "Too much air traffic right now."
    f["dest"] = pb
    f["tgt_c"] = b
    f["speed"] = 105.0
    cs[a]["money"] -= 1500.0
    cs[a]["pm_away"] = true
    if a == me:
        _news("The " + String(COUNTRIES[a]["title"]) + " is flying to " + String(COUNTRIES[b]["cap"]) + ".", "info")
    return ""


func _pm_arrived(f: Dictionary) -> void:
    var a: int = f["own"]
    var b: int = f["tgt_c"]
    _remove_flight(f)
    cs[a]["pm_away"] = false
    if a == me:
        _snd("msg")
        _open_summit(b)
    else:
        _add_rel(a, b, 10.0)
        if false:
            _popup("Visit from " + String(COUNTRIES[a]["name"]), "The " + String(COUNTRIES[a]["title"]) + " of " + String(COUNTRIES[a]["name"]) + " landed in " + String(COUNTRIES[b]["cap"]) + " and proposes a partnership.",
                [["Sign trade deal", "prop:trade:" + str(a)], ["Sign defence pact", "prop:alliance:" + str(a)], ["Just a handshake", ""]])
        else:
            var r := rng.randf()
            if r < 0.5 and not cs[a]["trade"][b]:
                cs[a]["trade"][b] = true
                cs[b]["trade"][a] = true
                _news(String(COUNTRIES[a]["short"]) + " PM visited " + String(COUNTRIES[b]["short"]) + " and signed a trade deal.", "info")
            elif r < 0.7 and cs[a]["rel"][b] > 45.0 and cs[a]["st"][b] == "peace":
                cs[a]["st"][b] = "ally"
                cs[b]["st"][a] = "ally"
                _news(String(COUNTRIES[a]["short"]) + " and " + String(COUNTRIES[b]["short"]) + " signed a defence pact during a state visit.", "info")


func _handle_prop(code: String) -> void:
    var parts := code.split(":")
    if parts.size() < 3:
        return
    var kind := parts[1]
    var other := int(parts[2])
    match kind:
        "joinwar":
            _declare_war(me, other, "defending our ally")
        "stayout":
            _add_rel(me, other, -15.0)
            cs[me]["st"][other] = "peace" if false else cs[me]["st"][other]
        "trade":
            cs[me]["trade"][other] = true
            cs[other]["trade"][me] = true
            _add_rel(me, other, 8.0)
            _news("Trade deal signed with " + String(COUNTRIES[other]["name"]) + ".", "good")
        "alliance":
            cs[me]["st"][other] = "ally"
            cs[other]["st"][me] = "ally"
            _add_rel(me, other, 15.0)
            _news("Defence pact signed with " + String(COUNTRIES[other]["name"]) + ".", "good")
        "ceasefire":
            _make_peace(me, other, "your acceptance")
        "refuse":
            _add_rel(me, other, -3.0, false)
            cs[other]["ref_" + str(me) + "ai"] = gtime
        "ultimatum_ok":
            cs[me]["money"] -= 8000.0
            _add_rel(me, other, 10.0)
        "ultimatum_no":
            _add_rel(me, other, -20.0)
    _refresh_hud()


# =====================================================================
#  AI COUNTRIES
# =====================================================================
const AI_TECH_ORDER := ["ad2", "drone", "eco1", "ballistic", "avionics", "ad3", "sub", "eco2", "icbm", "ad4", "carrier", "hyper", "stealth", "sat", "ad5"]

func _ai_update(dt: float) -> void:
    for c in range(9):
        if c == me:
            continue
        var s: Dictionary = cs[c]
        s["think"] -= dt
        if s["think"] <= 0.0:
            s["think"] = rng.randf_range(4.0, 8.0)
            _ai_economy(c)
            _ai_diplomacy(c)
        s["ops"] -= dt
        if s["ops"] <= 0.0:
            s["ops"] = rng.randf_range(12.0, 26.0) / max(0.4, s["aggr"] + 0.4)
            _ai_ops(c)
        if s.has("protest_vis"):
            s["protest_vis"] = max(0.0, s["protest_vis"] - dt)
    if cs[me].has("protest_vis"):
        cs[me]["protest_vis"] = max(0.0, cs[me]["protest_vis"] - dt)
    peace_left = max(0.0, peace_left - dt)


func _ai_find_spot(c: int, t: String) -> Variant:
    var cen := _land_center(c)
    var d := _bdef(t, c)
    var cnt: int = cs[c]["bl"].size()
    var rad: float = clamp(35.0 + sqrt(float(cnt)) * 22.0, 40.0, LAND - 12.0)
    for i in range(70):
        var x := 0.0
        var z := 0.0
        var r := rng.randi() % 2
        if t == "port":
            var side := rng.randi() % 4
            var lat := rng.randf_range(-LAND + 40.0, LAND - 40.0)
            match side:
                0: x = cen.x + lat; z = cen.z + LAND - 2.0
                1: x = cen.x + LAND - 2.0; z = cen.z + lat
                2: x = cen.x + lat; z = cen.z - LAND + 2.0
                _: x = cen.x - LAND + 2.0; z = cen.z + lat
        else:
            x = cen.x + rng.randf_range(-rad, rad)
            z = cen.z + rng.randf_range(-rad, rad)
        x = _snap(x)
        z = _snap(z)
        if t == "port":
            r = _port_rot(c, x, z)
        if _can_place(c, t, x, z, r) == "":
            return [x, z, r]
    return null


func _ai_spend_ok(c: int, cost: float, reserve: float) -> bool:
    return cs[c]["money"] - cost > reserve


func _ai_build(c: int, t: String) -> bool:
    if not _unlocked(c, t):
        return false
    var d := _bdef(t, c)
    var cost := float(d["cost"])
    var reserve := 3000.0 + (8000.0 if _wars_of(c).size() > 0 else 0.0)
    if not _ai_spend_ok(c, cost, reserve):
        return false
    var sp: Variant = _ai_find_spot(c, t)
    if sp == null:
        return false
    cs[c]["money"] -= cost
    _add_building(c, t, sp[0], sp[1], sp[2], false)
    return true


func _ai_economy(c: int) -> void:
    var s: Dictionary = cs[c]
    var m := month
    var at_war := _wars_of(c).size() > 0
    # tax / policies
    if s["happy"] < 44.0 and s["tax"] > 0.12:
        s["tax"] -= 0.02
    elif s["happy"] > 66.0 and s["tax"] < 0.27:
        s["tax"] += 0.01
    if m == 3 or m == 4:
        var cd: Dictionary = COUNTRIES[c]
        if cd["aggr"] > 0.55:
            s["pol"]["wareco"] = true
        if cd["aggr"] < 0.4:
            s["pol"]["freetrade"] = true
        s["pol"]["subsidy"] = s["pol"].get("subsidy", false)
    # research
    if s["cur"] == "" and _lab_level(c) > 0:
        for k in AI_TECH_ORDER:
            if not s["tech"].has(k) and _start_research(c, k) == "":
                break
        if s["cur"] == "" and COUNTRIES[c]["nuke"] and not s["tech"].has("nuc3") and m > 12:
            for k in ["nuc1", "nuc2", "nuc3"]:
                if not s["tech"].has(k) and _start_research(c, k) == "":
                    break
        if s["cur"] == "" and c == 5 and m > 30 and not s["tech"].has("nuc3"):
            for k in ["nuc1", "nuc2", "nuc3"]:
                if not s["tech"].has(k) and _start_research(c, k) == "":
                    break
    # build economy
    var n_house := _count_b(c, "house", false)
    var tgt_house := int(min(26.0, 5.0 + float(m) * 0.35))
    var built := false
    if m > 2 and _count_b(c, "hospital", false) < 1:
        built = _ai_build(c, "hospital")
    if not built and m > 3 and _count_b(c, "police", false) < 1:
        built = _ai_build(c, "police")
    if not built and n_house < tgt_house:
        built = _ai_build(c, "house")
    if not built and _count_b(c, "apartment", false) < int(m / 7) and m > 6:
        built = _ai_build(c, "apartment")
    if not built and _count_b(c, "commerce", false) < int(m / 10) and m > 8:
        built = _ai_build(c, "commerce")
    if not built and _count_b(c, "factory", false) < int(m / 14) and m > 10:
        built = _ai_build(c, "factory")
    if not built and _count_b(c, "office", false) < int(m / 22) and m > 18:
        built = _ai_build(c, "office")
    if not built and _count_b(c, "university", false) < 1 and m > 12:
        built = _ai_build(c, "university")
    if not built and _count_b(c, "park", false) < 3 + int(m / 20):
        built = _ai_build(c, "park")
    if not built and _count_b(c, "embassy", false) < 1 and m > 15:
        built = _ai_build(c, "embassy")
    # military infrastructure
    var aggr: float = s["aggr"]
    if not built and m > 5 and _count_b(c, "airbase", false) < 1 + int(m / 45):
        built = _ai_build(c, "airbase")
    if not built and m > 7 and _count_b(c, "lab", false) < 1 + int(m / 60):
        built = _ai_build(c, "lab")
    if not built and m > 6 and _count_b(c, "radar", false) < 1 + int(m / 30):
        built = _ai_build(c, "radar")
    if not built and m > 9 and _count_b(c, "missilebase", false) < 1 + int(m / 40):
        built = _ai_build(c, "missilebase")
    if not built and m > 8 and _count_b(c, "port", false) < 1 + int(m / 50):
        built = _ai_build(c, "port")
    if not built and m > 14 and _count_b(c, "armybase", false) < 1:
        built = _ai_build(c, "armybase")
    if not built and COUNTRIES[c]["nuke"] and s["tech"].has("nuc2") and _count_b(c, "enrich", false) < 1:
        built = _ai_build(c, "enrich")
    if not built and c == 5 and s["tech"].has("nuc2") and _count_b(c, "enrich", false) < 1:
        built = _ai_build(c, "enrich")
    # air defence
    var n_aa := 0
    for b in s["bl"]:
        if _is_aa(b):
            n_aa += 1
    var want_aa := int(min(16.0, 2.0 + float(m) / 5.0 + (4.0 if at_war else 0.0)))
    if not built and n_aa < want_aa and m > 3:
        var tier := 4
        while tier >= 0:
            if _unlocked(c, "aa" + str(tier)) and _ai_spend_ok(c, float(AA_COST[tier]), 4000.0):
                break
            tier -= 1
        if tier >= 0:
            built = _ai_build(c, "aa" + str(tier))
    # upgrades
    if not built and rng.randf() < 0.3:
        var list := []
        for b in s["bl"]:
            if b["st"] == "ok" and b["lvl"] < _max_level(b) and _upgrade_cost(b) * 2.5 < s["money"]:
                list.append(b)
        if list.size() > 0:
            var b: Dictionary = list[rng.randi() % list.size()]
            _upgrade_building(b, false)
    # repairs
    for b in s["bl"]:
        if b["st"] == "ruin" and s["money"] > _repair_cost(b) * 3.0 and rng.randf() < 0.3:
            _repair_building(b)
            break
        elif b["st"] == "ok" and b["hp"] < b["mhp"] * 0.5 and s["money"] > 8000.0:
            _repair_building(b)
            break
    # weapons
    _ai_buy_weapons(c)


func _ai_buy_weapons(c: int) -> void:
    var s: Dictionary = cs[c]
    var at_war := _wars_of(c).size() > 0
    var budget_frac := 0.65 if at_war else 0.35
    var spend: float = s["money"] * budget_frac - 2000.0
    if spend < 1500.0:
        return
    # jets
    if _count_b(c, "airbase") > 0 and rng.randf() < 0.6:
        var t := 3
        while t >= 0:
            if _weapon_state(c, "jet", t)["state"] != "locked":
                break
            t -= 1
        if t >= 0:
            if _weapon_state(c, "jet", t)["state"] == "unlockable":
                _unlock_weapon(c, "jet", t)
            elif _jet_total(c) < 6 * _total_ab_level(c):
                _buy_jet(c, t)
    # missiles
    if _count_b(c, "missilebase") > 0 and rng.randf() < 0.6 and _ammo_total(c) < _ammo_cap(c):
        var k := 4
        while k >= 0:
            if k < 5 and _weapon_state(c, "msl", k)["state"] != "locked":
                break
            k -= 1
        if k >= 0:
            if rng.randf() < 0.4:
                k = rng.randi() % (k + 1)
                if _weapon_state(c, "msl", k)["state"] == "locked":
                    k = 0
            if _weapon_state(c, "msl", k)["state"] == "unlockable":
                _unlock_weapon(c, "msl", k)
            else:
                _buy_missile(c, k, 2)
    # nukes (only for nuclear states with the full tech chain)
    if s["tech"].has("nuc3") and _count_b(c, "enrich") > 0 and _count_b(c, "missilebase") > 0 and not s["pol"].get("npt", false):
        if s["ammo"][5] < 3 and rng.randf() < 0.15:
            _buy_missile(c, 5, 1)
    # ships
    if _count_b(c, "port") > 0 and _ship_count(c) < _ship_cap(c) and rng.randf() < 0.4:
        var sk := 4
        while sk >= 0:
            if _weapon_state(c, "ship", sk)["state"] != "locked" and (sk != 4 or _carrier_count(c) < 1 + _count_b(c, "port") / 2):
                break
            sk -= 1
        if sk >= 0:
            if sk >= 2 and rng.randf() < 0.5:
                sk = rng.randi() % 3
            if _weapon_state(c, "ship", sk)["state"] == "unlockable":
                _unlock_weapon(c, "ship", sk)
            else:
                _buy_ship(c, sk)


func _carrier_count(c: int) -> int:
    var n := 0
    for s in ships:
        if s["own"] == c and s["k"] == 4 and not s["dead"]:
            n += 1
    return n


func _ai_diplomacy(c: int) -> void:
    var s: Dictionary = cs[c]
    var wars := _wars_of(c)
    for j in range(9):
        if j == c:
            continue
        var st: String = s["st"][j]
        var rel: float = s["rel"][j]
        if st == "war":
            # ceasefire logic
            var age := _war_age(c, j)
            var p := 0.0
            if age > 60.0:
                p = 0.02 + s["war_w"] / 900.0 + max(0.0, s["dmg_taken"] - s["dmg_dealt"]) / 60000.0
            if j == me:
                if rng.randf() < p * 1.5 and gtime - float(s.get("ref_" + str(me) + "ai", -999.0)) > 40.0:
                    _popup(String(COUNTRIES[c]["name"]) + " offers a ceasefire", "After heavy fighting, " + String(COUNTRIES[c]["name"]) + " proposes to stop the war.",
                        [["Accept ceasefire", "prop:ceasefire:" + str(c)], ["Reject and keep fighting", "prop:refuse:" + str(c)]])
            elif j > c and rng.randf() < p:
                _make_peace(c, j, "mediation")
            continue
        # war declaration
        if peace_left <= 0.0 and st == "peace" and wars.size() < 2 and gtime > 120.0:
            if rel < -55.0:
                var dist := _land_center(c).distance_to(_land_center(j))
                var pp: float = 0.012 * s["aggr"] * (1.0 + (-rel - 55.0) / 40.0)
                pp *= clamp(1800.0 / max(dist, 300.0), 0.35, 1.6)
                if COUNTRIES[c]["nuke"] and COUNTRIES[j]["nuke"]:
                    pp *= 0.3
                if j == me:
                    pp *= 0.8 + 0.4 * min(1.0, float(_power(c)) / max(5.0, _power(me)))
                var pr = _power(c) / max(3.0, _power(j))
                pp *= clamp(pr, 0.3, 2.0)
                if rng.randf() < pp:
                    _declare_war(c, j, "tensions escalated")
                    wars = _wars_of(c)
                    continue
        # friendly proposals (removed: no diplomacy popups)
        if j == me:
            continue
        if false:
            if st == "peace" and rel > 58.0 and rng.randf() < 0.012 and gtime - float(s.get("ref_" + str(me) + "ai", -999.0)) > 60.0:
                _popup(String(COUNTRIES[c]["name"]) + " proposes an alliance", String(COUNTRIES[c]["title"]) + " of " + String(COUNTRIES[c]["name"]) + " offers a mutual defence pact.",
                    [["Sign the pact", "prop:alliance:" + str(c)], ["Decline", "prop:refuse:" + str(c)]])
            elif st != "war" and not s["trade"][me] and rel > 15.0 and rng.randf() < 0.012 and gtime - float(s.get("ref_" + str(me) + "ai", -999.0)) > 60.0:
                _popup(String(COUNTRIES[c]["name"]) + " proposes a trade deal", "Open borders for trade would raise both economies.",
                    [["Sign trade deal", "prop:trade:" + str(c)], ["Decline", "prop:refuse:" + str(c)]])
            elif rel < -35.0 and st == "peace" and rng.randf() < 0.004 and gtime > 100.0:
                _popup(String(COUNTRIES[c]["name"]) + " issues an ultimatum", "They demand a payment of " + _fmt(8000.0) + " or relations will collapse.",
                    [["Pay " + _fmt(8000.0), "prop:ultimatum_ok:" + str(c)], ["Refuse", "prop:ultimatum_no:" + str(c)]])
        else:
            if st == "peace" and rel > 55.0 and rng.randf() < 0.01:
                cs[c]["st"][j] = "ally"
                cs[j]["st"][c] = "ally"
                _news(String(COUNTRIES[c]["short"]) + " and " + String(COUNTRIES[j]["short"]) + " formed an alliance.", "info")
            elif st != "ally" and rel > 20.0 and not s["trade"][j] and rng.randf() < 0.015:
                s["trade"][j] = true
                cs[j]["trade"][c] = true
        # incidents
        if st == "peace" and rel < -40.0 and rng.randf() < 0.004:
            _add_rel(c, j, -8.0)
            if j == me or c == me:
                _news("Border incident between " + String(COUNTRIES[c]["short"]) + " and " + String(COUNTRIES[j]["short"]) + " raised tensions.", "warn")
    # aggression cools in peace
    if wars.is_empty():
        s["aggr"] = max(float(COUNTRIES[c]["aggr"]) * 0.7, s["aggr"] - 0.002)


func _pick_target(att: int, vic: int, prefer_aa: bool = false) -> Variant:
    var list := []
    var w := []
    var tot := 0.0
    for b in cs[vic]["bl"]:
        if b["st"] == "ruin":
            continue
        var wt := 1.0
        match String(b["t"]):
            "airbase": wt = 3.0
            "missilebase": wt = 3.0
            "port": wt = 2.0
            "lab": wt = 2.5
            "enrich": wt = 5.0
            "parliament": wt = 1.5
            "radar": wt = 2.5 if prefer_aa else 1.0
            "armybase": wt = 1.5
            "house": wt = 0.5
        if _is_aa(b):
            wt = 3.5 if prefer_aa else 1.2
        list.append(b)
        w.append(wt)
        tot += wt
    if list.is_empty():
        return null
    var r := rng.randf() * tot
    for i in range(list.size()):
        r -= w[i]
        if r <= 0.0:
            return list[i]
    return list[list.size() - 1]


func _coast_point(c: int, e: int) -> Vector3:
    var a := _land_center(c)
    var b := _land_center(e)
    var d := (a - b)
    d.y = 0
    var off: Vector3
    if abs(d.x) > abs(d.z):
        off = Vector3(sign(d.x) * (LAND + 85.0), 0, clamp(d.z * 0.2, -90.0, 90.0))
    else:
        off = Vector3(clamp(d.x * 0.2, -90.0, 90.0), 0, sign(d.z) * (LAND + 85.0))
    return b + off + Vector3(rng.randf_range(-40, 40), 0, rng.randf_range(-20, 20))


func _ai_ops(c: int) -> void:
    var wars := _wars_of(c)
    if wars.is_empty():
        return
    var s: Dictionary = cs[c]
    # choose enemy (closest)
    var e = wars[0]
    var bd := 1e9
    for j in wars:
        var d := _land_center(c).distance_to(_land_center(j))
        if d < bd:
            bd = d
            e = j
    # missiles
    var have_any := false
    var order := [4, 3, 2, 0, 1]
    for k in order:
        if s["ammo"][k] > 0:
            var tb: Variant = _pick_target(c, e, true)
            if tb != null:
                var n := int(min(s["ammo"][k], rng.randi_range(2, 6)))
                if _fire_salvo(c, k, n, tb) > 0:
                    have_any = true
                    break
    # nuclear option (very rare)
    if s["ammo"][5] > 0 and COUNTRIES[e]["nuke"] and s["war_w"] > 40.0 and rng.randf() < 0.06 and _war_age(c, e) > 150.0:
        var tn: Variant = bmap.get(cs[e]["cap_b"], null)
        if tn == null:
            tn = _pick_target(c, e)
        if tn != null:
            _fire_salvo(c, 5, 1, tn)
            return
    # air strikes
    if _jet_ready_count(c) >= 2 and rng.randf() < 0.8:
        var tb2: Variant = _pick_target(c, e, true)
        if tb2 != null:
            var nj := rng.randi_range(2, 5)
            if rng.randf() < 0.3:
                _launch_sweep(c, e, min(3, nj))
            else:
                _launch_strike(c, tb2, nj)
    # navy
    for sh in ships:
        if sh["own"] == c and not sh["dead"] and sh["wp"].is_empty():
            if sh["k"] == 4 and rng.randf() < 0.5:
                var tb3: Variant = _pick_target(c, e)
                if tb3 != null and _jet_ready_count(c) >= 2:
                    _launch_strike(c, tb3, 3)
            var dist_e := _dist2(sh["pos"], _land_center(e))
            if dist_e > LAND + 140.0 and sh["k"] != 4:
                sh["wp"] = _sea_path(sh["pos"], _coast_point(c, e))
            elif sh["k"] == 4 and dist_e > 900.0:
                var mid: Vector3 = _land_center(c).lerp(_land_center(e), 0.6)
                var dst := _coast_point(c, e).lerp(sh["pos"], 0.0)
                var tgt_p := dst + (_land_center(c) - dst).normalized() * 380.0
                sh["wp"] = _sea_path(sh["pos"], tgt_p)


# =====================================================================
#  SHOP: buildings, weapons
# =====================================================================
func _total_ab_level(c: int) -> int:
    var n := 0
    for b in cs[c]["bl"]:
        if b["t"] == "airbase" and b["st"] == "ok":
            n += b["lvl"]
    return n


func _weapon_info(c: int, kind: String, idx: int) -> Dictionary:
    match kind:
        "jet":
            var j: Dictionary = JET_T[idx]
            return {"name": _jet_name(c, idx), "price": float(j["price"]), "unlock": float(j["unlock"]), "tech": String(j["tech"])}
        "ship":
            var s: Dictionary = SHIPS[idx]
            return {"name": String(s["name"]), "price": float(s["price"]), "unlock": float(s["unlock"]), "tech": String(s["tech"])}
        _:
            var m: Dictionary = MSL[idx]
            return {"name": _msl_name(c, idx), "price": float(m["price"]), "unlock": float(m["unlock"]), "tech": String(m["tech"])}


func _weapon_state(c: int, kind: String, idx: int) -> Dictionary:
    var w := _weapon_info(c, kind, idx)
    var price: float = w["price"] * _wmult(c)
    if kind == "msl" and idx == 5:
        if not _has_tech(c, "nuc3"):
            return {"state": "locked", "reason": "Research: Warhead Design (Nuclear path)", "fee": 0.0, "price": price}
        if cs[c]["pol"].get("npt", false):
            return {"state": "locked", "reason": "Withdraw from NPT", "fee": 0.0, "price": price}
        if _count_b(c, "enrich") <= 0:
            return {"state": "locked", "reason": "Build a Nuclear Complex", "fee": 0.0, "price": price}
        return {"state": "ready", "reason": "", "fee": 0.0, "price": price}
    var key := kind + ":" + str(idx)
    if float(w["unlock"]) <= 0.0 or cs[c]["unl"].has(key):
        if not _has_tech(c, String(w["tech"])):
            return {"state": "locked", "reason": "Research: " + String(TECHS[w["tech"]]["name"]), "fee": 0.0, "price": price}
        return {"state": "ready", "reason": "", "fee": 0.0, "price": price}
    var fee: float = float(w["unlock"]) * 0.3
    if cs[c]["peak"] < float(w["unlock"]):
        return {"state": "locked", "reason": "Reach " + _fmt(float(w["unlock"])) + " treasury", "fee": fee, "price": price}
    if not _has_tech(c, String(w["tech"])):
        return {"state": "locked", "reason": "Research: " + String(TECHS[w["tech"]]["name"]), "fee": fee, "price": price}
    return {"state": "unlockable", "reason": "", "fee": fee, "price": price}


func _unlock_weapon(c: int, kind: String, idx: int) -> String:
    var st := _weapon_state(c, kind, idx)
    if st["state"] != "unlockable":
        return "Cannot unlock"
    if cs[c]["money"] < st["fee"]:
        return "Not enough money (" + _fmt(st["fee"]) + ")"
    cs[c]["money"] -= st["fee"]
    cs[c]["unl"][kind + ":" + str(idx)] = true
    if c == me:
        _news("Unlocked: " + String(_weapon_info(c, kind, idx)["name"]) + ".", "good")
        _snd("build")
    return ""


func _buy_jet(c: int, tier: int) -> String:
    var st := _weapon_state(c, "jet", tier)
    if st["state"] != "ready":
        return "Locked"
    if cs[c]["money"] < st["price"]:
        return "Not enough money"
    var slot: Variant = null
    for b in cs[c]["bl"]:
        if b["t"] == "airbase" and b["st"] == "ok" and b["jets"].size() < 6 * b["lvl"]:
            slot = b
            break
    if slot == null:
        return "No free hangar space - build or upgrade an Air Force Base"
    cs[c]["money"] -= st["price"]
    slot["jets"].append({"tier": tier, "state": "ready", "t": 0.0})
    _refresh_airbase_parked(slot)
    if c == me:
        _snd("build")
    return ""


func _buy_carrier_jet(c: int, tier: int, sh: Dictionary) -> String:
    var st := _weapon_state(c, "jet", tier)
    if st["state"] != "ready":
        return "Locked"
    if sh["jets"].size() >= 8:
        return "Carrier is full"
    if cs[c]["money"] < st["price"]:
        return "Not enough money"
    cs[c]["money"] -= st["price"]
    sh["jets"].append({"tier": tier, "state": "ready", "t": 0.0})
    return ""


func _buy_missile(c: int, k: int, n: int) -> String:
    var st := _weapon_state(c, "msl", k)
    if st["state"] != "ready":
        return "Locked"
    if _count_b(c, "missilebase") <= 0:
        return "Build a Missile Base first"
    var room := _ammo_cap(c) - _ammo_total(c)
    if room <= 0:
        return "Missile storage is full - build/upgrade Missile Bases"
    n = min(n, room)
    var cost: float = st["price"] * float(n)
    if cs[c]["money"] < cost:
        n = int(cs[c]["money"] / st["price"])
        if n <= 0:
            return "Not enough money"
        cost = st["price"] * float(n)
    cs[c]["money"] -= cost
    cs[c]["ammo"][k] += n
    if c == me:
        _snd("build")
    return ""


func _buy_ship(c: int, k: int) -> String:
    var st := _weapon_state(c, "ship", k)
    if st["state"] != "ready":
        return "Locked"
    if cs[c]["money"] < st["price"]:
        return "Not enough money"
    if _ship_count(c) >= _ship_cap(c):
        return "Port is full - build or upgrade a Naval Port"
    var ports := []
    for b in cs[c]["bl"]:
        if b["t"] == "port" and b["st"] == "ok":
            ports.append(b)
    if ports.is_empty():
        return "Build a Naval Port first"
    var port: Dictionary = ports[rng.randi() % ports.size()]
    var sp := _port_spawn(port)
    var outv := sp - Vector3(port["x"], 0, port["z"])
    var yaw := atan2(-outv.x, -outv.z)
    var s: Variant = _spawn_ship(c, k, sp, yaw)
    if s == null:
        return "Too many ships at sea"
    cs[c]["money"] -= st["price"]
    # sail a short distance to open water
    s["wp"] = [sp + outv.normalized() * 40.0]
    if c == me:
        _snd("build")
        _news(String(SHIPS[k]["name"]) + " launched from your port.", "good")
    return ""


func _buy_building(c: int, t: String, x: float, z: float, r: int) -> String:
    if not _unlocked(c, t):
        return "Locked: " + _unlock_reason(c, t)
    var d := _bdef(t, c)
    if cs[c]["money"] < float(d["cost"]):
        return "Not enough money (" + _fmt(float(d["cost"])) + ")"
    var err := _can_place(c, t, x, z, r)
    if err != "":
        return err
    cs[c]["money"] -= float(d["cost"])
    _add_building(c, t, x, z, r, false)
    return ""


func _upgrade_building(b: Dictionary, charge_player: bool = true) -> String:
    var c: int = b["c"]
    if b["lvl"] >= _max_level(b):
        return "Max level"
    if b["st"] != "ok":
        return "Not ready"
    var cost := _upgrade_cost(b)
    if cs[c]["money"] < cost:
        return "Not enough money (" + _fmt(cost) + ")"
    if b["t"] in ["lab"] and false:
        pass
    cs[c]["money"] -= cost
    b["lvl"] += 1
    var d := _bdef(b["t"], c)
    b["mhp"] = float(d["hp"]) * (1.0 + 0.4 * float(b["lvl"] - 1))
    b["hp"] = b["mhp"]
    _make_node(b)
    lod_dirty[c] = true
    if b["t"] == "airbase":
        _refresh_airbase_parked(b)
    if c == me:
        _snd("build")
    return ""


func _repair_building(b: Dictionary) -> String:
    var c: int = b["c"]
    var cost := _repair_cost(b)
    if cs[c]["money"] < cost:
        return "Not enough money (" + _fmt(cost) + ")"
    cs[c]["money"] -= cost
    if b["st"] == "ruin":
        b["st"] = "build"
        b["prog"] = 0.0
        b["hp"] = b["mhp"]
        _make_node(b)
        lod_dirty[c] = true
    else:
        b["hp"] = b["mhp"]
    return ""


func _sell_building(b: Dictionary) -> String:
    if b["t"] == "parliament":
        return "You cannot sell the Parliament"
    var c: int = b["c"]
    var d := _bdef(b["t"], c)
    cs[c]["money"] += float(d["cost"]) * 0.5 * (0.2 if b["st"] == "ruin" else 1.0)
    _remove_building(b)
    return ""


func _move_building_to(b: Dictionary, x: float, z: float, r: int) -> String:
    var c: int = b["c"]
    var fee := float(_bdef(b["t"], c)["cost"]) * 0.08
    if cs[c]["money"] < fee:
        return "Not enough money for the move (" + _fmt(fee) + ")"
    var err := _can_place(c, b["t"], x, z, r, b["id"])
    if err != "":
        return err
    cs[c]["money"] -= fee
    b["x"] = x
    b["z"] = z
    b["r"] = r if b["t"] != "port" else _port_rot(c, x, z)
    _make_node(b)
    var h := _fp_half(b["t"], b["r"], c)
    _clear_trees_rect(c, x, z, h.x, h.y)
    lod_dirty[c] = true
    return ""


# =====================================================================
#  SAVE / LOAD
# =====================================================================
func _has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)


func _save_game() -> void:
    if game_state != "playing":
        return
    var data := {"v": 10, "me": me, "month": month, "gtime": gtime, "day_t": day_t, "peace_left": peace_left, "uid": uid_counter, "c": [], "ships": []}
    for c in cs:
        var cd := {"money": c["money"], "peak": c["peak"], "pop": c["pop"], "happy": c["happy"], "tax": c["tax"], "rel": c["rel"], "st": c["st"],
            "cease_t": c["cease_t"], "trade": c["trade"], "sanc": c["sanc"], "pol": c["pol"], "rp": c["rp"], "tech": c["tech"], "cur": c["cur"],
            "unl": c["unl"], "ammo": c["ammo"], "war_w": c["war_w"], "rep": c["rep"], "next_elec": c["next_elec"], "aggr": c["aggr"], "nuke": c["nuke"], "bl": []}
        for b in c["bl"]:
            var jets := []
            for j in b["jets"]:
                jets.append({"tier": j["tier"]})
            cd["bl"].append({"t": b["t"], "x": b["x"], "z": b["z"], "r": b["r"], "lvl": b["lvl"], "hp": b["hp"], "mhp": b["mhp"], "st": b["st"], "prog": b["prog"], "v": b["v"], "jets": jets})
        data["c"].append(cd)
    for s in ships:
        if s["dead"]:
            continue
        var jets2 := []
        for j in s["jets"]:
            jets2.append({"tier": j["tier"]})
        data["ships"].append({"own": s["own"], "k": s["k"], "x": s["pos"].x, "z": s["pos"].z, "yaw": s["yaw"], "hp": s["hp"], "jets": jets2})
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))
        f.close()
        _toast("Game saved", "good")


func _load_game() -> bool:
    if not _has_save():
        return false
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return false
    var data = JSON.parse_string(f.get_as_text())
    f.close()
    if typeof(data) != TYPE_DICTIONARY or not data.has("c"):
        return false
    # clear current
    for c in cs:
        _clear_country_nodes(c)
    for p in projs:
        if is_instance_valid(p["node"]):
            p["node"].queue_free()
    projs.clear()
    for fl in flights:
        if is_instance_valid(fl["node"]):
            fl["node"].queue_free()
    flights.clear()
    for s in ships:
        if is_instance_valid(s["node"]):
            s["node"].queue_free()
    ships.clear()
    bmap.clear()
    cs = []
    me = int(data["me"])
    month = int(data["month"])
    gtime = float(data["gtime"])
    day_t = float(data["day_t"])
    peace_left = float(data["peace_left"])
    for i in range(9):
        var cd: Dictionary = data["c"][i]
        var c := _new_country(i)
        c["ai"] = (i != me)
        for k in ["money", "peak", "pop", "happy", "tax", "rp", "war_w", "rep", "aggr"]:
            c[k] = float(cd[k])
        c["next_elec"] = int(cd["next_elec"])
        c["cur"] = String(cd["cur"])
        c["nuke"] = bool(cd["nuke"])
        c["rel"] = []
        for v in cd["rel"]:
            c["rel"].append(float(v))
        c["st"] = []
        for v in cd["st"]:
            c["st"].append(String(v))
        c["cease_t"] = []
        for v in cd["cease_t"]:
            c["cease_t"].append(float(v))
        c["trade"] = []
        for v in cd["trade"]:
            c["trade"].append(bool(v))
        c["sanc"] = []
        for v in cd["sanc"]:
            c["sanc"].append(bool(v))
        c["pol"] = cd["pol"]
        c["tech"] = cd["tech"]
        c["unl"] = cd["unl"]
        c["ammo"] = []
        for v in cd["ammo"]:
            c["ammo"].append(int(v))
        cs.append(c)
        _reset_trees(i)
        for bd in cd["bl"]:
            var b := _add_building(i, String(bd["t"]), float(bd["x"]), float(bd["z"]), int(bd["r"]), true)
            b["lvl"] = int(bd["lvl"])
            b["hp"] = float(bd["hp"])
            b["mhp"] = float(bd["mhp"])
            b["st"] = String(bd["st"])
            b["prog"] = float(bd["prog"])
            b["v"] = int(bd["v"])
            b["jets"] = []
            for j in bd["jets"]:
                b["jets"].append({"tier": int(j["tier"]), "state": "ready", "t": 0.0})
            _make_node(b)
            if b["t"] == "parliament":
                c["cap_b"] = b["id"]
            _refresh_airbase_parked(b)
    for sd in data["ships"]:
        var s: Variant = _spawn_ship(int(sd["own"]), int(sd["k"]), Vector3(float(sd["x"]), 0, float(sd["z"])), float(sd["yaw"]))
        if s != null:
            s["hp"] = float(sd["hp"])
            s["jets"] = []
            for j in sd["jets"]:
                s["jets"].append({"tier": int(j["tier"]), "state": "ready", "t": 0.0})
    game_state = "playing"
    speed = 1
    cam_target = _land_center(me) + Vector3(0, 0, 40)
    cam_goal = cam_target
    cam_goal_dist = 320.0
    cam_dist = 320.0
    if menu_root:
        menu_root.visible = false
    _hide_all_windows()
    _refresh_hud()
    _news("Game loaded.", "info")
    return true


# =====================================================================
#  UI - helpers
# =====================================================================
var ui: CanvasLayer
var ui_root: Control
var top_bar: PanelContainer
var lbl_country: Label
var lbl_money: Label
var lbl_income: Label
var lbl_pop: Label
var lbl_happy: Label
var lbl_rp: Label
var lbl_date: Label
var speed_btns: Array = []
var flag_holder: Control
var dock: HBoxContainer
var ticker_lbl: Label
var ticker_panel: PanelContainer
var ticker_t := 0.0
var toast_box: VBoxContainer
var banner_lbl: Label
var banner_panel: PanelContainer
var banner_t := 0.0
var win_root: PanelContainer
var win_title: Label
var win_scroll: ScrollContainer
var win_body: VBoxContainer
var win_tab := ""
var win_arg: Variant = null
var win_refresh_t := 0.0
var side_panel: PanelContainer
var side_body: VBoxContainer
var place_bar: PanelContainer
var place_lbl: Label
var place_ok_btn: Button
var popup_root: Control
var popup_panel: PanelContainer
var popup_queue: Array = []
var popup_open := false
var menu_root: Control
var hud_t := 0.0
var alert_hint: Label

const C_PANEL := Color(0.05, 0.08, 0.13, 0.94)
const C_PANEL2 := Color(0.09, 0.13, 0.2, 0.96)
const C_ACC := Color(0.25, 0.55, 0.95)
const C_GOOD := Color(0.15, 0.62, 0.32)
const C_BAD := Color(0.78, 0.2, 0.2)
const C_WARN := Color(0.85, 0.6, 0.1)
const C_TXT := Color(0.92, 0.95, 1.0)
const C_DIM := Color(0.62, 0.7, 0.8)


func _sb(col: Color, rad: int = 10, border: Color = Color(0, 0, 0, 0), bw: int = 0) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = col
    s.set_corner_radius_all(rad)
    s.border_color = border
    s.set_border_width_all(bw)
    s.content_margin_left = 10
    s.content_margin_right = 10
    s.content_margin_top = 6
    s.content_margin_bottom = 6
    return s


func _lbl(text: String, size: int = 20, col: Color = C_TXT, wrap: bool = false) -> Label:
    var l := Label.new()
    l.text = text
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", col)
    if wrap:
        l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        l.custom_minimum_size = Vector2(200, 0)
    return l


func _btn(text: String, kind: String, cb: Callable, minw: int = 0, minh: int = 52, size: int = 20) -> Button:
    var b := Button.new()
    b.text = text
    b.add_theme_font_size_override("font_size", size)
    b.custom_minimum_size = Vector2(minw, minh)
    var col := C_ACC
    match kind:
        "good": col = C_GOOD
        "bad": col = C_BAD
        "warn": col = C_WARN
        "dark": col = Color(0.18, 0.22, 0.3)
        "off": col = Color(0.14, 0.16, 0.2)
    b.add_theme_stylebox_override("normal", _sb(col, 9))
    b.add_theme_stylebox_override("hover", _sb(col.lightened(0.12), 9))
    b.add_theme_stylebox_override("pressed", _sb(col.darkened(0.2), 9))
    b.add_theme_stylebox_override("disabled", _sb(Color(0.14, 0.16, 0.2), 9))
    b.add_theme_color_override("font_color", C_TXT)
    b.add_theme_color_override("font_disabled_color", Color(0.5, 0.55, 0.62))
    b.pressed.connect(func():
        _snd("click")
        cb.call())
    return b


func _hbox(sep: int = 8) -> HBoxContainer:
    var h := HBoxContainer.new()
    h.add_theme_constant_override("separation", sep)
    return h


func _vbox(sep: int = 6) -> VBoxContainer:
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", sep)
    return v


func _card(col: Color = C_PANEL2) -> VBoxContainer:
    var p := PanelContainer.new()
    p.add_theme_stylebox_override("panel", _sb(col, 10, Color(0.2, 0.3, 0.45, 0.6), 1))
    p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var v := _vbox(4)
    p.add_child(v)
    v.set_meta("card", p)
    return v


func _add_card(parent: Control, v: VBoxContainer) -> void:
    parent.add_child(v.get_meta("card"))


func _bar(frac: float, col: Color, w: int = 120, h: int = 12) -> Control:
    var c := Control.new()
    c.custom_minimum_size = Vector2(w, h)
    c.draw.connect(func():
        c.draw_rect(Rect2(0, 0, c.size.x, c.size.y), Color(0.12, 0.15, 0.2), true)
        c.draw_rect(Rect2(0, 0, c.size.x * clamp(frac, 0.0, 1.0), c.size.y), col, true))
    return c


func _relbar(rel: float, w: int = 150) -> Control:
    var c := Control.new()
    c.custom_minimum_size = Vector2(w, 14)
    c.draw.connect(func():
        c.draw_rect(Rect2(0, 0, c.size.x, c.size.y), Color(0.12, 0.15, 0.2), true)
        var mid := c.size.x * 0.5
        var f: float = rel / 100.0
        if f >= 0.0:
            c.draw_rect(Rect2(mid, 0, mid * f, c.size.y), Color(0.2, 0.75, 0.35), true)
        else:
            c.draw_rect(Rect2(mid + mid * f, 0, -mid * f, c.size.y), Color(0.85, 0.25, 0.25), true)
        c.draw_rect(Rect2(mid - 1, 0, 2, c.size.y), Color(1, 1, 1, 0.7), true))
    return c


func _mk_flag(idx: int, w: int = 54, h: int = 36) -> Control:
    var c := Control.new()
    c.custom_minimum_size = Vector2(w, h)
    c.draw.connect(func(): _draw_flag(c, idx))
    return c


func _star(c: Control, cen: Vector2, r: float, col: Color) -> void:
    var pts := PackedVector2Array()
    for k in range(10):
        var a := -PI * 0.5 + float(k) * PI / 5.0
        var rr := r if k % 2 == 0 else r * 0.4
        pts.append(cen + Vector2(cos(a), sin(a)) * rr)
    c.draw_colored_polygon(pts, col)


func _draw_flag(c: Control, idx: int) -> void:
    var w: float = c.size.x
    var h: float = c.size.y
    var id := String(COUNTRIES[idx]["id"])
    match id:
        "usa":
            for k in range(7):
                c.draw_rect(Rect2(0, h * float(k) / 7.0, w, h / 7.0 + 1), Color(0.75, 0.1, 0.2) if k % 2 == 0 else Color(1, 1, 1), true)
            c.draw_rect(Rect2(0, 0, w * 0.42, h * 4.0 / 7.0), Color(0.1, 0.15, 0.45), true)
            for a in range(3):
                for b in range(4):
                    c.draw_circle(Vector2(w * 0.06 + float(b) * w * 0.095, h * 0.09 + float(a) * h * 0.13), 1.2, Color(1, 1, 1))
        "uk":
            c.draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.12, 0.45), true)
            c.draw_line(Vector2(0, 0), Vector2(w, h), Color(1, 1, 1), h * 0.22)
            c.draw_line(Vector2(w, 0), Vector2(0, h), Color(1, 1, 1), h * 0.22)
            c.draw_line(Vector2(0, 0), Vector2(w, h), Color(0.8, 0.1, 0.15), h * 0.09)
            c.draw_line(Vector2(w, 0), Vector2(0, h), Color(0.8, 0.1, 0.15), h * 0.09)
            c.draw_rect(Rect2(w * 0.4, 0, w * 0.2, h), Color(1, 1, 1), true)
            c.draw_rect(Rect2(0, h * 0.37, w, h * 0.26), Color(1, 1, 1), true)
            c.draw_rect(Rect2(w * 0.44, 0, w * 0.12, h), Color(0.8, 0.1, 0.15), true)
            c.draw_rect(Rect2(0, h * 0.42, w, h * 0.16), Color(0.8, 0.1, 0.15), true)
        "eu":
            c.draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.2, 0.6), true)
            for k in range(12):
                var a := float(k) * TAU / 12.0
                c.draw_circle(Vector2(w * 0.5 + cos(a) * h * 0.32, h * 0.5 + sin(a) * h * 0.32), 1.8, Color(1, 0.85, 0.1))
        "rus":
            c.draw_rect(Rect2(0, 0, w, h / 3.0 + 1), Color(1, 1, 1), true)
            c.draw_rect(Rect2(0, h / 3.0, w, h / 3.0 + 1), Color(0.0, 0.22, 0.65), true)
            c.draw_rect(Rect2(0, h * 2.0 / 3.0, w, h / 3.0 + 1), Color(0.85, 0.15, 0.1), true)
        "isr":
            c.draw_rect(Rect2(0, 0, w, h), Color(1, 1, 1), true)
            c.draw_rect(Rect2(0, h * 0.1, w, h * 0.14), Color(0.0, 0.22, 0.65), true)
            c.draw_rect(Rect2(0, h * 0.76, w, h * 0.14), Color(0.0, 0.22, 0.65), true)
            var cen := Vector2(w * 0.5, h * 0.5)
            var r := h * 0.2
            c.draw_colored_polygon(PackedVector2Array([cen + Vector2(0, -r), cen + Vector2(r * 0.87, r * 0.5), cen + Vector2(-r * 0.87, r * 0.5)]), Color(0.0, 0.22, 0.65))
            c.draw_colored_polygon(PackedVector2Array([cen + Vector2(0, r), cen + Vector2(r * 0.87, -r * 0.5), cen + Vector2(-r * 0.87, -r * 0.5)]), Color(0.0, 0.22, 0.65))
            c.draw_colored_polygon(PackedVector2Array([cen + Vector2(0, -r * 0.55), cen + Vector2(r * 0.48, r * 0.28), cen + Vector2(-r * 0.48, r * 0.28)]), Color(1, 1, 1))
            c.draw_colored_polygon(PackedVector2Array([cen + Vector2(0, r * 0.55), cen + Vector2(r * 0.48, -r * 0.28), cen + Vector2(-r * 0.48, -r * 0.28)]), Color(1, 1, 1))
        "irn":
            c.draw_rect(Rect2(0, 0, w, h / 3.0 + 1), Color(0.1, 0.6, 0.25), true)
            c.draw_rect(Rect2(0, h / 3.0, w, h / 3.0 + 1), Color(1, 1, 1), true)
            c.draw_rect(Rect2(0, h * 2.0 / 3.0, w, h / 3.0 + 1), Color(0.8, 0.1, 0.1), true)
            c.draw_circle(Vector2(w * 0.5, h * 0.5), h * 0.1, Color(0.8, 0.1, 0.1))
        "pak":
            c.draw_rect(Rect2(0, 0, w, h), Color(0.0, 0.35, 0.15), true)
            c.draw_rect(Rect2(0, 0, w * 0.25, h), Color(1, 1, 1), true)
            c.draw_circle(Vector2(w * 0.62, h * 0.5), h * 0.28, Color(1, 1, 1))
            c.draw_circle(Vector2(w * 0.68, h * 0.45), h * 0.24, Color(0.0, 0.35, 0.15))
            _star(c, Vector2(w * 0.72, h * 0.38), h * 0.12, Color(1, 1, 1))
        "ind":
            c.draw_rect(Rect2(0, 0, w, h / 3.0 + 1), Color(1.0, 0.6, 0.2), true)
            c.draw_rect(Rect2(0, h / 3.0, w, h / 3.0 + 1), Color(1, 1, 1), true)
            c.draw_rect(Rect2(0, h * 2.0 / 3.0, w, h / 3.0 + 1), Color(0.07, 0.53, 0.03), true)
            c.draw_arc(Vector2(w * 0.5, h * 0.5), h * 0.12, 0, TAU, 20, Color(0.0, 0.0, 0.5), 1.5)
        "chn":
            c.draw_rect(Rect2(0, 0, w, h), Color(0.88, 0.1, 0.1), true)
            _star(c, Vector2(w * 0.2, h * 0.28), h * 0.2, Color(1, 0.85, 0.1))
            for k in range(4):
                _star(c, Vector2(w * (0.38 + float(k % 2) * 0.05 + float(k / 2) * 0.0), h * (0.12 + float(k) * 0.15)), h * 0.06, Color(1, 0.85, 0.1))
        _:
            c.draw_rect(Rect2(0, 0, w, h), COUNTRIES[idx]["col"], true)
    c.draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 0.5), false, 1.0)


func _clear(n: Node) -> void:
    for ch in n.get_children():
        n.remove_child(ch)
        ch.queue_free()


# =====================================================================
#  UI - construction
# =====================================================================
func _build_ui() -> void:
    ui = CanvasLayer.new()
    ui.layer = 5
    add_child(ui)
    ui_root = Control.new()
    ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
    ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui.add_child(ui_root)

    flash_rect = ColorRect.new()
    flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    flash_rect.color = Color(1, 1, 1, 0)
    flash_rect.visible = false
    ui_root.add_child(flash_rect)

    # ---- top bar ----
    top_bar = PanelContainer.new()
    top_bar.add_theme_stylebox_override("panel", _sb(C_PANEL, 0))
    top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
    top_bar.custom_minimum_size = Vector2(0, 60)
    ui_root.add_child(top_bar)
    var th := _hbox(14)
    top_bar.add_child(th)
    flag_holder = Control.new()
    flag_holder.custom_minimum_size = Vector2(60, 40)
    th.add_child(flag_holder)
    lbl_country = _lbl("", 22)
    th.add_child(lbl_country)
    lbl_money = _lbl("$0", 24, Color(0.5, 1.0, 0.6))
    th.add_child(lbl_money)
    lbl_income = _lbl("", 17, C_DIM)
    th.add_child(lbl_income)
    lbl_pop = _lbl("", 18)
    th.add_child(lbl_pop)
    lbl_happy = _lbl("", 18)
    lbl_happy.visible = false
    th.add_child(lbl_happy)
    lbl_rp = _lbl("", 18, Color(0.6, 0.85, 1.0))
    th.add_child(lbl_rp)
    var sp := Control.new()
    sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    th.add_child(sp)
    lbl_date = _lbl("", 18, C_DIM)
    th.add_child(lbl_date)
    var labels := ["II", "1x", "2x", "4x"]
    for k in range(4):
        var spd_v: int = [0, 1, 2, 4][k]
        var b := _btn(labels[k], "dark", func():
            speed = spd_v
            _refresh_hud(), 52, 46, 18)
        th.add_child(b)
        speed_btns.append(b)
    th.add_child(_btn("MENU", "dark", func(): _show_menu(_has_save()), 84, 46, 17))

    # ---- ticker ----
    ticker_panel = PanelContainer.new()
    ticker_panel.add_theme_stylebox_override("panel", _sb(Color(0, 0, 0, 0.55), 8))
    ticker_panel.anchor_left = 0.0
    ticker_panel.anchor_right = 1.0
    ticker_panel.anchor_top = 1.0
    ticker_panel.anchor_bottom = 1.0
    ticker_panel.offset_left = 12
    ticker_panel.offset_right = -12
    ticker_panel.offset_top = -120
    ticker_panel.offset_bottom = -90
    ticker_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    ui_root.add_child(ticker_panel)
    ticker_lbl = _lbl("", 17)
    ticker_panel.add_child(ticker_lbl)
    ticker_panel.gui_input.connect(func(ev):
        if ev is InputEventMouseButton and ev.pressed:
            _open_tab("world"))

    # ---- dock ----
    var dock_panel := PanelContainer.new()
    dock_panel.add_theme_stylebox_override("panel", _sb(C_PANEL, 14))
    dock_panel.anchor_left = 0.5
    dock_panel.anchor_right = 0.5
    dock_panel.anchor_top = 1.0
    dock_panel.anchor_bottom = 1.0
    dock_panel.offset_top = -84
    dock_panel.offset_bottom = -8
    dock_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    ui_root.add_child(dock_panel)
    dock = _hbox(6)
    dock_panel.add_child(dock)
    var tabs := [["BUILD\n(Banao)", "build"], ["MILITARY\n(Fauj)", "mil"], ["AIR\n(Hawai)", "air"], ["NAVY\n(Behri)", "navy"], ["RESEARCH\n(Tehqeeq)", "res"], ["WORLD\n(Dunya)", "world"]]
    for t in tabs:
        var key: String = t[1]
        dock.add_child(_btn(t[0], "dark", func(): _open_tab(key), 118, 60, 15))

    # ---- toasts + banner ----
    toast_box = _vbox(4)
    toast_box.anchor_left = 0.5
    toast_box.anchor_right = 0.5
    toast_box.offset_top = 70
    toast_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
    toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(toast_box)
    banner_panel = PanelContainer.new()
    banner_panel.add_theme_stylebox_override("panel", _sb(Color(0.7, 0.08, 0.08, 0.92), 10, Color(1, 0.6, 0.6), 2))
    banner_panel.anchor_left = 0.5
    banner_panel.anchor_right = 0.5
    banner_panel.offset_top = 130
    banner_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    banner_panel.visible = false
    banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(banner_panel)
    banner_lbl = _lbl("", 22, Color(1, 1, 1))
    banner_panel.add_child(banner_lbl)

    # ---- window ----
    win_root = PanelContainer.new()
    win_root.add_theme_stylebox_override("panel", _sb(C_PANEL, 14, Color(0.25, 0.4, 0.65), 2))
    win_root.anchor_left = 0.0
    win_root.anchor_right = 1.0
    win_root.anchor_top = 0.0
    win_root.anchor_bottom = 1.0
    win_root.offset_left = 70
    win_root.offset_right = -70
    win_root.offset_top = 68
    win_root.offset_bottom = -96
    win_root.visible = false
    ui_root.add_child(win_root)
    var wv := _vbox(6)
    win_root.add_child(wv)
    var wh := _hbox(8)
    wv.add_child(wh)
    win_title = _lbl("", 26, Color(1, 0.9, 0.5))
    win_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    wh.add_child(win_title)
    wh.add_child(_btn("X", "bad", func(): _close_window(), 60, 46, 22))
    win_scroll = ScrollContainer.new()
    win_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    win_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    wv.add_child(win_scroll)
    win_body = _vbox(8)
    win_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    win_scroll.add_child(win_body)

    # ---- side panel ----
    side_panel = PanelContainer.new()
    side_panel.add_theme_stylebox_override("panel", _sb(C_PANEL, 12, Color(0.25, 0.4, 0.65), 2))
    side_panel.anchor_left = 1.0
    side_panel.anchor_right = 1.0
    side_panel.anchor_top = 0.0
    side_panel.anchor_bottom = 0.0
    side_panel.offset_left = -330
    side_panel.offset_right = -8
    side_panel.offset_top = 70
    side_panel.visible = false
    ui_root.add_child(side_panel)
    side_body = _vbox(5)
    side_panel.add_child(side_body)

    # ---- placement bar ----
    place_bar = PanelContainer.new()
    place_bar.add_theme_stylebox_override("panel", _sb(C_PANEL, 12, Color(0.3, 0.8, 0.4), 2))
    place_bar.anchor_left = 0.5
    place_bar.anchor_right = 0.5
    place_bar.anchor_top = 1.0
    place_bar.anchor_bottom = 1.0
    place_bar.offset_top = -190
    place_bar.offset_bottom = -92
    place_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
    place_bar.visible = false
    ui_root.add_child(place_bar)
    var pv := _vbox(4)
    place_bar.add_child(pv)
    place_lbl = _lbl("", 19)
    pv.add_child(place_lbl)
    var ph := _hbox(10)
    pv.add_child(ph)
    ph.add_child(_btn("ROTATE", "dark", func():
        place_r = (place_r + 1) % 4
        _update_ghost(), 120, 52))
    ph.add_child(_btn("CANCEL", "bad", func(): _cancel_place(), 120, 52))
    place_ok_btn = _btn("BUILD", "good", func(): _confirm_place(), 160, 52)
    ph.add_child(place_ok_btn)

    # ---- popup ----
    popup_root = Control.new()
    popup_root.set_anchors_preset(Control.PRESET_FULL_RECT)
    popup_root.visible = false
    popup_root.mouse_filter = Control.MOUSE_FILTER_STOP
    ui_root.add_child(popup_root)
    var dim := ColorRect.new()
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.color = Color(0, 0, 0, 0.55)
    dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
    popup_root.add_child(dim)
    popup_panel = PanelContainer.new()
    popup_panel.add_theme_stylebox_override("panel", _sb(C_PANEL, 16, Color(0.9, 0.7, 0.2), 2))
    popup_panel.anchor_left = 0.5
    popup_panel.anchor_right = 0.5
    popup_panel.anchor_top = 0.5
    popup_panel.anchor_bottom = 0.5
    popup_panel.offset_left = -330
    popup_panel.offset_right = 330
    popup_panel.offset_top = -160
    popup_panel.offset_bottom = 160
    popup_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    popup_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    popup_root.add_child(popup_panel)

    # ---- menu ----
    menu_root = Control.new()
    menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
    menu_root.visible = false
    menu_root.mouse_filter = Control.MOUSE_FILTER_STOP
    ui_root.add_child(menu_root)


func _refresh_hud() -> void:
    if cs.is_empty():
        return
    var s: Dictionary = cs[me]
    var cd: Dictionary = COUNTRIES[me]
    if flag_holder.get_child_count() == 0 or flag_holder.get_meta("idx", -1) != me:
        _clear(flag_holder)
        flag_holder.add_child(_mk_flag(me, 60, 40))
        flag_holder.set_meta("idx", me)
    lbl_country.text = String(cd["name"])
    lbl_money.text = _fmt(s["money"])
    lbl_money.add_theme_color_override("font_color", Color(0.5, 1.0, 0.6) if s["money"] >= 0 else Color(1, 0.4, 0.4))
    var net: float = s["last_inc"]
    lbl_income.text = ("+" if net >= 0 else "") + _fmt(net) + "/mo"
    lbl_income.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6) if net >= 0 else Color(1, 0.5, 0.5))
    lbl_pop.text = "Pop " + (String.num(s["pop"], 1) + "M")
    var hp: float = s["happy"]
    lbl_happy.text = "Approval " + str(int(hp)) + "%"
    lbl_happy.add_theme_color_override("font_color", Color(0.5, 1.0, 0.6) if hp >= 55.0 else (Color(1, 0.8, 0.3) if hp >= 38.0 else Color(1, 0.4, 0.4)))
    lbl_rp.text = ("RP " + str(int(s["rp"])) + "/" + str(int(TECHS[s["cur"]]["cost"]))) if s["cur"] != "" else "RP -"
    var mn := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    lbl_date.text = mn[month % 12] + " " + str(2026 + month / 12)
    var sv := [0, 1, 2, 4]
    for k in range(4):
        speed_btns[k].add_theme_stylebox_override("normal", _sb(C_ACC if speed == sv[k] else Color(0.18, 0.22, 0.3), 9))


func _ticker(text: String, kind: String) -> void:
    if ticker_lbl == null:
        return
    ticker_lbl.text = text
    var col := C_TXT
    match kind:
        "bad": col = Color(1.0, 0.55, 0.5)
        "good": col = Color(0.55, 1.0, 0.65)
        "warn": col = Color(1.0, 0.85, 0.4)
    ticker_lbl.add_theme_color_override("font_color", col)
    ticker_t = 14.0
    ticker_panel.visible = true
    if kind == "bad" or kind == "good" or kind == "warn":
        _toast(text, kind)


func _toast(text: String, kind: String = "info") -> void:
    if toast_box == null:
        return
    while toast_box.get_child_count() >= 3:
        var oc = toast_box.get_child(0)
        toast_box.remove_child(oc)
        oc.queue_free()
    var p := PanelContainer.new()
    var col := Color(0.1, 0.16, 0.28, 0.95)
    match kind:
        "bad": col = Color(0.5, 0.1, 0.1, 0.95)
        "good": col = Color(0.08, 0.38, 0.2, 0.95)
        "warn": col = Color(0.5, 0.36, 0.05, 0.95)
    p.add_theme_stylebox_override("panel", _sb(col, 10))
    p.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var l := _lbl(text, 18)
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.custom_minimum_size = Vector2(560, 0)
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    p.add_child(l)
    toast_box.add_child(p)
    var tw := create_tween()
    tw.tween_interval(5.0)
    tw.tween_property(p, "modulate:a", 0.0, 0.6)
    tw.tween_callback(p.queue_free)


func _banner(text: String, kind: String = "bad") -> void:
    banner_lbl.text = text
    banner_panel.visible = true
    banner_t = 7.0


func _popup(title: String, text: String, choices: Array) -> void:
    popup_queue.append({"title": title, "text": text, "choices": choices})
    if not popup_open:
        _next_popup()


func _next_popup() -> void:
    if popup_queue.is_empty():
        popup_root.visible = false
        popup_open = false
        return
    var p: Dictionary = popup_queue.pop_front()
    popup_open = true
    popup_root.visible = true
    _snd("msg")
    _clear(popup_panel)
    var v := _vbox(10)
    popup_panel.add_child(v)
    v.add_child(_lbl(p["title"], 28, Color(1, 0.88, 0.4)))
    v.add_child(_lbl(p["text"], 20, C_TXT, true))
    var sp := Control.new()
    sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
    v.add_child(sp)
    for ch in p["choices"]:
        var code: String = ch[1]
        v.add_child(_btn(ch[0], "good" if code != "" and not code.begins_with("prop:refuse") and not code.begins_with("prop:stayout") and not code.ends_with("_no") else "dark", func():
            popup_open = false
            if code != "":
                _event_choice(code)
            _next_popup(), 0, 54))


func _hud_update(delta: float) -> void:
    hud_t += delta
    if ticker_t > 0.0:
        ticker_t -= delta
        if ticker_t <= 0.0:
            ticker_panel.visible = false
    if banner_t > 0.0:
        banner_t -= delta
        if banner_t <= 0.0:
            banner_panel.visible = false
    if hud_t > 0.4:
        hud_t = 0.0
        _refresh_hud()
        if side_panel.visible and sel_b >= 0:
            if bmap.has(sel_b):
                _show_building_panel(bmap[sel_b])
            else:
                side_panel.visible = false
        elif side_panel.visible and sel_ship >= 0:
            _show_ship_panel()
        if mode == "place":
            _update_place_label()
    if win_root.visible:
        win_refresh_t += delta
        if win_refresh_t > 1.2 and win_tab in ["mil", "air", "navy", "gov", "res", "dip", "world", "strike"]:
            win_refresh_t = 0.0
            _win_refresh()


# =====================================================================
#  WINDOWS
# =====================================================================
func _open_tab(tab: String, arg: Variant = null) -> void:
    win_tab = tab
    win_arg = arg
    win_root.visible = true
    win_scroll.scroll_vertical = 0
    _win_refresh()


func _close_window() -> void:
    win_root.visible = false
    win_tab = ""
    if mode == "strike" or mode == "airtarget":
        mode = "none"


func _hide_all_windows() -> void:
    win_root.visible = false
    side_panel.visible = false
    place_bar.visible = false
    mode = "none"
    if ghost_node and is_instance_valid(ghost_node):
        ghost_node.queue_free()
        ghost_node = null
    for gm in ground_mats:
        gm.set_shader_parameter("grid_on", 0.0)
        gm.set_shader_parameter("ghost", Vector4(0, 0, 0, 0))


func _win_refresh() -> void:
    if not win_root.visible or cs.is_empty():
        return
    var sv := win_scroll.scroll_vertical
    _clear(win_body)
    match win_tab:
        "build": _tab_build()
        "mil": _tab_mil()
        "air": _tab_air()
        "navy": _tab_navy()
        "dip": _tab_dip()
        "gov": _tab_gov()
        "res": _tab_res()
        "world": _tab_world()
        "country": _tab_country(int(win_arg))
        "strike": _tab_strike(win_arg)
        "summit": _tab_summit(int(win_arg))
    win_scroll.set_deferred("scroll_vertical", sv)


func _grid(cols: int) -> GridContainer:
    var g := GridContainer.new()
    g.columns = cols
    g.add_theme_constant_override("h_separation", 8)
    g.add_theme_constant_override("v_separation", 8)
    g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return g


# ------------------------------- BUILD -------------------------------------
var build_cat := "city"

func _tab_build() -> void:
    win_title.text = "BUILD  -  place anything anywhere on your land"
    var tabs := _hbox(6)
    win_body.add_child(tabs)
    for t in [["City", "city"], ["Services", "service"], ["Military", "mil"], ["Air Force", "air"], ["Navy", "navy"]]:
        var key: String = t[1]
        tabs.add_child(_btn(t[0], "good" if build_cat == key else "dark", func():
            build_cat = key
            _win_refresh(), 0, 46, 18))
    var g := _grid(3)
    win_body.add_child(g)
    for t in _all_types():
        var d := _bdef(t, me)
        if String(d["cat"]) != build_cat:
            continue
        var unl := _unlocked(me, t)
        var cv := _card(C_PANEL2 if unl else Color(0.07, 0.08, 0.1, 0.95))
        cv.add_child(_lbl(String(d["name"]), 21, C_TXT if unl else C_DIM))
        cv.add_child(_lbl(_fmt(float(d["cost"])) + "   (" + str(d["w"]) + "x" + str(d["d"]) + ")", 18, Color(0.6, 1.0, 0.7) if unl else C_DIM))
        cv.add_child(_lbl(String(d["desc"]), 15, C_DIM, true))
        if unl:
            var tt = t
            cv.add_child(_btn("PLACE", "good", func(): _begin_place(tt), 0, 46))
        else:
            cv.add_child(_lbl("LOCKED: " + _unlock_reason(me, t), 15, Color(1, 0.6, 0.4), true))
        _add_card(g, cv)


# ------------------------------- MILITARY ---------------------------------
func _tab_mil() -> void:
    win_title.text = "MILITARY"
    var s: Dictionary = cs[me]
    var top := _card()
    top.add_child(_lbl("Missile stock: " + str(_ammo_total(me)) + " / " + str(_ammo_cap(me)) + "      Jets: " + str(_jet_total(me)) + "      Ships: " + str(_ship_count(me)) + "      Power: " + str(int(_power(me))), 20))
    var nAA := 0
    for b in s["bl"]:
        if _is_aa(b) and b["st"] == "ok":
            nAA += 1
    top.add_child(_lbl("Air defence sites: " + str(nAA) + "      Radars: " + str(_count_b(me, "radar")) + "      Weapon price modifier: x" + String.num(_wmult(me), 2), 17, C_DIM))
    _add_card(win_body, top)
    win_body.add_child(_lbl("MISSILES  (store in Missile Bases, launch from the Diplomacy > country > Strike menu)", 18, Color(1, 0.9, 0.5)))
    for k in range(6):
        var st := _weapon_state(me, "msl", k)
        var cv := _card()
        var h := _hbox(10)
        cv.add_child(h)
        var vv := _vbox(2)
        vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(vv)
        var md: Dictionary = MSL[k]
        vv.add_child(_lbl(_msl_name(me, k) + "   [" + String(md["short"]) + "]   in stock: " + str(s["ammo"][k]), 20))
        var rg := "unlimited" if float(md["range"]) > 90000.0 else str(int(md["range"]))
        vv.add_child(_lbl("Range " + rg + "   Damage " + (str(int(md["dmg"])) if not md["nuke"] else "TOTAL") + "   Blast " + str(int(md["rad"])) + "   Price " + _fmt(st["price"]), 15, C_DIM))
        if st["state"] == "ready":
            for n in [1, 5, 10]:
                var nn: int = n
                var kk := k
                h.add_child(_btn("+" + str(n), "good", func():
                    var e := _buy_missile(me, kk, nn)
                    if e != "":
                        _toast(e, "warn")
                    _win_refresh(), 74, 48))
        elif st["state"] == "unlockable":
            var kk2 := k
            h.add_child(_btn("UNLOCK " + _fmt(st["fee"]), "warn", func():
                var e2 := _unlock_weapon(me, "msl", kk2)
                if e2 != "":
                    _toast(e2, "warn")
                _win_refresh(), 200, 48))
        else:
            h.add_child(_lbl(String(st["reason"]), 15, Color(1, 0.6, 0.4), true))
        _add_card(win_body, cv)
    var hint := _lbl("Tip: to attack, open DIPLOMACY, choose an enemy country, press Missile Strike, then tap a building on its land.", 16, C_DIM, true)
    win_body.add_child(hint)


# ------------------------------- AIR ---------------------------------------
func _tab_air() -> void:
    win_title.text = "AIR FORCE"
    var s: Dictionary = cs[me]
    var ready := 0
    var out := 0
    var rearm := 0
    for b in s["bl"]:
        if b["t"] == "airbase":
            for j in b["jets"]:
                match String(j["state"]):
                    "ready": ready += 1
                    "out": out += 1
                    _: rearm += 1
    var top := _card()
    top.add_child(_lbl("Airbases: " + str(_count_b(me, "airbase")) + "      Jets: " + str(_jet_total(me)) + "  (ready " + str(ready) + ", airborne " + str(out) + ", rearming " + str(rearm) + ")", 20))
    top.add_child(_lbl("Hangar space: " + str(_jet_total_ab(me)) + " / " + str(6 * _total_ab_level(me)) + "   -   build or upgrade Air Force Bases for more.", 16, C_DIM))
    _add_card(win_body, top)
    win_body.add_child(_lbl("BUY JETS", 18, Color(1, 0.9, 0.5)))
    for t in range(4):
        var st := _weapon_state(me, "jet", t)
        var cv := _card()
        var h := _hbox(10)
        cv.add_child(h)
        var vv := _vbox(2)
        vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(vv)
        var jd: Dictionary = JET_T[t]
        vv.add_child(_lbl(_jet_name(me, t), 21))
        vv.add_child(_lbl("Speed " + str(int(jd["speed"])) + "   Missiles " + str(jd["shots"]) + "   Damage " + str(int(jd["dmg"])) + "   Stealth/evasion " + str(int(float(jd["evade"]) * 100.0)) + "%   Dogfight skill " + String.num(float(jd["skill"]), 1) + "   Price " + _fmt(st["price"]), 15, C_DIM, true))
        if st["state"] == "ready":
            var tt := t
            h.add_child(_btn("BUY", "good", func():
                var e := _buy_jet(me, tt)
                if e != "":
                    _toast(e, "warn")
                _win_refresh(), 110, 48))
        elif st["state"] == "unlockable":
            var tt2 := t
            h.add_child(_btn("UNLOCK " + _fmt(st["fee"]), "warn", func():
                var e2 := _unlock_weapon(me, "jet", tt2)
                if e2 != "":
                    _toast(e2, "warn")
                _win_refresh(), 190, 48))
        else:
            h.add_child(_lbl(String(st["reason"]), 15, Color(1, 0.6, 0.4), true))
        _add_card(win_body, cv)
    win_body.add_child(_lbl("MISSIONS", 18, Color(1, 0.9, 0.5)))
    win_body.add_child(_lbl("Air strike: DIPLOMACY > enemy country > Air Strike, then tap a building. Fighter sweep sends jets to hunt enemy aircraft over a country (flying into a country you are not at war with is an airspace violation!). Jets that enter hostile airspace are met by scrambled fighters and air defence.", 16, C_DIM, true))
    var g := _grid(3)
    win_body.add_child(g)
    for j in range(9):
        if j == me or _allied(me, j):
            continue
        var jj := j
        g.add_child(_btn("Sweep " + String(COUNTRIES[j]["short"]), "dark" if not _at_war(me, j) else "bad", func():
            var n := _launch_sweep(me, jj, 3)
            if n == 0:
                _toast("No ready jets", "warn")
            else:
                _toast(str(n) + " jets on a fighter sweep over " + String(COUNTRIES[jj]["name"]), "info")
            _win_refresh(), 0, 46, 17))


func _jet_total_ab(c: int) -> int:
    var n := 0
    for b in cs[c]["bl"]:
        if b["t"] == "airbase":
            n += b["jets"].size()
    return n


# ------------------------------- NAVY --------------------------------------
func _tab_navy() -> void:
    win_title.text = "NAVY"
    var top := _card()
    top.add_child(_lbl("Ports: " + str(_count_b(me, "port")) + "      Ships: " + str(_ship_count(me)) + " / " + str(_ship_cap(me)), 20))
    top.add_child(_lbl("Ships are first LOCKED. When your treasury is big enough you can UNLOCK a class, then BUY ships at your Naval Port (build one on the coast).", 16, C_DIM, true))
    _add_card(win_body, top)
    for k in range(5):
        var st := _weapon_state(me, "ship", k)
        var sd: Dictionary = SHIPS[k]
        var cv := _card()
        var h := _hbox(10)
        cv.add_child(h)
        var vv := _vbox(2)
        vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(vv)
        vv.add_child(_lbl(String(sd["name"]) + "  -  " + String(sd["real"]), 20))
        vv.add_child(_lbl("Hull " + str(int(sd["hp"])) + "   Speed " + str(int(sd["speed"])) + "   Weapon range " + (str(int(sd["rng"])) if float(sd["rng"]) > 0.0 else "air wing") + "   Price " + _fmt(st["price"]), 15, C_DIM))
        if st["state"] == "ready":
            var kk := k
            h.add_child(_btn("BUY", "good", func():
                var e := _buy_ship(me, kk)
                if e != "":
                    _toast(e, "warn")
                _win_refresh(), 110, 48))
        elif st["state"] == "unlockable":
            var kk2 := k
            h.add_child(_btn("UNLOCK " + _fmt(st["fee"]), "warn", func():
                var e2 := _unlock_weapon(me, "ship", kk2)
                if e2 != "":
                    _toast(e2, "warn")
                _win_refresh(), 190, 48))
        else:
            h.add_child(_lbl("LOCKED: " + String(st["reason"]), 15, Color(1, 0.6, 0.4), true))
        _add_card(win_body, cv)
    win_body.add_child(_lbl("YOUR FLEET", 18, Color(1, 0.9, 0.5)))
    var any := false
    for sh in ships:
        if sh["own"] != me or sh["dead"]:
            continue
        any = true
        var cv2 := _card()
        var h2 := _hbox(10)
        cv2.add_child(h2)
        var shid: int = sh["id"]
        var tx := String(SHIPS[sh["k"]]["name"]) + "   hull " + str(int(100.0 * sh["hp"] / sh["mhp"])) + "%" + ("   jets " + str(sh["jets"].size()) if sh["k"] == 4 else "")
        var l := _lbl(tx, 18)
        l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h2.add_child(l)
        h2.add_child(_btn("SELECT", "good", func():
            sel_ship = shid
            sel_b = -1
            for q in ships:
                if q["id"] == shid:
                    _focus(q["pos"], 260.0)
            _close_window()
            _show_ship_panel(), 120, 44, 17))
        _add_card(win_body, cv2)
    if not any:
        win_body.add_child(_lbl("No ships yet.", 17, C_DIM))


# ------------------------------- GOVERNMENT --------------------------------
func _tab_gov() -> void:
    win_title.text = "GOVERNMENT of " + String(COUNTRIES[me]["name"])
    var s: Dictionary = cs[me]
    var top := _card()
    top.add_child(_lbl("Head of government: The " + String(COUNTRIES[me]["title"]) + " (you)      Capital: " + String(COUNTRIES[me]["cap"]), 20))
    top.add_child(_lbl("Population " + String.num(s["pop"], 1) + " million      Approval " + str(int(s["happy"])) + "%      Reputation " + str(int(s["rep"])) + "      Stability bonus " + str(int(s["stab"])), 18))
    var r := _compute_income(me)
    top.add_child(_lbl("Income " + _fmt(r["inc"]) + "/mo      Upkeep " + _fmt(r["up"]) + "/mo      War weariness " + str(int(s["war_w"])) + "      Next election in " + str(max(0, int(s["next_elec"]) - month)) + " months", 17, C_DIM))
    if s["prot"] > 0.25:
        top.add_child(_lbl("PROTESTS: citizens are demonstrating in the streets! Lower taxes, build hospitals/police/parks or change policies.", 17, Color(1, 0.5, 0.4), true))
    _add_card(win_body, top)
    # tax
    var tc := _card()
    var tl := _lbl("TAX RATE: " + str(int(round(s["tax"] * 100.0))) + "%   (higher tax = more money, less approval)", 19)
    tc.add_child(tl)
    var sl := HSlider.new()
    sl.min_value = 5
    sl.max_value = 50
    sl.step = 1
    sl.value = round(s["tax"] * 100.0)
    sl.custom_minimum_size = Vector2(0, 40)
    sl.value_changed.connect(func(v: float):
        cs[me]["tax"] = v / 100.0
        tl.text = "TAX RATE: " + str(int(v)) + "%   (higher tax = more money, less approval)")
    tc.add_child(sl)
    _add_card(win_body, tc)
    win_body.add_child(_lbl("POLICIES  (toggle on/off)", 18, Color(1, 0.9, 0.5)))
    for k in POLICIES.keys():
        var pd: Dictionary = POLICIES[k]
        var on: bool = s["pol"].get(k, false)
        var cv := _card(Color(0.1, 0.2, 0.14, 0.96) if on else C_PANEL2)
        var h := _hbox(10)
        cv.add_child(h)
        var vv := _vbox(2)
        vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(vv)
        vv.add_child(_lbl(String(pd["name"]), 20))
        vv.add_child(_lbl(String(pd["desc"]), 15, C_DIM, true))
        var eff := []
        if pd.has("inc"): eff.append("income " + ("%+d" % int(float(pd["inc"]) * 100.0)) + "%")
        if pd.has("happy"): eff.append("approval " + ("%+d" % int(pd["happy"])))
        if pd.has("mil"): eff.append("weapon price " + ("%+d" % int(float(pd["mil"]) * 100.0)) + "%")
        if pd.has("rp"): eff.append("research " + ("%+d" % int(float(pd["rp"]) * 100.0)) + "%")
        if pd.has("stab"): eff.append("stability " + ("%+d" % int(pd["stab"])))
        if pd.has("rep"): eff.append("reputation " + ("%+.1f" % float(pd["rep"])))
        if float(pd.get("cost", 0)) != 0.0: eff.append("cost " + _fmt(float(pd["cost"])) + "/mo")
        vv.add_child(_lbl(", ".join(eff), 14, Color(0.6, 0.85, 1.0)))
        var kk: String = k
        h.add_child(_btn("ON" if on else "OFF", "good" if on else "dark", func():
            _toggle_policy(me, kk)
            _win_refresh(), 90, 50))
        _add_card(win_body, cv)


# ------------------------------- RESEARCH ----------------------------------
func _tab_res() -> void:
    win_title.text = "RESEARCH"
    var s: Dictionary = cs[me]
    var lab := _lab_level(me)
    var top := _card()
    if lab <= 0:
        top.add_child(_lbl("You need a Research Lab. Build one in BUILD > Military (needs " + _fmt(float(BDEFS["lab"]["unlock"])) + " treasury).", 19, Color(1, 0.7, 0.4), true))
    else:
        var r := _compute_income(me)
        top.add_child(_lbl("Research Lab level " + str(lab) + "      Research points per month: " + String.num(float(r["rp"]) * (1.0 + _pol_sum(me, "rp")), 1), 20))
        if s["cur"] != "":
            var t: Dictionary = TECHS[s["cur"]]
            top.add_child(_lbl("Researching: " + String(t["name"]) + "   " + str(int(s["rp"])) + " / " + str(int(t["cost"])), 19, Color(0.6, 0.9, 1.0)))
            top.add_child(_bar(s["rp"] / float(t["cost"]), Color(0.3, 0.7, 1.0), 400, 14))
        else:
            top.add_child(_lbl("Nothing being researched. Pick a technology below.", 17, C_DIM))
    _add_card(win_body, top)
    for k in TECHS.keys():
        var t2: Dictionary = TECHS[k]
        var done: bool = s["tech"].has(k)
        var cv := _card(Color(0.1, 0.2, 0.14, 0.96) if done else C_PANEL2)
        var h := _hbox(10)
        cv.add_child(h)
        var vv := _vbox(2)
        vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(vv)
        var nuke_tag := "   [NUCLEAR PATH]" if String(k).begins_with("nuc") else ""
        vv.add_child(_lbl(String(t2["name"]) + nuke_tag, 20, Color(1, 0.8, 0.5) if nuke_tag != "" else C_TXT))
        var req := ""
        if String(t2["req"]) != "":
            req = "   needs: " + String(TECHS[t2["req"]]["name"])
        vv.add_child(_lbl(String(t2["desc"]) + "   Cost " + str(t2["cost"]) + " RP   Lab lvl " + str(t2["lab"]) + req, 15, C_DIM, true))
        if done:
            h.add_child(_lbl("DONE", 20, Color(0.5, 1, 0.6)))
        else:
            var kk: String = k
            var err := ""
            if int(t2["lab"]) > lab or lab <= 0 or (String(t2["req"]) != "" and not s["tech"].has(t2["req"])) or (kk.begins_with("nuc") and s["pol"].get("npt", false)):
                err = "x"
            h.add_child(_btn("RESEARCH" if s["cur"] != kk else "IN PROGRESS", "good" if err == "" else "off", func():
                var e := _start_research(me, kk)
                if e != "":
                    _toast(e, "warn")
                _win_refresh(), 150, 48, 17))
        _add_card(win_body, cv)


# ------------------------------- WORLD / NEWS ------------------------------
func _tab_world() -> void:
    win_title.text = "WORLD OVERVIEW"
    var g := _grid(1)
    win_body.add_child(g)
    var order := []
    for i in range(9):
        order.append(i)
    order.sort_custom(func(a, b): return _power(a) > _power(b))
    for i in order:
        var cv := _card(Color(0.12, 0.2, 0.32, 0.96) if i == me else C_PANEL2)
        var h := _hbox(12)
        cv.add_child(h)
        h.add_child(_mk_flag(i, 54, 36))
        var vv := _vbox(1)
        vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(vv)
        var wars := []
        for j in _wars_of(i):
            wars.append(String(COUNTRIES[j]["short"]))
        vv.add_child(_lbl(String(COUNTRIES[i]["name"]) + ("  (YOU)" if i == me else "") + ("   NUCLEAR" if cs[i]["nuke"] else ""), 19))
        vv.add_child(_lbl("Pop " + String.num(cs[i]["pop"], 0) + "M   Treasury " + _fmt(cs[i]["money"]) + "   Power " + str(int(_power(i))) + ("   WAR vs " + ", ".join(wars) if wars.size() > 0 else ""), 15, Color(1, 0.6, 0.5) if wars.size() > 0 else C_DIM))
        var ii = i
        h.add_child(_btn("GO", "dark", func():
            _focus_country(ii)
            _close_window(), 70, 44, 17))
        _add_card(g, cv)
    win_body.add_child(_lbl("NEWS", 18, Color(1, 0.9, 0.5)))
    for n in news_log:
        var col := C_TXT
        match String(n["kind"]):
            "bad": col = Color(1.0, 0.55, 0.5)
            "good": col = Color(0.55, 1.0, 0.65)
            "warn": col = Color(1.0, 0.85, 0.4)
        win_body.add_child(_lbl("[" + str(n["m"]) + "] " + String(n["text"]), 16, col, true))


# ------------------------------- DIPLOMACY ---------------------------------
func _tab_dip() -> void:
    win_title.text = "DIPLOMACY"
    win_body.add_child(_lbl("Tap a country to talk, make treaties, visit with your PM, or go to war. You can also tap any foreign island on the map.", 16, C_DIM, true))
    for i in range(9):
        if i == me:
            continue
        var cv := _card()
        var h := _hbox(12)
        cv.add_child(h)
        h.add_child(_mk_flag(i, 60, 40))
        var vv := _vbox(2)
        vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(vv)
        var stt := _status_text(me, i)
        vv.add_child(_lbl(String(COUNTRIES[i]["name"]) + "   -   " + stt, 20, Color(1, 0.5, 0.45) if stt == "AT WAR" else (Color(0.5, 1, 0.6) if stt == "ALLIED" else C_TXT)))
        var rr := _hbox(8)
        vv.add_child(rr)
        rr.add_child(_lbl("Their opinion of you:", 14, C_DIM))
        rr.add_child(_relbar(cs[i]["rel"][me], 220))
        rr.add_child(_lbl(str(int(cs[i]["rel"][me])), 14, C_DIM))
        var ii := i
        h.add_child(_btn("OPEN", "good", func(): _open_tab("country", ii), 100, 50))
        _add_card(win_body, cv)


var country_msg := ""
var strike_kind := "missile"

func _tab_country(c: int) -> void:
    win_title.text = String(COUNTRIES[c]["name"]).to_upper()
    var s: Dictionary = cs[c]
    var hd := _card()
    var h := _hbox(14)
    hd.add_child(h)
    h.add_child(_mk_flag(c, 90, 60))
    var vv := _vbox(2)
    h.add_child(vv)
    vv.add_child(_lbl(String(COUNTRIES[c]["title"]) + " of " + String(COUNTRIES[c]["name"]) + "  -  capital " + String(COUNTRIES[c]["cap"]), 19))
    vv.add_child(_lbl("Status: " + _status_text(me, c) + "     Pop " + String.num(s["pop"], 0) + "M     Power " + str(int(_power(c))) + " (yours " + str(int(_power(me))) + ")", 16, C_DIM))
    vv.add_child(_lbl(String(COUNTRIES[c]["blurb"]), 15, C_DIM, true))
    var rr := _hbox(8)
    vv.add_child(rr)
    rr.add_child(_lbl("Relations:", 15))
    rr.add_child(_relbar(s["rel"][me], 260))
    rr.add_child(_lbl(str(int(s["rel"][me])), 15))
    var info := ""
    if s["nuke"]:
        info += "Nuclear armed.  "
    if cs[me]["trade"][c]:
        info += "Trade partner.  "
    if cs[me]["sanc"][c]:
        info += "You sanction them.  "
    if s["sanc"][me]:
        info += "They sanction you.  "
    var dist := int(_land_center(me).distance_to(_land_center(c)))
    info += "Distance " + str(dist)
    vv.add_child(_lbl(info, 15, C_DIM))
    _add_card(win_body, hd)
    if country_msg != "":
        var mc := _card(Color(0.16, 0.2, 0.1, 0.98))
        mc.add_child(_lbl(country_msg, 18, Color(1, 0.95, 0.6), true))
        _add_card(win_body, mc)
    var st: String = cs[me]["st"][c]
    var g := _grid(3)
    win_body.add_child(g)
    g.add_child(_btn("VIEW LAND", "dark", func():
        _focus_country(c)
        _close_window(), 0, 54, 18))
    if st == "war":
        g.add_child(_btn("MISSILE STRIKE", "bad", func(): _begin_strike("missile", c), 0, 54, 18))
        g.add_child(_btn("AIR STRIKE", "bad", func(): _begin_strike("air", c), 0, 54, 18))
        g.add_child(_btn("FIGHTER SWEEP", "bad", func():
            var n := _launch_sweep(me, c, 4)
            country_msg = (str(n) + " fighters sent to hunt over " + String(COUNTRIES[c]["short"]) + ".") if n > 0 else "No ready jets."
            _win_refresh(), 0, 54, 18))
        g.add_child(_btn("ASK FOR CEASEFIRE", "good", func():
            var r := _propose(me, c, "ceasefire")
            country_msg = String(r["msg"])
            _win_refresh(), 0, 54, 18))
    else:
        g.add_child(_btn("DECLARE WAR", "bad", func():
            _popup("Declare war on " + String(COUNTRIES[c]["name"]) + "?", "War means missiles, air raids and unrest. Their allies may join. Your people may protest.", [["Declare WAR", "war:" + str(c)], ["Cancel", ""]]), 0, 54, 18))
        g.add_child(_btn("FIGHTER SWEEP (provocation)", "warn", func():
            var n2 := _launch_sweep(me, c, 2)
            country_msg = (str(n2) + " jets flying into " + String(COUNTRIES[c]["short"]) + " airspace. This is an airspace violation!") if n2 > 0 else "No ready jets."
            _win_refresh(), 0, 54, 16))
    win_body.add_child(_lbl("Tip: jang mein AI jeet raha ho to ceasefire se inkar kar sakta hai. Mazboot defence banao aur dobara koshish karo.", 15, C_DIM, true))


func _begin_strike(kind: String, c: int) -> void:
    strike_kind = kind
    strike_target_c = c
    mode = "strike"
    _close_window()
    mode = "strike"
    _focus_country(c, 300.0)
    _toast("Tap a building in " + String(COUNTRIES[c]["name"]) + " to choose it as the target", "info")


func _target_picked(tb: Dictionary) -> void:
    mode = "none"
    if not _at_war(me, tb["c"]):
        _toast("You are not at war with " + String(COUNTRIES[tb["c"]]["name"]), "warn")
        return
    _open_tab("strike", tb)


func _tab_strike(tb: Variant) -> void:
    if tb == null or not (tb is Dictionary) or not bmap.has(tb["id"]):
        win_title.text = "TARGET"
        win_body.add_child(_lbl("Target no longer exists.", 18))
        return
    var d := _bdef(tb["t"], tb["c"])
    win_title.text = "STRIKE: " + String(d["name"]) + " in " + String(COUNTRIES[tb["c"]]["short"])
    var hc := _card()
    hc.add_child(_lbl("Target: " + String(d["name"]) + "   level " + str(tb["lvl"]) + "   health " + str(int(tb["hp"])) + " / " + str(int(tb["mhp"])) + ("   (DESTROYED)" if tb["st"] == "ruin" else ""), 19))
    var aa := 0
    var tx := Vector3(tb["x"], 0, tb["z"])
    for a in _aa_sources():
        if a["own"] == tb["c"] and _dist2(a["pos"], tx) < a["r"]:
            aa += 1
    hc.add_child(_lbl("Air defence sites covering the target: " + str(aa) + (" - expect interceptions" if aa > 0 else " - undefended"), 16, Color(1, 0.8, 0.4) if aa > 0 else Color(0.6, 1, 0.7)))
    _add_card(win_body, hc)
    if strike_kind == "missile":
        win_body.add_child(_lbl("MISSILES", 18, Color(1, 0.9, 0.5)))
        var any := false
        for k in range(6):
            if cs[me]["ammo"][k] <= 0:
                continue
            any = true
            var org := _missile_origins(me, k, tx)
            var cv := _card()
            var h := _hbox(8)
            cv.add_child(h)
            var l := _lbl(_msl_name(me, k) + "   x" + str(cs[me]["ammo"][k]) + ("" if not org.is_empty() else "   OUT OF RANGE"), 19, C_TXT if not org.is_empty() else Color(1, 0.5, 0.4))
            l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            h.add_child(l)
            if not org.is_empty():
                for n in [1, 3, 6, 99]:
                    var nn: int = n
                    var kk := k
                    var nuke: bool = MSL[k]["nuke"]
                    h.add_child(_btn("ALL" if n == 99 else str(n), "bad" if nuke else "good", func():
                        if MSL[kk]["nuke"]:
                            _popup("NUCLEAR STRIKE", "You are about to use a nuclear weapon on " + String(COUNTRIES[tb["c"]]["name"]) + ". The world will condemn you, allies will turn against you, and retaliation is likely.", [["LAUNCH", "nuke:" + str(tb["id"])], ["Cancel", ""]])
                        else:
                            var f := _fire_salvo(me, kk, nn, tb)
                            if f == 0:
                                _toast("Could not launch", "warn")
                            _win_refresh(), 70, 48))
            _add_card(win_body, cv)
        if not any:
            win_body.add_child(_lbl("No missiles in stock. Buy some in MILITARY (needs a Missile Base).", 17, Color(1, 0.7, 0.5), true))
    else:
        win_body.add_child(_lbl("AIR STRIKE", 18, Color(1, 0.9, 0.5)))
        var rdy := _jet_ready_count(me)
        var cv2 := _card()
        cv2.add_child(_lbl("Ready jets: " + str(rdy) + ".  Jets take off, fly across the sea into enemy airspace, fire their missiles and return. Enemy fighters will scramble and air defence will shoot at them.", 16, C_DIM, true))
        var h2 := _hbox(8)
        cv2.add_child(h2)
        for n in [1, 2, 4, 8]:
            var nn2: int = n
            h2.add_child(_btn("Send " + str(n), "good", func():
                var l := _launch_strike(me, tb, nn2)
                if l == 0:
                    _toast("No ready jets (buy jets in AIR)", "warn")
                _win_refresh(), 110, 52))
        _add_card(win_body, cv2)
    win_body.add_child(_btn("CHOOSE ANOTHER TARGET", "dark", func():
        if strike_kind == "missile":
            _begin_strike("missile", tb["c"])
        else:
            _begin_strike("air", tb["c"]), 0, 50))


func _tab_summit(c: int) -> void:
    win_title.text = "SUMMIT in " + String(COUNTRIES[c]["cap"]).to_upper()
    var hd := _card()
    var h := _hbox(12)
    hd.add_child(h)
    h.add_child(_mk_flag(c, 80, 54))
    h.add_child(_lbl("Your " + String(COUNTRIES[me]["title"]) + " meets the " + String(COUNTRIES[c]["title"]) + " of " + String(COUNTRIES[c]["name"]) + ".\nRelations: " + str(int(cs[c]["rel"][me])), 19, C_TXT, true))
    _add_card(win_body, hd)
    if country_msg != "":
        var mc := _card(Color(0.16, 0.2, 0.1, 0.98))
        mc.add_child(_lbl(country_msg, 18, Color(1, 0.95, 0.6), true))
        _add_card(win_body, mc)
    var g := _grid(2)
    win_body.add_child(g)
    g.add_child(_btn("JOINT STATEMENT (+12 relations)", "good", func():
        _add_rel(me, c, 12.0)
        country_msg = "A warm joint statement was published."
        _win_refresh(), 0, 60, 18))
    g.add_child(_btn("TRADE AGREEMENT", "good", func():
        country_msg = String(_propose(me, c, "trade", 0.25)["msg"])
        _win_refresh(), 0, 60, 18))
    g.add_child(_btn("DEFENCE PACT (alliance)", "good", func():
        country_msg = String(_propose(me, c, "alliance", 0.25)["msg"])
        _win_refresh(), 0, 60, 18))
    g.add_child(_btn("NON-AGGRESSION PACT", "dark", func():
        country_msg = String(_propose(me, c, "peace", 0.25)["msg"])
        _win_refresh(), 0, 60, 18))
    win_body.add_child(_btn("LEAVE SUMMIT", "dark", func():
        country_msg = ""
        _close_window(), 0, 54))


func _open_summit(c: int) -> void:
    country_msg = ""
    _open_tab("summit", c)


# ------------------------------- SIDE PANELS -------------------------------
func _hide_side_panel() -> void:
    side_panel.visible = false


func _show_building_panel(b: Dictionary) -> void:
    side_panel.visible = true
    _clear(side_body)
    var d := _bdef(b["t"], b["c"])
    side_body.add_child(_lbl(String(d["name"]) + "   Lv " + str(b["lvl"]), 22, Color(1, 0.9, 0.5)))
    if b["c"] != me:
        side_body.add_child(_lbl(String(COUNTRIES[b["c"]]["name"]), 17, C_DIM))
    side_body.add_child(_bar(b["hp"] / b["mhp"], Color(0.3, 0.85, 0.4) if b["hp"] > b["mhp"] * 0.5 else Color(0.9, 0.4, 0.3), 280, 14))
    var st := ""
    match String(b["st"]):
        "build": st = "Under construction " + str(int(b["prog"] * 100.0)) + "%"
        "ruin": st = "DESTROYED"
        _: st = "HP " + str(int(b["hp"])) + " / " + str(int(b["mhp"]))
    side_body.add_child(_lbl(st, 16))
    if b["c"] != me:
        if _at_war(me, b["c"]):
            side_body.add_child(_btn("STRIKE THIS", "bad", func():
                strike_kind = "missile"
                _open_tab("strike", b), 0, 48))
        side_body.add_child(_btn("CLOSE", "dark", func(): side_panel.visible = false; sel_b = -1, 0, 44))
        return
    side_body.add_child(_lbl(String(d["desc"]), 14, C_DIM, true))
    if float(d["inc"]) > 0.0:
        side_body.add_child(_lbl("Income " + _fmt(float(d["inc"]) * (1.0 + 0.6 * float(b["lvl"] - 1))) + "/mo", 15, Color(0.6, 1, 0.7)))
    if _is_aa(b):
        side_body.add_child(_lbl("Range " + str(int(AA_RANGE[_aa_tier(b)])), 15))
    if b["t"] == "airbase":
        side_body.add_child(_lbl("Jets " + str(b["jets"].size()) + " / " + str(6 * b["lvl"]), 15))
        side_body.add_child(_btn("BUY JETS", "good", func(): _open_tab("air"), 0, 44))
    if b["t"] == "missilebase":
        side_body.add_child(_btn("MISSILES", "good", func(): _open_tab("mil"), 0, 44))
    if b["t"] == "lab":
        side_body.add_child(_btn("RESEARCH", "good", func(): _open_tab("res"), 0, 44))
    if b["t"] == "port":
        side_body.add_child(_btn("SHIPS", "good", func(): _open_tab("navy"), 0, 44))
    if b["t"] == "parliament" or b["t"] == "embassy":
        side_body.add_child(_btn("GOVERNMENT" if b["t"] == "parliament" else "DIPLOMACY", "good", func(): _open_tab("gov" if b["t"] == "parliament" else "dip"), 0, 44))
    if b["st"] == "ok" and b["lvl"] < _max_level(b):
        side_body.add_child(_btn("UPGRADE " + _fmt(_upgrade_cost(b)), "good", func():
            var e := _upgrade_building(b)
            if e != "":
                _toast(e, "warn")
            _show_building_panel(b), 0, 44, 17))
    if b["st"] == "ruin" or b["hp"] < b["mhp"]:
        side_body.add_child(_btn("REPAIR " + _fmt(_repair_cost(b)), "warn", func():
            var e2 := _repair_building(b)
            if e2 != "":
                _toast(e2, "warn")
            _show_building_panel(b), 0, 44, 17))
    if b["st"] == "ok":
        side_body.add_child(_btn("MOVE (" + _fmt(float(d["cost"]) * 0.08) + ")", "dark", func():
            _begin_place(String(b["t"]), b["id"]), 0, 44, 17))
    if b["t"] != "parliament":
        side_body.add_child(_btn("SELL +" + _fmt(float(d["cost"]) * 0.5), "bad", func():
            _sell_building(b)
            side_panel.visible = false, 0, 44, 17))
    side_body.add_child(_btn("CLOSE", "dark", func():
        side_panel.visible = false
        sel_b = -1, 0, 40, 16))


func _find_ship(id: int) -> Variant:
    for s in ships:
        if s["id"] == id and not s["dead"]:
            return s
    return null


func _show_ship_panel() -> void:
    var s: Variant = _find_ship(sel_ship)
    if s == null:
        side_panel.visible = false
        return
    side_panel.visible = true
    _clear(side_body)
    var sd: Dictionary = SHIPS[s["k"]]
    side_body.add_child(_lbl(String(sd["name"]), 22, Color(1, 0.9, 0.5)))
    side_body.add_child(_lbl(String(sd["real"]), 14, C_DIM))
    side_body.add_child(_bar(s["hp"] / s["mhp"], Color(0.3, 0.85, 0.4), 280, 14))
    side_body.add_child(_lbl("Hull " + str(int(s["hp"])) + " / " + str(int(s["mhp"])) + "    " + ("sailing" if s["wp"].size() > 0 else "holding"), 16))
    side_body.add_child(_btn("MOVE TO...", "good", func():
        mode = "shipdest"
        _toast("Tap a point on the sea", "info"), 0, 46))
    side_body.add_child(_btn("STOP", "dark", func(): s["wp"] = [], 0, 42))
    if s["k"] == 4:
        var rd := 0
        for j in s["jets"]:
            if j["state"] == "ready":
                rd += 1
        side_body.add_child(_lbl("Air wing: " + str(s["jets"].size()) + " / 8   ready " + str(rd), 16))
        for t in range(4):
            if _weapon_state(me, "jet", t)["state"] == "ready":
                var tt := t
                side_body.add_child(_btn("+ " + _jet_name(me, t) + " " + _fmt(_weapon_state(me, "jet", t)["price"]), "dark", func():
                    var e := _buy_carrier_jet(me, tt, s)
                    if e != "":
                        _toast(e, "warn")
                    _show_ship_panel(), 0, 40, 14))
        for c in _wars_of(me):
            var cc: int = c
            side_body.add_child(_btn("Strike " + String(COUNTRIES[cc]["short"]) + "...", "bad", func(): _begin_strike("air", cc), 0, 42, 16))
    side_body.add_child(_btn("CLOSE", "dark", func():
        side_panel.visible = false
        sel_ship = -1, 0, 40, 16))


func _show_country_panel(c: int) -> void:
    side_panel.visible = true
    _clear(side_body)
    side_body.add_child(_mk_flag(c, 80, 54))
    side_body.add_child(_lbl(String(COUNTRIES[c]["name"]), 22, Color(1, 0.9, 0.5)))
    side_body.add_child(_lbl(_status_text(me, c) + "   relations " + str(int(cs[c]["rel"][me])), 16))
    side_body.add_child(_lbl("Pop " + String.num(cs[c]["pop"], 0) + "M   power " + str(int(_power(c))), 15, C_DIM))
    side_body.add_child(_btn("DIPLOMACY", "good", func():
        side_panel.visible = false
        _open_tab("country", c), 0, 46))
    if _at_war(me, c):
        side_body.add_child(_btn("MISSILE STRIKE", "bad", func(): _begin_strike("missile", c), 0, 44, 17))
        side_body.add_child(_btn("AIR STRIKE", "bad", func(): _begin_strike("air", c), 0, 44, 17))
    side_body.add_child(_btn("CLOSE", "dark", func(): side_panel.visible = false, 0, 40, 16))


# ------------------------------- PLACEMENT ---------------------------------
var ghost_mat: StandardMaterial3D

func _begin_place(t: String, move_id: int = -1) -> void:
    _close_window()
    side_panel.visible = false
    mode = "place"
    place_type = t
    place_move_id = move_id
    place_r = 0
    if move_id >= 0 and bmap.has(move_id):
        place_r = bmap[move_id]["r"]
        place_x = bmap[move_id]["x"]
        place_z = bmap[move_id]["z"]
    else:
        var vs := get_viewport().get_visible_rect().size
        var g := _screen_to_ground(vs * 0.5)
        place_x = _snap(g.x)
        place_z = _snap(g.z)
        var cen := _land_center(me)
        if abs(place_x - cen.x) > LAND - 10.0 or abs(place_z - cen.z) > LAND - 10.0:
            place_x = _snap(cen.x)
            place_z = _snap(cen.z + 60.0)
            _focus(Vector3(place_x, 0, place_z), 260.0)
    if cam_goal_dist > 700.0:
        cam_goal_dist = 300.0
        _focus(Vector3(place_x, 0, place_z))
    if ghost_node and is_instance_valid(ghost_node):
        ghost_node.queue_free()
    ghost_node = Node3D.new()
    var mi := MeshInstance3D.new()
    mi.mesh = _building_mesh(t, 1, 0, me)
    if ghost_mat == null:
        ghost_mat = StandardMaterial3D.new()
        ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mi.material_override = ghost_mat
    mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    ghost_node.add_child(mi)
    add_child(ghost_node)
    ground_mats[me].set_shader_parameter("grid_on", 1.0)
    place_bar.visible = true
    _update_ghost()


func _update_ghost() -> void:
    if place_type == "":
        return
    var r := place_r
    if place_type == "port":
        r = _port_rot(me, place_x, place_z)
        place_r = r
    ghost_node.position = Vector3(place_x, 0.3, place_z)
    ghost_node.rotation.y = deg_to_rad(90.0 * float(r))
    var err := _can_place(me, place_type, place_x, place_z, r, place_move_id)
    var ok := err == ""
    ghost_mat.albedo_color = Color(0.2, 1.0, 0.4, 0.5) if ok else Color(1.0, 0.2, 0.2, 0.5)
    var h := _fp_half(place_type, r, me)
    var gm: ShaderMaterial = ground_mats[me]
    gm.set_shader_parameter("ghost", Vector4(place_x, place_z, h.x, h.y))
    gm.set_shader_parameter("ghost_ok", 1.0 if ok else 0.0)
    _update_place_label()


func _update_place_label() -> void:
    if place_type == "" or mode != "place":
        return
    var d := _bdef(place_type, me)
    var err := _can_place(me, place_type, place_x, place_z, place_r, place_move_id)
    var cost: float = float(d["cost"]) if place_move_id < 0 else float(d["cost"]) * 0.08
    var txt := String(d["name"]) + "   cost " + _fmt(cost) + "   -   "
    var can_pay: bool = cs[me]["money"] >= cost
    if err != "":
        txt += err
    elif not can_pay:
        txt += "not enough money"
    else:
        txt += "tap map to move, then BUILD"
    place_lbl.text = txt
    place_lbl.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7) if err == "" and can_pay else Color(1.0, 0.6, 0.5))
    place_ok_btn.disabled = err != "" or not can_pay
    place_ok_btn.text = "MOVE" if place_move_id >= 0 else "BUILD"


func _confirm_place() -> void:
    var e := ""
    if place_move_id >= 0 and bmap.has(place_move_id):
        e = _move_building_to(bmap[place_move_id], place_x, place_z, place_r)
        if e == "":
            _cancel_place()
            return
    else:
        e = _buy_building(me, place_type, place_x, place_z, place_r)
    if e != "":
        _toast(e, "warn")
    else:
        _snd("build")
        _update_ghost()


func _cancel_place() -> void:
    mode = "none"
    place_type = ""
    place_move_id = -1
    place_bar.visible = false
    if ghost_node and is_instance_valid(ghost_node):
        ghost_node.queue_free()
        ghost_node = null
    for gm in ground_mats:
        gm.set_shader_parameter("grid_on", 0.0)
        gm.set_shader_parameter("ghost", Vector4(0, 0, 0, 0))


# ------------------------------- MENU --------------------------------------
func _show_menu(has_save: bool) -> void:
    menu_root.visible = true
    _clear(menu_root)
    var bg := ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.02, 0.04, 0.08, 0.92)
    menu_root.add_child(bg)
    var v := _vbox(8)
    v.set_anchors_preset(Control.PRESET_FULL_RECT)
    v.offset_left = 40
    v.offset_right = -40
    v.offset_top = 20
    v.offset_bottom = -20
    menu_root.add_child(v)
    v.add_child(_lbl("WORLD COMMANDER", 44, Color(1, 0.85, 0.3)))
    v.add_child(_lbl("Lead a nation. Build your economy, rule your people, make treaties - or conquer the world. The game never ends.", 18, C_DIM, true))
    var hb := _hbox(10)
    v.add_child(hb)
    if has_save:
        hb.add_child(_btn("CONTINUE SAVED GAME", "good", func(): _load_game(), 300, 54))
    if game_state == "playing":
        hb.add_child(_btn("RESUME", "good", func(): menu_root.visible = false, 160, 54))
        hb.add_child(_btn("SAVE GAME", "dark", func():
            _save_game()
            menu_root.visible = false, 160, 54))
    v.add_child(_lbl("CHOOSE YOUR COUNTRY (starts a new game)", 22, Color(0.8, 0.9, 1.0)))
    var sc := ScrollContainer.new()
    sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
    sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    v.add_child(sc)
    var g := _grid(3)
    sc.add_child(g)
    for i in range(9):
        var cv := _card()
        var h := _hbox(10)
        cv.add_child(h)
        h.add_child(_mk_flag(i, 72, 48))
        h.add_child(_lbl(String(COUNTRIES[i]["name"]), 22))
        cv.add_child(_lbl(String(COUNTRIES[i]["blurb"]), 14, C_DIM, true))
        cv.add_child(_lbl("Pop " + String.num(COUNTRIES[i]["pop"], 0) + "M    Economy x" + String.num(COUNTRIES[i]["econ"], 2) + "    " + ("Nuclear" if COUNTRIES[i]["nuke"] else "No nukes"), 14, Color(0.6, 0.85, 1.0)))
        var ii := i
        cv.add_child(_btn("PLAY AS " + String(COUNTRIES[i]["short"]), "good", func():
            _start_game(ii), 0, 46))
        _add_card(g, cv)


# =====================================================================
#  MAIN LOOP
# =====================================================================
func _process(delta: float) -> void:
    _update_camera(delta)
    _update_markers()
    _fx_update(delta)
    if game_state == "playing":
        _hud_update(delta)
        if speed > 0 and not (menu_root and menu_root.visible):
            _sim(min(delta, 0.1) * float(speed))
    _lod_rebuild()


func _sim(dt: float) -> void:
    gtime += dt
    day_t = fposmod(day_t + dt / 420.0, 1.0)
    _update_daylight()
    tick_t += dt
    while tick_t >= TICK:
        tick_t -= TICK
        _economy_tick()
        _refresh_hud()
    _building_update(dt)
    _ai_update(dt)
    _war_update(dt)
    _protest_update(dt)
    autosave_t += dt
    if autosave_t > 90.0:
        autosave_t = 0.0
        _save_game()

var autosave_t := 0.0
var crowd_node: Node3D
var crowd_cache := {}

# street protests: crowds with placards appear in the capital when people are unhappy
func _protest_update(dt: float) -> void:
    return
    for c in range(9):
        var level: float = cs[c]["prot"]
        var vis: float = cs[c].get("protest_vis", 0.0)
        if vis > 0.0:
            level = max(level, 0.55)
        var key := "pr" + str(c)
        var want := level > 0.2
        var node: Variant = crowd_cache.get(key, null)
        if want and node == null:
            node = _make_crowd(c)
            crowd_cache[key] = node
        elif not want and node != null:
            node.queue_free()
            crowd_cache.erase(key)
            node = null
        if node != null:
            var t := gtime
            var cnt: int = node.multimesh.instance_count
            var show := int(float(cnt) * clamp(level, 0.2, 1.0))
            for k in range(cnt):
                var ph := float(k) * 1.7
                var tf: Transform3D = node.get_meta("base")[k]
                if k >= show:
                    tf.origin.y = -50.0
                else:
                    tf.origin.y = abs(sin(t * 3.0 + ph)) * 0.35
                node.multimesh.set_instance_transform(k, tf)


func _make_crowd(c: int) -> Node3D:
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    var mb := MB.new()
    _m_crowd_person(mb, Color(0.7, 0.2, 0.2))
    mm.mesh = mb.bake(mats)
    mm.instance_count = 70
    var inst := MultiMeshInstance3D.new()
    inst.multimesh = mm
    inst.visibility_range_end = 900.0
    add_child(inst)
    var cap: Variant = bmap.get(cs[c]["cap_b"], null)
    var cen := _land_center(c)
    if cap != null:
        cen = Vector3(cap["x"], 0, cap["z"] + 22.0)
    var base := []
    var r := RandomNumberGenerator.new()
    r.seed = 900 + c
    for k in range(70):
        var a := r.randf() * TAU
        var rad := sqrt(r.randf()) * 14.0
        var tf := Transform3D(Basis(Vector3.UP, r.randf() * TAU), cen + Vector3(cos(a) * rad * 1.8, 0.3, sin(a) * rad * 0.8))
        base.append(tf)
        mm.set_instance_transform(k, tf)
    inst.set_meta("base", base)
    return inst


# =====================================================================
#  TEST HARNESS (screenshots + headless self-test)
# =====================================================================
func _demo_city(c: int) -> void:
    var cen := _land_center(c)
    var plan := [
        ["apartment", -56, 70], ["apartment", -80, 70], ["commerce", 0, 70], ["office", 28, 90], ["office", 50, 90], ["factory", -70, 30],
        ["hospital", 60, 60], ["university", 56, -50], ["stadium", 80, 30], ["police", -90, 100], ["embassy", 90, 80],
        ["armybase", -60, -60], ["missilebase", 0, -70], ["radar", 40, -30], ["lab", -30, -90],
        ["aa0", 22, -40], ["aa1", -22, -40], ["aa2", 30, 40], ["aa3", -50, 10], ["aa4", 60, -80], ["airbase", 20, -122], ["port", 0, 148],
        ["house", -100, 50], ["house", -100, 62], ["house", -88, 50], ["house", -88, 62], ["house", -76, 50], ["house", -76, 62], ["park", 100, -20],
        ["enrich", 100, -100],
    ]
    for p in plan:
        var t: String = p[0]
        var x: float = cen.x + float(p[1])
        var z: float = cen.z + float(p[2])
        var b := _add_building(c, t, x, z, 0, true)
        if t == "port":
            b["r"] = _port_rot(c, x, z)
            _make_node(b)
        if t == "airbase":
            for k in range(6):
                b["jets"].append({"tier": k % 4, "state": "ready", "t": 0.0})
            _refresh_airbase_parked(b)
    lod_dirty[c] = true


func _shot_setup() -> void:
    _start_game(5)
    _demo_city(5)
    for i in range(9):
        if i != 5:
            _demo_city(i) if i == 4 else null
    var cam := args_cam.split(",")
    if cam.size() >= 3:
        cam_target = Vector3(float(cam[0]), 0, float(cam[1]))
        cam_goal = cam_target
        cam_dist = float(cam[2])
        cam_goal_dist = cam_dist
    if cam.size() >= 4:
        cam_yaw = deg_to_rad(float(cam[3]))
    if cam.size() >= 5:
        day_t = float(cam[4])
    cs[5]["money"] = 900000.0
    cs[5]["peak"] = 900000.0
    cs[5]["tech"]["nuc3"] = true
    if args_gui != "":
        var parts := args_gui.split(":")
        if parts[0] == "tab":
            _open_tab(parts[1], int(parts[2]) if parts.size() > 2 else null)
        elif parts[0] == "menu":
            _show_menu(false)
        elif parts[0] == "place":
            _begin_place(parts[1])
        elif parts[0] == "war":
            _declare_war(5, 4, "test")
            _war_demo()
    var frames := 0
    var wait := 24
    if args_gui.begins_with("war"):
        wait = 420
    set_process(true)
    var timer := get_tree().create_timer(2.0 if wait < 100 else 14.0)
    await timer.timeout
    for k in range(wait):
        await get_tree().process_frame
    var img := get_viewport().get_texture().get_image()
    img.save_png(args_shot)
    print("shot saved ", args_shot)
    get_tree().quit()


func _war_demo() -> void:
    # a visible air war between Iran and Israel for screenshots
    cs[4]["money"] = 900000.0
    cs[4]["peak"] = 900000.0
    for tgt in range(4):
        _buy_jet(5, tgt)
    for k in range(4):
        _buy_jet(4, k)
    cs[5]["unl"]["msl:0"] = true
    cs[5]["ammo"][0] = 12
    var tb: Variant = _pick_target(5, 4, true)
    if tb != null:
        _launch_strike(5, tb, 4)
        _fire_salvo(5, 0, 6, tb)
    var tb2: Variant = _pick_target(4, 5, true)
    if tb2 != null:
        _launch_strike(4, tb2, 3)
    speed = 4


func _selftest() -> void:
    print("SELFTEST begin")
    var fails := 0
    _start_game(5)
    # 1) building placement and economy
    var cen := _land_center(5)
    var e := _buy_building(5, "house", cen.x - 90.0, cen.z + 40.0, 0)
    if e != "":
        print("FAIL house: ", e)
        fails += 1
    e = _buy_building(5, "house", cen.x - 90.0, cen.z + 40.0, 0)
    if e == "":
        print("FAIL overlap allowed")
        fails += 1
    for i in range(30):
        _sim(1.0)
    print("money after 30s ", cs[5]["money"], " bl ", cs[5]["bl"].size())
    # 2) all AI countries build up over time; run a long simulation
    for c in range(9):
        cs[c]["money"] += 200000.0
        cs[c]["peak"] = max(cs[c]["peak"], cs[c]["money"])
    for step in range(900):
        _sim(0.5)
        if step % 200 == 0:
            print("t=", int(gtime), " month ", month, " bl ", cs[1]["bl"].size(), " ", cs[3]["bl"].size(), " flights ", flights.size(), " projs ", projs.size(), " ships ", ships.size())
    # 3) force a war between two AIs and between AI and player
    _declare_war(4, 5, "selftest")
    _declare_war(3, 2, "selftest")
    for c in [4, 5, 3, 2]:
        cs[c]["money"] += 3000000.0
        cs[c]["peak"] = cs[c]["money"]
        for k in range(4):
            _unlock_weapon(c, "jet", k)
            _buy_jet(c, k)
        for k in range(4):
            _unlock_weapon(c, "msl", k)
            _buy_missile(c, k, 4)
        _unlock_weapon(c, "ship", 0)
        _buy_ship(c, 0)
    for step in range(1200):
        _sim(0.25)
        if step % 100 == 0:
            _ai_ops(4)
            _ai_ops(3)
            var tb: Variant = _pick_target(5, 4, true)
            if tb != null:
                _launch_strike(5, tb, 2)
                _fire_salvo(5, 0, 2, tb)
    print("war sim done: flights ", flights.size(), " projs ", projs.size(), " ships ", ships.size())
    for c in [3, 2, 4, 5]:
        print(COUNTRIES[c]["short"], " dmg_taken ", int(cs[c]["dmg_taken"]), " jets_lost ", cs[c]["jets_lost"], " planes_down ", cs[c]["planes_down"], " ships_lost ", cs[c]["ships_lost"])
    # 4) diplomacy
    var r := _propose(5, 6, "trade")
    print("trade: ", r)
    var r2 := _propose(5, 4, "ceasefire")
    print("ceasefire: ", r2)
    var pm := _send_pm(5, 6)
    print("pm: '", pm, "'")
    for step in range(300):
        _sim(0.5)
    # 5) nuke test
    cs[5]["tech"]["nuc3"] = true
    var tbn: Variant = _pick_target(4, 5)
    if tbn != null:
        _launch_missile(4, 5, Vector3(cen.x, 3, cen.z - 600), Vector3(tbn["x"], 0, tbn["z"]), tbn, 1.0, 5)
    for step in range(200):
        _sim(0.25)
    # 6) save / load
    _save_game()
    var ok := _load_game()
    print("load ok ", ok, " bl ", cs[5]["bl"].size())
    if not ok:
        fails += 1
    for step in range(100):
        _sim(0.5)
    print("SELFTEST done fails=", fails, " news=", news_log.size())
    for n in news_log.slice(0, 12):
        print("  NEWS: ", n["text"])
    get_tree().quit(1 if fails > 0 else 0)
