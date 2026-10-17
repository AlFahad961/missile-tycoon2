extends Node3D
## Missile Tycoon Islands 6.0
## WW3-Commander style island war. Builders auto-build and upgrade houses, repairmen fix wrecks,
## buy missiles and air defense in MILITARY, fire from the satellite view with 1x / 5x taps.
## Procedural sound, layered air defense, drones. (Godot 4.x, Compatibility renderer)
## Left half of the screen = floating joystick, right half = drag to look around.

const SAVE_PATH := "user://missile_tycoon_v8.json"
const SETTINGS_PATH := "user://settings_v1.json"
const PLOT_HALF := 120.0
const PLAYER_HALF := 117.0
const RING := [0.0, 0.0, 650.0, 760.0, 900.0]
const WALK_SPEED := 26.0
const MAX_HOUSES := 50
const MAX_DEFENSES := 30
const MAX_MISSILES := 100
const MAX_JETS := 12
const NM := 8
const RW_X := 100.0
const RW_Z0 := 104.0
const RW_Z1 := -104.0
const TAXI_X := 88.0
const ISL_LIM := 118.0
const MIL_RECT := Rect2(-116.0, -116.0, 154.0, 126.0)
const MAX_BUILDERS := 5
const MAX_BREP := 5
const MAX_AREP := 3
const MAX_LEVEL := 5
const START_MONEY := 600
const PEACE_TIME := 600.0
const SPACING := 7.0
const SAT_HEIGHT := 300.0
const BUILDER_PRICES := [600, 1100, 1900, 3000, 4500]
const BREP_PRICES := [800, 1400, 2300, 3400, 5000]
const AREP_PRICES := [3500, 7000, 12000]
const BUILDER_UPGRADE := [4000, 14000, 45000, 140000]
const LOOK_SENS := [0.006, 0.010, 0.016]
const SENS_NAMES := ["LOW", "MEDIUM", "HIGH"]
const RATE := 16000

const TIME_HOUSE := 45.0
const TIME_UPGRADE := 60.0
const TIME_REPAIR := 20.0

const HOUSE_INCOME := [2, 6, 14, 30, 60]
const HOUSE_HP := [150.0, 250.0, 400.0, 600.0, 900.0]
const DEFENSE_HP := 220.0

const TEAM_COLORS := [
    Color(0.2, 0.55, 1.0),
    Color(0.9, 0.22, 0.2),
    Color(0.7, 0.3, 0.9),
    Color(1.0, 0.6, 0.1),
]

const MISSILES := [
    {"name": "Cruise Missile", "cls": "Tomahawk / Babur class", "short": "Cruise", "price": 450,
        "dmg": 55.0, "radius": 5.0, "speed": 90.0, "arc": 0.05, "cep": 3.0, "count": 1, "unlock": 0, "cap": 4},
    {"name": "Ballistic Missile", "cls": "Iskander / Fateh class", "short": "Ballistic", "price": 1400,
        "dmg": 110.0, "radius": 8.0, "speed": 142.5, "arc": 0.45, "cep": 5.0, "count": 1, "unlock": 3000, "cap": 2},
    {"name": "Hypersonic Missile", "cls": "Kinzhal / Fattah class", "short": "Hypersonic", "price": 3500,
        "dmg": 190.0, "radius": 6.0, "speed": 255.0, "arc": 0.12, "cep": 3.0, "count": 1, "unlock": 15000, "cap": 2},
    {"name": "MIRV Strategic", "cls": "Sarmat / Topol class, 3 warheads", "short": "MIRV", "price": 8000,
        "dmg": 80.0, "radius": 7.0, "speed": 195.0, "arc": 0.5, "cep": 14.0, "count": 3, "unlock": 40000, "cap": 1},
    {"name": "Kamikaze Drone", "cls": "Shahed class", "short": "Drone", "price": 200,
        "dmg": 40.0, "radius": 3.5, "speed": 48.0, "arc": 0.03, "cep": 6.0, "count": 1, "unlock": 0, "cap": 6},
    {"name": "Rocket Barrage", "cls": "Fajr / MLRS class, 2 rockets", "short": "Rockets", "price": 250,
        "dmg": 30.0, "radius": 4.5, "speed": 105.0, "arc": 0.22, "cep": 7.0, "count": 2, "unlock": 0, "cap": 8},
    {"name": "Stealth Cruise", "cls": "Storm Shadow / JASSM class", "short": "Stealth", "price": 2400,
        "dmg": 120.0, "radius": 4.0, "speed": 127.5, "arc": 0.04, "cep": 2.0, "count": 1, "unlock": 8000, "cap": 4},
    {"name": "ICBM", "cls": "Minuteman / Agni-V class, huge blast", "short": "ICBM", "price": 20000,
        "dmg": 420.0, "radius": 16.0, "speed": 225.0, "arc": 0.8, "cep": 6.0, "count": 1, "unlock": 100000, "cap": 1},
]


const DEFENSES := [
    {"name": "CIWS Gun", "cls": "Phalanx / Pantsir-gun class", "short": "CIWS", "price": 1200, "range": 26.0,
        "cd": 1.2, "mag": 40, "ref": 3, "unlock": 0},
    {"name": "Iron Dome", "cls": "Iron Dome / Tor class, short range", "short": "Iron Dome", "price": 4000, "range": 50.0,
        "cd": 2.0, "mag": 20, "ref": 30, "unlock": 5000},
    {"name": "HQ-9 / Patriot", "cls": "HQ-9 / Patriot class, medium range", "short": "HQ-9", "price": 9500, "range": 80.0,
        "cd": 3.0, "mag": 12, "ref": 90, "unlock": 15000},
    {"name": "S-400", "cls": "S-400 class, long range", "short": "S-400", "price": 19000, "range": 115.0,
        "cd": 3.5, "mag": 10, "ref": 165, "unlock": 35000},
    {"name": "THAAD / S-500", "cls": "THAAD / S-500 class, anti-ballistic", "short": "THAAD", "price": 36000, "range": 135.0,
        "cd": 4.5, "mag": 8, "ref": 300, "unlock": 70000},
]


# columns: cruise, ballistic, hypersonic, MIRV, drone, rockets, stealth, ICBM
const DEF_TABLE := [
    [0.55, 0.05, 0.0, 0.0, 0.85, 0.7, 0.2, 0.0],
    [0.75, 0.25, 0.05, 0.1, 0.9, 0.9, 0.35, 0.0],
    [0.8, 0.6, 0.2, 0.35, 0.6, 0.6, 0.45, 0.05],
    [0.85, 0.75, 0.45, 0.55, 0.5, 0.5, 0.55, 0.2],
    [0.3, 0.9, 0.6, 0.7, 0.05, 0.1, 0.3, 0.55],
]

# chance that each air-defense type hits an (unstealthy) jet
const JET_DEF := [0.25, 0.35, 0.6, 0.7, 0.15]
const DEF_SPEED := [110.0, 120.0, 150.0, 180.0, 220.0]

const JETS := [
    {"name": "JF-17 Thunder", "cls": "Pakistan / China light multirole", "short": "JF-17", "price": 9000, "shots": 2,
        "dmg": 55.0, "radius": 5.0, "speed": 87.0, "evade": 0.05, "fee": 250, "unlock": 25000},
    {"name": "F-16 Fighting Falcon", "cls": "USA multirole fighter", "short": "F-16", "price": 16000, "shots": 3,
        "dmg": 60.0, "radius": 5.0, "speed": 99.0, "evade": 0.12, "fee": 400, "unlock": 45000},
    {"name": "J-10C Vigorous Dragon", "cls": "China delta-canard fighter", "short": "J-10C", "price": 22000, "shots": 3,
        "dmg": 70.0, "radius": 5.5, "speed": 105.0, "evade": 0.2, "fee": 500, "unlock": 70000},
    {"name": "Rafale", "cls": "France omnirole fighter", "short": "Rafale", "price": 34000, "shots": 4,
        "dmg": 80.0, "radius": 5.5, "speed": 108.0, "evade": 0.28, "fee": 700, "unlock": 110000},
    {"name": "F-22 Raptor", "cls": "USA stealth air-superiority", "short": "F-22", "price": 65000, "shots": 4,
        "dmg": 100.0, "radius": 6.0, "speed": 126.0, "evade": 0.65, "fee": 1000, "unlock": 180000},
    {"name": "F-35 Lightning II", "cls": "USA stealth strike fighter", "short": "F-35", "price": 82000, "shots": 6,
        "dmg": 85.0, "radius": 6.0, "speed": 114.0, "evade": 0.55, "fee": 1200, "unlock": 250000},
]


const WATER_SHADER := """
shader_type spatial;
uniform vec3 deep_color : source_color = vec3(0.02, 0.2, 0.42);
uniform vec3 shallow_color : source_color = vec3(0.12, 0.58, 0.82);
varying vec3 wpos;
float wave(vec2 p, float t) {
    return sin(p.x * 0.35 + t * 1.1) * 0.5 + sin(p.y * 0.27 - t * 0.9) * 0.5 + sin((p.x + p.y) * 0.18 + t * 0.6) * 0.5;
}
void vertex() {
    wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
    vec2 p = wpos.xz;
    float e = 0.6;
    float h = wave(p, TIME);
    float hx = wave(p + vec2(e, 0.0), TIME);
    float hz = wave(p + vec2(0.0, e), TIME);
    vec3 n = normalize(vec3((h - hx) * 0.8, e, (h - hz) * 0.8));
    NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
    float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.5);
    ALBEDO = mix(deep_color, shallow_color, fres);
    ROUGHNESS = 0.1;
    SPECULAR = 0.8;
}
"""

const CHECKER_SHADER := """
shader_type spatial;
uniform vec3 c1 : source_color = vec3(0.3, 0.62, 0.25);
uniform vec3 c2 : source_color = vec3(0.26, 0.56, 0.22);
uniform float tile = 10.0;
varying vec3 lp;
void vertex() {
    lp = VERTEX;
}
void fragment() {
    vec2 g = floor(lp.xz / tile);
    float m = mod(g.x + g.y, 2.0);
    ALBEDO = mix(c1, c2, m);
    ROUGHNESS = 0.95;
    SPECULAR = 0.02;
}
"""


# ---- game state ----
var emp: Array = []  # one Dictionary per island; index 0 = the player
var island_count := 2
var selected_enemy := 1
var game_state := "menu"  # menu, playing, paused, won, lost
var elapsed := 0.0
var income_timer := 0.0
var uid_counter := 0
var look_sens_idx := 1
var launch_queue: Array = []
var ui_timer := 0.0

# ---- satellite ----
var sat_open := false
var sat_island := 1
var sat_has_point := false
var sat_local := Vector2.ZERO
var sat_marker: MeshInstance3D
var sat_drag_id := -1

# ---- world ----
var level_root: Node3D
var camera: Camera3D
var island_nodes: Array = []
var island_pos: Array = []
var clouds: Array = []
var projectiles: Array = []
var sorties: Array = []
var route_mode := 0
var route_wps: Array = []
var route_marks: Array = []
var route_row: Control
var route_edit: Control
var route_btns: Array = []
var jetcam_on := false
var jetcam_id := 0
var jetcam_shot := 0
var jetcam_t := 0.0
var jetcam_fixed := Vector3.ZERO
var jetcam_layer: Control
var jetcam_info: Label
var jetcam_live: Label
var jetcam_btn: Button
var jetcam_panels: Array = []
var player: Node3D
var player_off := Vector3(0.0, 0.0, 5.0)
var walk_amount := 0.0
var walk_phase := 0.0
var mat_cache := {}
var sounds := {}
var shake := 0.0

# ---- camera ----
var cam_yaw := 0.0
var cam_pitch := 0.38
var cam_dist := 12.0
var cam_goal := 0.0
var cam_auto := 0.0

# ---- touch ----
var joy_id := -1
var joy_center := Vector2.ZERO
var joy_vec := Vector2.ZERO
var look_id := -1

# ---- ui ----
var ui_root: Control
var overlay: Panel
var money_label: Label
var stats_label: Label
var status_label: Label
var joy_base: Panel
var joy_knob: Panel
var ov_title: Label
var ov_sub: Label
var btn_resume: Button
var btn_continue: Button
var btn_sens: Button
var sat_root: Control
var sat_panels: Array = []
var sat_island_box: HBoxContainer
var sat_island_btns: Array = []
var sat_back_btn: Button
var sat_type := 0
var sat_mult := 1
var sat_cool := 0.0
var sat_money: Label
var sat_title: Label
var sat_hint: Label
var sat_type_btns: Array = []
var sat_mult_btns: Array = []
var stats_panel: PanelContainer
var tabs_box: HBoxContainer
var hot_box: HBoxContainer
var hot_slots: Array = []
var hot_items: Array = []
var menu_btn: Button
var status_box: MarginContainer
var mil_panel: PanelContainer
var work_panel: PanelContainer
var mil_tab := 0
var work_tab := 0
var mil_tab_btns: Array = []
var work_tab_btns: Array = []
var mil_body_missile: Control
var mil_body_aa: Control
var work_body_hire: Control
var work_body_up: Control
var cards_missile: Array = []
var cards_aa: Array = []
var cards_worker: Array = []
var up_card: Dictionary = {}
var stat_missile: Label
var stat_aa: Label
var stat_jets: Label
var sat_page := 0
var sat_page_btns: Array = []
var place_mode := false
var place_kind := ""
var place_id := 0
var place_ok := false
var place_panel: Control
var place_label: Label
var place_zone: MeshInstance3D
var cards_jet: Array = []
var mil_body_jet: Control
var mil_body_manage: Control
var manage_list: VBoxContainer
var stat_house: Label
var income_label: Label



func _ready() -> void:
    randomize()
    _load_settings()
    _build_sounds()
    _build_sounds_extra()
    _build_environment()
    _build_ui()
    _reset_state(2)
    _build_world()
    get_viewport().size_changed.connect(_reset_joystick)
    _update_sens_text()
    _show_overlay("MISSILE TYCOON", "Hire builders (WORKER), buy missiles and air defense (MILITARY), then attack from the satellite (ATTACK). Rivals start from the same place as you!")
    _refresh_ui()
    if OS.get_cmdline_user_args().has("--selftest"):
        call_deferred("_selftest")


func _build_sounds_extra() -> void:
    var n: int
    var s: PackedFloat32Array
    var t := 0.0

    # drone buzz
    n = int(RATE * 1.4)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        var saw := fmod(t * 95.0, 1.0) * 2.0 - 1.0
        var fade := minf(1.0, t * 8.0) * minf(1.0, (1.4 - t) * 6.0)
        s[i] = (saw * 0.35 + sin(TAU * 190.0 * t) * 0.2) * fade * 0.6
    sounds["drone"] = _wav(s)

    # incoming warning siren
    n = int(RATE * 1.6)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        var fade2 := minf(1.0, t * 10.0) * minf(1.0, (1.6 - t) * 6.0)
        s[i] = sin(TAU * 700.0 * t - 200.0 * cos(TAU * 1.25 * t)) * 0.35 * fade2
    sounds["siren"] = _wav(s)

    # construction hammering
    n = int(RATE * 0.8)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        var tt := fmod(t, 0.2)
        s[i] = ((randf() * 2.0 - 1.0) * 0.4 + sin(TAU * 260.0 * tt) * 0.6) * exp(-tt * 45.0) * 0.6
    sounds["hammer"] = _wav(s)

    # satellite beep (two tones)
    n = int(RATE * 0.3)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        var f := 1300.0 if t < 0.12 else 1750.0
        s[i] = sin(TAU * f * t) * 0.35 * exp(-fmod(t, 0.12) * 12.0)
    sounds["sat"] = _wav(s)

    # error buzz
    n = int(RATE * 0.25)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        s[i] = (fmod(t * 140.0, 1.0) * 2.0 - 1.0) * 0.3 * exp(-t * 8.0)
    sounds["error"] = _wav(s)


func _yaw_to(d: Vector3) -> float:
    return atan2(-d.x, -d.z)


func _mat(color: Color, rough: float = 0.85) -> StandardMaterial3D:
    var key := "%s_%s" % [color.to_html(true), str(rough)]
    if mat_cache.has(key):
        return mat_cache[key]
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = rough
    m.metallic_specular = 0.12
    mat_cache[key] = m
    return m


func _glow_mat(color: Color) -> StandardMaterial3D:
    var gkey := "glow_" + color.to_html(true)
    if mat_cache.has(gkey):
        return mat_cache[gkey]
    var m := StandardMaterial3D.new()
    mat_cache[gkey] = m
    m.albedo_color = color
    m.emission_enabled = true
    m.emission = color
    m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return m


func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var b := BoxMesh.new()
    b.size = size
    m.mesh = b
    m.position = pos
    m.material_override = _mat(color)
    parent.add_child(m)
    return m


func _cyl(parent: Node3D, top: float, bottom: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var c := CylinderMesh.new()
    c.top_radius = top
    c.bottom_radius = bottom
    c.height = height
    c.radial_segments = 16
    c.rings = 1
    m.mesh = c
    m.position = pos
    m.material_override = _mat(color)
    parent.add_child(m)
    return m


func _sphere(parent: Node3D, radius: float, pos: Vector3, color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var s := SphereMesh.new()
    s.radius = radius
    s.height = radius * 2.0
    s.radial_segments = 16
    s.rings = 8
    m.mesh = s
    m.position = pos
    m.material_override = _mat(color)
    parent.add_child(m)
    return m


func _vibrate(ms: int) -> void:
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(ms)


func _isl(i: int) -> Node3D:
    return island_nodes[i]


func _team(i: int) -> Color:
    return TEAM_COLORS[i % 4]


# =====================================================================
# Sound (all generated in code, no audio files needed)
# =====================================================================
func _wav(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
    var bytes := PackedByteArray()
    bytes.resize(samples.size() * 2)
    for i in range(samples.size()):
        var v: int = clampi(int(samples[i] * 32767.0), -32768, 32767)
        bytes.encode_s16(i * 2, v)
    var w := AudioStreamWAV.new()
    w.format = AudioStreamWAV.FORMAT_16_BITS
    w.mix_rate = RATE
    w.stereo = false
    w.data = bytes
    if loop:
        w.loop_mode = AudioStreamWAV.LOOP_FORWARD
        w.loop_begin = 0
        w.loop_end = samples.size()
    return w


func _build_sounds() -> void:
    var n: int
    var s: PackedFloat32Array
    var y := 0.0
    var t := 0.0

    # rocket launch: rumbling whoosh
    n = int(RATE * 1.0)
    s = PackedFloat32Array()
    s.resize(n)
    y = 0.0
    for i in range(n):
        t = float(i) / float(RATE)
        y += ((randf() * 2.0 - 1.0) - y) * 0.25
        var env := minf(t * 12.0, 1.0) * exp(-t * 3.0)
        s[i] = (y * 0.9 + sin(TAU * 70.0 * t) * 0.4) * env * 0.8
    sounds["launch"] = _wav(s)

    # explosion: deep boom
    n = int(RATE * 1.8)
    s = PackedFloat32Array()
    s.resize(n)
    y = 0.0
    for i in range(n):
        t = float(i) / float(RATE)
        y += ((randf() * 2.0 - 1.0) - y) * 0.08
        var env2 := exp(-t * 2.2)
        s[i] = (y * 1.8 + sin(TAU * (55.0 - 20.0 * t) * t) * 0.7) * env2 * 0.9
    sounds["boom"] = _wav(s)

    # air-defense hit: short pop
    n = int(RATE * 0.35)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        s[i] = ((randf() * 2.0 - 1.0) * 0.5 + sin(TAU * 1100.0 * t) * 0.5) * exp(-t * 14.0) * 0.7
    sounds["pop"] = _wav(s)

    # interceptor launch: chirp
    n = int(RATE * 0.3)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        s[i] = sin(TAU * (1500.0 - 2500.0 * t) * t) * exp(-t * 9.0) * 0.4
    sounds["blip"] = _wav(s)

    # button click
    n = int(RATE * 0.07)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        s[i] = sin(TAU * 800.0 * t) * exp(-t * 50.0) * 0.5
    sounds["click"] = _wav(s)

    # build / buy: two rising notes
    n = int(RATE * 0.45)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        var f := 523.0 if t < 0.18 else 784.0
        s[i] = sin(TAU * f * t) * exp(-t * 5.0) * 0.5
    sounds["build"] = _wav(s)

    # base hit alarm
    n = int(RATE * 0.9)
    s = PackedFloat32Array()
    s.resize(n)
    for i in range(n):
        t = float(i) / float(RATE)
        var f2 := 650.0 if fmod(t, 0.3) < 0.15 else 850.0
        s[i] = sin(TAU * f2 * t) * 0.35 * minf(1.0, (0.9 - t) * 5.0)
    sounds["alarm"] = _wav(s)

    # ocean ambience (loops)
    n = int(RATE * 3.0)
    s = PackedFloat32Array()
    s.resize(n)
    y = 0.0
    for i in range(n):
        t = float(i) / float(RATE)
        y += ((randf() * 2.0 - 1.0) - y) * 0.03
        var sw := sin(PI * t / 3.0)
        s[i] = y * (0.1 + 0.9 * sw * sw) * 2.2
    sounds["waves"] = _wav(s, true)


func _play_ui(sound: String, vol: float = -4.0) -> void:
    if not sounds.has(sound):
        return
    var p := AudioStreamPlayer.new()
    p.stream = sounds[sound]
    p.volume_db = vol
    add_child(p)
    p.finished.connect(p.queue_free)
    p.play()


func _play3d(sound: String, pos: Vector3, vol: float = 0.0, pitch: float = 1.0) -> void:
    if not sounds.has(sound) or level_root == null:
        return
    var p := AudioStreamPlayer3D.new()
    p.stream = sounds[sound]
    p.volume_db = vol
    p.pitch_scale = pitch
    p.unit_size = 40.0
    p.max_distance = 900.0
    level_root.add_child(p)
    p.global_position = pos
    p.finished.connect(p.queue_free)
    p.play()


# =====================================================================
# Environment (sky, sun, water, clouds, camera)
# =====================================================================
func _build_environment() -> void:
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.08, 0.36, 0.92)
    sky_mat.sky_horizon_color = Color(0.74, 0.88, 0.98)
    sky_mat.ground_horizon_color = Color(0.74, 0.88, 0.98)
    sky_mat.ground_bottom_color = Color(0.3, 0.55, 0.78)
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.82, 0.9, 1.0)
    env.ambient_light_energy = 0.42
    env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
    env.fog_enabled = true
    env.fog_light_color = Color(0.74, 0.88, 0.98)
    env.fog_density = 0.0008
    var we := WorldEnvironment.new()
    we.environment = env
    add_child(we)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48.0, -35.0, 0.0)
    sun.light_energy = 1.15
    sun.light_color = Color(1.0, 0.96, 0.88)
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 140.0
    add_child(sun)

    var water := MeshInstance3D.new()
    var pm := PlaneMesh.new()
    pm.size = Vector2(6000.0, 6000.0)
    water.mesh = pm
    water.position.y = -0.45
    var shader := Shader.new()
    shader.code = WATER_SHADER
    var wm := ShaderMaterial.new()
    wm.shader = shader
    water.material_override = wm
    water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(water)

    var cloud_mat := StandardMaterial3D.new()
    cloud_mat.albedo_color = Color(1.0, 1.0, 1.0)
    cloud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    for k in range(22):
        var c := Node3D.new()
        c.position = Vector3(randf_range(-600.0, 600.0), randf_range(90.0, 140.0), randf_range(-600.0, 600.0))
        for j in range(4):
            var m := MeshInstance3D.new()
            var s := SphereMesh.new()
            s.radius = 1.0
            s.height = 2.0
            s.radial_segments = 12
            s.rings = 6
            m.mesh = s
            m.scale = Vector3(randf_range(18.0, 30.0), randf_range(7.0, 10.0), randf_range(14.0, 24.0))
            m.position = Vector3(float(j) * 20.0 - 30.0, randf_range(-3.0, 3.0), randf_range(-8.0, 8.0))
            m.material_override = cloud_mat
            m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
            c.add_child(m)
        add_child(c)
        clouds.append(c)

    get_viewport().msaa_3d = Viewport.MSAA_4X
    camera = Camera3D.new()
    camera.fov = 70.0
    camera.far = 3000.0
    camera.current = true
    add_child(camera)

    var amb := AudioStreamPlayer.new()
    amb.stream = sounds["waves"]
    amb.volume_db = -14.0
    add_child(amb)
    amb.play()



# =====================================================================
# State
# =====================================================================
func _new_empire(aggr: float) -> Dictionary:
    return {
        "money": START_MONEY, "peak": START_MONEY, "builders": 0, "brep": 0, "arep": 0, "blevel": 1,
        "structs": [], "jobs": [],
        "ammo": [0, 0, 0, 0, 0, 0, 0, 0], "jets": [], "aggr": aggr, "grudge": -1, "phase": "build",
        "salvo": randi_range(5, 7), "rest": 0.0, "think": randf_range(2.0, 4.0),
        "cool": 0.0, "dead": false, "wnodes": [], "mnodes": [], "auto": randf_range(0.2, 1.0),
    }


func _reset_state(count: int) -> void:
    island_count = count
    emp = []
    uid_counter = 0
    for i in range(count):
        var e := _new_empire(randf_range(0.3, 0.9))
        emp.append(e)
        var hp := _house_pos(0)
        _add_struct(i, "house", 0, hp.x, hp.y, "ok", 0)
    selected_enemy = 1
    sat_island = 1
    elapsed = 0.0
    income_timer = 0.0
    launch_queue = []
    sat_open = false
    sat_has_point = false
    sat_type = 0
    sat_mult = 1
    sat_cool = 0.0
    player_off = Vector3(0.0, 0.0, 24.0)


func _struct_world(i: int, s: Dictionary) -> Vector3:
    return _isl(i).to_global(Vector3(float(s["lx"]), 0.6, float(s["lz"])))


# =====================================================================
# World building
# =====================================================================
func _build_world() -> void:
    if level_root != null and is_instance_valid(level_root):
        level_root.queue_free()
    level_root = Node3D.new()
    add_child(level_root)
    island_nodes.clear()
    island_pos.clear()
    projectiles.clear()
    sorties.clear()
    launch_queue.clear()
    sat_marker = null

    var radius: float = RING[island_count]
    for i in range(island_count):
        var ang: float = PI / 2.0 + float(i) * TAU / float(island_count)
        var p := Vector3(cos(ang) * radius, 0.0, sin(ang) * radius)
        island_pos.append(p)
        var isl := _make_island(i, p)
        level_root.add_child(isl)
        island_nodes.append(isl)

    player = _make_character(TEAM_COLORS[0])
    level_root.add_child(player)

    for i in range(island_count):
        var e: Dictionary = emp[i]
        e["wnodes"] = []
        e["mnodes"] = []
        var structs: Array = e["structs"]
        for sv in structs:
            var s: Dictionary = sv
            s["node"] = null
            s["rub"] = null
            s["ring"] = null
            s["lbl"] = null
            var st: String = s["state"]
            if st == "destroyed":
                _show_rubble(i, s)
            else:
                _spawn_struct_node(i, s, 0.0)
            _refresh_struct_label(i, s)
        _refresh_workers(i)
        var jl0: Array = e["jets"]
        for jv0 in jl0:
            var j0: Dictionary = jv0
            j0["node"] = null
            j0["state"] = "parked"
        var pt: Array = e.get("ptrucks", [])
        for pv in pt:
            var pd: Dictionary = pv
            _spawn_mtruck(i, int(pd["t"]), Vector2(float(pd["lx"]), float(pd["lz"])), int(pd["n"]), false)
        e["ptrucks"] = []
        _sync_missiles(i)
        _sync_jets(i)
        if bool(e["dead"]):
            var dead: Node3D = island_nodes[i]
            dead.position.y = -8.0

    _ensure_target()
    _update_rings()
    _look_at_target(false)


func _house_model(n: Node3D, color: Color, lvl: int) -> void:
    var glow := _glow_mat(Color(0.35, 0.95, 1.0))
    var hedge := Color(0.2, 0.5, 0.22)
    _box(n, Vector3(2.0, 0.1, 2.0), Vector3(0.0, 0.05, 0.0), Color(0.8, 0.82, 0.86))
    _box(n, Vector3(1.7, 0.24, 0.2), Vector3(0.0, 0.22, -0.9), hedge)
    _box(n, Vector3(1.7, 0.24, 0.2), Vector3(0.0, 0.22, 0.9), hedge)
    if lvl <= 2:
        var h := 0.85
        for f in range(lvl):
            var y := 0.1 + h * 0.5 + float(f) * h
            _box(n, Vector3(1.4, h, 1.2), Vector3(0.0, y, 0.0), color)
            for sx in [-0.45, 0.0, 0.45]:
                if f == 0 and sx == 0.0:
                    continue
                var wm := _box(n, Vector3(0.28, 0.32, 0.05), Vector3(sx, y + 0.05, -0.62), Color.WHITE)
                wm.material_override = glow
        var top := 0.1 + h * float(lvl)
        var roof := MeshInstance3D.new()
        var pr := PrismMesh.new()
        pr.size = Vector3(1.7, 0.6, 1.45)
        roof.mesh = pr
        roof.position = Vector3(0.0, top + 0.3, 0.0)
        roof.material_override = _mat(Color(0.34, 0.36, 0.42))
        n.add_child(roof)
        _box(n, Vector3(0.34, 0.55, 0.05), Vector3(0.0, 0.38, -0.62), Color(0.3, 0.18, 0.08))
        _box(n, Vector3(0.2, 0.45, 0.2), Vector3(0.45, top + 0.35, 0.25), Color(0.4, 0.4, 0.42))
    else:
        var floors := 2 * lvl - 1
        var fh := 0.62
        var total := fh * float(floors)
        var body := Color(0.24, 0.3, 0.46).lerp(color, 0.12)
        _box(n, Vector3(1.3, total, 1.1), Vector3(0.0, 0.1 + total * 0.5, 0.0), body)
        for f2 in range(floors):
            var y2 := 0.1 + fh * (float(f2) + 0.5)
            var wf := _box(n, Vector3(1.05, 0.2, 0.04), Vector3(0.0, y2, -0.56), Color.WHITE)
            wf.material_override = glow
            var wb := _box(n, Vector3(1.05, 0.2, 0.04), Vector3(0.0, y2, 0.56), Color.WHITE)
            wb.material_override = glow
            var wl := _box(n, Vector3(0.04, 0.2, 0.85), Vector3(-0.66, y2, 0.0), Color.WHITE)
            wl.material_override = glow
            var wr := _box(n, Vector3(0.04, 0.2, 0.85), Vector3(0.66, y2, 0.0), Color.WHITE)
            wr.material_override = glow
        var neon := Color(1.0, 0.3, 0.85) if lvl >= 4 else Color(0.3, 0.8, 1.0)
        var cap := _box(n, Vector3(1.4, 0.16, 1.2), Vector3(0.0, 0.1 + total + 0.08, 0.0), Color.WHITE)
        cap.material_override = _glow_mat(neon)
        if lvl >= 4:
            for cx in [-0.66, 0.66]:
                for cz in [-0.56, 0.56]:
                    var ed := _box(n, Vector3(0.07, total, 0.07), Vector3(cx, 0.1 + total * 0.5, cz), Color.WHITE)
                    ed.material_override = _glow_mat(neon)
        _cyl(n, 0.03, 0.03, 0.8, Vector3(0.0, total + 0.6, 0.0), Color(0.6, 0.6, 0.65))


func _make_rubble() -> Node3D:
    var r := Node3D.new()
    for k in range(7):
        var b := _box(r, Vector3(randf_range(0.5, 1.6), randf_range(0.2, 0.7), randf_range(0.5, 1.6)),
            Vector3(randf_range(-2.2, 2.2), 0.15, randf_range(-2.2, 2.2)), Color(0.18, 0.17, 0.16))
        b.rotation.y = randf() * TAU
    var ember := _sphere(r, 0.5, Vector3(0.0, 0.4, 0.0), Color(1.0, 0.4, 0.1))
    ember.material_override = _glow_mat(Color(1.0, 0.35, 0.08))
    return r


func _struct_scale(s: Dictionary) -> Vector3:
    var bs: float = s["bs"]
    return Vector3(bs, bs, bs)


func _spawn_struct_node(i: int, s: Dictionary, anim_time: float) -> void:
    var isl := _isl(i)
    var team := _team(i)
    var kind: String = s["kind"]
    var sub: int = s["sub"]
    var node := Node3D.new()
    node.position = Vector3(float(s["lx"]), 0.6, float(s["lz"]))
    isl.add_child(node)
    if kind == "house":
        var palette := [Color(0.66, 0.32, 0.28), Color(0.72, 0.46, 0.3), Color(0.56, 0.3, 0.34), Color(0.74, 0.62, 0.42)]
        var slot: int = s["slot"]
        var color: Color = palette[slot % 4]
        if i > 0:
            color = team.lightened(0.1 * float(slot % 3))
        _house_model(node, color, int(s["lvl"]))
        _merge_model(node, [])
        s["bs"] = 2.2
    else:
        _defense_model(node, sub, team)
        var dscale := [2.2, 1.5, 1.2, 1.15, 1.15]
        s["bs"] = dscale[sub]
    var target := _struct_scale(s)
    if anim_time > 0.0:
        node.scale = target * 0.2
        var tw := node.create_tween()
        tw.tween_property(node, "scale", target, anim_time)
    else:
        node.scale = target
    s["node"] = node
    if kind == "defense":
        var rng: float = DEFENSES[sub]["range"]
        var ring := _make_ring(rng, Color(0.3, 0.9, 1.0, 0.45) if i == 0 else Color(1.0, 0.35, 0.3, 0.3))
        ring.position = Vector3(float(s["lx"]), 0.7, float(s["lz"]))
        isl.add_child(ring)
        ring.visible = sat_open and sat_island == i
        s["ring"] = ring


func _show_rubble(i: int, s: Dictionary) -> void:
    var old = s["node"]
    if old != null and is_instance_valid(old):
        var o: Node3D = old
        o.queue_free()
    s["node"] = null
    var ring = s["ring"]
    if ring != null and is_instance_valid(ring):
        var rg: Node3D = ring
        rg.queue_free()
    s["ring"] = null
    var oldr = s["rub"]
    if oldr != null and is_instance_valid(oldr):
        var orr: Node3D = oldr
        orr.queue_free()
    var rub := _make_rubble()
    rub.position = Vector3(float(s["lx"]), 0.6, float(s["lz"]))
    _isl(i).add_child(rub)
    s["rub"] = rub


func _clear_rubble(s: Dictionary) -> void:
    var oldr = s["rub"]
    if oldr != null and is_instance_valid(oldr):
        var orr: Node3D = oldr
        orr.queue_free()
    s["rub"] = null


func _refresh_struct_label(i: int, s: Dictionary) -> void:
    var state: String = s["state"]
    var hp: float = s["hp"]
    var mx: float = s["maxhp"]
    var txt := ""
    var col := Color(1.0, 0.9, 0.4)
    if state == "building":
        txt = "BUILDING..."
    elif state == "destroyed":
        txt = "DESTROYED"
        col = Color(1.0, 0.35, 0.3)
    elif hp < mx - 0.5:
        txt = "%d%%" % int(round(hp / mx * 100.0))
        col = Color(1.0, 0.7, 0.3)
    var lbl = s["lbl"]
    if txt == "":
        if lbl != null and is_instance_valid(lbl):
            var hide_l: Label3D = lbl
            hide_l.visible = false
        return
    if lbl == null or not is_instance_valid(lbl):
        var nl := Label3D.new()
        nl.font_size = 48
        nl.pixel_size = 0.07
        nl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        nl.no_depth_test = true
        nl.render_priority = 2
        nl.outline_size = 12
        nl.position = Vector3(float(s["lx"]), 13.0, float(s["lz"]))
        _isl(i).add_child(nl)
        s["lbl"] = nl
        lbl = nl
    var lab: Label3D = lbl
    lab.text = txt
    lab.modulate = col
    lab.visible = true


func _refresh_workers(i: int) -> void:
    var e: Dictionary = emp[i]
    var old: Array = e["wnodes"]
    for n in old:
        if is_instance_valid(n):
            n.queue_free()
    var arr: Array = []
    var counts := [int(e["builders"]), int(e["brep"]), int(e["arep"])]
    var shirts := [Color(1.0, 0.55, 0.1), Color(0.75, 0.75, 0.8), Color(0.25, 0.5, 1.0)]
    for kind in range(3):
        for k in range(int(counts[kind])):
            var ch := _make_character(shirts[kind])
            ch.position = Vector3(-8.0 + float(k) * 4.0, 0.6, 20.0 + float(kind) * 7.0)
            ch.rotation.y = randf_range(-0.6, 0.6)
            ch.scale = Vector3.ONE * 1.5
            _isl(i).add_child(ch)
            arr.append(ch)
    e["wnodes"] = arr


func _checker_mat(i: int) -> ShaderMaterial:
    var shader := Shader.new()
    shader.code = CHECKER_SHADER
    var m := ShaderMaterial.new()
    m.shader = shader
    var team := _team(i)
    var g1 := Color(0.13, 0.34, 0.15).lerp(team, 0.05)
    var g2 := Color(0.1, 0.29, 0.12).lerp(team, 0.05)
    m.set_shader_parameter("c1", g1)
    m.set_shader_parameter("c2", g2)
    m.set_shader_parameter("tile", 10.0)
    return m


func _make_ring(radius: float, col: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var t := TorusMesh.new()
    t.inner_radius = maxf(radius - 0.4, 0.1)
    t.outer_radius = radius + 0.4
    t.rings = 96
    t.ring_segments = 6
    m.mesh = t
    var mat := StandardMaterial3D.new()
    mat.albedo_color = col
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    m.material_override = mat
    m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    return m


func _make_character(shirt: Color) -> Node3D:
    var root := Node3D.new()
    var skin := Color(1.0, 0.82, 0.3)
    _box(root, Vector3(0.9, 0.95, 0.45), Vector3(0.0, 1.25, 0.0), shirt)
    _box(root, Vector3(0.65, 0.65, 0.65), Vector3(0.0, 2.05, 0.0), skin)
    _box(root, Vector3(0.1, 0.12, 0.04), Vector3(-0.15, 2.12, -0.33), Color(0.05, 0.05, 0.05))
    _box(root, Vector3(0.1, 0.12, 0.04), Vector3(0.15, 2.12, -0.33), Color(0.05, 0.05, 0.05))
    _box(root, Vector3(0.28, 0.06, 0.04), Vector3(0.0, 1.93, -0.33), Color(0.3, 0.1, 0.05))
    _box(root, Vector3(0.72, 0.2, 0.72), Vector3(0.0, 2.45, 0.0), shirt.darkened(0.2))
    _box(root, Vector3(0.5, 0.06, 0.3), Vector3(0.0, 2.4, -0.45), shirt.darkened(0.2))
    _box(root, Vector3(0.7, 0.8, 0.25), Vector3(0.0, 1.3, 0.35), Color(0.25, 0.25, 0.3))
    for side in [-1, 1]:
        var arm := Node3D.new()
        arm.position = Vector3(float(side) * 0.62, 1.65, 0.0)
        root.add_child(arm)
        _box(arm, Vector3(0.32, 0.95, 0.32), Vector3(0.0, -0.4, 0.0), skin)
        var leg := Node3D.new()
        leg.position = Vector3(float(side) * 0.22, 0.78, 0.0)
        root.add_child(leg)
        _box(leg, Vector3(0.4, 0.78, 0.4), Vector3(0.0, -0.39, 0.0), Color(0.2, 0.3, 0.7))
        if side < 0:
            root.set_meta("arm_l", arm)
            root.set_meta("leg_l", leg)
        else:
            root.set_meta("arm_r", arm)
            root.set_meta("leg_r", leg)
    return root




# =====================================================================
# Economy: structures, workers, jobs
# Return codes: 0 = ok, 1 = not enough money, 2 = limit reached / not available,
# 3 = no free worker, 4 = spot blocked, 5 = nothing to do
# =====================================================================
func _count_structs(i: int, kind: String, sub: int, only_ok: bool) -> int:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var n := 0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) != kind:
            continue
        if sub >= 0 and int(s["sub"]) != sub:
            continue
        if only_ok and str(s["state"]) != "ok":
            continue
        n += 1
    return n


func _count_destroyed(i: int) -> int:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var n := 0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["state"]) == "destroyed":
            n += 1
    return n


func _free_workers(i: int, kind: String) -> int:
    var e: Dictionary = emp[i]
    var total := _worker_total(e, kind)
    var busy := 0
    var jobs: Array = e["jobs"]
    for jv in jobs:
        var j: Dictionary = jv
        if str(j["worker"]) == kind:
            busy += 1
    return total - busy


func _worker_price(i: int, kind: String) -> int:
    var e: Dictionary = emp[i]
    var n := mini(_worker_total(e, kind), _worker_max(kind) - 1)
    if kind == "builder":
        return int(BUILDER_PRICES[n])
    if kind == "brep":
        return int(BREP_PRICES[n])
    return int(AREP_PRICES[n])


func _struct_name(s: Dictionary) -> String:
    var kind: String = s["kind"]
    var sub: int = s["sub"]
    if kind == "house":
        return "House Lv%d" % int(s["lvl"])
    return str(DEFENSES[sub]["name"])


func _income(i: int) -> int:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var total := 0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) == "house" and str(s["state"]) == "ok":
            var lvl: int = s["lvl"]
            total += int(HOUSE_INCOME[lvl - 1])
    return total


func _add_struct(i: int, kind: String, sub: int, lx: float, lz: float, state: String, slot: int) -> Dictionary:
    uid_counter += 1
    var mx := DEFENSE_HP
    var mag := 0
    if kind == "house":
        mx = HOUSE_HP[0]
    else:
        mag = int(DEFENSES[sub]["mag"])
    var s := {
        "id": uid_counter, "kind": kind, "sub": sub, "lx": lx, "lz": lz, "hp": mx, "maxhp": mx,
        "lvl": 1, "state": state, "slot": slot, "bs": 1.0, "mag": mag, "cd": 0.0,
        "upg": false, "fixing": false, "node": null, "rub": null, "ring": null, "lbl": null,
    }
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    structs.append(s)
    return s


func _free_slot(i: int) -> int:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var used := {}
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) == "house":
            used[int(s["slot"])] = true
    for slot in range(MAX_HOUSES):
        if not used.has(slot):
            return slot
    return -1


func _start_job(i: int, s: Dictionary, jtype: String, secs: float) -> void:
    var e: Dictionary = emp[i]
    var jobs: Array = e["jobs"]
    var worker := "builder"
    if jtype == "repair":
        worker = "brep" if str(s["kind"]) == "house" else "arep"
    jobs.append({"s": s, "type": jtype, "worker": worker, "left": secs, "total": secs})


# ---------- actions (used by the player and by the rival AI) ----------


func _cancel_jobs_for(i: int, s: Dictionary) -> void:
    var e: Dictionary = emp[i]
    var jobs: Array = e["jobs"]
    for k in range(jobs.size() - 1, -1, -1):
        var j: Dictionary = jobs[k]
        var js: Dictionary = j["s"]
        if int(js["id"]) == int(s["id"]):
            jobs.remove_at(k)
    s["upg"] = false
    s["fixing"] = false


# ---------- actions (used by the player and by the rival AI) ----------
func _do_hire(i: int, kind: String) -> int:
    var e: Dictionary = emp[i]
    var key := "builders"
    if kind == "brep":
        key = "brep"
    elif kind == "arep":
        key = "arep"
    var cur: int = e[key]
    if cur >= _worker_max(kind):
        return 2
    var price := _worker_price(i, kind)
    if int(e["money"]) < price:
        return 1
    e["money"] = int(e["money"]) - price
    e[key] = cur + 1
    _refresh_workers(i)
    if i == 0:
        _play_ui("build", -3.0)
    return 0


func _process_jobs(delta: float) -> void:
    for i in range(island_count):
        var e: Dictionary = emp[i]
        var jobs: Array = e["jobs"]
        for k in range(jobs.size() - 1, -1, -1):
            var j: Dictionary = jobs[k]
            var left: float = float(j["left"]) - delta
            j["left"] = left
            if left > 0.0:
                continue
            jobs.remove_at(k)
            _finish_job(i, j)


func _finish_job(i: int, j: Dictionary) -> void:
    var s: Dictionary = j["s"]
    var jt: String = j["type"]
    var state: String = s["state"]
    if jt == "build":
        if state == "building":
            s["state"] = "ok"
            _refresh_struct_label(i, s)
            if i == 0:
                _play_ui("build", -6.0)
    elif jt == "upgrade":
        s["upg"] = false
        if state == "ok":
            var lvl: int = s["lvl"]
            if lvl < MAX_LEVEL:
                s["lvl"] = lvl + 1
                var mx: float = HOUSE_HP[lvl]
                s["maxhp"] = mx
                s["hp"] = mx
                _rebuild_node(i, s, 0.8)
                _refresh_struct_label(i, s)
                if i == 0:
                    _play_ui("build", -6.0)
    else:
        s["fixing"] = false
        if state == "destroyed":
            s["state"] = "ok"
            s["hp"] = s["maxhp"]
            if str(s["kind"]) == "defense":
                var sub: int = s["sub"]
                s["mag"] = int(DEFENSES[sub]["mag"])
            _clear_rubble(s)
            _spawn_struct_node(i, s, 1.2)
            _refresh_struct_label(i, s)
            if i == 0:
                _say("%s repaired and working again." % _struct_name(s))
                _play_ui("build", -4.0)
        elif state == "ok":
            s["hp"] = s["maxhp"]
            _refresh_struct_label(i, s)


func _err_text(code: int, what: String) -> String:
    if code == 1:
        return "Not enough money for %s." % what
    if code == 2:
        return "%s: limit reached." % what
    if code == 3:
        return "Hire a builder first (WORKER > HIRE)."
    if code == 4:
        return "%s is still locked. Keep playing to unlock it." % what
    if code == 6:
        return "That spot is blocked or outside the military area."
    return "Nothing to do for %s." % what


func _ai_tick(i: int, delta: float) -> void:
    var e: Dictionary = emp[i]
    if bool(e["dead"]):
        return
    e["think"] = float(e["think"]) - delta
    e["rest"] = maxf(0.0, float(e["rest"]) - delta)
    if float(e["think"]) <= 0.0:
        e["think"] = randf_range(2.0, 3.5)
        _ai_think(i)
    if elapsed > PEACE_TIME and float(e["rest"]) <= 0.0 and _ammo_total(i) >= int(e["salvo"]):
        _ai_salvo(i)


func _damaged_count(i: int) -> int:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var n := 0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["state"]) == "ok" and float(s["hp"]) < float(s["maxhp"]) - 0.5:
            n += 1
    return n


func _ai_pick_target(i: int) -> int:
    var e: Dictionary = emp[i]
    var gr: int = e["grudge"]
    if gr >= 0 and gr != i and not bool(emp[gr]["dead"]) and randf() < 0.6:
        return gr
    var cands: Array = []
    for k in range(island_count):
        var ek: Dictionary = emp[k]
        if k != i and not bool(ek["dead"]):
            cands.append(k)
    if cands.is_empty():
        return -1
    if cands.has(0) and randf() < 0.55:
        return 0
    return int(cands[randi() % cands.size()])


func _weighted_struct(target: int) -> Dictionary:
    var te: Dictionary = emp[target]
    var structs: Array = te["structs"]
    var pool: Array = []
    var weights: Array = []
    var total := 0.0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["state"]) == "destroyed":
            continue
        var w := 3.0
        var kind: String = s["kind"]
        if kind == "defense":
            w = 1.2
        pool.append(s)
        weights.append(w)
        total += w
    if pool.is_empty():
        return {}
    var roll := randf() * total
    for k in range(pool.size()):
        roll -= float(weights[k])
        if roll <= 0.0:
            return pool[k]
    return pool[pool.size() - 1]


func _queue_launch(attacker: int, target: int, t: int, aim: Vector2, delay: float) -> void:
    launch_queue.append({"a": attacker, "tg": target, "t": t, "aim": aim, "delay": delay})


func _process_launch_queue(delta: float) -> void:
    for k in range(launch_queue.size() - 1, -1, -1):
        var q: Dictionary = launch_queue[k]
        var d: float = float(q["delay"]) - delta
        q["delay"] = d
        if d > 0.0:
            continue
        launch_queue.remove_at(k)
        if q.has("jet"):
            _start_sortie(int(q["a"]), int(q["tg"]), q["jet"], q["aim"], q.get("route", {}), int(q.get("payload", 0)))
        else:
            _spawn_missile(int(q["a"]), int(q["tg"]), int(q["t"]), q["aim"])


func _make_missile_model(friendly: bool, mtype: int, with_trail: bool = true) -> Node3D:
    var root := Node3D.new()
    var model := Node3D.new()
    var sc: float = [2.2, 2.8, 2.6, 3.0, 2.2, 1.7, 2.4, 4.0][mtype]
    model.scale = Vector3.ONE * sc
    root.add_child(model)
    var body_col := Color(0.93, 0.93, 0.96) if friendly else Color(0.4, 0.08, 0.08)
    var tip_col := Color(1.0, 0.45, 0.1) if friendly else Color(0.95, 0.15, 0.15)
    var flame_col := Color(1.0, 0.6, 0.1)
    if mtype == 4:
        # Shahed-style delta-wing drone: no smoke trail, small engine glow
        var wing := _box(model, Vector3(1.5, 0.05, 0.9), Vector3(0.0, 0.0, 0.1), Color(0.75, 0.77, 0.8) if friendly else Color(0.35, 0.3, 0.3))
        wing.rotation.y = 0.0
        var fus := _cyl(model, 0.09, 0.09, 1.3, Vector3.ZERO, tip_col)
        fus.rotation.x = PI / 2.0
        _box(model, Vector3(0.05, 0.3, 0.2), Vector3(0.0, 0.15, 0.55), tip_col)
        var glow := _sphere(model, 0.12, Vector3(0.0, 0.0, 0.7), flame_col)
        glow.material_override = _glow_mat(flame_col)
        return root
    if mtype == 1:
        body_col = Color(0.55, 0.58, 0.6) if friendly else Color(0.3, 0.1, 0.1)
    elif mtype == 2:
        body_col = Color(0.15, 0.17, 0.2)
        tip_col = Color(0.2, 0.9, 1.0) if friendly else Color(1.0, 0.3, 0.9)
        flame_col = Color(0.4, 0.8, 1.0)
    elif mtype == 3:
        body_col = Color(0.25, 0.27, 0.3) if friendly else Color(0.35, 0.05, 0.05)
        tip_col = Color(1.0, 0.85, 0.2)
    elif mtype == 5:
        body_col = Color(0.6, 0.62, 0.6) if friendly else Color(0.4, 0.12, 0.1)
    elif mtype == 6:
        body_col = Color(0.26, 0.28, 0.32) if friendly else Color(0.3, 0.06, 0.06)
        tip_col = Color(0.85, 0.15, 0.15)
    elif mtype == 7:
        tip_col = Color(0.95, 0.15, 0.12)
    var body := _cyl(model, 0.2, 0.2, 1.2, Vector3.ZERO, body_col)
    body.rotation.x = PI / 2.0
    var nose := _cyl(model, 0.0, 0.2, 0.45, Vector3(0.0, 0.0, -0.82), tip_col)
    nose.rotation.x = -PI / 2.0
    _box(model, Vector3(0.7, 0.04, 0.3), Vector3(0.0, 0.0, 0.45), tip_col)
    _box(model, Vector3(0.04, 0.7, 0.3), Vector3(0.0, 0.0, 0.45), tip_col)
    var flame := MeshInstance3D.new()
    var fs := SphereMesh.new()
    fs.radius = 0.18
    fs.height = 0.36
    flame.mesh = fs
    flame.position = Vector3(0.0, 0.0, 0.75)
    flame.scale = Vector3(1.0, 1.0, 1.8)
    flame.material_override = _glow_mat(flame_col)
    model.add_child(flame)
    if with_trail:
        _add_trail(model, 0.9 if mtype == 2 else 0.6)
    return root


func _spawn_missile(attacker: int, target: int, t: int, aim_local: Vector2) -> void:
    var info: Dictionary = MISSILES[t]
    var from_pos := _take_missile_pos(attacker, t) + Vector3(0.0, 1.0, 0.0)
    var warheads: int = info["count"]
    var cep: float = info["cep"]
    var isl_t := _isl(target)
    for w in range(warheads):
        var lp := aim_local + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * cep
        lp.x = clampf(lp.x, -118.0, 118.0)
        lp.y = clampf(lp.y, -118.0, 118.0)
        var to_pos := isl_t.to_global(Vector3(lp.x, 1.4, lp.y))
        var m := _make_missile_model(attacker == 0, t)
        level_root.add_child(m)
        m.position = from_pos
        var dist := from_pos.distance_to(to_pos)
        projectiles.append({
            "node": m, "start": from_pos, "end": to_pos, "t": 0.0,
            "dur": maxf(0.8, dist / float(info["speed"])), "h": dist * float(info["arc"]),
            "attacker": attacker, "target": target, "wt": t, "lp": lp, "tried": [], "kill": -1.0,
        })
    if t == 4:
        _play3d("drone", from_pos, 2.0, randf_range(0.9, 1.15))
    else:
        _play3d("launch", from_pos, 4.0, 1.0 + float(t) * 0.1)


func _update_defense_cd(delta: float) -> void:
    for i in range(island_count):
        var e: Dictionary = emp[i]
        var structs: Array = e["structs"]
        for sv in structs:
            var s: Dictionary = sv
            if str(s["kind"]) == "defense":
                s["cd"] = maxf(0.0, float(s["cd"]) - delta)


func _update_projectiles(delta: float) -> void:
    for i in range(projectiles.size() - 1, -1, -1):
        var d: Dictionary = projectiles[i]
        var node: Node3D = d["node"]
        if not is_instance_valid(node):
            projectiles.remove_at(i)
            continue
        var dur: float = d["dur"]
        var t: float = float(d["t"]) + delta / dur
        d["t"] = t
        var p0: Vector3 = d["start"]
        var p1: Vector3 = d["end"]
        var h: float = d["h"]
        var target: int = d["target"]
        var tt: float = minf(t, 1.0)
        node.position = _arc(p0, p1, tt, h)
        var ahead := _arc(p0, p1, minf(tt + 0.03, 1.0), h)
        if ahead.distance_to(node.position) > 0.01:
            node.look_at(ahead, Vector3.UP)
        if t >= 1.0:
            node.queue_free()
            projectiles.remove_at(i)
            _on_impact(d)
            continue
        var kill: float = d["kill"]
        if kill >= 0.0:
            kill -= delta
            d["kill"] = kill
            if kill <= 0.0:
                _explode(node.position, Color(0.6, 0.9, 1.0), 3.5)
                _play3d("pop", node.position, 6.0)
                node.queue_free()
                projectiles.remove_at(i)
                if target == 0:
                    _say("Air defense intercepted an incoming %s!" % MISSILES[int(d["wt"])]["short"])
                elif int(d["attacker"]) == 0:
                    _say("Enemy air defense shot down your %s." % MISSILES[int(d["wt"])]["short"])
            continue
        if dur * (1.0 - t) < 0.8:
            continue
        _try_intercept(d, node, t, dur, p0, p1, h)


func _on_impact(d: Dictionary) -> void:
    var target: int = d["target"]
    var attacker: int = d["attacker"]
    var wt: int = d["wt"]
    var lp: Vector2 = d["lp"]
    var info: Dictionary = MISSILES[wt]
    var pos: Vector3 = d["end"]
    var sizes := [4.0, 5.5, 5.0, 4.5, 2.4, 3.0, 3.5, 12.0]
    var esize: float = sizes[wt]
    _explode(pos, Color(1.0, 0.5, 0.1), esize)
    _play3d("boom", pos, 6.0 + esize)
    var te: Dictionary = emp[target]
    if game_state != "playing" or bool(te["dead"]):
        return
    te["grudge"] = attacker
    if target == 0:
        _vibrate(120)
        shake = 0.6
    var blast_r: float = float(d["jrad"]) if d.has("jrad") else float(info["radius"])
    var blast_d: float = float(d["jdmg"]) if d.has("jdmg") else float(info["dmg"])
    _apply_blast(target, lp, blast_r, blast_d, attacker)
    _refresh_ui()
    _save_game()


func _apply_blast(target: int, lp: Vector2, radius: float, dmg: float, attacker: int) -> void:
    var te: Dictionary = emp[target]
    var structs: Array = te["structs"]
    var lost: Array = []
    var damaged := 0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["state"]) == "destroyed":
            continue
        var dd := Vector2(float(s["lx"]) - lp.x, float(s["lz"]) - lp.y).length()
        if dd > radius + 2.0:
            continue
        var f := 1.0 - 0.6 * (dd / (radius + 2.0))
        var hp: float = float(s["hp"]) - dmg * f
        s["hp"] = hp
        if hp <= 0.0:
            lost.append(_struct_name(s))
            _struct_destroyed(target, s)
        else:
            damaged += 1
            _refresh_struct_label(target, s)
    if not lost.is_empty():
        var names := ", ".join(PackedStringArray(lost))
        if target == 0:
            _say("Your %s destroyed by Enemy %d!" % [names, attacker])
            _play_ui("alarm", -2.0)
        elif attacker == 0:
            _say("Direct hit! Enemy %d lost: %s" % [target, names])
    elif damaged > 0 and attacker == 0:
        _say("Hit on Enemy %d: %d structure(s) damaged." % [target, damaged])
    elif damaged == 0 and attacker == 0:
        _say("Missed! Nothing in the blast area of Enemy %d." % target)
    _check_alive(target, attacker)


func _struct_destroyed(i: int, s: Dictionary) -> void:
    s["state"] = "destroyed"
    s["hp"] = 0.0
    _cancel_jobs_for(i, s)
    _show_rubble(i, s)
    _refresh_struct_label(i, s)


func _check_alive(i: int, attacker: int) -> void:
    var e: Dictionary = emp[i]
    if bool(e["dead"]):
        return
    var structs: Array = e["structs"]
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) == "house" and str(s["state"]) != "destroyed":
            return
    _island_collapsed(i, attacker)


func _island_collapsed(i: int, by: int) -> void:
    var e: Dictionary = emp[i]
    e["dead"] = true
    _clear_jets(i)
    var jobs: Array = e["jobs"]
    jobs.clear()
    if i == 0:
        _game_over(false)
        return
    var be: Dictionary = emp[by]
    be["money"] = int(be["money"]) + 5000
    if by == 0:
        _say("Enemy %d economy collapsed! You loot $5000." % i)
    else:
        _say("Enemy %d was wiped out by Enemy %d!" % [i, by])
    var isl: Node3D = island_nodes[i]
    var tw := isl.create_tween()
    tw.tween_interval(2.0)
    tw.tween_property(isl, "position:y", -8.0, 3.5)
    var any_alive := false
    for k in range(1, island_count):
        var ek: Dictionary = emp[k]
        if not bool(ek["dead"]):
            any_alive = true
    if not any_alive:
        _game_over(true)
    else:
        _ensure_target()
        if sat_open and sat_island == i:
            _sat_pick_island(selected_enemy)


func _game_over(won: bool) -> void:
    game_state = "won" if won else "lost"
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
    _vibrate(300)
    _close_windows()
    await get_tree().create_timer(2.5).timeout
    if sat_open:
        _close_sat()
    if game_state == "won":
        _play_ui("build")
        _show_overlay("VICTORY!", "Every rival economy has collapsed. You are the missile tycoon!")
    elif game_state == "lost":
        _show_overlay("YOUR ISLAND FELL", "Your last house was destroyed. Build more houses, layer your air defense and keep a repair crew ready next time.")


func _add_trail(parent: Node3D, size: float) -> void:
    var p := CPUParticles3D.new()
    p.amount = 24
    p.lifetime = 1.0
    p.local_coords = false
    p.direction = Vector3(0.0, 0.0, 1.0)
    p.spread = 20.0
    p.initial_velocity_min = 0.3
    p.initial_velocity_max = 0.8
    p.gravity = Vector3.ZERO
    var pm := SphereMesh.new()
    pm.radius = size * 0.4
    pm.height = size * 0.8
    var pmat := StandardMaterial3D.new()
    pmat.albedo_color = Color(0.92, 0.92, 0.92)
    pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    pm.material = pmat
    p.mesh = pm
    p.position = Vector3(0.0, 0.0, 0.9)
    parent.add_child(p)
    p.emitting = true


func _arc(s: Vector3, e: Vector3, t: float, h: float) -> Vector3:
    var p := s.lerp(e, t)
    p.y += sin(t * PI) * h
    return p


func _make_shock(color: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var t := TorusMesh.new()
    t.inner_radius = 0.93
    t.outer_radius = 1.0
    t.rings = 48
    t.ring_segments = 4
    m.mesh = t
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(color.r, color.g, color.b, 0.7)
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    m.material_override = mat
    m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    return m


func _explode(pos: Vector3, color: Color, size: float) -> void:
    var flash := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 1.0
    sm.height = 2.0
    sm.radial_segments = 16
    sm.rings = 8
    flash.mesh = sm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(color.r, color.g, color.b, 0.85)
    mat.emission_enabled = true
    mat.emission = color
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    flash.material_override = mat
    flash.position = pos
    flash.scale = Vector3.ONE * 0.3 * size
    level_root.add_child(flash)
    var tw := create_tween()
    tw.set_parallel(true)
    tw.tween_property(flash, "scale", Vector3.ONE * 2.2 * size, 0.4)
    tw.tween_property(mat, "albedo_color:a", 0.0, 0.4)
    tw.chain().tween_callback(flash.queue_free)

    # sparks
    var p := CPUParticles3D.new()
    p.one_shot = true
    p.amount = 40
    p.lifetime = 1.0
    p.explosiveness = 1.0
    p.direction = Vector3.UP
    p.spread = 180.0
    p.initial_velocity_min = 3.0 * size
    p.initial_velocity_max = 8.0 * size
    p.gravity = Vector3(0.0, -9.0, 0.0)
    var pm := SphereMesh.new()
    pm.radius = 0.16 * size
    pm.height = 0.32 * size
    pm.material = _glow_mat(color)
    p.mesh = pm
    p.position = pos
    level_root.add_child(p)
    p.emitting = true
    get_tree().create_timer(1.8).timeout.connect(p.queue_free)

    if size >= 4.0:
        # shockwave ring + rising smoke for big hits
        var ring := _make_shock(color)
        ring.position = pos
        ring.scale = Vector3.ONE * 0.5 * size
        level_root.add_child(ring)
        var rmat := ring.material_override as StandardMaterial3D
        var tw2 := create_tween()
        tw2.set_parallel(true)
        tw2.tween_property(ring, "scale", Vector3.ONE * 7.0 * size, 0.7)
        tw2.tween_property(rmat, "albedo_color:a", 0.0, 0.7)
        tw2.chain().tween_callback(ring.queue_free)

        var smoke := CPUParticles3D.new()
        smoke.one_shot = true
        smoke.amount = 18
        smoke.lifetime = 3.0
        smoke.explosiveness = 0.6
        smoke.direction = Vector3.UP
        smoke.spread = 30.0
        smoke.initial_velocity_min = 3.0
        smoke.initial_velocity_max = 7.0
        smoke.gravity = Vector3(0.0, 1.5, 0.0)
        smoke.scale_amount_min = 1.0
        smoke.scale_amount_max = 2.5
        var smesh := SphereMesh.new()
        smesh.radius = 1.4
        smesh.height = 2.8
        smesh.radial_segments = 8
        smesh.rings = 4
        var smat := StandardMaterial3D.new()
        smat.vertex_color_use_as_albedo = true
        smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        smesh.material = smat
        smoke.mesh = smesh
        var grad := Gradient.new()
        grad.set_color(0, Color(0.25, 0.23, 0.22, 0.85))
        grad.set_color(1, Color(0.55, 0.55, 0.55, 0.0))
        smoke.color_ramp = grad
        smoke.position = pos
        level_root.add_child(smoke)
        smoke.emitting = true
        get_tree().create_timer(3.6).timeout.connect(smoke.queue_free)


# =====================================================================
# Main loop
# =====================================================================
func _process(delta: float) -> void:
    _animate_world(delta)
    if game_state == "playing":
        elapsed += delta
        income_timer += delta
        if income_timer >= 1.0:
            income_timer -= 1.0
            _pay_income()
        _process_jobs(delta)
        for ii in range(island_count):
            _island_tick(ii, delta)
        _process_launch_queue(delta)
        _update_defense_cd(delta)
        if not sat_open:
            _move_player(delta)
        for i in range(1, island_count):
            _ai_tick(i, delta)
        _update_projectiles(delta)
        _update_sorties(delta)
        _jetcam_ui_tick()
        _process_jets(delta)
        sat_cool = maxf(0.0, sat_cool - delta)
        ui_timer += delta
        if ui_timer >= 0.5:
            ui_timer = 0.0
            _refresh_ui()
    elif game_state == "menu":
        cam_yaw += delta * 0.12
    _update_camera(delta)


func _pay_income() -> void:
    for i in range(island_count):
        var e: Dictionary = emp[i]
        if not bool(e["dead"]):
            e["money"] = int(e["money"]) + _income(i)
            e["peak"] = maxi(int(e.get("peak", 0)), int(e["money"]))


func _animate_world(delta: float) -> void:
    for c in clouds:
        var cn: Node3D = c
        cn.position.x += delta * 3.0
        if cn.position.x > 650.0:
            cn.position.x = -650.0


func _alive_enemy_count() -> int:
    var n := 0
    for k in range(1, island_count):
        var ek: Dictionary = emp[k]
        if not bool(ek["dead"]):
            n += 1
    return n


func _ensure_target() -> void:
    if island_count < 2:
        return
    selected_enemy = clampi(selected_enemy, 1, island_count - 1)
    var e: Dictionary = emp[selected_enemy]
    if not bool(e["dead"]):
        return
    for k in range(1, island_count):
        var ek: Dictionary = emp[k]
        if not bool(ek["dead"]):
            selected_enemy = k
            return


func _player_world() -> Vector3:
    var base: Vector3 = island_pos[0]
    return base + player_off + Vector3(0.0, 0.6, 0.0)


func _move_player(delta: float) -> void:
    var fwd := Vector3(-sin(cam_yaw), 0.0, -cos(cam_yaw))
    var right := Vector3(cos(cam_yaw), 0.0, -sin(cam_yaw))
    var mv := joy_vec
    var moving := mv.length() > 0.1
    if moving:
        var dir := right * mv.x + fwd * (-mv.y)
        if dir.length() > 1.0:
            dir = dir.normalized()
        player_off += dir * WALK_SPEED * delta
        player_off.x = clampf(player_off.x, -PLAYER_HALF, PLAYER_HALF)
        player_off.z = clampf(player_off.z, -PLAYER_HALF, PLAYER_HALF)
        if dir.length() > 0.05:
            player.rotation.y = lerp_angle(player.rotation.y, _yaw_to(dir), clampf(delta * 12.0, 0.0, 1.0))
        walk_amount = minf(1.0, walk_amount + delta * 6.0)
        walk_phase += delta * 12.0
    else:
        walk_amount = maxf(0.0, walk_amount - delta * 6.0)
    player.position = _player_world()
    var s := sin(walk_phase) * 0.9 * walk_amount
    var arm_l: Node3D = player.get_meta("arm_l")
    var arm_r: Node3D = player.get_meta("arm_r")
    var leg_l: Node3D = player.get_meta("leg_l")
    var leg_r: Node3D = player.get_meta("leg_r")
    arm_l.rotation.x = s
    arm_r.rotation.x = -s
    leg_l.rotation.x = -s
    leg_r.rotation.x = s


func _look_at_target(smooth: bool) -> void:
    if island_pos.size() < 2:
        return
    var a: Vector3 = island_pos[0]
    var b: Vector3 = island_pos[selected_enemy]
    cam_goal = _yaw_to(b - a)
    if smooth:
        cam_auto = 1.2
    else:
        cam_yaw = cam_goal




# =====================================================================
# Camera (walking view and satellite view)
# =====================================================================
func _update_camera(delta: float) -> void:
    if jetcam_on:
        _jetcam_update(delta)
        return
    if sat_open:
        var ip: Vector3 = island_pos[sat_island]
        var isl := _isl(sat_island)
        var up_dir: Vector3 = isl.global_transform.basis * Vector3(0.0, 0.0, -1.0)
        camera.position = ip + Vector3(0.0, SAT_HEIGHT, 0.0)
        camera.look_at(ip + Vector3(0.0, 0.5, 0.0), up_dir)
        return
    if cam_auto > 0.0:
        cam_auto -= delta
        cam_yaw = lerp_angle(cam_yaw, cam_goal, clampf(delta * 5.0, 0.0, 1.0))
    var fwd := Vector3(-sin(cam_yaw), 0.0, -cos(cam_yaw))
    var focus := _player_world() + Vector3(0.0, 1.8, 0.0)
    var off := -fwd * cos(cam_pitch) + Vector3.UP * sin(cam_pitch)
    var want := focus + off * cam_dist
    want.y = maxf(want.y, 1.2)
    camera.position = camera.position.lerp(want, clampf(delta * 10.0, 0.0, 1.0))
    camera.look_at(focus + fwd * 3.0 + Vector3(0.0, 0.4, 0.0), Vector3.UP)
    if shake > 0.0:
        camera.position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake
        shake = maxf(0.0, shake - delta * 2.5)


# =====================================================================
# Satellite targeting view
# =====================================================================
func _open_sat() -> void:
    if game_state != "playing" or sat_open:
        return
    if _alive_enemy_count() < 1:
        return
    if jetcam_on:
        _jetcam_exit()
    _close_windows()
    _ensure_target()
    sat_open = true
    for cl in clouds:
        var cn: Node3D = cl
        cn.visible = false
    sat_island = selected_enemy
    sat_has_point = false
    sat_drag_id = -1
    sat_cool = 0.0
    camera.fov = 50.0
    joy_id = -1
    look_id = -1
    joy_vec = Vector2.ZERO
    _reset_joystick()
    _update_rings()
    _sat_ui_show(true)
    _play_ui("sat")
    _say("Pick a weapon on the left, choose X1 or X5, then tap the enemy island to fire.")
    _refresh_sat()


func _close_sat() -> void:
    if not sat_open:
        return
    sat_open = false
    place_mode = false
    route_wps.clear()
    _clear_route_marks()
    for cl2 in clouds:
        var cn2: Node3D = cl2
        cn2.visible = true
    sat_drag_id = -1
    camera.fov = 70.0
    _remove_sat_marker()
    _update_rings()
    _sat_ui_show(false)
    if sat_island > 0:
        selected_enemy = sat_island
    _ensure_target()
    _look_at_target(false)
    camera.position = _player_world() + Vector3(0.0, 6.0, 12.0)
    _save_game()


func _sat_pick_island(i: int) -> void:
    var e: Dictionary = emp[i]
    if bool(e["dead"]):
        return
    sat_island = i
    selected_enemy = i
    sat_has_point = false
    route_wps.clear()
    _clear_route_marks()
    _remove_sat_marker()
    _update_rings()
    _refresh_sat()


func _remove_sat_marker() -> void:
    if sat_marker != null and is_instance_valid(sat_marker):
        sat_marker.queue_free()
    sat_marker = null


func _sat_screen_to_local(pos: Vector2) -> Vector2:
    var o := camera.project_ray_origin(pos)
    var dir := camera.project_ray_normal(pos)
    var ip: Vector3 = island_pos[sat_island]
    var plane_y := ip.y + 0.6
    if absf(dir.y) < 0.0001:
        return Vector2.ZERO
    var tt := (plane_y - o.y) / dir.y
    var hit := o + dir * tt
    var local := _isl(sat_island).to_local(hit)
    return Vector2(clampf(local.x, -118.0, 118.0), clampf(local.z, -118.0, 118.0))


func _sat_set_point(pos: Vector2) -> void:
    sat_local = _sat_screen_to_local(pos)
    sat_has_point = true
    _update_sat_marker()
    _refresh_sat()


func _update_sat_marker() -> void:
    if not sat_has_point:
        _remove_sat_marker()
        return
    if sat_marker == null or not is_instance_valid(sat_marker):
        sat_marker = _make_ring(6.0, Color(1.0, 0.2, 0.2, 0.9))
        _cyl(sat_marker, 0.3, 0.3, 60.0, Vector3(0.0, 30.0, 0.0), Color(1.0, 0.3, 0.3))
        _isl(sat_island).add_child(sat_marker)
    sat_marker.position = Vector3(sat_local.x, 1.0, sat_local.y)
    sat_marker.scale = Vector3.ONE * (_sat_blast_radius() / 6.0)


func _update_rings() -> void:
    for i in range(island_count):
        var e: Dictionary = emp[i]
        var structs: Array = e["structs"]
        for sv in structs:
            var s: Dictionary = sv
            var ring = s["ring"]
            if ring == null or not is_instance_valid(ring):
                continue
            var r: Node3D = ring
            r.visible = sat_open and sat_island == i


func _has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)


func _after_buy() -> void:
    _refresh_ui()
    _save_game()


func _save_game() -> void:
    if game_state != "playing" or emp.is_empty():
        return
    var arr: Array = []
    for i in range(island_count):
        var e: Dictionary = emp[i]
        var sl: Array = []
        var structs: Array = e["structs"]
        for sv in structs:
            var s: Dictionary = sv
            sl.append({
                "kind": s["kind"], "sub": s["sub"], "lx": s["lx"], "lz": s["lz"], "hp": s["hp"],
                "lvl": s["lvl"], "state": s["state"], "slot": s["slot"], "mag": s["mag"],
            })
        var jl: Array = []
        var jets: Array = e["jets"]
        for jv in jets:
            var jj: Dictionary = jv
            jl.append({"t": jj["t"], "slot": jj["slot"]})
        var tl: Array = []
        var trucks: Array = e["mnodes"]
        for tv in trucks:
            var tt: Dictionary = tv
            tl.append({"t": tt["t"], "n": tt["n"], "lx": tt["lx"], "lz": tt["lz"]})
        arr.append({
            "money": e["money"], "peak": e.get("peak", 0), "builders": e["builders"], "brep": e["brep"], "arep": e["arep"],
            "blevel": e["blevel"], "ammo": e["ammo"], "aggr": e["aggr"], "grudge": e["grudge"],
            "salvo": e["salvo"], "rest": e["rest"], "dead": e["dead"], "structs": sl, "jets": jl, "mtrucks": tl,
        })
    var data := {
        "v": 8, "island_count": island_count, "emp": arr,
        "selected": selected_enemy, "elapsed": elapsed,
    }
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))


func _load_game() -> bool:
    if not _has_save():
        return false
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not f:
        return false
    var parsed = JSON.parse_string(f.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    if int(parsed.get("v", 0)) != 8:
        return false
    var count := clampi(int(parsed.get("island_count", 2)), 2, 4)
    var emp_raw = parsed.get("emp", [])
    if typeof(emp_raw) != TYPE_ARRAY or emp_raw.size() != count:
        return false
    _reset_state(count)
    for i in range(count):
        var src: Dictionary = emp_raw[i]
        var e: Dictionary = emp[i]
        e["structs"] = []
        e["money"] = int(src.get("money", START_MONEY))
        e["peak"] = maxi(int(src.get("peak", 0)), int(e["money"]))
        e["builders"] = clampi(int(src.get("builders", 0)), 0, MAX_BUILDERS)
        e["brep"] = clampi(int(src.get("brep", 0)), 0, MAX_BREP)
        e["arep"] = clampi(int(src.get("arep", 0)), 0, MAX_AREP)
        e["blevel"] = clampi(int(src.get("blevel", 1)), 1, MAX_LEVEL)
        e["aggr"] = float(src.get("aggr", 0.5))
        e["grudge"] = int(src.get("grudge", -1))
        e["salvo"] = int(src.get("salvo", 6))
        e["rest"] = float(src.get("rest", 0.0))
        e["dead"] = bool(src.get("dead", false))
        var am = src.get("ammo", [])
        var ammo: Array = e["ammo"]
        for t in range(NM):
            ammo[t] = int(am[t]) if t < am.size() else 0
        var jraw = src.get("jets", [])
        var jlist: Array = e["jets"]
        for jv in jraw:
            var jd: Dictionary = jv
            if jlist.size() < MAX_JETS:
                jlist.append({"t": clampi(int(jd.get("t", 0)), 0, JETS.size() - 1), "state": "parked", "slot": int(jd.get("slot", jlist.size())), "node": null, "timer": 0.0})
        var traw = src.get("mtrucks", [])
        var ptl: Array = []
        for tv in traw:
            var td: Dictionary = tv
            ptl.append(td)
        e["ptrucks"] = ptl
        var raw_structs = src.get("structs", [])
        for rv in raw_structs:
            var r: Dictionary = rv
            var kind := str(r.get("kind", "house"))
            if kind != "house" and kind != "defense":
                continue
            var sub := clampi(int(r.get("sub", 0)), 0, 4)
            var state := str(r.get("state", "ok"))
            if state == "building":
                state = "ok"
            var s := _add_struct(i, kind, sub, float(r.get("lx", 0.0)), float(r.get("lz", 0.0)), state, int(r.get("slot", 0)))
            var lvl := clampi(int(r.get("lvl", 1)), 1, MAX_LEVEL)
            s["lvl"] = lvl
            if kind == "house":
                s["maxhp"] = HOUSE_HP[lvl - 1]
            var mx: float = s["maxhp"]
            s["hp"] = minf(float(r.get("hp", mx)), mx)
            if state == "destroyed":
                s["hp"] = 0.0
            if kind == "defense":
                s["mag"] = clampi(int(r.get("mag", DEFENSES[sub]["mag"])), 0, int(DEFENSES[sub]["mag"]))
    selected_enemy = int(parsed.get("selected", 1))
    elapsed = float(parsed.get("elapsed", 0.0))
    var pe: Dictionary = emp[0]
    if bool(pe["dead"]):
        return false
    return true


func _load_settings() -> void:
    if not FileAccess.file_exists(SETTINGS_PATH):
        return
    var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
    if not f:
        return
    var parsed = JSON.parse_string(f.get_as_text())
    if typeof(parsed) == TYPE_DICTIONARY:
        look_sens_idx = clampi(int(parsed.get("sens", 1)), 0, 2)


func _save_settings() -> void:
    var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify({"sens": look_sens_idx}))


func _cycle_sens() -> void:
    look_sens_idx = (look_sens_idx + 1) % 3
    _save_settings()
    _update_sens_text()


func _update_sens_text() -> void:
    if btn_sens:
        btn_sens.text = "LOOK SENSITIVITY: %s  (tap to change)" % SENS_NAMES[look_sens_idx]


func _style_panel(c: Control, col: Color = Color(0.05, 0.1, 0.18, 0.72)) -> void:
    var sb := StyleBoxFlat.new()
    sb.bg_color = col
    sb.set_corner_radius_all(18)
    sb.content_margin_left = 16.0
    sb.content_margin_right = 16.0
    sb.content_margin_top = 10.0
    sb.content_margin_bottom = 10.0
    c.add_theme_stylebox_override("panel", sb)


func _style_button(b: Button, col: Color) -> void:
    for state in ["normal", "hover", "pressed", "disabled", "focus"]:
        var sb := StyleBoxFlat.new()
        sb.bg_color = col
        if state == "pressed":
            sb.bg_color = col.darkened(0.3)
        elif state == "hover":
            sb.bg_color = col.lightened(0.1)
        elif state == "disabled":
            sb.bg_color = Color(0.3, 0.3, 0.34, 0.85)
        sb.set_corner_radius_all(16)
        sb.content_margin_left = 18.0
        sb.content_margin_right = 18.0
        sb.content_margin_top = 8.0
        sb.content_margin_bottom = 8.0
        b.add_theme_stylebox_override(state, sb)


func _make_button(text: String, col: Color, cb: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(300.0, 62.0)
    _style_button(b, col)
    b.pressed.connect(_play_ui.bind("click", -8.0))
    b.pressed.connect(cb)
    return b


func _round_style(alpha: float) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(1.0, 1.0, 1.0, alpha)
    sb.set_corner_radius_all(120)
    sb.set_border_width_all(3)
    sb.border_color = Color(1.0, 1.0, 1.0, 0.45)
    return sb



# =====================================================================
# UI construction
# =====================================================================
func _build_ui() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 10
    add_child(layer)
    ui_root = Control.new()
    ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var th := Theme.new()
    th.set_default_font_size(24)
    ui_root.theme = th
    layer.add_child(ui_root)
    ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    _build_hud()
    _build_tabs()
    _build_hotbar()
    _build_military_window()
    _build_worker_window()
    _build_sat_ui()
    _build_jetcam_ui()

    joy_base = Panel.new()
    joy_base.size = Vector2(180.0, 180.0)
    joy_base.add_theme_stylebox_override("panel", _round_style(0.18))
    joy_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(joy_base)
    joy_knob = Panel.new()
    joy_knob.size = Vector2(84.0, 84.0)
    joy_knob.add_theme_stylebox_override("panel", _round_style(0.45))
    joy_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(joy_knob)
    _reset_joystick()

    _build_overlay()
    _tab_style(mil_tab_btns, 0)
    _tab_style(work_tab_btns, 0)


func _build_hud() -> void:
    stats_panel = PanelContainer.new()
    _style_panel(stats_panel, Color(0.03, 0.06, 0.1, 0.5))
    stats_panel.position = Vector2(12.0, 150.0)
    stats_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(stats_panel)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 2)
    stats_panel.add_child(v)
    stat_missile = Label.new()
    _style_text(stat_missile, 22, Color(1.0, 1.0, 1.0))
    v.add_child(stat_missile)
    stat_aa = Label.new()
    _style_text(stat_aa, 22, Color(1.0, 1.0, 1.0))
    v.add_child(stat_aa)
    stat_jets = Label.new()
    _style_text(stat_jets, 22, Color(1.0, 1.0, 1.0))
    v.add_child(stat_jets)
    stat_house = Label.new()
    _style_text(stat_house, 22, Color(1.0, 1.0, 1.0))
    v.add_child(stat_house)
    money_label = Label.new()
    _style_text(money_label, 40, Color(0.25, 1.0, 0.3))
    v.add_child(money_label)
    income_label = Label.new()
    _style_text(income_label, 26, Color(0.25, 0.9, 0.35))
    v.add_child(income_label)
    stats_label = Label.new()
    _style_text(stats_label, 19, Color(1.0, 0.85, 0.5))
    v.add_child(stats_label)

    var mc := MarginContainer.new()
    status_box = mc
    mc.add_theme_constant_override("margin_top", 84)
    mc.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(mc)
    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.custom_minimum_size = Vector2(760.0, 0.0)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _style_text(status_label, 24, Color(1.0, 0.93, 0.6))
    mc.add_child(status_label)
    mc.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
    mc.grow_horizontal = Control.GROW_DIRECTION_BOTH

    menu_btn = _make_button("MENU", Color(0.2, 0.24, 0.32), _on_menu_pressed)
    menu_btn.custom_minimum_size = Vector2(130.0, 52.0)
    ui_root.add_child(menu_btn)
    menu_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
    menu_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN


func _build_overlay() -> void:
    overlay = Panel.new()
    var osb := StyleBoxFlat.new()
    osb.bg_color = Color(0.02, 0.06, 0.12, 0.78)
    overlay.add_theme_stylebox_override("panel", osb)
    ui_root.add_child(overlay)
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var cc := CenterContainer.new()
    overlay.add_child(cc)
    cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var ov := VBoxContainer.new()
    ov.add_theme_constant_override("separation", 12)
    cc.add_child(ov)
    ov_title = Label.new()
    ov_title.add_theme_font_size_override("font_size", 56)
    ov_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ov.add_child(ov_title)
    ov_sub = Label.new()
    ov_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    ov_sub.custom_minimum_size = Vector2(760.0, 0.0)
    ov_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ov.add_child(ov_sub)
    btn_resume = _make_button("RESUME", Color(0.2, 0.6, 0.35), _resume_game)
    btn_continue = _make_button("CONTINUE SAVED GAME", Color(0.2, 0.5, 0.85), _continue_game)
    ov.add_child(btn_resume)
    ov.add_child(btn_continue)
    ov.add_child(_make_button("NEW GAME: 1 vs 1 (2 islands)", Color(0.8, 0.35, 0.2), _start_new.bind(2)))
    ov.add_child(_make_button("NEW GAME: 1 vs 1 vs 1 (3 islands)", Color(0.8, 0.35, 0.2), _start_new.bind(3)))
    ov.add_child(_make_button("NEW GAME: 4 islands battle", Color(0.8, 0.35, 0.2), _start_new.bind(4)))
    btn_sens = _make_button("", Color(0.3, 0.35, 0.5), _cycle_sens)
    ov.add_child(btn_sens)
    for c in ov.get_children():
        if c is Button:
            var cb: Button = c
            cb.custom_minimum_size = Vector2(560.0, 60.0)



# =====================================================================
# Shop button actions
# =====================================================================
func _ui_result(code: int, what: String, ok_msg: String) -> void:
    if game_state != "playing":
        return
    if code == 0:
        _play_ui("build", -4.0)
        _say(ok_msg)
        _after_buy()
    else:
        _play_ui("error")
        _say(_err_text(code, what))
        _refresh_ui()


func _ui_hire(kind: String) -> void:
    var nm := "a builder"
    if kind == "brep":
        nm = "a build repairman"
    elif kind == "arep":
        nm = "an anti-air repairman"
    _ui_result(_do_hire(0, kind), nm, "Hired %s." % nm)


func _sat_ui_show(on: bool) -> void:
    sat_root.visible = on
    tabs_box.visible = not on
    hot_box.visible = not on
    stats_panel.visible = not on
    status_box.visible = not on
    joy_base.visible = not on
    joy_knob.visible = not on
    if on:
        _close_windows()
        _update_mult_style()


func _over_ui(pos: Vector2) -> bool:
    for c in [stats_panel, tabs_box, hot_box, menu_btn, jetcam_btn, mil_panel, work_panel, overlay]:
        var ctl: Control = c
        if ctl.is_visible_in_tree() and ctl.get_global_rect().has_point(pos):
            return true
    return false


func _over_sat_ui(pos: Vector2) -> bool:
    for c in sat_panels:
        var ctl: Control = c
        if ctl.is_visible_in_tree() and ctl.get_global_rect().has_point(pos):
            return true
    if menu_btn.get_global_rect().has_point(pos) or overlay.is_visible_in_tree():
        return true
    return false


func _show_overlay(title: String, sub: String) -> void:
    joy_id = -1
    look_id = -1
    joy_vec = Vector2.ZERO
    _reset_joystick()
    ov_title.text = title
    ov_sub.text = sub
    if game_state == "playing":
        game_state = "paused"
    btn_resume.visible = game_state == "paused"
    btn_continue.visible = _has_save() and game_state != "paused"
    overlay.show()


func _on_menu_pressed() -> void:
    if game_state != "playing":
        return
    _close_windows()
    game_state = "paused"
    _show_overlay("PAUSED", "Your progress is saved automatically.")


func _say(message: String) -> void:
    if status_label:
        status_label.text = message
    if sat_hint:
        sat_hint.text = message


func _place_joystick(c: Vector2) -> void:
    joy_base.position = c - joy_base.size / 2.0
    joy_knob.position = c - joy_knob.size / 2.0


func _reset_joystick() -> void:
    if joy_base == null:
        return
    var vp := get_viewport().get_visible_rect().size
    _place_joystick(Vector2(230.0, vp.y - 230.0))
    joy_base.modulate.a = 0.55
    joy_knob.modulate.a = 0.55


func _update_joystick(pos: Vector2) -> void:
    var d := pos - joy_center
    if d.length() > 60.0:
        d = d.normalized() * 60.0
    joy_vec = d / 60.0
    joy_knob.position = joy_center + d - joy_knob.size / 2.0



# =====================================================================
# Input
# =====================================================================
func _sat_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var te := event as InputEventScreenTouch
        if te.pressed:
            if _over_sat_ui(te.position):
                return
            _sat_tap(te.position)


func _input(event: InputEvent) -> void:
    if game_state != "playing":
        return
    if jetcam_on:
        return
    if sat_open:
        _sat_input(event)
        return
    if event is InputEventScreenTouch:
        var te := event as InputEventScreenTouch
        if te.pressed:
            if _over_ui(te.position):
                return
            var vp := get_viewport().get_visible_rect().size
            if te.position.x < vp.x * 0.5:
                if joy_id == -1:
                    joy_id = te.index
                    joy_center = te.position
                    joy_vec = Vector2.ZERO
                    _place_joystick(te.position)
                    joy_base.modulate.a = 1.0
                    joy_knob.modulate.a = 1.0
            elif look_id == -1:
                look_id = te.index
        else:
            if te.index == joy_id:
                joy_id = -1
                joy_vec = Vector2.ZERO
                _reset_joystick()
            elif te.index == look_id:
                look_id = -1
    elif event is InputEventScreenDrag:
        var de := event as InputEventScreenDrag
        if de.index == joy_id:
            _update_joystick(de.position)
        elif de.index == look_id:
            var sens: float = LOOK_SENS[look_sens_idx]
            cam_yaw += de.relative.x * sens
            cam_pitch = clampf(cam_pitch - de.relative.y * sens * 0.7, 0.12, 1.1)
            cam_auto = 0.0


# =====================================================================
# Game flow
# =====================================================================
func _enter_game(msg: String) -> void:
    if sat_open:
        sat_open = false
        camera.fov = 70.0
    _sat_ui_show(false)
    overlay.hide()
    _close_windows()
    game_state = "playing"
    ui_timer = 0.0
    _say(msg)
    _refresh_ui()


func _start_new(count: int) -> void:
    _reset_state(count)
    _build_world()
    _enter_game("You own one house and $%d. Open WORKER and hire a builder: builders raise houses for income by themselves. Rivals start the same way and attack after the peace time." % START_MONEY)
    _save_game()


func _continue_game() -> void:
    if _load_game():
        _build_world()
        _enter_game("Welcome back!")
    else:
        _start_new(2)


func _resume_game() -> void:
    overlay.hide()
    game_state = "playing"


func _worker_total(e: Dictionary, kind: String) -> int:
    if kind == "builder":
        return int(e["builders"])
    if kind == "brep":
        return int(e["brep"])
    return int(e["arep"])


func _worker_max(kind: String) -> int:
    if kind == "builder":
        return MAX_BUILDERS
    if kind == "brep":
        return MAX_BREP
    return MAX_AREP


func _ammo_total(i: int) -> int:
    var e: Dictionary = emp[i]
    var ammo: Array = e["ammo"]
    var n := 0
    for v in ammo:
        n += int(v)
    return n


func _do_upgrade_builder(i: int) -> int:
    var e: Dictionary = emp[i]
    var lvl: int = e["blevel"]
    if lvl >= MAX_LEVEL:
        return 2
    if int(e["builders"]) < 1:
        return 3
    var price: int = BUILDER_UPGRADE[lvl - 1]
    if int(e["money"]) < price:
        return 1
    e["money"] = int(e["money"]) - price
    e["blevel"] = lvl + 1
    if i == 0:
        _play_ui("build")
    return 0


func _island_tick(i: int, delta: float) -> void:
    var e: Dictionary = emp[i]
    if bool(e["dead"]):
        return
    e["auto"] = float(e["auto"]) - delta
    if float(e["auto"]) > 0.0:
        return
    e["auto"] = 1.0
    _auto_workers(i)
    _auto_restock(i)


func _auto_workers(i: int) -> void:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var blvl: int = e["blevel"]
    var fb := _free_workers(i, "builder")
    # builders first upgrade every house to the builder level ...
    for sv in structs:
        if fb < 1:
            break
        var s: Dictionary = sv
        if str(s["kind"]) != "house" or str(s["state"]) != "ok" or bool(s["upg"]) or bool(s["fixing"]):
            continue
        if int(s["lvl"]) < blvl:
            s["upg"] = true
            _start_job(i, s, "upgrade", TIME_UPGRADE)
            fb -= 1
    # ... then raise new houses (already at the builder level)
    while fb > 0 and _count_structs(i, "house", -1, false) < MAX_HOUSES:
        var slot := _free_slot(i)
        if slot < 0:
            break
        var hp := _house_pos(slot)
        var ns := _add_struct(i, "house", 0, hp.x, hp.y, "building", slot)
        ns["lvl"] = blvl
        var mx: float = HOUSE_HP[blvl - 1]
        ns["maxhp"] = mx
        ns["hp"] = mx
        _spawn_struct_node(i, ns, TIME_HOUSE)
        _refresh_struct_label(i, ns)
        _start_job(i, ns, "build", TIME_HOUSE)
        fb -= 1
    # repair crews
    var fh := _free_workers(i, "brep")
    var fa := _free_workers(i, "arep")
    for sv2 in structs:
        var r: Dictionary = sv2
        var st: String = r["state"]
        if bool(r["fixing"]) or st == "building":
            continue
        var hurt := st == "destroyed" or float(r["hp"]) < float(r["maxhp"]) - 0.5
        if not hurt:
            continue
        var is_house := str(r["kind"]) == "house"
        if is_house and fh < 1:
            continue
        if (not is_house) and fa < 1:
            continue
        if bool(r["upg"]):
            continue
        r["fixing"] = true
        _start_job(i, r, "repair", TIME_REPAIR if st == "destroyed" else 6.0)
        if is_house:
            fh -= 1
        else:
            fa -= 1


func _auto_restock(i: int) -> void:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) != "defense" or str(s["state"]) != "ok":
            continue
        var sub: int = s["sub"]
        var mag: int = s["mag"]
        if mag >= int(DEFENSES[sub]["mag"]):
            continue
        var cost: int = DEFENSES[sub]["ref"]
        if int(e["money"]) >= cost:
            e["money"] = int(e["money"]) - cost
            s["mag"] = mag + 1


# ---------- standing missiles on the island ----------


func _rebuild_node(i: int, s: Dictionary, anim: float) -> void:
    var old = s["node"]
    if old != null and is_instance_valid(old):
        var o: Node3D = old
        o.queue_free()
    s["node"] = null
    _spawn_struct_node(i, s, anim)


func _fmt_money(n: int) -> String:
    if n >= 1000000:
        return "%.1fM" % (float(n) / 1000000.0)
    if n >= 100000:
        return "%dK" % (n / 1000)
    if n >= 1000:
        return "%.1fK" % (float(n) / 1000.0)
    return str(n)


func _style_text(l: Label, size: int, col: Color) -> void:
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", col)
    l.add_theme_constant_override("outline_size", 6)
    l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))


func _tab_button(text: String, col: Color, cb: Callable) -> Button:
    var b := _make_button(text, Color(0.16, 0.19, 0.24, 0.94), cb)
    b.custom_minimum_size = Vector2(200.0, 58.0)
    b.add_theme_font_size_override("font_size", 28)
    b.add_theme_color_override("font_color", col)
    b.add_theme_color_override("font_hover_color", col.lightened(0.3))
    b.add_theme_color_override("font_pressed_color", col)
    return b


func _build_tabs() -> void:
    tabs_box = HBoxContainer.new()
    tabs_box.add_theme_constant_override("separation", 10)
    ui_root.add_child(tabs_box)
    tabs_box.add_child(_tab_button("MILITARY", Color(0.3, 0.95, 0.95), _toggle_mil))
    tabs_box.add_child(_tab_button("ATTACK", Color(1.0, 0.82, 0.1), _open_sat))
    tabs_box.add_child(_tab_button("WORKER", Color(0.3, 0.95, 0.95), _toggle_work))
    tabs_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 8)
    tabs_box.grow_horizontal = Control.GROW_DIRECTION_BOTH


func _make_slot(idx: int) -> Dictionary:
    var b := Button.new()
    b.custom_minimum_size = Vector2(74.0, 74.0)
    _style_button(b, Color(0.1, 0.12, 0.17, 0.9))
    b.pressed.connect(_play_ui.bind("click", -8.0))
    b.pressed.connect(_on_hot_slot.bind(idx))
    var ic := MiniIcon.new()
    ic.custom_minimum_size = Vector2(62.0, 62.0)
    b.add_child(ic)
    ic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
    var lbl := Label.new()
    lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _style_text(lbl, 20, Color(1.0, 1.0, 1.0))
    b.add_child(lbl)
    lbl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 4)
    lbl.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
    var num := Label.new()
    num.mouse_filter = Control.MOUSE_FILTER_IGNORE
    num.text = str(idx + 1)
    _style_text(num, 16, Color(0.8, 0.85, 0.9))
    b.add_child(num)
    num.position = Vector2(6.0, 2.0)
    return {"btn": b, "icon": ic, "lbl": lbl}


func _tab_style(btns: Array, sel: int) -> void:
    for k in range(btns.size()):
        var b: Button = btns[k]
        var on := k == sel
        _style_button(b, Color(1.0, 0.85, 0.05) if on else Color(0.04, 0.04, 0.05))
        var fc := Color(0.05, 0.05, 0.05) if on else Color(1.0, 1.0, 1.0)
        b.add_theme_color_override("font_color", fc)
        b.add_theme_color_override("font_hover_color", fc)
        b.add_theme_color_override("font_pressed_color", fc)


func _make_window(tab_names: Array, on_tab: Callable, tab_btns: Array) -> Dictionary:
    var panel := PanelContainer.new()
    _style_panel(panel, Color(0.05, 0.07, 0.1, 0.96))
    ui_root.add_child(panel)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 8)
    panel.add_child(v)
    var head := HBoxContainer.new()
    head.add_theme_constant_override("separation", 8)
    v.add_child(head)
    for k in range(tab_names.size()):
        var tb := _make_button(str(tab_names[k]), Color(0.05, 0.05, 0.06), on_tab.bind(k))
        tb.custom_minimum_size = Vector2(205.0, 54.0)
        tb.add_theme_font_size_override("font_size", 26)
        head.add_child(tb)
        tab_btns.append(tb)
    var sp := Control.new()
    sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
    head.add_child(sp)
    var xb := _make_button("X", Color(0.1, 0.3, 0.95), _close_windows)
    xb.custom_minimum_size = Vector2(64.0, 54.0)
    head.add_child(xb)
    panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
    panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    panel.position.y += 18.0
    panel.hide()
    return {"panel": panel, "vbox": v}


func _make_grid(parent: Control) -> GridContainer:
    var sc := ScrollContainer.new()
    sc.custom_minimum_size = Vector2(920.0, 430.0)
    sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    parent.add_child(sc)
    var g := GridContainer.new()
    g.columns = 2
    g.add_theme_constant_override("h_separation", 10)
    g.add_theme_constant_override("v_separation", 10)
    sc.add_child(g)
    return g


func _make_card(icon_kind: int, icon_sub: int, title: String, lines: Array, cb1: Callable, cb5: Callable) -> Dictionary:
    var card := PanelContainer.new()
    _style_panel(card, Color(0.1, 0.11, 0.14, 0.98))
    card.custom_minimum_size = Vector2(445.0, 126.0)
    card.mouse_filter = Control.MOUSE_FILTER_PASS
    var h := HBoxContainer.new()
    h.add_theme_constant_override("separation", 10)
    h.mouse_filter = Control.MOUSE_FILTER_PASS
    card.add_child(h)
    var ic := MiniIcon.new()
    ic.kind = icon_kind
    ic.sub = icon_sub
    ic.custom_minimum_size = Vector2(96.0, 96.0)
    h.add_child(ic)
    var mid := VBoxContainer.new()
    mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    mid.mouse_filter = Control.MOUSE_FILTER_PASS
    h.add_child(mid)
    var t := Label.new()
    t.text = title
    t.add_theme_font_size_override("font_size", 23)
    t.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
    mid.add_child(t)
    var info := Label.new()
    info.text = "\n".join(PackedStringArray(lines))
    info.add_theme_font_size_override("font_size", 19)
    info.add_theme_color_override("font_color", Color(0.65, 0.78, 1.0))
    mid.add_child(info)
    var side := VBoxContainer.new()
    side.add_theme_constant_override("separation", 6)
    h.add_child(side)
    var b1 := _make_button("", Color(0.1, 0.32, 0.95), cb1)
    b1.custom_minimum_size = Vector2(160.0, 52.0)
    b1.add_theme_font_size_override("font_size", 21)
    side.add_child(b1)
    var b5: Button = null
    if not cb5.is_null():
        b5 = _make_button("", Color(0.1, 0.32, 0.95), cb5)
        b5.custom_minimum_size = Vector2(160.0, 52.0)
        b5.add_theme_font_size_override("font_size", 21)
        side.add_child(b5)
    return {"card": card, "title": t, "info": info, "b1": b1, "b5": b5}


func _build_worker_window() -> void:
    work_tab_btns = []
    var w := _make_window(["HIRE", "UPGRADE"], _work_tab, work_tab_btns)
    work_panel = w["panel"]
    var v: VBoxContainer = w["vbox"]
    var gh := _make_grid(v)
    work_body_hire = gh.get_parent()
    cards_worker = []
    var specs := [
        [2, "Builder", "Auto-builds and upgrades houses", "builder"],
        [3, "Build Repairman", "Fixes wrecked houses (no gold while broken)", "brep"],
        [4, "AntiAir Repairman", "Repairs wrecked air defense", "arep"],
    ]
    for sp in specs:
        var kind: String = sp[3]
        var c := _make_card(int(sp[0]), 0, str(sp[1]), [str(sp[2]), ""], _ui_hire.bind(kind), Callable())
        gh.add_child(c["card"])
        cards_worker.append(c)
    var gu := _make_grid(v)
    work_body_up = gu.get_parent()
    up_card = _make_card(5, 0, "Builder Lv.1", ["", ""], _ui_upgrade_builder, Callable())
    gu.add_child(up_card["card"])
    work_body_up.hide()


func _update_mult_style() -> void:
    for k in range(sat_mult_btns.size()):
        var b: Button = sat_mult_btns[k]
        var on := (k == 0 and sat_mult == 1) or (k == 1 and sat_mult == 5)
        _style_button(b, Color(1.0, 0.85, 0.05) if on else Color(0.05, 0.05, 0.06))
        var fc := Color(0.05, 0.05, 0.05) if on else Color(1.0, 1.0, 1.0)
        b.add_theme_color_override("font_color", fc)
        b.add_theme_color_override("font_hover_color", fc)
        b.add_theme_color_override("font_pressed_color", fc)


func _sat_set_type(t: int) -> void:
    sat_type = t
    _update_sat_marker()
    _refresh_sat()


func _sat_set_mult(m: int) -> void:
    sat_mult = m
    _update_mult_style()


func _close_windows() -> void:
    if mil_panel != null:
        mil_panel.hide()
    if work_panel != null:
        work_panel.hide()


func _toggle_mil() -> void:
    if game_state != "playing" or sat_open:
        return
    var show_it := not mil_panel.visible
    _close_windows()
    mil_panel.visible = show_it
    _refresh_ui()


func _toggle_work() -> void:
    if game_state != "playing" or sat_open:
        return
    var show_it := not work_panel.visible
    _close_windows()
    work_panel.visible = show_it
    _refresh_ui()


func _work_tab(k: int) -> void:
    work_tab = k
    work_body_hire.visible = k == 0
    work_body_up.visible = k == 1
    _tab_style(work_tab_btns, k)


func _ui_buy_missile(t: int, n: int) -> void:
    var nm: String = MISSILES[t]["name"]
    _ui_result(_do_buy_missile(0, t, n), nm, "Bought %s (x%d). It stands on your island and sits in your bottom boxes." % [nm, n])


func _ui_buy_def(t: int) -> void:
    var nm: String = DEFENSES[t]["name"]
    _ui_result(_do_buy_defense(0, t), nm, "%s installed on your island." % nm)


func _ui_upgrade_builder() -> void:
    _ui_result(_do_upgrade_builder(0), "the builder upgrade", "Builders upgraded! All houses will be upgraded to the new level.")


# =====================================================================
# UI refresh
# =====================================================================


class MiniIcon extends Control:
    var kind := 0
    var sub := 0

    func _init() -> void:
        mouse_filter = Control.MOUSE_FILTER_IGNORE

    func _draw() -> void:
        var w := size.x
        var h := size.y
        draw_rect(Rect2(0.0, 0.0, w, h), Color(0.06, 0.07, 0.09))
        if kind == 0:
            _draw_missile(w, h)
        elif kind == 1:
            _draw_defense(w, h)
        elif kind == 5:
            _draw_house(w, h)
        elif kind == 6:
            _draw_bag(w, h)
        elif kind == 7:
            _draw_jet(w, h)
        else:
            _draw_worker(w, h)

    func _draw_missile(w: float, h: float) -> void:
        var cx := w * 0.5
        var white := Color(0.92, 0.93, 0.97)
        var red := Color(0.95, 0.35, 0.15)
        if sub == 4:
            draw_colored_polygon(PackedVector2Array([Vector2(cx, h * 0.12), Vector2(w * 0.9, h * 0.8), Vector2(cx, h * 0.66), Vector2(w * 0.1, h * 0.8)]), Color(0.75, 0.77, 0.8))
            draw_rect(Rect2(cx - w * 0.04, h * 0.2, w * 0.08, h * 0.5), red)
            return
        if sub == 5:
            for k in range(3):
                var x0 := w * (0.28 + 0.22 * float(k))
                draw_rect(Rect2(x0 - w * 0.05, h * 0.3, w * 0.1, h * 0.5), Color(0.62, 0.64, 0.62))
                draw_colored_polygon(PackedVector2Array([Vector2(x0, h * 0.14), Vector2(x0 + w * 0.05, h * 0.3), Vector2(x0 - w * 0.05, h * 0.3)]), Color(0.85, 0.42, 0.18))
            return
        var bw := w * 0.1
        var col := white
        var tip := red
        if sub == 1:
            bw = w * 0.14
            col = Color(0.62, 0.66, 0.7)
        elif sub == 2:
            bw = w * 0.09
            col = Color(0.25, 0.28, 0.33)
            tip = Color(0.2, 0.9, 1.0)
        elif sub == 3:
            bw = w * 0.17
            col = Color(0.4, 0.43, 0.48)
            tip = Color(1.0, 0.85, 0.2)
        elif sub == 6:
            bw = w * 0.09
            col = Color(0.3, 0.32, 0.36)
            tip = Color(0.85, 0.15, 0.15)
        elif sub == 7:
            bw = w * 0.2
            tip = Color(0.9, 0.18, 0.15)
        var top := h * 0.1
        var nose := h * 0.26
        var bot := h * 0.8
        draw_rect(Rect2(cx - bw, nose, bw * 2.0, bot - nose), col)
        draw_colored_polygon(PackedVector2Array([Vector2(cx, top), Vector2(cx + bw, nose), Vector2(cx - bw, nose)]), tip)
        draw_colored_polygon(PackedVector2Array([Vector2(cx - bw, bot - h * 0.22), Vector2(cx - bw - w * 0.16, bot), Vector2(cx - bw, bot)]), tip)
        draw_colored_polygon(PackedVector2Array([Vector2(cx + bw, bot - h * 0.22), Vector2(cx + bw + w * 0.16, bot), Vector2(cx + bw, bot)]), tip)
        draw_colored_polygon(PackedVector2Array([Vector2(cx - bw * 0.6, bot), Vector2(cx + bw * 0.6, bot), Vector2(cx, bot + h * 0.12)]), Color(1.0, 0.7, 0.2))
        if sub == 3:
            for dx in [-0.55, 0.0, 0.55]:
                draw_colored_polygon(PackedVector2Array([Vector2(cx + bw * dx, nose - h * 0.12), Vector2(cx + bw * dx + w * 0.04, nose), Vector2(cx + bw * dx - w * 0.04, nose)]), Color(1.0, 0.85, 0.2))

    func _wheels(w: float, h: float, n: int, x0: float, x1: float) -> void:
        for k in range(n):
            var x := x0 + (x1 - x0) * float(k) / float(maxi(n - 1, 1))
            draw_circle(Vector2(w * x, h * 0.84), w * 0.055, Color(0.08, 0.08, 0.09))
            draw_circle(Vector2(w * x, h * 0.84), w * 0.025, Color(0.5, 0.5, 0.53))

    func _draw_defense(w: float, h: float) -> void:
        var gray := Color(0.5, 0.52, 0.54)
        if sub == 0:
            draw_rect(Rect2(w * 0.2, h * 0.7, w * 0.6, h * 0.16), gray.darkened(0.2))
            draw_rect(Rect2(w * 0.3, h * 0.5, w * 0.34, h * 0.22), gray)
            draw_rect(Rect2(w * 0.38, h * 0.2, w * 0.18, h * 0.3), Color(0.82, 0.84, 0.86))
            draw_circle(Vector2(w * 0.47, h * 0.2), w * 0.09, Color(0.88, 0.89, 0.92))
            draw_rect(Rect2(w * 0.04, h * 0.55, w * 0.3, h * 0.07), Color(0.15, 0.15, 0.17))
            return
        var body := Color(0.3, 0.38, 0.26)
        if sub == 1 or sub == 4:
            body = Color(0.76, 0.66, 0.48)
        draw_rect(Rect2(w * 0.1, h * 0.66, w * 0.8, h * 0.1), body.darkened(0.2))
        draw_rect(Rect2(w * 0.68, h * 0.5, w * 0.2, h * 0.18), body)
        draw_rect(Rect2(w * 0.8, h * 0.54, w * 0.06, h * 0.08), Color(0.12, 0.2, 0.3))
        _wheels(w, h, 3 if sub < 3 else 4, 0.22, 0.78)
        if sub == 1:
            draw_colored_polygon(PackedVector2Array([Vector2(w * 0.4, h * 0.66), Vector2(w * 0.18, h * 0.3), Vector2(w * 0.36, h * 0.2), Vector2(w * 0.58, h * 0.56)]), Color(0.72, 0.5, 0.28))
            draw_line(Vector2(w * 0.1, h * 0.66), Vector2(w * 0.1, h * 0.2), Color(0.8, 0.8, 0.84), 3.0)
            draw_circle(Vector2(w * 0.1, h * 0.2), w * 0.05, Color(0.85, 0.15, 0.15))
        elif sub == 2:
            draw_colored_polygon(PackedVector2Array([Vector2(w * 0.5, h * 0.66), Vector2(w * 0.2, h * 0.24), Vector2(w * 0.32, h * 0.16), Vector2(w * 0.6, h * 0.58)]), Color(0.78, 0.8, 0.77))
        elif sub == 3:
            for k in range(3):
                var x0 := w * (0.22 + 0.1 * float(k))
                draw_rect(Rect2(x0, h * 0.14, w * 0.075, h * 0.52), Color(0.32, 0.42, 0.28))
            draw_rect(Rect2(w * 0.68, h * 0.2, w * 0.06, h * 0.26), Color(0.4, 0.46, 0.34))
        else:
            draw_colored_polygon(PackedVector2Array([Vector2(w * 0.5, h * 0.66), Vector2(w * 0.16, h * 0.28), Vector2(w * 0.32, h * 0.14), Vector2(w * 0.62, h * 0.56)]), Color(0.82, 0.72, 0.54))

    func _draw_jet(w: float, h: float) -> void:
        var cx := w * 0.5
        var col := Color(0.62, 0.68, 0.72)
        var span := 0.38
        var sweep := 0.16
        if sub == 4 or sub == 5:
            col = Color(0.4, 0.43, 0.48)
            span = 0.42
            sweep = 0.2
        elif sub == 2 or sub == 3:
            span = 0.4
            sweep = 0.24
        draw_colored_polygon(PackedVector2Array([Vector2(cx, h * 0.08), Vector2(cx + w * 0.07, h * 0.3), Vector2(cx + w * 0.06, h * 0.82), Vector2(cx - w * 0.06, h * 0.82), Vector2(cx - w * 0.07, h * 0.3)]), col)
        draw_colored_polygon(PackedVector2Array([Vector2(cx + w * 0.06, h * 0.4), Vector2(cx + w * span, h * (0.42 + sweep)), Vector2(cx + w * span, h * (0.5 + sweep)), Vector2(cx + w * 0.06, h * 0.66)]), col.darkened(0.12))
        draw_colored_polygon(PackedVector2Array([Vector2(cx - w * 0.06, h * 0.4), Vector2(cx - w * span, h * (0.42 + sweep)), Vector2(cx - w * span, h * (0.5 + sweep)), Vector2(cx - w * 0.06, h * 0.66)]), col.darkened(0.12))
        draw_colored_polygon(PackedVector2Array([Vector2(cx + w * 0.05, h * 0.72), Vector2(cx + w * 0.2, h * 0.86), Vector2(cx + w * 0.05, h * 0.86)]), col.darkened(0.2))
        draw_colored_polygon(PackedVector2Array([Vector2(cx - w * 0.05, h * 0.72), Vector2(cx - w * 0.2, h * 0.86), Vector2(cx - w * 0.05, h * 0.86)]), col.darkened(0.2))
        draw_rect(Rect2(cx - w * 0.025, h * 0.22, w * 0.05, h * 0.14), Color(0.15, 0.25, 0.4))
        draw_circle(Vector2(cx, h * 0.86), w * 0.035, Color(1.0, 0.6, 0.2))

    func _draw_house(w: float, h: float) -> void:
        draw_rect(Rect2(w * 0.2, h * 0.45, w * 0.6, h * 0.4), Color(0.7, 0.32, 0.28))
        draw_colored_polygon(PackedVector2Array([Vector2(w * 0.12, h * 0.46), Vector2(w * 0.5, h * 0.16), Vector2(w * 0.88, h * 0.46)]), Color(0.35, 0.37, 0.42))
        draw_rect(Rect2(w * 0.3, h * 0.56, w * 0.14, h * 0.14), Color(0.3, 0.95, 1.0))
        draw_rect(Rect2(w * 0.56, h * 0.56, w * 0.14, h * 0.14), Color(0.3, 0.95, 1.0))

    func _draw_bag(w: float, h: float) -> void:
        draw_rect(Rect2(w * 0.24, h * 0.34, w * 0.52, h * 0.5), Color(0.35, 0.4, 0.5))
        draw_rect(Rect2(w * 0.32, h * 0.58, w * 0.36, h * 0.18), Color(0.25, 0.3, 0.4))
        draw_arc(Vector2(w * 0.5, h * 0.32), w * 0.12, PI, TAU, 12, Color(0.9, 0.92, 0.95), 3.0)

    func _draw_worker(w: float, h: float) -> void:
        var cx := w * 0.5
        var shirt := Color(1.0, 0.6, 0.1)
        if kind == 3:
            shirt = Color(0.85, 0.5, 0.15)
        elif kind == 4:
            shirt = Color(0.2, 0.45, 0.95)
        draw_rect(Rect2(cx - w * 0.2, h * 0.5, w * 0.4, h * 0.34), shirt)
        draw_rect(Rect2(cx - w * 0.2, h * 0.84, w * 0.17, h * 0.12), Color(0.2, 0.3, 0.5))
        draw_rect(Rect2(cx + w * 0.03, h * 0.84, w * 0.17, h * 0.12), Color(0.2, 0.3, 0.5))
        draw_circle(Vector2(cx, h * 0.38), w * 0.14, Color(1.0, 0.82, 0.3))
        draw_rect(Rect2(cx - w * 0.17, h * 0.2, w * 0.34, h * 0.12), Color(1.0, 0.5, 0.1) if kind == 2 else Color(0.2, 0.2, 0.25))
        draw_line(Vector2(cx + w * 0.26, h * 0.82), Vector2(cx + w * 0.38, h * 0.48), Color(0.55, 0.42, 0.3), 4.0)
        draw_rect(Rect2(cx + w * 0.3, h * 0.42, w * 0.16, h * 0.09), Color(0.6, 0.6, 0.65))


func _wheel(parent: Node3D, x: float, z: float, r: float) -> void:
    var w := _cyl(parent, r, r, 0.36, Vector3(x, r, z), Color(0.07, 0.07, 0.08))
    w.rotation.x = PI / 2.0
    var hub := _cyl(parent, r * 0.5, r * 0.5, 0.4, Vector3(x, r, z), Color(0.5, 0.5, 0.53))
    hub.rotation.x = PI / 2.0


# truck faces +x. Returns the height of the cargo deck.
func _truck_chassis(parent: Node3D, body: Color, cab: Color, axles: int, length: float) -> float:
    var half := length * 0.5
    _box(parent, Vector3(length, 0.3, 1.3), Vector3(0.0, 0.7, 0.0), body.darkened(0.35))
    var dl := length - 1.8
    _box(parent, Vector3(dl, 0.14, 1.85), Vector3(-half + dl * 0.5, 0.92, 0.0), body)
    var cx := half - 0.85
    _box(parent, Vector3(1.55, 1.1, 1.85), Vector3(cx, 1.3, 0.0), cab)
    _box(parent, Vector3(0.12, 0.5, 1.55), Vector3(half - 0.05, 1.5, 0.0), Color(0.1, 0.18, 0.26))
    _box(parent, Vector3(0.8, 0.4, 0.06), Vector3(cx + 0.05, 1.5, 0.94), Color(0.1, 0.18, 0.26))
    _box(parent, Vector3(0.8, 0.4, 0.06), Vector3(cx + 0.05, 1.5, -0.94), Color(0.1, 0.18, 0.26))
    _box(parent, Vector3(0.3, 0.3, 1.95), Vector3(half + 0.05, 0.6, 0.0), body.darkened(0.45))
    for sz in [-0.7, 0.7]:
        var hl := _box(parent, Vector3(0.08, 0.16, 0.3), Vector3(half, 0.95, float(sz)), Color.WHITE)
        hl.material_override = _glow_mat(Color(1.0, 0.95, 0.7))
    var r := 0.52
    for k in range(axles):
        var ax := half - 1.1 - float(k) * 1.25
        _wheel(parent, ax, 0.9, r)
        _wheel(parent, ax, -0.9, r)
    return 0.99


func _msl_mesh(parent: Node3D, body: Color, tip: Color, ln: float, rad: float, wing: bool) -> Node3D:
    var root := Node3D.new()
    parent.add_child(root)
    _cyl(root, rad, rad, ln * 0.78, Vector3(0.0, ln * 0.39, 0.0), body)
    _cyl(root, 0.0, rad, ln * 0.22, Vector3(0.0, ln * 0.89, 0.0), tip)
    _box(root, Vector3(rad * 4.5, ln * 0.12, 0.05), Vector3(0.0, ln * 0.06, 0.0), tip)
    _box(root, Vector3(0.05, ln * 0.12, rad * 4.5), Vector3(0.0, ln * 0.06, 0.0), tip)
    if wing:
        _box(root, Vector3(0.04, ln * 0.4, rad * 9.0), Vector3(0.0, ln * 0.25, 0.0), body.lightened(0.1))
    return root


# config per missile type: truck colours, axles, length, rack tilt, missile size, layout
func _mtruck_cfg(t: int) -> Dictionary:
    if t == 0:
        return {"body": Color(0.42, 0.47, 0.32), "cab": Color(0.38, 0.43, 0.3), "ax": 3, "len": 5.8, "tilt": 35.0,
            "ln": 2.5, "rad": 0.17, "mb": Color(0.92, 0.93, 0.96), "mt": Color(0.95, 0.4, 0.15), "plate": 0.15,
            "pos": [Vector3(0, 0, -0.66), Vector3(0, 0, -0.22), Vector3(0, 0, 0.22), Vector3(0, 0, 0.66)], "wing": false}
    if t == 1:
        return {"body": Color(0.28, 0.34, 0.26), "cab": Color(0.26, 0.32, 0.24), "ax": 4, "len": 7.2, "tilt": 55.0,
            "ln": 3.6, "rad": 0.27, "mb": Color(0.62, 0.66, 0.68), "mt": Color(0.5, 0.5, 0.54), "plate": 0.2,
            "pos": [Vector3(0, 0, -0.45), Vector3(0, 0, 0.45)], "wing": false}
    if t == 2:
        return {"body": Color(0.2, 0.22, 0.26), "cab": Color(0.18, 0.2, 0.24), "ax": 4, "len": 6.8, "tilt": 42.0,
            "ln": 3.2, "rad": 0.21, "mb": Color(0.15, 0.17, 0.2), "mt": Color(0.2, 0.9, 1.0), "plate": 0.2,
            "pos": [Vector3(0, 0, -0.45), Vector3(0, 0, 0.45)], "wing": false}
    if t == 3:
        return {"body": Color(0.24, 0.29, 0.25), "cab": Color(0.22, 0.27, 0.23), "ax": 4, "len": 8.0, "tilt": 72.0,
            "ln": 5.2, "rad": 0.42, "mb": Color(0.36, 0.38, 0.42), "mt": Color(1.0, 0.85, 0.2), "plate": 0.3,
            "pos": [Vector3(0, 0, 0)], "wing": false}
    if t == 4:
        return {"body": Color(0.55, 0.5, 0.38), "cab": Color(0.5, 0.45, 0.34), "ax": 2, "len": 5.0, "tilt": 22.0,
            "ln": 1.7, "rad": 0.09, "mb": Color(0.88, 0.88, 0.9), "mt": Color(0.95, 0.45, 0.15), "plate": 0.1,
            "pos": [Vector3(0, 0, -0.55), Vector3(0, 0, 0.0), Vector3(0, 0, 0.55),
                Vector3(0, 1.8, -0.55), Vector3(0, 1.8, 0.0), Vector3(0, 1.8, 0.55)], "wing": true}
    if t == 5:
        var ps: Array = []
        for lay in range(2):
            for c in range(4):
                ps.append(Vector3(float(lay) * 0.34, 0.0, -0.57 + float(c) * 0.38))
        return {"body": Color(0.3, 0.4, 0.28), "cab": Color(0.27, 0.36, 0.25), "ax": 3, "len": 6.2, "tilt": 42.0,
            "ln": 2.2, "rad": 0.13, "mb": Color(0.62, 0.64, 0.62), "mt": Color(0.85, 0.42, 0.18), "plate": 0.2,
            "pos": ps, "wing": false}
    if t == 6:
        return {"body": Color(0.22, 0.24, 0.28), "cab": Color(0.2, 0.22, 0.26), "ax": 3, "len": 6.0, "tilt": 30.0,
            "ln": 2.9, "rad": 0.17, "mb": Color(0.28, 0.3, 0.34), "mt": Color(0.85, 0.15, 0.15), "plate": 0.2,
            "pos": [Vector3(0, 0, -0.32), Vector3(0, 0, 0.32), Vector3(0.4, 0, -0.32), Vector3(0.4, 0, 0.32)], "wing": false}
    return {"body": Color(0.3, 0.34, 0.3), "cab": Color(0.28, 0.32, 0.28), "ax": 4, "len": 9.0, "tilt": 80.0,
        "ln": 6.8, "rad": 0.52, "mb": Color(0.94, 0.94, 0.96), "mt": Color(0.9, 0.18, 0.15), "plate": 0.4,
        "pos": [Vector3(0, 0, 0)], "wing": false}


func _missile_truck_model(t: int) -> Node3D:
    if t == 3 or t == 7:
        return _silo_model(t)
    if t == 6:
        return _bunker_model()
    var cfg: Dictionary = _mtruck_cfg(t)
    var root := Node3D.new()
    var len: float = cfg["len"]
    var half := len * 0.5
    var deck := _truck_chassis(root, cfg["body"], cfg["cab"], int(cfg["ax"]), len)
    var tilt: float = cfg["tilt"]
    var ln: float = cfg["ln"]
    var rad: float = cfg["rad"]
    var th := deg_to_rad(tilt)
    var pxx := -half + ln * sin(th) + 0.2
    pxx = minf(pxx, half - 2.2)
    var rack := Node3D.new()
    rack.position = Vector3(pxx, deck + 0.1, 0.0)
    rack.rotation.z = th
    root.add_child(rack)
    var plate: float = cfg["plate"]
    var poss: Array = cfg["pos"]
    var maxz := 0.0
    var maxy := 0.0
    for pv in poss:
        var pp: Vector3 = pv
        maxz = maxf(maxz, absf(pp.z))
        maxy = maxf(maxy, pp.y)
    _box(rack, Vector3(plate, ln + maxy + 0.2, maxz * 2.0 + rad * 2.0 + 0.3), Vector3(-rad - plate * 0.5, (ln + maxy) * 0.5, 0.0), Color(0.16, 0.17, 0.19))
    # support strut
    var strut := _cyl(root, 0.08, 0.08, 1.6, Vector3(pxx + 0.9, deck + 0.7, 0.0), Color(0.2, 0.2, 0.22))
    strut.rotation.z = deg_to_rad(40.0)
    var ms: Array = []
    var tips: Array = []
    for pv2 in poss:
        var pp2: Vector3 = pv2
        var m := _msl_mesh(rack, cfg["mb"], cfg["mt"], ln, rad, bool(cfg["wing"]))
        m.position = Vector3(pp2.x, pp2.y, pp2.z)
        ms.append(m)
        var tip_local := rack.transform * Vector3(pp2.x, pp2.y + ln, pp2.z)
        tips.append(tip_local)
    root.set_meta("ms", ms)
    root.set_meta("tips", tips)
    for mn in ms:
        _merge_model(mn, [])
    _merge_model(root, ms)
    return root


func _defense_model(n: Node3D, t: int, team: Color) -> void:
    if t == 0:
        _model_ciws(n)
    elif t == 1:
        _model_dome(n)
    elif t == 2:
        _model_hq9(n)
    elif t == 3:
        _model_s400(n)
    else:
        _model_thaad(n)
    _sphere(n, 0.18, Vector3(0.0, 0.1, 2.2 if t >= 2 else 1.4), team)
    _merge_model(n, [])


func _model_ciws(n: Node3D) -> void:
    var base := Color(0.5, 0.52, 0.54)
    _box(n, Vector3(2.4, 0.5, 2.4), Vector3(0.0, 0.25, 0.0), base.darkened(0.15))
    _box(n, Vector3(2.0, 0.22, 2.0), Vector3(0.0, 0.6, 0.0), base)
    _cyl(n, 0.85, 0.95, 0.6, Vector3(0.0, 0.95, 0.0), base.lightened(0.05))
    _box(n, Vector3(1.25, 0.9, 1.1), Vector3(0.0, 1.2, 0.0), base.darkened(0.1))
    _box(n, Vector3(0.35, 0.9, 1.0), Vector3(-0.8, 1.25, 0.1), base.darkened(0.25))
    _box(n, Vector3(0.35, 0.9, 1.0), Vector3(0.8, 1.25, 0.1), base.darkened(0.25))
    _cyl(n, 0.55, 0.62, 0.8, Vector3(0.0, 1.95, 0.35), Color(0.8, 0.82, 0.83))
    _sphere(n, 0.55, Vector3(0.0, 2.35, 0.35), Color(0.86, 0.87, 0.89))
    _box(n, Vector3(0.6, 0.6, 1.0), Vector3(0.0, 1.35, -0.85), Color(0.3, 0.32, 0.34))
    for k in range(6):
        var a := float(k) / 6.0 * TAU
        var bar := _cyl(n, 0.07, 0.07, 1.3, Vector3(cos(a) * 0.17, 1.35 + sin(a) * 0.17, -1.75), Color(0.12, 0.12, 0.14))
        bar.rotation.x = PI / 2.0
    var ring := _cyl(n, 0.28, 0.28, 0.12, Vector3(0.0, 1.35, -2.3), Color(0.2, 0.2, 0.22))
    ring.rotation.x = PI / 2.0


func _model_dome(n: Node3D) -> void:
    var tan := Color(0.66, 0.56, 0.4)
    var wood := Color(0.72, 0.52, 0.3)
    _box(n, Vector3(5.2, 0.28, 2.0), Vector3(0.0, 0.8, 0.0), tan.darkened(0.2))
    for ax in [-1.9, -0.8]:
        _wheel(n, float(ax), 1.0, 0.5)
        _wheel(n, float(ax), -1.0, 0.5)
    _box(n, Vector3(1.0, 0.9, 1.9), Vector3(2.2, 1.35, 0.0), tan)
    _box(n, Vector3(0.1, 0.4, 1.6), Vector3(2.72, 1.5, 0.0), Color(0.1, 0.18, 0.26))
    var rack := Node3D.new()
    rack.position = Vector3(0.4, 1.0, 0.0)
    rack.rotation.z = deg_to_rad(52.0)
    n.add_child(rack)
    _box(rack, Vector3(1.0, 2.2, 1.9), Vector3(0.0, 1.1, 0.0), wood)
    _box(rack, Vector3(0.08, 2.0, 1.7), Vector3(0.54, 1.1, 0.0), Color(0.18, 0.15, 0.12))
    for r in range(5):
        for c in range(4):
            _box(rack, Vector3(0.06, 0.26, 0.28), Vector3(0.58, 0.28 + float(r) * 0.4, -0.6 + float(c) * 0.4), Color(0.04, 0.04, 0.05))
    var m1 := _msl_mesh(rack, Color(0.92, 0.93, 0.96), Color(0.9, 0.3, 0.2), 0.6, 0.1, false)
    m1.position = Vector3(0.55, 1.95, 0.4)
    _box(n, Vector3(1.2, 0.9, 1.3), Vector3(-1.6, 1.4, 0.0), tan.darkened(0.1))
    _cyl(n, 0.07, 0.07, 3.6, Vector3(-2.3, 2.3, 0.0), Color(0.75, 0.76, 0.8))
    var disc := _cyl(n, 0.4, 0.4, 0.08, Vector3(-2.3, 4.1, 0.0), Color(0.85, 0.15, 0.15))
    disc.rotation.x = PI / 2.0
    var disc2 := _cyl(n, 0.22, 0.22, 0.1, Vector3(-2.3, 4.1, 0.0), Color.WHITE)
    disc2.rotation.x = PI / 2.0
    for k in range(5):
        _cyl(n, 0.1, 0.1, 0.05, Vector3(-2.3, 0.6 + float(k) * 0.65, 0.0), Color(0.8, 0.8, 0.84))


func _model_thaad(n: Node3D) -> void:
    var tan := Color(0.78, 0.68, 0.5)
    var deck := _truck_chassis(n, tan, tan.darkened(0.05), 4, 7.6)
    var rack := Node3D.new()
    rack.position = Vector3(-1.2, deck + 0.15, 0.0)
    rack.rotation.z = deg_to_rad(52.0)
    n.add_child(rack)
    _box(rack, Vector3(1.0, 4.2, 1.9), Vector3(0.0, 2.1, 0.0), tan.darkened(0.08))
    _box(rack, Vector3(0.1, 4.0, 1.7), Vector3(0.55, 2.1, 0.0), tan.lightened(0.05))
    for k in range(5):
        _box(rack, Vector3(0.06, 4.0, 0.06), Vector3(0.6, 2.1, -0.72 + float(k) * 0.36), tan.darkened(0.35))
    for r in range(4):
        _box(rack, Vector3(0.06, 0.06, 1.7), Vector3(0.6, 0.6 + float(r) * 1.0, 0.0), tan.darkened(0.35))
    _box(rack, Vector3(1.1, 0.2, 2.0), Vector3(0.0, 4.25, 0.0), tan.darkened(0.2))
    var strut := _cyl(n, 0.1, 0.1, 3.0, Vector3(0.2, deck + 1.3, 0.0), Color(0.62, 0.55, 0.42))
    strut.rotation.z = deg_to_rad(-35.0)
    _cyl(n, 0.12, 0.12, 0.9, Vector3(-3.7, 0.5, 0.0), Color(0.3, 0.3, 0.32))
    _box(n, Vector3(0.7, 0.5, 0.5), Vector3(0.6, deck + 0.3, 1.0), tan.darkened(0.15))
    _cyl(n, 0.05, 0.05, 1.4, Vector3(1.2, 2.3, -0.7), Color(0.7, 0.7, 0.72))


func _model_s400(n: Node3D) -> void:
    var green := Color(0.28, 0.36, 0.24)
    var deck := _truck_chassis(n, green, green.darkened(0.05), 4, 8.2)
    var rack := Node3D.new()
    rack.position = Vector3(-2.1, deck + 0.1, 0.0)
    rack.rotation.z = deg_to_rad(76.0)
    n.add_child(rack)
    for c in range(2):
        for r in range(2):
            var can := _cyl(rack, 0.52, 0.52, 5.4, Vector3(float(c) * 1.1, 2.7, -0.58 + float(r) * 1.16), Color(0.3, 0.38, 0.26))
            for b in range(5):
                _cyl(rack, 0.55, 0.55, 0.1, Vector3(float(c) * 1.1, 0.6 + float(b) * 1.0, -0.58 + float(r) * 1.16), Color(0.36, 0.44, 0.3))
            _cyl(rack, 0.5, 0.5, 0.14, Vector3(float(c) * 1.1, 5.42, -0.58 + float(r) * 1.16), Color(0.2, 0.26, 0.18))
            can.rotation.z = 0.0
    _box(rack, Vector3(0.3, 5.2, 1.9), Vector3(-0.5, 2.6, 0.0), Color(0.2, 0.25, 0.2))
    var strut := _cyl(n, 0.1, 0.1, 3.2, Vector3(-0.3, deck + 1.3, 0.0), Color(0.22, 0.28, 0.2))
    strut.rotation.z = deg_to_rad(-30.0)
    # radar truck beside
    var rt := Node3D.new()
    rt.position = Vector3(1.0, 0.0, 5.2)
    n.add_child(rt)
    var rdeck := _truck_chassis(rt, green, green.darkened(0.05), 3, 6.0)
    _box(rt, Vector3(2.4, 0.7, 1.6), Vector3(-0.9, rdeck + 0.4, 0.0), green.darkened(0.12))
    _cyl(rt, 0.12, 0.12, 1.8, Vector3(-0.9, rdeck + 1.5, 0.0), Color(0.3, 0.34, 0.3))
    var panel := _box(rt, Vector3(0.18, 2.0, 2.6), Vector3(-0.9, rdeck + 3.0, 0.0), Color(0.34, 0.4, 0.3))
    panel.rotation.z = deg_to_rad(-12.0)
    _cyl(rt, 0.04, 0.04, 2.2, Vector3(1.4, 2.8, 0.7), Color(0.6, 0.6, 0.64))


func _model_hq9(n: Node3D) -> void:
    var olive := Color(0.36, 0.4, 0.3)
    var deck := _truck_chassis(n, olive, olive.darkened(0.04), 4, 7.6)
    var rack := Node3D.new()
    rack.position = Vector3(-1.4, deck + 0.12, 0.0)
    rack.rotation.z = deg_to_rad(66.0)
    n.add_child(rack)
    for c in range(2):
        for r in range(2):
            _box(rack, Vector3(0.78, 4.4, 0.78), Vector3(float(c) * 0.95, 2.2, -0.5 + float(r) * 1.0), Color(0.76, 0.78, 0.75))
            _box(rack, Vector3(0.82, 0.16, 0.82), Vector3(float(c) * 0.95, 4.45, -0.5 + float(r) * 1.0), Color(0.3, 0.32, 0.3))
            _box(rack, Vector3(0.82, 0.12, 0.82), Vector3(float(c) * 0.95, 1.2, -0.5 + float(r) * 1.0), Color(0.3, 0.32, 0.3))
    _box(rack, Vector3(0.25, 4.4, 2.2), Vector3(-0.5, 2.2, 0.0), Color(0.22, 0.25, 0.22))
    var strut := _cyl(n, 0.1, 0.1, 3.0, Vector3(0.0, deck + 1.2, 0.0), Color(0.24, 0.27, 0.22))
    strut.rotation.z = deg_to_rad(-32.0)
    # phased-array panel on the cab roof
    _cyl(n, 0.08, 0.08, 1.0, Vector3(3.0, 2.3, 0.0), Color(0.3, 0.32, 0.3))
    var pn := _box(n, Vector3(0.14, 1.0, 1.6), Vector3(3.0, 3.2, 0.0), Color(0.5, 0.54, 0.46))
    pn.rotation.z = deg_to_rad(-10.0)
    _box(n, Vector3(0.7, 0.6, 0.6), Vector3(0.2, deck + 0.35, 1.0), olive.darkened(0.15))


# underground silo: strategic missiles (MIRV, ICBM) really sit in silos
func _silo_model(t: int) -> Node3D:
    var cfg: Dictionary = _mtruck_cfg(t)
    var root := Node3D.new()
    var conc := Color(0.55, 0.57, 0.6)
    var dark := Color(0.12, 0.12, 0.14)
    var big := t == 7
    var r := 3.6 if big else 3.0
    var ln: float = cfg["ln"]
    var rad: float = cfg["rad"]
    _box(root, Vector3(r * 2.7, 0.18, r * 2.7), Vector3(0.0, 0.1, 0.0), Color(0.42, 0.44, 0.47))
    _cyl(root, r, r + 0.35, 0.7, Vector3(0.0, 0.45, 0.0), conc)
    _cyl(root, r - 0.5, r - 0.5, 0.74, Vector3(0.0, 0.47, 0.0), dark)
    for k in range(8):
        var a := float(k) * TAU / 8.0
        _box(root, Vector3(0.7, 0.2, 0.7), Vector3(cos(a) * (r + 0.3), 0.85, sin(a) * (r + 0.3)),
            Color(0.95, 0.8, 0.1) if k % 2 == 0 else Color(0.1, 0.1, 0.1))
    # blast door, slid open
    var door := _box(root, Vector3(r * 1.1, 0.35, r * 1.6), Vector3(r + 1.2, 0.9, 0.0), conc.darkened(0.15))
    door.rotation.z = deg_to_rad(-18.0)
    # service gantry
    _box(root, Vector3(0.3, 4.0, 0.3), Vector3(-r - 1.0, 2.0, 1.6), Color(0.8, 0.45, 0.1))
    _box(root, Vector3(0.3, 0.3, 3.2), Vector3(-r - 1.0, 4.0, 0.0), Color(0.8, 0.45, 0.1))
    var lamp := _sphere(root, 0.25, Vector3(-r - 1.0, 4.3, 0.0), Color(1.0, 0.2, 0.2))
    lamp.material_override = _glow_mat(Color(1.0, 0.25, 0.2))
    var ms: Array = []
    var tips: Array = []
    var m := _msl_mesh(root, cfg["mb"], cfg["mt"], ln, rad, false)
    var base_y := -ln * 0.42
    m.position = Vector3(0.0, base_y, 0.0)
    ms.append(m)
    tips.append(Vector3(0.0, base_y + ln, 0.0))
    root.set_meta("ms", ms)
    root.set_meta("tips", tips)
    _merge_model(m, [])
    _merge_model(root, ms)
    return root


# hardened bunker with air-launched stealth cruise missiles on trolleys
func _bunker_model() -> Node3D:
    var cfg: Dictionary = _mtruck_cfg(6)
    var root := Node3D.new()
    var conc := Color(0.5, 0.52, 0.52)
    _box(root, Vector3(9.0, 0.16, 6.6), Vector3(0.0, 0.1, 0.0), Color(0.4, 0.42, 0.44))
    var arch := _cyl(root, 2.5, 2.5, 5.2, Vector3(-1.8, 0.6, 0.0), conc)
    arch.rotation.x = PI / 2.0
    arch.scale = Vector3(1.0, 1.0, 0.8)
    _box(root, Vector3(4.2, 1.2, 5.2), Vector3(-1.8, 0.25, 0.0), conc)
    _box(root, Vector3(0.3, 2.0, 3.2), Vector3(0.45, 1.0, 0.0), Color(0.18, 0.2, 0.24))
    _box(root, Vector3(0.12, 0.5, 3.2), Vector3(0.58, 2.1, 0.0), Color(0.9, 0.75, 0.1))
    for k in range(5):
        _box(root, Vector3(0.9, 0.12, 0.5), Vector3(-3.6 + float(k) * 0.85, 2.6, 2.6), Color(0.3, 0.34, 0.3))
    var ms: Array = []
    var tips: Array = []
    var ln: float = cfg["ln"]
    var rad: float = cfg["rad"]
    for k2 in range(4):
        var tray := Node3D.new()
        tray.position = Vector3(2.4, 0.3 + float(k2 % 2) * 0.55, -1.0 + float(int(k2 / 2)) * 2.0)
        tray.rotation.z = deg_to_rad(-90.0)
        root.add_child(tray)
        var m := _msl_mesh(tray, cfg["mb"], cfg["mt"], ln, rad, true)
        ms.append(m)
        tips.append(tray.transform * Vector3(0.0, ln, 0.0))
        _box(root, Vector3(2.8, 0.1, 0.5), Vector3(3.2, 0.06 + float(k2 % 2) * 0.55, -1.0 + float(int(k2 / 2)) * 2.0), Color(0.2, 0.2, 0.22))
    root.set_meta("ms", ms)
    root.set_meta("tips", tips)
    for mn in ms:
        _merge_model(mn, [])
    _merge_model(root, ms)
    return root


func _house_pos(slot: int) -> Vector2:
    var col := slot % 16
    var row := int(slot / 16)
    return Vector2(-113.0 + float(col) * 7.0, 28.0 + float(row) * 8.0)


func _def_pos(slot: int) -> Vector2:
    var col := slot % 11
    var row := int(slot / 11)
    return Vector2(-108.0 + float(col) * 13.5, -16.0 - float(row) * 9.0)


func _missile_pos(slot: int) -> Vector2:
    var col := slot % 11
    var row := int(slot / 11)
    return Vector2(-108.0 + float(col) * 13.5, -52.0 - float(row) * 10.5)


func _stand_pos(slot: int) -> Vector2:
    var col := slot % 2
    var row := int(slot / 2)
    return Vector2(62.0 + float(col) * 14.0, -96.0 + float(row) * 17.0)


func _make_island(i: int, p: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Island_%d" % i
    root.position = p
    root.rotation.y = _yaw_to(-p)
    var team := _team(i)
    var side := PLOT_HALF * 2.0
    _box(root, Vector3(side + 5.0, 1.4, side + 5.0), Vector3(0.0, -0.35, 0.0), team.darkened(0.25))
    var top := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = Vector3(side, 0.3, side)
    top.mesh = bm
    top.position = Vector3(0.0, 0.45, 0.0)
    top.material_override = _checker_mat(i)
    root.add_child(top)
    # concrete military apron
    _box(root, Vector3(154.0, 0.06, 126.0), Vector3(-39.0, 0.63, -53.0), Color(0.3, 0.32, 0.35))
    var holder := Node3D.new()
    root.add_child(holder)
    _island_props(holder)
    _airport(holder)
    _merge_model(holder, [])
    var lab := Label3D.new()
    lab.text = "YOU" if i == 0 else "ENEMY %d" % i
    lab.font_size = 72
    lab.pixel_size = 0.1
    lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    lab.no_depth_test = true
    lab.render_priority = 3
    lab.outline_size = 16
    lab.modulate = team.lightened(0.3)
    lab.position = Vector3(0.0, 60.0, 0.0)
    root.add_child(lab)
    return root


func _island_props(root: Node3D) -> void:
    var white := Color(0.92, 0.95, 0.95)
    # road between the military apron and the houses
    _box(root, Vector3(156.0, 0.07, 6.0), Vector3(-38.0, 0.66, 17.0), Color(0.15, 0.16, 0.19))
    _box(root, Vector3(156.0, 0.09, 0.25), Vector3(-38.0, 0.68, 14.2), white)
    _box(root, Vector3(156.0, 0.09, 0.25), Vector3(-38.0, 0.68, 19.8), white)
    for k in range(20):
        _box(root, Vector3(3.0, 0.09, 0.3), Vector3(-114.0 + float(k) * 7.8, 0.68, 17.0), Color(0.95, 0.82, 0.2))
    for k2 in range(13):
        var lx := -114.0 + float(k2) * 12.5
        _cyl(root, 0.12, 0.16, 4.2, Vector3(lx, 2.7, 20.7), Color(0.3, 0.3, 0.34))
        var bulb := _sphere(root, 0.4, Vector3(lx, 4.9, 20.7), Color.WHITE)
        bulb.material_override = _glow_mat(Color(1.0, 0.93, 0.65))
    var rng := RandomNumberGenerator.new()
    rng.seed = 12345
    for k3 in range(46):
        var tx := rng.randf_range(-116.0, 40.0)
        var tz := rng.randf_range(84.0, 116.0)
        if k3 >= 28:
            tx = -118.0 + rng.randf_range(0.0, 2.0)
            tz = rng.randf_range(26.0, 80.0)
        var th := rng.randf_range(0.9, 1.4)
        _cyl(root, 0.22 * th, 0.32 * th, 1.8 * th, Vector3(tx, 1.5, tz), Color(0.4, 0.26, 0.14))
        _sphere(root, 1.5 * th, Vector3(tx, 3.4 * th, tz), Color(0.1, 0.42, 0.17))
        _sphere(root, 1.0 * th, Vector3(tx + 0.5, 4.5 * th, tz - 0.3), Color(0.14, 0.5, 0.2))
    # fuel depot at the back
    for k4 in range(4):
        var tx2 := -90.0 + float(k4) * 24.0
        _cyl(root, 2.8, 2.8, 5.0, Vector3(tx2, 3.2, 104.0), Color(0.85, 0.87, 0.9))
        _cyl(root, 2.9, 2.9, 0.5, Vector3(tx2, 5.9, 104.0), Color(0.5, 0.52, 0.56))
    _box(root, Vector3(76.0, 0.5, 0.5), Vector3(-54.0, 2.0, 99.0), Color(0.6, 0.14, 0.14))
    # fence around the military zone
    for fz in [-116.5, 10.5]:
        _box(root, Vector3(154.0, 1.0, 0.15), Vector3(-39.0, 1.1, float(fz)), Color(0.45, 0.47, 0.5))
    _box(root, Vector3(0.15, 1.0, 126.0), Vector3(-116.5, 1.1, -53.0), Color(0.45, 0.47, 0.5))


func _airport(root: Node3D) -> void:
    var asphalt := Color(0.14, 0.15, 0.17)
    var conc := Color(0.5, 0.52, 0.55)
    var white := Color(0.95, 0.95, 0.97)
    # apron and taxiway
    _box(root, Vector3(34.0, 0.07, 104.0), Vector3(69.0, 0.64, -58.0), conc)
    _box(root, Vector3(6.0, 0.08, 216.0), Vector3(TAXI_X, 0.65, -2.0), Color(0.22, 0.23, 0.26))
    _box(root, Vector3(40.0, 0.08, 6.0), Vector3(TAXI_X - 14.0, 0.65, 96.0), Color(0.22, 0.23, 0.26))
    # runway
    _box(root, Vector3(13.0, 0.09, 216.0), Vector3(RW_X, 0.66, 0.0), asphalt)
    for k in range(23):
        _box(root, Vector3(0.5, 0.1, 5.0), Vector3(RW_X, 0.7, -100.0 + float(k) * 9.0), white)
    _box(root, Vector3(0.35, 0.1, 216.0), Vector3(RW_X - 6.0, 0.7, 0.0), white)
    _box(root, Vector3(0.35, 0.1, 216.0), Vector3(RW_X + 6.0, 0.7, 0.0), white)
    for end_z in [RW_Z1, RW_Z0]:
        for k2 in range(6):
            _box(root, Vector3(0.7, 0.1, 5.0), Vector3(RW_X - 4.5 + float(k2) * 1.8, 0.7, float(end_z) + (4.0 if end_z < 0.0 else -4.0)), white)
    # runway edge lights
    for k5 in range(12):
        for sx in [-7.2, 7.2]:
            var lb := _sphere(root, 0.3, Vector3(RW_X + float(sx), 0.9, -100.0 + float(k5) * 18.0), Color.WHITE)
            lb.material_override = _glow_mat(Color(1.0, 0.95, 0.7))
    # parking stand markers
    for sl in range(MAX_JETS):
        var sp := _stand_pos(sl)
        _box(root, Vector3(9.0, 0.09, 0.25), Vector3(sp.x, 0.7, sp.y + 7.0), Color(0.95, 0.8, 0.15))
    # terminal, tower and hangars on the west side of the apron
    _box(root, Vector3(7.0, 3.5, 44.0), Vector3(47.0, 2.2, -16.0), Color(0.82, 0.84, 0.88))
    _box(root, Vector3(7.2, 0.5, 44.5), Vector3(47.0, 4.2, -16.0), Color(0.25, 0.3, 0.4))
    for k3 in range(10):
        var gw := _box(root, Vector3(0.1, 1.0, 2.6), Vector3(50.6, 2.4, -34.0 + float(k3) * 4.4), Color.WHITE)
        gw.material_override = _glow_mat(Color(0.5, 0.85, 1.0))
    _cyl(root, 1.1, 1.4, 11.0, Vector3(47.0, 6.2, 12.0), Color(0.85, 0.86, 0.9))
    _cyl(root, 2.4, 1.5, 2.2, Vector3(47.0, 12.9, 12.0), Color(0.3, 0.55, 0.7))
    _cyl(root, 2.6, 2.6, 0.3, Vector3(47.0, 14.2, 12.0), Color(0.3, 0.32, 0.36))
    for hz in [-100.0, -82.0]:
        _box(root, Vector3(10.0, 5.0, 14.0), Vector3(47.0, 3.2, float(hz)), Color(0.6, 0.64, 0.7))
        var arch := _cyl(root, 7.0, 7.0, 10.0, Vector3(47.0, 5.7, float(hz)), Color(0.55, 0.6, 0.66))
        arch.rotation.z = PI / 2.0
        arch.scale = Vector3(0.45, 1.0, 1.0)
        _box(root, Vector3(0.2, 4.0, 10.0), Vector3(52.1, 2.8, float(hz)), Color(0.2, 0.22, 0.26))
    # windsock
    _cyl(root, 0.1, 0.1, 5.0, Vector3(112.0, 3.1, 60.0), Color(0.8, 0.8, 0.85))
    _box(root, Vector3(1.8, 0.5, 0.5), Vector3(112.0, 5.4, 60.8), Color(1.0, 0.45, 0.1))


func _unlock_need(kind: String, t: int) -> int:
    if kind == "m":
        return int(MISSILES[t]["unlock"])
    if kind == "d":
        return int(DEFENSES[t]["unlock"])
    return int(JETS[t]["unlock"])


# unlocks depend on the most money this empire has ever held
func _unlocked(i: int, kind: String, t: int) -> bool:
    var e: Dictionary = emp[i]
    var pk: int = maxi(int(e.get("peak", 0)), int(e["money"]))
    e["peak"] = pk
    return pk >= _unlock_need(kind, t)


func _unlock_text(kind: String, t: int) -> String:
    return "$%s" % _fmt_money(_unlock_need(kind, t))


func _spot_free(i: int, x: float, z: float, ignore_id: int) -> bool:
    if not MIL_RECT.has_point(Vector2(x, z)):
        return false
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) != "defense" or int(s["id"]) == ignore_id:
            continue
        if absf(float(s["lx"]) - x) < 10.5 and absf(float(s["lz"]) - z) < 4.6:
            return false
    var trucks: Array = e["mnodes"]
    for tv in trucks:
        var tr: Dictionary = tv
        if int(tr["id"]) == ignore_id:
            continue
        if absf(float(tr["lx"]) - x) < 10.5 and absf(float(tr["lz"]) - z) < 4.6:
            return false
    return true


func _pick_spot(i: int, kind: String) -> Vector2:
    var n := 33 if kind == "d" else 66
    for slot in range(n):
        var p := _def_pos(slot) if kind == "d" else _missile_pos(slot)
        if _spot_free(i, p.x, p.y, -1):
            return p
    for k in range(80):
        var rp := Vector2(randf_range(-113.0, 35.0), randf_range(-113.0, 8.0))
        if _spot_free(i, rp.x, rp.y, -1):
            return rp
    return Vector2(randf_range(-100.0, 0.0), randf_range(-110.0, -20.0))


func _spawn_mtruck(i: int, t: int, pos: Vector2, n: int, anim: bool) -> Dictionary:
    uid_counter += 1
    var node := _missile_truck_model(t)
    node.position = Vector3(pos.x, 0.6, pos.y)
    var bsz := 1.15
    _isl(i).add_child(node)
    if anim:
        node.scale = Vector3.ONE * bsz * 0.2
        var tw := node.create_tween()
        tw.tween_property(node, "scale", Vector3.ONE * bsz, 0.7)
    else:
        node.scale = Vector3.ONE * bsz
    var tr := {"id": uid_counter, "t": t, "n": n, "cap": int(MISSILES[t]["cap"]), "node": node, "lx": pos.x, "lz": pos.y}
    var e: Dictionary = emp[i]
    var trucks: Array = e["mnodes"]
    trucks.append(tr)
    _truck_apply(tr)
    return tr


func _truck_apply(tr: Dictionary) -> void:
    var node: Node3D = tr["node"]
    var ms: Array = node.get_meta("ms")
    var n: int = tr["n"]
    for k in range(ms.size()):
        var m: Node3D = ms[k]
        m.visible = k < n


func _remove_truck(i: int, tr: Dictionary) -> void:
    var nn = tr["node"]
    if nn != null and is_instance_valid(nn):
        var n3: Node3D = nn
        n3.queue_free()
    var e: Dictionary = emp[i]
    var trucks: Array = e["mnodes"]
    trucks.erase(tr)


func _sync_missiles(i: int) -> void:
    var e: Dictionary = emp[i]
    var ammo: Array = e["ammo"]
    var trucks: Array = e["mnodes"]
    for t in range(NM):
        var want: int = int(ammo[t])
        var have := 0
        for tv in trucks:
            var tr0: Dictionary = tv
            if int(tr0["t"]) == t:
                have += int(tr0["n"])
        while have > want:
            var last: Dictionary = {}
            for tv2 in trucks:
                var tr1: Dictionary = tv2
                if int(tr1["t"]) == t:
                    last = tr1
            if last.is_empty():
                break
            var drop := mini(int(last["n"]), have - want)
            last["n"] = int(last["n"]) - drop
            have -= drop
            if int(last["n"]) <= 0:
                _remove_truck(i, last)
            else:
                _truck_apply(last)
        while have < want:
            var room: Dictionary = {}
            for tv3 in trucks:
                var tr2: Dictionary = tv3
                if int(tr2["t"]) == t and int(tr2["n"]) < int(tr2["cap"]):
                    room = tr2
                    break
            if room.is_empty():
                var add := mini(int(MISSILES[t]["cap"]), want - have)
                _spawn_mtruck(i, t, _pick_spot(i, "m"), add, true)
                have += add
            else:
                var add2 := mini(int(room["cap"]) - int(room["n"]), want - have)
                room["n"] = int(room["n"]) + add2
                have += add2
                _truck_apply(room)


func _take_missile_pos(i: int, t: int) -> Vector3:
    var e: Dictionary = emp[i]
    var trucks: Array = e["mnodes"]
    for k in range(trucks.size() - 1, -1, -1):
        var tr: Dictionary = trucks[k]
        if int(tr["t"]) != t or int(tr["n"]) < 1:
            continue
        var node: Node3D = tr["node"]
        var tips: Array = node.get_meta("tips")
        var n: int = int(tr["n"]) - 1
        var tip: Vector3 = tips[n]
        var wp := node.to_global(tip)
        tr["n"] = n
        if n <= 0:
            _remove_truck(i, tr)
        else:
            _truck_apply(tr)
        return wp
    return _isl(i).to_global(Vector3(-40.0, 6.0, -60.0))


func _find_struct(i: int, sid: int) -> Dictionary:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    for sv in structs:
        var s: Dictionary = sv
        if int(s["id"]) == sid:
            return s
    return {}


func _find_truck(i: int, tid: int) -> Dictionary:
    var e: Dictionary = emp[i]
    var trucks: Array = e["mnodes"]
    for tv in trucks:
        var tr: Dictionary = tv
        if int(tr["id"]) == tid:
            return tr
    return {}


func _remove_struct(i: int, s: Dictionary) -> void:
    _cancel_jobs_for(i, s)
    for key in ["node", "rub", "ring", "lbl"]:
        var nn = s[key]
        if nn != null and is_instance_valid(nn):
            var n3: Node3D = nn
            n3.queue_free()
        s[key] = null
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    structs.erase(s)


# codes: 0 ok, 5 not found, 6 spot blocked
func _do_sell_defense(i: int, sid: int) -> int:
    var s := _find_struct(i, sid)
    if s.is_empty() or str(s["kind"]) != "defense":
        return 5
    var refund := 0
    if str(s["state"]) == "ok":
        refund = int(float(DEFENSES[int(s["sub"])]["price"]) * 0.5)
    _remove_struct(i, s)
    var e: Dictionary = emp[i]
    e["money"] = int(e["money"]) + refund
    return 0


func _do_sell_truck(i: int, tid: int) -> int:
    var tr := _find_truck(i, tid)
    if tr.is_empty():
        return 5
    var t: int = tr["t"]
    var n: int = tr["n"]
    var e: Dictionary = emp[i]
    var ammo: Array = e["ammo"]
    ammo[t] = maxi(0, int(ammo[t]) - n)
    e["money"] = int(e["money"]) + int(float(MISSILES[t]["price"]) * 0.5 * float(n))
    _remove_truck(i, tr)
    return 0


func _do_move_defense(i: int, sid: int, x: float, z: float) -> int:
    var s := _find_struct(i, sid)
    if s.is_empty():
        return 5
    if not _spot_free(i, x, z, sid):
        return 6
    s["lx"] = x
    s["lz"] = z
    var nn = s["node"]
    if nn != null and is_instance_valid(nn):
        var n3: Node3D = nn
        n3.position = Vector3(x, 0.6, z)
    var rn = s["rub"]
    if rn != null and is_instance_valid(rn):
        var r3: Node3D = rn
        r3.position = Vector3(x, 0.6, z)
    var rg = s["ring"]
    if rg != null and is_instance_valid(rg):
        var g3: Node3D = rg
        g3.position = Vector3(x, 0.7, z)
    var lb = s["lbl"]
    if lb != null and is_instance_valid(lb):
        var l3: Node3D = lb
        l3.position = Vector3(x, 13.0, z)
    return 0


func _do_move_truck(i: int, tid: int, x: float, z: float) -> int:
    var tr := _find_truck(i, tid)
    if tr.is_empty():
        return 5
    if not _spot_free(i, x, z, tid):
        return 6
    tr["lx"] = x
    tr["lz"] = z
    var node: Node3D = tr["node"]
    node.position = Vector3(x, 0.6, z)
    return 0


func _do_buy_missile(i: int, t: int, n: int = 1) -> int:
    var e: Dictionary = emp[i]
    if not _unlocked(i, "m", t):
        return 4
    var room := MAX_MISSILES - _ammo_total(i)
    if room < 1:
        return 2
    var cnt := mini(n, room)
    var price: int = int(MISSILES[t]["price"]) * cnt
    if int(e["money"]) < price:
        return 1
    e["money"] = int(e["money"]) - price
    var ammo: Array = e["ammo"]
    ammo[t] = int(ammo[t]) + cnt
    _sync_missiles(i)
    return 0


func _do_buy_defense(i: int, t: int) -> int:
    var e: Dictionary = emp[i]
    if not _unlocked(i, "d", t):
        return 4
    if _count_structs(i, "defense", -1, false) >= MAX_DEFENSES:
        return 2
    var price: int = DEFENSES[t]["price"]
    if int(e["money"]) < price:
        return 1
    e["money"] = int(e["money"]) - price
    var dp := _pick_spot(i, "d")
    var s := _add_struct(i, "defense", t, dp.x, dp.y, "ok", 0)
    _spawn_struct_node(i, s, 1.2)
    _refresh_struct_label(i, s)
    if i == 0:
        _play_ui("hammer", -2.0)
    return 0


func _jet_model(jt: int, team: Color) -> Node3D:
    var root := Node3D.new()
    var mdl := Node3D.new()
    root.add_child(mdl)
    root.set_meta("mdl", mdl)
    var cols := [Color(0.5, 0.58, 0.6), Color(0.5, 0.52, 0.56), Color(0.58, 0.62, 0.68), Color(0.6, 0.62, 0.66),
        Color(0.28, 0.3, 0.34), Color(0.42, 0.44, 0.48)]
    var lens := [4.0, 4.0, 4.2, 4.2, 4.8, 4.4]
    var spans := [2.8, 2.7, 3.0, 2.9, 3.3, 3.3]
    var sweeps := [0.45, 0.55, 0.8, 0.8, 0.7, 0.62]
    var chords := [1.3, 1.25, 1.9, 1.9, 1.9, 1.8]
    var col: Color = cols[jt]
    var ln: float = lens[jt]
    var span: float = spans[jt]
    var sweep: float = sweeps[jt]
    var chord: float = chords[jt]
    var fr := 0.32 if jt < 4 else 0.4
    var fus := _cyl(mdl, fr, fr * 0.8, ln * 0.72, Vector3(0.0, 0.0, ln * 0.12), col)
    fus.rotation.x = PI / 2.0
    var nose := _cyl(mdl, 0.0, fr, ln * 0.3, Vector3(0.0, 0.0, -ln * 0.4), col.lightened(0.05))
    nose.rotation.x = -PI / 2.0
    var can := _sphere(mdl, 0.3, Vector3(0.0, fr * 0.8, -ln * 0.18), Color(0.12, 0.2, 0.32))
    can.scale = Vector3(0.75, 0.7, 2.0)
    for sd in [-1.0, 1.0]:
        var wing := _box(mdl, Vector3(span * 0.52, 0.07, chord), Vector3(float(sd) * span * 0.26, -0.04, ln * 0.18), col.darkened(0.08))
        wing.rotation.y = float(sd) * -sweep * -1.0
        var tipm := _box(mdl, Vector3(0.1, 0.1, 0.55), Vector3(float(sd) * span * 0.47, -0.04, ln * 0.3), team)
        tipm.material_override = _glow_mat(team)
        var hs := _box(mdl, Vector3(span * 0.26, 0.05, 0.6), Vector3(float(sd) * 0.6, 0.0, ln * 0.42), col.darkened(0.12))
        hs.rotation.y = float(sd) * 0.5
    if jt == 2 or jt == 3:
        for sd2 in [-1.0, 1.0]:
            var cn := _box(mdl, Vector3(span * 0.2, 0.05, 0.5), Vector3(float(sd2) * 0.45, 0.1, -ln * 0.16), col)
            cn.rotation.y = float(sd2) * 0.4
    if jt < 4:
        var fin := _box(mdl, Vector3(0.07, 0.95, 0.95), Vector3(0.0, 0.62, ln * 0.37), col.darkened(0.05))
        fin.rotation.x = 0.35
    else:
        for sd3 in [-1.0, 1.0]:
            var fin2 := _box(mdl, Vector3(0.07, 0.85, 0.9), Vector3(float(sd3) * 0.42, 0.5, ln * 0.37), col.darkened(0.05))
            fin2.rotation.z = float(sd3) * -0.38
            fin2.rotation.x = 0.3
    if jt == 0 or jt == 1 or jt == 2:
        _box(mdl, Vector3(0.55, 0.32, 0.8), Vector3(0.0, -0.34, -ln * 0.1), col.darkened(0.2))
    else:
        for sd4 in [-1.0, 1.0]:
            _box(mdl, Vector3(0.3, 0.35, 0.8), Vector3(float(sd4) * 0.4, 0.02, -ln * 0.1), col.darkened(0.2))
    var nz := 2 if jt == 4 else 1
    for k in range(nz):
        var xo := 0.0 if nz == 1 else (float(k) - 0.5) * 0.5
        var ex := _cyl(mdl, 0.2, 0.26, 0.3, Vector3(xo, 0.0, ln * 0.5), Color(0.1, 0.1, 0.12))
        ex.rotation.x = PI / 2.0
        var fl := _sphere(mdl, 0.14, Vector3(xo, 0.0, ln * 0.56), Color(1.0, 0.6, 0.2))
        fl.material_override = _glow_mat(Color(1.0, 0.6, 0.25))
    _merge_model(mdl, [])
    return root


func _stand_world(i: int, slot: int) -> Vector3:
    var sp := _stand_pos(slot)
    return _isl(i).to_global(Vector3(sp.x, 1.0, sp.y))


func _jets_ready(i: int, jt: int) -> int:
    var e: Dictionary = emp[i]
    var jets: Array = e["jets"]
    var n := 0
    for jv in jets:
        var j: Dictionary = jv
        if int(j["t"]) == jt and str(j["state"]) == "parked":
            n += 1
    return n


func _jets_owned(i: int, jt: int) -> int:
    var e: Dictionary = emp[i]
    var jets: Array = e["jets"]
    var n := 0
    for jv in jets:
        var j: Dictionary = jv
        if jt < 0 or int(j["t"]) == jt:
            n += 1
    return n


func _free_stand(i: int) -> int:
    var e: Dictionary = emp[i]
    var jets: Array = e["jets"]
    var used := {}
    for jv in jets:
        var j: Dictionary = jv
        used[int(j["slot"])] = true
    for slot in range(MAX_JETS):
        if not used.has(slot):
            return slot
    return -1


func _park_node(i: int, j: Dictionary) -> void:
    var nn = j["node"]
    if nn == null or not is_instance_valid(nn):
        var node := _jet_model(int(j["t"]), _team(i))
        node.scale = Vector3.ONE * 2.4
        level_root.add_child(node)
        j["node"] = node
        nn = node
    var n3: Node3D = nn
    n3.position = _stand_world(i, int(j["slot"]))
    n3.rotation = Vector3(0.0, _isl(i).rotation.y, 0.0)
    var mdl: Node3D = n3.get_meta("mdl")
    mdl.rotation = Vector3.ZERO


func _sync_jets(i: int) -> void:
    var e: Dictionary = emp[i]
    var jets: Array = e["jets"]
    for jv in jets:
        var j: Dictionary = jv
        var st: String = j["state"]
        if st == "away":
            continue
        var nn = j["node"]
        if nn == null or not is_instance_valid(nn):
            _park_node(i, j)


func _do_buy_jet(i: int, jt: int) -> int:
    var e: Dictionary = emp[i]
    if not _unlocked(i, "j", jt):
        return 4
    if _jets_owned(i, -1) >= MAX_JETS:
        return 2
    var price: int = JETS[jt]["price"]
    if int(e["money"]) < price:
        return 1
    var slot := _free_stand(i)
    if slot < 0:
        return 2
    e["money"] = int(e["money"]) - price
    var jets: Array = e["jets"]
    var j := {"t": jt, "state": "parked", "slot": slot, "node": null, "timer": 0.0}
    jets.append(j)
    _park_node(i, j)
    if i == 0:
        _play_ui("hammer", -2.0)
    return 0


func _clear_jets(i: int) -> void:
    var e: Dictionary = emp[i]
    var jets: Array = e["jets"]
    for jv in jets:
        var j: Dictionary = jv
        var nn = j["node"]
        if nn != null and is_instance_valid(nn) and str(j["state"]) != "away":
            var n3: Node3D = nn
            n3.queue_free()
        j["node"] = null
    jets.clear()


func _process_jets(delta: float) -> void:
    for i in range(island_count):
        var e: Dictionary = emp[i]
        var jets: Array = e["jets"]
        for jv in jets:
            var j: Dictionary = jv
            if str(j["state"]) == "rearm":
                j["timer"] = float(j["timer"]) - delta
                if float(j["timer"]) <= 0.0:
                    j["state"] = "parked"


# queue a sortie (fee is paid now). Returns false when it cannot start.
# route: {"mode": 0 straight / 1 from behind / 2 flank / 3 custom, "wps": [Vector2 ...]}
func _queue_sortie(a: int, tg: int, j: Dictionary, aim: Vector2, delay: float, route: Dictionary = {}, payload: int = 0) -> bool:
    var e: Dictionary = emp[a]
    var jt: int = j["t"]
    var fee: int = JETS[jt]["fee"]
    if str(j["state"]) != "parked" or int(e["money"]) < fee:
        return false
    e["money"] = int(e["money"]) - fee
    j["state"] = "queued"
    launch_queue.append({"a": a, "tg": tg, "t": NM + jt, "aim": aim, "delay": delay, "jet": j, "route": route, "payload": payload})
    return true


func _flat_dir(from_p: Vector3, to_p: Vector3) -> Vector3:
    var d := Vector3(to_p.x - from_p.x, 0.0, to_p.z - from_p.z)
    if d.length() < 0.5:
        return Vector3(0.0, 0.0, -1.0)
    return d.normalized()


func _sortie_curve_points(a: int, tg: int, j: Dictionary, aim: Vector2, route: Dictionary) -> Dictionary:
    var isl := _isl(a)
    var tisl := _isl(tg)
    var sp := _stand_pos(int(j["slot"]))
    var home: Vector3 = island_pos[a]
    var cr := 40.0
    var aimw := tisl.to_global(Vector3(aim.x, 1.4, aim.y))
    var mode := int(route.get("mode", 0))
    var pts: Array = []
    pts.append(isl.to_global(Vector3(sp.x, 1.0, sp.y)))
    pts.append(isl.to_global(Vector3(sp.x, 1.0, sp.y + 8.0)))
    pts.append(isl.to_global(Vector3(TAXI_X, 1.0, sp.y + 12.0)))
    pts.append(isl.to_global(Vector3(TAXI_X, 1.0, RW_Z0 - 14.0)))
    pts.append(isl.to_global(Vector3(TAXI_X + 8.0, 1.0, RW_Z0 - 3.0)))
    var rw0 := isl.to_global(Vector3(RW_X - 1.0, 1.0, RW_Z0 - 4.0))
    pts.append(rw0)
    pts.append(isl.to_global(Vector3(RW_X, 1.0, RW_Z0 - 18.0)))
    pts.append(isl.to_global(Vector3(RW_X, 1.2, 40.0)))
    pts.append(isl.to_global(Vector3(RW_X, 1.7, -40.0)))
    pts.append(isl.to_global(Vector3(RW_X, 8.0, -92.0)))
    var p8 := isl.to_global(Vector3(RW_X, 26.0, RW_Z1 - 90.0))
    pts.append(p8)
    var fwd: Vector3 = isl.global_transform.basis * Vector3(0.0, 0.0, -1.0)
    fwd.y = 0.0
    fwd = fwd.normalized()
    var rgt := Vector3(-fwd.z, 0.0, fwd.x) * -1.0
    var d := _flat_dir(p8, aimw)
    var perp := Vector3(-d.z, 0.0, d.x)
    var hv := Vector3(home.x - aimw.x, 0.0, home.z - aimw.z)
    if hv.dot(perp) < 0.0:
        perp = -perp
    # a wide climbing turn when the target is not straight ahead
    var first := aimw
    if mode == 3 and route.has("wps"):
        var wl0: Array = route["wps"]
        if wl0.size() > 1:
            var w0: Vector2 = wl0[0]
            first = tisl.to_global(Vector3(w0.x, cr, w0.y))
    var td0 := _flat_dir(p8, first)
    if td0.dot(fwd) < 0.45:
        var sd := 1.0 if td0.dot(rgt) >= 0.0 else -1.0
        pts.append(p8 + fwd * 70.0 + rgt * sd * 110.0 + Vector3(0.0, 8.0, 0.0))
        pts.append(p8 + fwd * 10.0 + rgt * sd * 230.0 + Vector3(0.0, 12.0, 0.0))
    var ad := d
    var pay := aimw
    var rel := aimw
    var over := aimw
    var oy := Vector3(0.0, cr - aimw.y, 0.0)
    if mode == 0:
        pts.append(aimw - d * 230.0 + oy)
        pay = aimw - d * 130.0 + oy
        rel = aimw - d * 55.0 + oy
        pts.append(pay)
        pts.append(rel)
        over = aimw + d * 30.0 + oy
        pts.append(over)
        pts.append(aimw + d * 90.0 + perp * 35.0 + oy)
        pts.append(aimw + d * 50.0 + perp * 120.0 + oy)
        pts.append(aimw - d * 60.0 + perp * 160.0 + oy)
    elif mode == 1:
        ad = -d
        pts.append(aimw - d * 150.0 + perp * 200.0 + oy)
        pts.append(aimw + d * 100.0 + perp * 225.0 + oy)
        pts.append(aimw + d * 240.0 + perp * 130.0 + oy)
        pts.append(aimw + d * 270.0 + perp * 35.0 + oy)
        pay = aimw + d * 130.0 + oy
        rel = aimw + d * 55.0 + oy
        pts.append(aimw + d * 200.0 + oy)
        pts.append(pay)
        pts.append(rel)
        over = aimw - d * 30.0 + oy
        pts.append(over)
        pts.append(aimw - d * 110.0 + perp * 25.0 + oy)
    elif mode == 2:
        ad = -perp
        pts.append(aimw - d * 160.0 + perp * 200.0 + oy)
        pts.append(aimw - d * 70.0 + perp * 235.0 + oy)
        pts.append(aimw + d * 10.0 + perp * 200.0 + oy)
        pay = aimw + perp * 130.0 + oy
        rel = aimw + perp * 55.0 + oy
        pts.append(pay)
        pts.append(rel)
        over = aimw - perp * 35.0 + oy
        pts.append(over)
        pts.append(aimw - perp * 100.0 - d * 50.0 + oy)
        pts.append(aimw - perp * 150.0 - d * 140.0 + oy)
    else:
        var wl: Array = route.get("wps", [])
        var prev := p8
        for wi in range(wl.size() - 1):
            var wv: Vector2 = wl[wi]
            var wp := tisl.to_global(Vector3(wv.x, cr, wv.y))
            pts.append(wp)
            prev = wp
        ad = _flat_dir(prev, aimw)
        var dist := Vector2(aimw.x - prev.x, aimw.z - prev.z).length()
        pay = aimw - ad * minf(130.0, dist * 0.8) + oy
        rel = aimw - ad * minf(55.0, dist * 0.4) + oy
        if dist > 60.0:
            pts.append(pay)
        pts.append(rel)
        over = aimw + ad * 30.0 + oy
        pts.append(over)
        var pp := Vector3(-ad.z, 0.0, ad.x)
        if (home - aimw).dot(pp) < 0.0:
            pp = -pp
        pts.append(aimw + ad * 95.0 + pp * 40.0 + oy)
        pts.append(aimw + ad * 55.0 + pp * 125.0 + oy)
        pts.append(aimw - ad * 50.0 + pp * 165.0 + oy)
    # home: long final approach, touchdown, roll-out and taxi to the stand
    pts.append(isl.to_global(Vector3(RW_X, 40.0, RW_Z1 - 340.0)))
    pts.append(isl.to_global(Vector3(RW_X, 24.0, RW_Z1 - 215.0)))
    pts.append(isl.to_global(Vector3(RW_X, 10.0, RW_Z1 - 130.0)))
    var td := isl.to_global(Vector3(RW_X, 1.3, RW_Z1 + 12.0))
    pts.append(td)
    var roll := isl.to_global(Vector3(RW_X, 1.2, 26.0))
    pts.append(roll)
    pts.append(isl.to_global(Vector3(RW_X - 6.0, 1.0, 36.0)))
    pts.append(isl.to_global(Vector3(TAXI_X + 1.0, 1.0, 30.0)))
    pts.append(isl.to_global(Vector3(TAXI_X, 1.0, 10.0)))
    pts.append(isl.to_global(Vector3(TAXI_X, 1.0, sp.y + 12.0)))
    pts.append(isl.to_global(Vector3(sp.x, 1.0, sp.y + 8.0)))
    pts.append(isl.to_global(Vector3(sp.x, 1.0, sp.y)))
    return {"pts": pts, "rw0": rw0, "rel": rel, "pay": pay, "over": over, "td": td, "roll": roll, "aimw": aimw}


func _start_sortie(a: int, tg: int, j: Dictionary, aim: Vector2, route: Dictionary = {}, payload: int = 0) -> void:
    var te: Dictionary = emp[tg]
    var ae: Dictionary = emp[a]
    if bool(te["dead"]) or bool(ae["dead"]):
        j["state"] = "parked"
        ae["money"] = int(ae["money"]) + int(JETS[int(j["t"])]["fee"])
        if payload > 0:
            var am: Array = ae["ammo"]
            am[6] = int(am[6]) + payload
            _sync_missiles(a)
        return
    _park_node(a, j)
    var info := _sortie_curve_points(a, tg, j, aim, route)
    var pts: Array = info["pts"]
    var c := Curve3D.new()
    c.bake_interval = 0.8
    for k in range(pts.size()):
        var p: Vector3 = pts[k]
        var prev: Vector3 = pts[maxi(k - 1, 0)]
        var nxt: Vector3 = pts[mini(k + 1, pts.size() - 1)]
        var seg := minf(p.distance_to(prev), p.distance_to(nxt))
        var dir := nxt - prev
        var tang := Vector3.ZERO
        if dir.length() > 0.001:
            tang = dir.normalized() * seg * 0.38
        c.add_point(p, -tang, tang)
    var jt: int = j["t"]
    var so := {
        "a": a, "tg": tg, "j": j, "jt": jt, "node": j["node"], "curve": c, "len": c.get_baked_length(), "off": 0.0,
        "spd": float(JETS[jt]["speed"]), "strike_off": c.get_closest_offset(info["rel"]),
        "pay_off": c.get_closest_offset(info["pay"]), "payload": payload, "paid": false,
        "taxi_end": c.get_closest_offset(info["rw0"]), "td": c.get_closest_offset(info["td"]),
        "roll_end": c.get_closest_offset(info["roll"]), "doom": -1.0, "id": 0,
        "fired": false, "aim": aim, "aa_t": 0.5, "tried": {}, "prev_yaw": 0.0, "bank": 0.0,
    }
    uid_counter += 1
    so["id"] = uid_counter
    j["state"] = "away"
    sorties.append(so)
    _play3d("drone", pts[0], 3.0, 0.7)
    if a == 0:
        _say("%s taking off for Enemy %d!" % [JETS[jt]["short"], tg])
    elif tg == 0:
        _say("WARNING! Enemy %d jet (%s) is inbound to your island!" % [a, JETS[jt]["short"]])
        _play_ui("siren", -3.0)


func _sortie_speed(so: Dictionary, off: float) -> float:
    var base: float = so["spd"]
    var te: float = so["taxi_end"]
    var td: float = so["td"]
    var ro: float = so["roll_end"]
    if off < te:
        return 20.0
    if off < te + 120.0:
        return lerpf(20.0, base, (off - te) / 120.0)
    if off > ro:
        return 18.0
    if off > td:
        return lerpf(base * 0.45, 18.0, clampf((off - td) / maxf(ro - td, 1.0), 0.0, 1.0))
    if off > td - 150.0:
        return lerpf(base, base * 0.45, clampf((off - (td - 150.0)) / 150.0, 0.0, 1.0))
    return base


func _update_sorties(delta: float) -> void:
    for k in range(sorties.size() - 1, -1, -1):
        var so: Dictionary = sorties[k]
        var nn = so["node"]
        if nn == null or not is_instance_valid(nn):
            sorties.remove_at(k)
            continue
        var node: Node3D = nn
        var curve: Curve3D = so["curve"]
        var total: float = so["len"]
        var off: float = float(so["off"]) + _sortie_speed(so, float(so["off"])) * delta
        so["off"] = off
        if off >= total:
            sorties.remove_at(k)
            _sortie_finish(so)
            continue
        var pos := curve.sample_baked(off, true)
        var ahead := curve.sample_baked(minf(off + 6.0, total), true)
        var dirv := ahead - pos
        node.position = pos
        if dirv.length() > 0.05:
            node.look_at(ahead, Vector3.UP)
            var yaw := atan2(-dirv.x, -dirv.z)
            var dyaw := wrapf(yaw - float(so["prev_yaw"]), -PI, PI)
            so["prev_yaw"] = yaw
            var want := clampf(dyaw / maxf(delta, 0.001) * 0.7, -0.9, 0.9)
            so["bank"] = lerpf(float(so["bank"]), want, clampf(delta * 4.0, 0.0, 1.0))
            var mdl: Node3D = node.get_meta("mdl")
            mdl.rotation.z = float(so["bank"])
        if int(so["payload"]) > 0 and not bool(so["paid"]) and off >= float(so["pay_off"]):
            so["paid"] = true
            _jet_launch_payload(so, pos)
        if not bool(so["fired"]) and off >= float(so["strike_off"]):
            so["fired"] = true
            _jet_fire(so, pos)
        var doom: float = float(so["doom"])
        if doom >= 0.0:
            doom -= delta
            so["doom"] = doom
            if doom <= 0.0:
                sorties.remove_at(k)
                _jet_shot_down(so, node)
            continue
        var aa_t: float = float(so["aa_t"]) - delta
        so["aa_t"] = aa_t
        if aa_t <= 0.0:
            so["aa_t"] = 0.3
            if off > float(so["taxi_end"]) + 150.0 and off < float(so["td"]) - 150.0:
                _jet_aa_check(so, node)


func _jet_launch_payload(so: Dictionary, from_pos: Vector3) -> void:
    var a: int = so["a"]
    var tg: int = so["tg"]
    var aim: Vector2 = so["aim"]
    var isl_t := _isl(tg)
    var n: int = so["payload"]
    var info: Dictionary = MISSILES[6]
    for w in range(n):
        var lp := aim + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * float(info["cep"]) * (1.0 + float(w))
        lp.x = clampf(lp.x, -118.0, 118.0)
        lp.y = clampf(lp.y, -118.0, 118.0)
        var to_pos := isl_t.to_global(Vector3(lp.x, 1.4, lp.y))
        var m := _make_missile_model(a == 0, 6)
        level_root.add_child(m)
        var sp0 := from_pos + Vector3(0.0, -1.2, 0.0) + Vector3(float(w) * 2.0 - 1.0, 0.0, 0.0)
        m.position = sp0
        var dist := sp0.distance_to(to_pos)
        projectiles.append({
            "node": m, "start": sp0, "end": to_pos, "t": 0.0, "dur": maxf(0.8, dist / float(info["speed"])) + 0.3 * float(w),
            "h": dist * float(info["arc"]), "attacker": a, "target": tg, "wt": 6, "lp": lp, "tried": [], "kill": -1.0,
        })
    _play3d("launch", from_pos, 3.0, 1.1)
    if a == 0:
        _say("Stealth cruise missiles released from your jet!")


func _jet_fire(so: Dictionary, from_pos: Vector3) -> void:
    var info: Dictionary = JETS[int(so["jt"])]
    var a: int = so["a"]
    var tg: int = so["tg"]
    var aim: Vector2 = so["aim"]
    var isl_t := _isl(tg)
    var shots: int = info["shots"]
    for w in range(shots):
        var lp := aim + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 4.5
        lp.x = clampf(lp.x, -118.0, 118.0)
        lp.y = clampf(lp.y, -118.0, 118.0)
        var to_pos := isl_t.to_global(Vector3(lp.x, 1.4, lp.y))
        var m := _make_missile_model(a == 0, 0)
        level_root.add_child(m)
        m.position = from_pos
        var dist := from_pos.distance_to(to_pos)
        projectiles.append({
            "node": m, "start": from_pos, "end": to_pos, "t": 0.0, "dur": maxf(0.8, dist / 120.0) + 0.18 * float(w), "h": dist * 0.03,
            "attacker": a, "target": tg, "wt": 0, "lp": lp, "tried": [], "kill": -1.0,
            "jdmg": float(info["dmg"]), "jrad": float(info["radius"]),
        })
    _play3d("launch", from_pos, 3.0, 1.3)


# air defense versus a jet: predicts where the jet will be and flies the interceptor there
func _jet_aa_check(so: Dictionary, node: Node3D) -> void:
    var tg: int = so["tg"]
    var te: Dictionary = emp[tg]
    if bool(te["dead"]):
        return
    var structs: Array = te["structs"]
    var tried: Dictionary = so["tried"]
    var info: Dictionary = JETS[int(so["jt"])]
    var curve: Curve3D = so["curve"]
    var total: float = so["len"]
    var off: float = so["off"]
    var spd := _sortie_speed(so, off)
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) != "defense" or str(s["state"]) != "ok":
            continue
        if int(s["mag"]) <= 0 or float(s["cd"]) > 0.0:
            continue
        var sid: int = s["id"]
        if int(tried.get(sid, 0)) >= 2:
            continue
        var dpos := _struct_world(tg, s)
        var dtype: int = s["sub"]
        var rng: float = DEFENSES[dtype]["range"]
        var flat := Vector2(node.position.x - dpos.x, node.position.z - dpos.z)
        if flat.length() > rng:
            continue
        tried[sid] = int(tried.get(sid, 0)) + 1
        s["mag"] = int(s["mag"]) - 1
        s["cd"] = float(DEFENSES[dtype]["cd"])
        var chance: float = float(JET_DEF[dtype]) * (1.0 - float(info["evade"]))
        var ok := randf() < chance
        var from_p := dpos + Vector3(0.0, 4.0, 0.0)
        var tm := from_p.distance_to(node.position) / float(DEF_SPEED[dtype])
        var meet := node.position
        for it in range(3):
            meet = curve.sample_baked(minf(off + spd * tm, total), true)
            tm = from_p.distance_to(meet) / float(DEF_SPEED[dtype])
        tm = maxf(tm * 1.1, 0.7)
        meet = curve.sample_baked(minf(off + spd * tm, total), true)
        _spawn_interceptor(from_p, meet, tm, dtype, ok)
        if ok:
            so["doom"] = tm
            return


func _jet_shot_down(so: Dictionary, node: Node3D) -> void:
    var a: int = so["a"]
    var tg: int = so["tg"]
    var jt: int = so["jt"]
    _explode(node.position, Color(1.0, 0.5, 0.1), 7.0)
    _play3d("boom", node.position, 8.0)
    node.queue_free()
    var e: Dictionary = emp[a]
    var jets: Array = e["jets"]
    jets.erase(so["j"])
    if a == 0:
        _say("Your %s was shot down over Enemy %d!" % [JETS[jt]["short"], tg])
        _play_ui("alarm", -2.0)
    elif tg == 0:
        _say("Your air defense shot down an enemy %s!" % JETS[jt]["short"])
    _refresh_ui()


func _sortie_finish(so: Dictionary) -> void:
    var a: int = so["a"]
    var j: Dictionary = so["j"]
    var e: Dictionary = emp[a]
    if bool(e["dead"]):
        var nn = j["node"]
        if nn != null and is_instance_valid(nn):
            var n3: Node3D = nn
            n3.queue_free()
        j["node"] = null
        var jets: Array = e["jets"]
        jets.erase(j)
        return
    j["state"] = "rearm"
    j["timer"] = 14.0
    _park_node(a, j)
    if a == 0:
        _say("%s landed safely and is being rearmed." % JETS[int(j["t"])]["short"])


const AI_PAD_ORDER := [5, 4, 0, 1, 6, 2, 3, 7]


func _ai_think(i: int) -> void:
    var e: Dictionary = emp[i]
    var money_i: int = e["money"]
    var aggr: float = e["aggr"]
    var nb: int = e["builders"]
    var lvl: int = e["blevel"]
    var defs_all := _count_structs(i, "defense", -1, false)

    # 1. builders first: they raise houses for income by themselves
    if nb < 1:
        _do_hire(i, "builder")
        return
    if nb < 2 and elapsed > 90.0:
        if _do_hire(i, "builder") == 0:
            return
    # 2. a repair crew once something is broken (or after a while)
    var hurt := _count_destroyed(i) > 0 or _damaged_count(i) > 0
    if int(e["brep"]) < 1 and (hurt or elapsed > 320.0):
        if _do_hire(i, "brep") == 0:
            return
    # 3. build a stockpile before the war starts
    if elapsed > 300.0 and _ammo_total(i) < int(e["salvo"]):
        var mt0 := _ai_pick_weapon(i)
        if mt0 >= 0 and _do_buy_missile(i, mt0) == 0:
            return
    # 4. air defense grows with time (cautious rivals build earlier)
    var want_def := mini(MAX_DEFENSES, int((elapsed - 120.0) / 140.0) + (1 if aggr < 0.5 else 0))
    if defs_all < want_def:
        var dt := -1
        for t2 in range(4, -1, -1):
            if _unlocked(i, "d", t2) and money_i >= int(DEFENSES[t2]["price"]):
                dt = t2
                break
        if dt >= 0:
            if _do_buy_defense(i, dt) == 0:
                return
    if int(e["arep"]) < 1 and defs_all >= 2:
        if _do_hire(i, "arep") == 0:
            return
    # 5. better builders = better houses = more money
    if lvl < MAX_LEVEL and elapsed > 160.0 * float(lvl):
        var need := int(float(BUILDER_UPGRADE[lvl - 1]) * 1.2)
        if money_i >= need:
            if _do_upgrade_builder(i) == 0:
                return
    # 6. more crews as the game goes on
    var goal_b := mini(MAX_BUILDERS, 2 + int(elapsed / 300.0))
    if nb < goal_b and money_i >= int(float(_worker_price(i, "builder")) * 1.2):
        if _do_hire(i, "builder") == 0:
            return
    var goal_r := mini(MAX_BREP, 1 + int(elapsed / 600.0))
    if int(e["brep"]) < goal_r and money_i >= int(float(_worker_price(i, "brep")) * 1.5):
        if _do_hire(i, "brep") == 0:
            return
    # 7. fighter jets once they unlock
    var goal_j := mini(MAX_JETS, int((elapsed - 600.0) / 500.0))
    if _jets_owned(i, -1) < goal_j:
        for jt in range(5, -1, -1):
            if _unlocked(i, "j", jt) and money_i >= int(float(JETS[jt]["price"]) * 1.2):
                if _do_buy_jet(i, jt) == 0:
                    return
                break
    # 8. keep stockpiling weapons for the next salvo
    if _ammo_total(i) < int(e["salvo"]) + 3:
        var mt := _ai_pick_weapon(i)
        if mt >= 0:
            _do_buy_missile(i, mt)


func _ai_pick_weapon(i: int) -> int:
    var e: Dictionary = emp[i]
    if _ammo_total(i) >= MAX_MISSILES:
        return -1
    var options: Array = []
    for t in AI_PAD_ORDER:
        if not _unlocked(i, "m", t):
            continue
        if t == 6 and _jets_owned(i, -1) < 1:
            continue
        if int(e["money"]) < int(MISSILES[t]["price"]):
            continue
        options.append(t)
    if options.is_empty():
        return -1
    if options.size() > 1 and randf() < 0.65:
        return int(options[options.size() - 1])
    return int(options[randi() % options.size()])


func _ai_salvo(i: int) -> void:
    var e: Dictionary = emp[i]
    var target := _ai_pick_target(i)
    var ammo: Array = e["ammo"]
    var primary := {}
    if target >= 0:
        primary = _weighted_struct(target)
    if target < 0 or primary.is_empty():
        e["rest"] = 20.0
        return
    var delay := 0.0
    var fired := 0
    for t in range(NM):
        if t == 6:
            continue
        var n: int = ammo[t]
        for k in range(n):
            var aim_s := primary
            if randf() < 0.3:
                var alt := _weighted_struct(target)
                if not alt.is_empty():
                    aim_s = alt
            var aim := Vector2(float(aim_s["lx"]), float(aim_s["lz"]))
            _queue_launch(i, target, t, aim, delay)
            delay += 0.22
            fired += 1
        ammo[t] = 0
    var jets: Array = e["jets"]
    var jl: Array = jets.duplicate()
    for jv in jl:
        var jj: Dictionary = jv
        var aim_j := primary
        if randf() < 0.5:
            var alt2 := _weighted_struct(target)
            if not alt2.is_empty():
                aim_j = alt2
        var aim2 := Vector2(float(aim_j["lx"]), float(aim_j["lz"]))
        var pay := mini(2, int(ammo[6]))
        var rt := {"mode": randi() % 3}
        if _queue_sortie(i, target, jj, aim2, delay + 3.0, rt, pay):
            ammo[6] = int(ammo[6]) - pay
            if pay > 0:
                _sync_missiles(i)
            delay += 1.5
            fired += 1
    var aggr: float = e["aggr"]
    var base_rest := randf_range(90.0, 150.0) * (1.3 - 0.6 * aggr)
    e["rest"] = base_rest * maxf(0.55, 1.0 - elapsed / 3000.0)
    e["salvo"] = randi_range(5, 8) + int(elapsed / 300.0)
    e["grudge"] = target
    if target == 0 and fired > 0:
        _say("WARNING! Enemy %d launched %d missiles/aircraft at you!" % [i, fired])
        _play_ui("siren", -3.0)


func _build_sat_ui() -> void:
    sat_root = Control.new()
    sat_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(sat_root)
    sat_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    sat_panels = []

    sat_money = Label.new()
    _style_text(sat_money, 36, Color(0.25, 1.0, 0.3))
    sat_money.position = Vector2(14.0, 8.0)
    sat_root.add_child(sat_money)

    var top := VBoxContainer.new()
    top.add_theme_constant_override("separation", 8)
    sat_root.add_child(top)
    var tp := PanelContainer.new()
    _style_panel(tp, Color(0.16, 0.19, 0.23, 0.92))
    top.add_child(tp)
    sat_title = Label.new()
    sat_title.text = "SELECT TARGET"
    sat_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sat_title.custom_minimum_size = Vector2(520.0, 0.0)
    sat_title.add_theme_font_size_override("font_size", 36)
    tp.add_child(sat_title)
    sat_island_box = HBoxContainer.new()
    sat_island_box.alignment = BoxContainer.ALIGNMENT_CENTER
    sat_island_box.add_theme_constant_override("separation", 10)
    top.add_child(sat_island_box)
    sat_island_btns = []
    for k in range(1, 4):
        var b := _make_button("ENEMY %d" % k, Color(0.7, 0.2, 0.2), _sat_pick_island.bind(k))
        b.custom_minimum_size = Vector2(170.0, 54.0)
        sat_island_box.add_child(b)
        sat_island_btns.append(b)
    top.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 6)
    top.grow_horizontal = Control.GROW_DIRECTION_BOTH
    sat_panels.append(top)

    var lp := VBoxContainer.new()
    lp.add_theme_constant_override("separation", 4)
    lp.position = Vector2(12.0, 64.0)
    sat_root.add_child(lp)
    sat_panels.append(lp)
    var pg := HBoxContainer.new()
    pg.add_theme_constant_override("separation", 6)
    lp.add_child(pg)
    sat_page_btns = []
    for pi in range(2):
        var pb := _make_button("MISSILES" if pi == 0 else "JETS", Color(0.05, 0.05, 0.06), _sat_page.bind(pi))
        pb.custom_minimum_size = Vector2(152.0, 46.0)
        pb.add_theme_font_size_override("font_size", 22)
        pg.add_child(pb)
        sat_page_btns.append(pb)
    sat_type_btns = []
    for t in range(NM + JETS.size()):
        var tb := Button.new()
        tb.custom_minimum_size = Vector2(310.0, 56.0)
        _style_button(tb, Color(0.07, 0.12, 0.2, 0.88))
        for stn in ["normal", "hover", "pressed", "disabled", "focus"]:
            var sbx: StyleBoxFlat = tb.get_theme_stylebox(stn)
            sbx.content_margin_left = 76.0
            sbx.content_margin_top = 2.0
            sbx.content_margin_bottom = 2.0
        tb.alignment = HORIZONTAL_ALIGNMENT_LEFT
        tb.add_theme_font_size_override("font_size", 18)
        tb.pressed.connect(_play_ui.bind("click", -8.0))
        tb.pressed.connect(_sat_set_type.bind(t))
        var ic := MiniIcon.new()
        ic.kind = 0 if t < NM else 7
        ic.sub = t if t < NM else t - NM
        ic.position = Vector2(6.0, 4.0)
        ic.size = Vector2(56.0, 48.0)
        tb.add_child(ic)
        lp.add_child(tb)
        sat_type_btns.append(tb)

    var rb := VBoxContainer.new()
    rb.add_theme_constant_override("separation", 14)
    sat_root.add_child(rb)
    sat_mult_btns = []
    for m in [1, 5]:
        var xb := _make_button("X%d" % m, Color(0.05, 0.05, 0.06), _sat_set_mult.bind(m))
        xb.custom_minimum_size = Vector2(104.0, 104.0)
        xb.add_theme_font_size_override("font_size", 36)
        rb.add_child(xb)
        sat_mult_btns.append(xb)
    rb.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT, Control.PRESET_MODE_MINSIZE, 14)
    rb.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    rb.grow_vertical = Control.GROW_DIRECTION_BOTH
    sat_panels.append(rb)

    var bot := VBoxContainer.new()
    bot.alignment = BoxContainer.ALIGNMENT_CENTER
    bot.add_theme_constant_override("separation", 8)
    bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
    sat_root.add_child(bot)
    route_row = HBoxContainer.new()
    route_row.alignment = BoxContainer.ALIGNMENT_CENTER
    route_row.add_theme_constant_override("separation", 8)
    bot.add_child(route_row)
    route_btns = []
    var rnames := ["STRAIGHT", "FROM BEHIND", "FLANK", "DRAW ROUTE"]
    for ri in range(4):
        var rbt := _make_button(str(rnames[ri]), Color(0.05, 0.05, 0.06), _route_mode_set.bind(ri))
        rbt.custom_minimum_size = Vector2(200.0, 54.0)
        rbt.add_theme_font_size_override("font_size", 22)
        route_row.add_child(rbt)
        route_btns.append(rbt)
    route_edit = HBoxContainer.new()
    route_edit.alignment = BoxContainer.ALIGNMENT_CENTER
    route_edit.add_theme_constant_override("separation", 8)
    bot.add_child(route_edit)
    var rsend := _make_button("SEND JET", Color(0.1, 0.6, 0.2), _route_send)
    rsend.custom_minimum_size = Vector2(230.0, 54.0)
    rsend.add_theme_font_size_override("font_size", 26)
    route_edit.add_child(rsend)
    var rundo := _make_button("UNDO", Color(0.35, 0.3, 0.1), _route_undo)
    rundo.custom_minimum_size = Vector2(150.0, 54.0)
    rundo.add_theme_font_size_override("font_size", 24)
    route_edit.add_child(rundo)
    var rclr := _make_button("CLEAR", Color(0.6, 0.15, 0.15), _route_clear)
    rclr.custom_minimum_size = Vector2(150.0, 54.0)
    rclr.add_theme_font_size_override("font_size", 24)
    route_edit.add_child(rclr)
    route_row.visible = false
    route_edit.visible = false
    sat_hint = Label.new()
    sat_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    sat_hint.custom_minimum_size = Vector2(820.0, 0.0)
    sat_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sat_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _style_text(sat_hint, 22, Color(1.0, 0.93, 0.6))
    bot.add_child(sat_hint)
    sat_back_btn = _make_button("Back", Color(0.05, 0.1, 0.2), _close_sat)
    sat_back_btn.custom_minimum_size = Vector2(280.0, 64.0)
    sat_back_btn.add_theme_font_size_override("font_size", 34)
    sat_back_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
    sat_back_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.4))
    sat_back_btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.1))
    bot.add_child(sat_back_btn)
    bot.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 8)
    bot.grow_horizontal = Control.GROW_DIRECTION_BOTH
    bot.grow_vertical = Control.GROW_DIRECTION_BEGIN
    sat_panels.append(sat_back_btn)
    sat_panels.append(route_row)
    sat_panels.append(route_edit)

    # placement panel (move a truck / launcher)
    var pp := VBoxContainer.new()
    pp.alignment = BoxContainer.ALIGNMENT_CENTER
    pp.add_theme_constant_override("separation", 8)
    sat_root.add_child(pp)
    place_label = Label.new()
    place_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    place_label.custom_minimum_size = Vector2(820.0, 0.0)
    place_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    place_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _style_text(place_label, 24, Color(0.6, 1.0, 0.7))
    pp.add_child(place_label)
    var prow := HBoxContainer.new()
    prow.alignment = BoxContainer.ALIGNMENT_CENTER
    prow.add_theme_constant_override("separation", 16)
    pp.add_child(prow)
    var okb := _make_button("PLACE HERE", Color(0.1, 0.6, 0.2), _place_confirm)
    okb.custom_minimum_size = Vector2(300.0, 64.0)
    okb.add_theme_font_size_override("font_size", 30)
    prow.add_child(okb)
    var cb := _make_button("CANCEL", Color(0.6, 0.15, 0.15), _place_cancel)
    cb.custom_minimum_size = Vector2(240.0, 64.0)
    cb.add_theme_font_size_override("font_size", 30)
    prow.add_child(cb)
    pp.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 8)
    pp.grow_horizontal = Control.GROW_DIRECTION_BOTH
    pp.grow_vertical = Control.GROW_DIRECTION_BEGIN
    place_panel = pp
    sat_panels.append(pp)
    pp.visible = false
    sat_root.visible = false


func _sat_page(p: int) -> void:
    sat_page = p
    if p == 0 and sat_type >= NM:
        sat_type = 0
    elif p == 1 and sat_type < NM:
        sat_type = NM
    _update_sat_marker()
    _refresh_sat()


func _open_sat_with(t: int) -> void:
    _open_sat()
    if sat_open:
        sat_type = t
        sat_page = 1 if t >= NM else 0
        _refresh_sat()


func _sat_blast_radius() -> float:
    if place_mode:
        return 5.0
    if sat_type >= NM:
        return maxf(4.0, float(JETS[sat_type - NM]["radius"]) + 2.0)
    var info: Dictionary = MISSILES[sat_type]
    return maxf(4.0, float(info["radius"]) + float(info["cep"]) * 0.5)


func _refresh_sat() -> void:
    if sat_root == null or emp.is_empty():
        return
    var e: Dictionary = emp[0]
    var ammo: Array = e["ammo"]
    sat_money.text = "$ %s" % _fmt_money(int(e["money"]))
    sat_title.text = "SELECT TARGET  -  ENEMY %d" % sat_island
    for k in range(sat_page_btns.size()):
        var pb: Button = sat_page_btns[k]
        var on := k == sat_page
        _style_button(pb, Color(1.0, 0.85, 0.05) if on else Color(0.05, 0.05, 0.06))
        var fc := Color(0.05, 0.05, 0.05) if on else Color(1.0, 1.0, 1.0)
        pb.add_theme_color_override("font_color", fc)
        pb.add_theme_color_override("font_hover_color", fc)
        pb.add_theme_color_override("font_pressed_color", fc)
    for t in range(sat_type_btns.size()):
        var b: Button = sat_type_btns[t]
        var is_jet := t >= NM
        b.visible = (is_jet and sat_page == 1) or ((not is_jet) and sat_page == 0)
        var have := 0
        if is_jet:
            var jinfo: Dictionary = JETS[t - NM]
            have = _jets_ready(0, t - NM)
            b.text = "%s\nSTRIKE x%d   READY %d/%d" % [jinfo["short"], int(jinfo["shots"]), have, _jets_owned(0, t - NM)]
        else:
            var info: Dictionary = MISSILES[t]
            have = int(ammo[t])
            b.text = "%s\nDMG %d      x%d" % [info["short"], int(float(info["dmg"]) * float(info["count"])), have]
            if t == 6:
                b.text = "%s (by jet)\nDMG %d      x%d" % [info["short"], int(float(info["dmg"])), have]
        if t == sat_type:
            b.modulate = Color(1.0, 1.0, 1.0)
        elif have > 0:
            b.modulate = Color(0.72, 0.72, 0.78)
        else:
            b.modulate = Color(0.45, 0.45, 0.5)
    var routable := sat_type >= NM or sat_type == 6
    route_row.visible = routable
    route_edit.visible = routable and route_mode == 3
    if not routable and not route_wps.is_empty():
        _route_clear()
    for rk in range(route_btns.size()):
        var rb2: Button = route_btns[rk]
        var ron := rk == route_mode
        _style_button(rb2, Color(0.2, 0.85, 1.0) if ron else Color(0.05, 0.05, 0.06))
        var rfc := Color(0.02, 0.05, 0.08) if ron else Color(1.0, 1.0, 1.0)
        rb2.add_theme_color_override("font_color", rfc)
        rb2.add_theme_color_override("font_hover_color", rfc)
        rb2.add_theme_color_override("font_pressed_color", rfc)
    for k2 in range(sat_island_btns.size()):
        var ib: Button = sat_island_btns[k2]
        var idx := k2 + 1
        if idx >= island_count:
            ib.visible = false
            continue
        ib.visible = true
        var te: Dictionary = emp[idx]
        ib.disabled = bool(te["dead"])
        ib.modulate = Color(1.0, 1.0, 1.0) if idx == sat_island else Color(0.7, 0.7, 0.7)


func _sat_tap(pos: Vector2) -> void:
    if place_mode:
        _place_tap(pos)
        return
    if game_state != "playing" or not sat_open or sat_cool > 0.0:
        return
    var e: Dictionary = emp[0]
    sat_local = _sat_screen_to_local(pos)
    sat_has_point = true
    _update_sat_marker()
    if sat_type >= NM or sat_type == 6:
        if route_mode == 3:
            route_wps.append(sat_local)
            _rebuild_route_marks()
            _play_ui("click", -6.0)
            _say("Route point %d set. Tap more points to steer the jet. The LAST point is where it attacks. Press SEND JET when ready." % route_wps.size())
            return
        _sat_commit(sat_local, {"mode": route_mode})
        return
    var ammo: Array = e["ammo"]
    var have: int = ammo[sat_type]
    if have < 1:
        _play_ui("error")
        _say("No %s left. Buy more in MILITARY, or pick another weapon." % MISSILES[sat_type]["short"])
        _refresh_sat()
        return
    var n := mini(sat_mult, have)
    var delay2 := 0.0
    for k in range(n):
        _queue_launch(0, sat_island, sat_type, sat_local, delay2)
        delay2 += 0.14
    ammo[sat_type] = have - n
    sat_cool = 0.22
    _say("%d x %s launched at Enemy %d!" % [n, MISSILES[sat_type]["short"], sat_island])
    _vibrate(40)
    _refresh_sat()
    _refresh_ui()


# ---------- moving trucks / launchers ----------
func _begin_move(kind: String, id: int) -> void:
    if game_state != "playing" or sat_open:
        return
    place_kind = kind
    place_id = id
    place_ok = false
    _close_windows()
    place_mode = true
    _open_sat()
    if not sat_open:
        place_mode = false
        return
    sat_island = 0
    sat_has_point = false
    _remove_sat_marker()
    for pv in sat_panels:
        var pc: Control = pv
        pc.visible = false
    place_panel.visible = true
    place_label.text = "MOVE: tap a free spot inside the green area, then press PLACE HERE."
    _update_rings()
    if place_zone == null or not is_instance_valid(place_zone):
        place_zone = MeshInstance3D.new()
        var zm := BoxMesh.new()
        zm.size = Vector3(MIL_RECT.size.x, 0.05, MIL_RECT.size.y)
        place_zone.mesh = zm
        var zmat := StandardMaterial3D.new()
        zmat.albedo_color = Color(0.2, 1.0, 0.4, 0.28)
        zmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        zmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        place_zone.material_override = zmat
        place_zone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        _isl(0).add_child(place_zone)
        place_zone.position = Vector3(MIL_RECT.position.x + MIL_RECT.size.x * 0.5, 1.0, MIL_RECT.position.y + MIL_RECT.size.y * 0.5)


func _end_place() -> void:
    place_mode = false
    place_panel.visible = false
    for pv in sat_panels:
        var pc: Control = pv
        pc.visible = true
    place_panel.visible = false
    if place_zone != null and is_instance_valid(place_zone):
        place_zone.queue_free()
    place_zone = null
    _close_sat()


func _place_cancel() -> void:
    if place_mode:
        _end_place()
        _say("Move cancelled.")


func _place_tap(pos: Vector2) -> void:
    if sat_island != 0:
        return
    sat_local = _sat_screen_to_local(pos)
    sat_has_point = true
    _update_sat_marker()
    place_ok = _spot_free(0, sat_local.x, sat_local.y, place_id)
    if place_ok:
        place_label.text = "Spot is free. Press PLACE HERE to move it."
    else:
        place_label.text = "Blocked or outside the green area. Tap another spot."
        _play_ui("error", -8.0)


func _place_confirm() -> void:
    if not place_mode:
        return
    if not sat_has_point or not place_ok:
        _play_ui("error")
        place_label.text = "First tap a free spot inside the green area."
        return
    var code := 0
    if place_kind == "d":
        code = _do_move_defense(0, place_id, sat_local.x, sat_local.y)
    else:
        code = _do_move_truck(0, place_id, sat_local.x, sat_local.y)
    if code != 0:
        _play_ui("error")
        place_label.text = "Could not place it there."
        return
    _end_place()
    _play_ui("build", -4.0)
    _say("Moved. Re-open MILITARY > MANAGE to move or sell more.")
    _save_game()


func _route_mode_set(m: int) -> void:
    route_mode = m
    if m != 3:
        _route_clear()
    var hints := [
        "STRAIGHT: the jet flies straight at the target, attacks, then loops back home. Tap the enemy island.",
        "FROM BEHIND: the jet flies around the island and attacks from the far side. Tap the enemy island.",
        "FLANK: the jet comes in from the side. Tap the enemy island.",
        "DRAW ROUTE: tap points on the map for the jet to fly through. The LAST point is the attack point. Then press SEND JET.",
    ]
    _say(str(hints[m]))
    _refresh_sat()


func _route_undo() -> void:
    if not route_wps.is_empty():
        route_wps.remove_at(route_wps.size() - 1)
    _rebuild_route_marks()
    if route_wps.is_empty():
        sat_has_point = false
        _update_sat_marker()
    else:
        sat_local = route_wps[route_wps.size() - 1]
        _update_sat_marker()


func _route_clear() -> void:
    route_wps.clear()
    _rebuild_route_marks()


func _route_send() -> void:
    if route_wps.is_empty():
        _play_ui("error")
        _say("Tap at least one point on the enemy island first (the last point is the attack point).")
        return
    var last: Vector2 = route_wps[route_wps.size() - 1]
    var r := {"mode": 3, "wps": route_wps.duplicate()}
    _sat_commit(last, r)
    _route_clear()


func _clear_route_marks() -> void:
    for mv in route_marks:
        if is_instance_valid(mv):
            var mn: Node = mv
            mn.queue_free()
    route_marks.clear()


func _rebuild_route_marks() -> void:
    _clear_route_marks()
    if not sat_open or route_wps.is_empty():
        return
    var par := _isl(sat_island)
    var prev := Vector3.ZERO
    var have_prev := false
    for k in range(route_wps.size()):
        var w: Vector2 = route_wps[k]
        var last := k == route_wps.size() - 1
        var col := Color(1.0, 0.25, 0.2) if last else Color(0.2, 0.85, 1.0)
        var p := Vector3(w.x, 14.0, w.y)
        var ball := _sphere(par, 3.2 if last else 2.4, p, col)
        ball.material_override = _glow_mat(col)
        route_marks.append(ball)
        var lab := Label3D.new()
        lab.text = "ATTACK" if last else str(k + 1)
        lab.font_size = 64
        lab.pixel_size = 0.12
        lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        lab.no_depth_test = true
        lab.render_priority = 4
        lab.outline_size = 14
        lab.modulate = col.lightened(0.3)
        lab.position = p + Vector3(0.0, 6.0, 0.0)
        par.add_child(lab)
        route_marks.append(lab)
        if have_prev:
            var dv := p - prev
            var ln := Vector2(dv.x, dv.z).length()
            if ln > 0.5:
                var seg := _box(par, Vector3(ln, 0.5, 0.9), (p + prev) * 0.5, Color(0.2, 0.85, 1.0))
                seg.rotation.y = atan2(-dv.z, dv.x)
                seg.material_override = _glow_mat(Color(0.2, 0.85, 1.0))
                route_marks.append(seg)
        prev = p
        have_prev = true


# fire jets or air-launched stealth cruise missiles along a chosen route
func _sat_commit(aim: Vector2, route: Dictionary) -> void:
    var e: Dictionary = emp[0]
    var jets: Array = e["jets"]
    if sat_type == 6:
        var ammo: Array = e["ammo"]
        var have6: int = ammo[6]
        if have6 < 1:
            _play_ui("error")
            _say("No Stealth Cruise missiles left. Buy more in MILITARY.")
            _refresh_sat()
            return
        var parked: Array = []
        for jv in jets:
            var jj: Dictionary = jv
            if str(jj["state"]) == "parked":
                parked.append(jj)
        if parked.is_empty():
            _play_ui("error")
            _say("Stealth Cruise missiles are air-launched. You need a parked fighter jet (MILITARY > AIRCRAFT).")
            _refresh_sat()
            return
        var n6 := mini(sat_mult, have6)
        var used := 0
        var sent6 := 0
        var dl := 0.0
        for pj in parked:
            if used >= n6:
                break
            var jd: Dictionary = pj
            var pay := mini(2, n6 - used)
            if _queue_sortie(0, sat_island, jd, aim, dl, route, pay):
                used += pay
                sent6 += 1
                dl += 1.4
            else:
                _play_ui("error")
                _say("Not enough money for the sortie fee.")
                break
        if used > 0:
            ammo[6] = have6 - used
            _sync_missiles(0)
            sat_cool = 0.4
            _say("%d jet(s) scrambled carrying %d Stealth Cruise missiles!" % [sent6, used])
            _vibrate(40)
        _refresh_sat()
        _refresh_ui()
        return
    var jt := sat_type - NM
    var ready := _jets_ready(0, jt)
    if ready < 1:
        _play_ui("error")
        _say("No %s ready at your airport. Buy one in MILITARY > AIRCRAFT, or wait for it to land." % JETS[jt]["short"])
        _refresh_sat()
        return
    var want := mini(sat_mult, ready)
    var sent := 0
    var delay := 0.0
    for jv2 in jets:
        if sent >= want:
            break
        var j: Dictionary = jv2
        if int(j["t"]) == jt and str(j["state"]) == "parked":
            if _queue_sortie(0, sat_island, j, aim, delay, route):
                sent += 1
                delay += 1.4
            else:
                _play_ui("error")
                _say("Not enough money for the %s sortie fee ($%d)." % [JETS[jt]["short"], int(JETS[jt]["fee"])])
                break
    if sent > 0:
        sat_cool = 0.4
        _say("%d x %s scrambled towards Enemy %d!" % [sent, JETS[jt]["short"], sat_island])
        _vibrate(40)
    _refresh_sat()
    _refresh_ui()


func _evade(t: int) -> int:
    var sum := 0.0
    for d in range(DEFENSES.size()):
        sum += float(DEF_TABLE[d][t])
    return int(round((1.0 - sum / float(DEFENSES.size())) * 100.0))


func _make_list(parent: Control) -> VBoxContainer:
    var sc := ScrollContainer.new()
    sc.custom_minimum_size = Vector2(920.0, 430.0)
    sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    parent.add_child(sc)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 8)
    v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    sc.add_child(v)
    return v


func _build_military_window() -> void:
    mil_tab_btns = []
    var w := _make_window(["MISSILE", "ANTI - AIR", "AIRCRAFT", "MANAGE"], _mil_tab, mil_tab_btns)
    mil_panel = w["panel"]
    var v: VBoxContainer = w["vbox"]
    var gm := _make_grid(v)
    mil_body_missile = gm.get_parent()
    cards_missile = []
    for t in range(NM):
        var m: Dictionary = MISSILES[t]
        var c := _make_card(0, t, str(m["name"]), ["", "", str(m["cls"])],
            _ui_buy_missile.bind(t, 1), _ui_buy_missile.bind(t, 5))
        gm.add_child(c["card"])
        cards_missile.append(c)
    var ga := _make_grid(v)
    mil_body_aa = ga.get_parent()
    cards_aa = []
    for t2 in range(DEFENSES.size()):
        var d: Dictionary = DEFENSES[t2]
        var c2 := _make_card(1, t2, str(d["name"]), ["", "", str(d["cls"])], _ui_buy_def.bind(t2), Callable())
        ga.add_child(c2["card"])
        cards_aa.append(c2)
    mil_body_aa.hide()
    var gj := _make_grid(v)
    mil_body_jet = gj.get_parent()
    cards_jet = []
    for t3 in range(JETS.size()):
        var jd: Dictionary = JETS[t3]
        var c3 := _make_card(7, t3, str(jd["name"]), ["", "", str(jd["cls"])], _ui_buy_jet.bind(t3), Callable())
        gj.add_child(c3["card"])
        cards_jet.append(c3)
    mil_body_jet.hide()
    manage_list = _make_list(v)
    mil_body_manage = manage_list.get_parent()
    mil_body_manage.hide()


func _mil_tab(k: int) -> void:
    mil_tab = k
    mil_body_missile.visible = k == 0
    mil_body_aa.visible = k == 1
    mil_body_jet.visible = k == 2
    mil_body_manage.visible = k == 3
    _tab_style(mil_tab_btns, k)
    if k == 3:
        _refresh_manage()


func _manage_row(kind: String, id: int, icon_kind: int, icon_sub: int, title: String, info: String, refund: int) -> void:
    var card := PanelContainer.new()
    _style_panel(card, Color(0.1, 0.11, 0.14, 0.98))
    card.custom_minimum_size = Vector2(900.0, 84.0)
    var h := HBoxContainer.new()
    h.add_theme_constant_override("separation", 10)
    card.add_child(h)
    var ic := MiniIcon.new()
    ic.kind = icon_kind
    ic.sub = icon_sub
    ic.custom_minimum_size = Vector2(70.0, 70.0)
    h.add_child(ic)
    var mid := VBoxContainer.new()
    mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    h.add_child(mid)
    var t := Label.new()
    t.text = title
    t.add_theme_font_size_override("font_size", 23)
    t.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
    mid.add_child(t)
    var inf := Label.new()
    inf.text = info
    inf.add_theme_font_size_override("font_size", 18)
    inf.add_theme_color_override("font_color", Color(0.65, 0.78, 1.0))
    mid.add_child(inf)
    var mb := _make_button("MOVE", Color(0.1, 0.32, 0.95), _begin_move.bind(kind, id))
    mb.custom_minimum_size = Vector2(130.0, 52.0)
    mb.add_theme_font_size_override("font_size", 22)
    h.add_child(mb)
    var sb := _make_button("SELL $%s" % _fmt_money(refund), Color(0.7, 0.15, 0.15), _ui_sell.bind(kind, id))
    sb.custom_minimum_size = Vector2(190.0, 52.0)
    sb.add_theme_font_size_override("font_size", 22)
    h.add_child(sb)
    manage_list.add_child(card)


func _refresh_manage() -> void:
    if manage_list == null:
        return
    for ch in manage_list.get_children():
        ch.queue_free()
    var e: Dictionary = emp[0]
    var structs: Array = e["structs"]
    var count := 0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) != "defense":
            continue
        var sub: int = s["sub"]
        var st: String = s["state"]
        var hp := int(round(float(s["hp"]) / float(s["maxhp"]) * 100.0))
        var refund := int(float(DEFENSES[sub]["price"]) * 0.5) if st == "ok" else 0
        _manage_row("d", int(s["id"]), 1, sub, str(DEFENSES[sub]["name"]),
            "Condition %d%%   Shots %d   %s" % [hp, int(s["mag"]), st], refund)
        count += 1
    var trucks: Array = e["mnodes"]
    for tv in trucks:
        var tr: Dictionary = tv
        var t: int = tr["t"]
        var n: int = tr["n"]
        _manage_row("m", int(tr["id"]), 0, t, "%s truck" % MISSILES[t]["short"],
            "Loaded %d / %d missiles" % [n, int(tr["cap"])], int(float(MISSILES[t]["price"]) * 0.5 * float(n)))
        count += 1
    if count == 0:
        var l := Label.new()
        l.text = "Nothing to manage yet. Buy missiles or air defense first."
        l.add_theme_font_size_override("font_size", 24)
        manage_list.add_child(l)


func _ui_sell(kind: String, id: int) -> void:
    if game_state != "playing":
        return
    var code := 0
    if kind == "d":
        code = _do_sell_defense(0, id)
    else:
        code = _do_sell_truck(0, id)
    if code == 0:
        _play_ui("build", -4.0)
        _say("Sold. You got half of the price back. Buy a different one in its place.")
    else:
        _play_ui("error")
    _refresh_manage()
    _after_buy()


func _ui_buy_jet(t: int) -> void:
    var nm: String = JETS[t]["name"]
    _ui_result(_do_buy_jet(0, t), nm, "%s parked at your airport. Send it from ATTACK > JETS." % nm)


func _build_hotbar() -> void:
    hot_box = HBoxContainer.new()
    hot_box.add_theme_constant_override("separation", 5)
    ui_root.add_child(hot_box)
    var bag := Button.new()
    bag.custom_minimum_size = Vector2(66.0, 66.0)
    _style_button(bag, Color(0.14, 0.18, 0.26, 0.9))
    var bi := MiniIcon.new()
    bi.kind = 6
    bag.add_child(bi)
    bi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
    hot_box.add_child(bag)
    hot_slots = []
    for k in range(14):
        var d := _make_slot(k)
        var sb: Button = d["btn"]
        hot_box.add_child(sb)
        hot_slots.append(d)
    hot_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 6)
    hot_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
    hot_box.grow_vertical = Control.GROW_DIRECTION_BEGIN


func _on_hot_slot(idx: int) -> void:
    if game_state != "playing" or idx >= hot_items.size():
        return
    var it: Dictionary = hot_items[idx]
    var k: String = it["k"]
    if k == "m":
        _open_sat_with(int(it["t"]))
    elif k == "j":
        _open_sat_with(NM + int(it["t"]))
    else:
        _say("%s x%d on your island. Air defense shoots incoming missiles and jets by itself." % [DEFENSES[int(it["t"])]["short"], int(it["n"])])


func _refresh_hotbar() -> void:
    var e: Dictionary = emp[0]
    var ammo: Array = e["ammo"]
    hot_items = []
    for t in range(NM):
        if int(ammo[t]) > 0:
            hot_items.append({"k": "m", "t": t, "n": int(ammo[t])})
    for t1 in range(JETS.size()):
        var jn := _jets_owned(0, t1)
        if jn > 0:
            hot_items.append({"k": "j", "t": t1, "n": jn})
    for t2 in range(DEFENSES.size()):
        var n := _count_structs(0, "defense", t2, true)
        if n > 0:
            hot_items.append({"k": "d", "t": t2, "n": n})
    for idx in range(hot_slots.size()):
        var d: Dictionary = hot_slots[idx]
        var b: Button = d["btn"]
        var ic: MiniIcon = d["icon"]
        var lbl: Label = d["lbl"]
        if idx < hot_items.size():
            var it: Dictionary = hot_items[idx]
            b.visible = true
            ic.visible = true
            var k: String = it["k"]
            ic.kind = 0 if k == "m" else (7 if k == "j" else 1)
            ic.sub = int(it["t"])
            ic.queue_redraw()
            lbl.text = "x%d" % int(it["n"])
        else:
            ic.visible = false
            lbl.text = ""
            b.visible = idx < 8


func _refresh_ui() -> void:
    if money_label == null or emp.is_empty():
        return
    var e: Dictionary = emp[0]
    var money: int = e["money"]
    var ammo: Array = e["ammo"]
    var total := _ammo_total(0)
    stat_missile.text = "Missiles   %d/%d" % [total, MAX_MISSILES]
    stat_aa.text = "Air defense   %d/%d" % [_count_structs(0, "defense", -1, true), MAX_DEFENSES]
    stat_jets.text = "Aircraft   %d/%d" % [_jets_owned(0, -1), MAX_JETS]
    stat_house.text = "Houses   %d/%d" % [_count_structs(0, "house", -1, true), MAX_HOUSES]
    money_label.text = "$ %s" % _fmt_money(money)
    income_label.text = "%s/s" % _fmt_money(_income(0))
    if elapsed < PEACE_TIME:
        var left := int(PEACE_TIME - elapsed)
        stats_label.text = "Peace time  %d:%02d" % [int(left / 60), left % 60]
    else:
        stats_label.text = "WAR! Rivals can attack"

    # military window
    for t in range(NM):
        var c: Dictionary = cards_missile[t]
        var m: Dictionary = MISSILES[t]
        var price: int = m["price"]
        var info: Label = c["info"]
        var b1: Button = c["b1"]
        var b5: Button = c["b5"]
        if not _unlocked(0, "m", t):
            info.text = "LOCKED\nUnlocks when you reach %s\nDMG %d" % [_unlock_text("m", t), int(float(m["dmg"]) * float(m["count"]))]
            b1.text = "LOCKED"
            b5.text = "LOCKED"
            b1.disabled = true
            b5.disabled = true
            continue
        info.text = "DMG %d\nRadius %d    Evade %d%%\nOwned: %d" % [int(float(m["dmg"]) * float(m["count"])), int(m["radius"]), _evade(t), int(ammo[t])]
        b1.text = "$%s   X1" % _fmt_money(price)
        b5.text = "$%s   X5" % _fmt_money(price * 5)
        b1.disabled = money < price or total >= MAX_MISSILES
        b5.disabled = money < price * 5 or total + 5 > MAX_MISSILES
    for t2 in range(DEFENSES.size()):
        var c2: Dictionary = cards_aa[t2]
        var d: Dictionary = DEFENSES[t2]
        var dprice: int = d["price"]
        var info2: Label = c2["info"]
        var db: Button = c2["b1"]
        if not _unlocked(0, "d", t2):
            info2.text = "LOCKED\nUnlocks when you reach %s\nRange %d" % [_unlock_text("d", t2), int(d["range"])]
            db.text = "LOCKED"
            db.disabled = true
            continue
        info2.text = "Range %d    Shots %d\nReload %.1fs    Refill $%d\nOwned: %d" % [int(d["range"]), int(d["mag"]), float(d["cd"]), int(d["ref"]), _count_structs(0, "defense", t2, false)]
        db.text = "$%s   BUY" % _fmt_money(dprice)
        db.disabled = money < dprice or _count_structs(0, "defense", -1, false) >= MAX_DEFENSES
    for t3 in range(JETS.size()):
        var c3: Dictionary = cards_jet[t3]
        var jd: Dictionary = JETS[t3]
        var jprice: int = jd["price"]
        var info3: Label = c3["info"]
        var jb: Button = c3["b1"]
        if not _unlocked(0, "j", t3):
            info3.text = "LOCKED\nUnlocks when you reach %s\nStrike x%d  DMG %d" % [_unlock_text("j", t3), int(jd["shots"]), int(jd["dmg"])]
            jb.text = "LOCKED"
            jb.disabled = true
            continue
        info3.text = "Strike x%d   DMG %d\nStealth %d%%   Sortie $%d\nOwned: %d" % [int(jd["shots"]), int(jd["dmg"]), int(float(jd["evade"]) * 100.0), int(jd["fee"]), _jets_owned(0, t3)]
        jb.text = "$%s   BUY" % _fmt_money(jprice)
        jb.disabled = money < jprice or _jets_owned(0, -1) >= MAX_JETS

    # worker window
    var kinds := ["builder", "brep", "arep"]
    var descs := ["Auto-builds and upgrades houses", "Fixes wrecked houses (they pay nothing while broken)", "Repairs wrecked air defense"]
    for k in range(3):
        var wc: Dictionary = cards_worker[k]
        var kind: String = kinds[k]
        var n := _worker_total(e, kind)
        var mx := _worker_max(kind)
        var winfo: Label = wc["info"]
        winfo.text = "%s\nHired %d / %d" % [descs[k], n, mx]
        var wb: Button = wc["b1"]
        var wprice := _worker_price(0, kind)
        if n >= mx:
            wb.text = "MAX"
            wb.disabled = true
        else:
            wb.text = "$%s   HIRE" % _fmt_money(wprice)
            wb.disabled = money < wprice
    var lvl: int = e["blevel"]
    var ut: Label = up_card["title"]
    var ui: Label = up_card["info"]
    var ub: Button = up_card["b1"]
    ut.text = "Builder Lv.%d" % lvl
    if lvl >= MAX_LEVEL:
        ui.text = "Max level reached.\nEvery house earns +$%d/s" % int(HOUSE_INCOME[MAX_LEVEL - 1])
        ub.text = "MAX"
        ub.disabled = true
    else:
        var uprice: int = BUILDER_UPGRADE[lvl - 1]
        ui.text = "Houses Lv%d -> Lv%d\nEarning +$%d -> +$%d per house" % [lvl, lvl + 1, int(HOUSE_INCOME[lvl - 1]), int(HOUSE_INCOME[lvl])]
        ub.text = "$%s   UPGRADE" % _fmt_money(uprice)
        ub.disabled = money < uprice or int(e["builders"]) < 1
    _refresh_hotbar()
    if sat_open:
        _refresh_sat()


func _selftest() -> void:
    print("SELFTEST start")
    await get_tree().process_frame
    _start_new(3)
    var me: Dictionary = emp[0]
    me["money"] = 500000000
    elapsed = 4000.0
    print("SELFTEST hire ", _do_hire(0, "builder"), _do_hire(0, "builder"), _do_hire(0, "brep"), _do_hire(0, "arep"))
    for t in range(NM):
        print("SELFTEST buy ", t, " ", _do_buy_missile(0, t, 5))
    for t2 in range(5):
        print("SELFTEST def ", t2, " ", _do_buy_defense(0, t2), _do_buy_defense(0, t2))
    for t3 in range(JETS.size()):
        print("SELFTEST jet ", t3, " ", _do_buy_jet(0, t3), _do_buy_jet(0, t3))
    print("SELFTEST up ", _do_upgrade_builder(0), _do_upgrade_builder(0))
    _toggle_mil()
    for k in range(4):
        _mil_tab(k)
    _close_windows()
    _toggle_work()
    _work_tab(1)
    _close_windows()
    _refresh_ui()
    # sell and move
    var structs: Array = me["structs"]
    var first_def := -1
    var second_def := -1
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) == "defense":
            if first_def < 0:
                first_def = int(s["id"])
            elif second_def < 0:
                second_def = int(s["id"])
    print("SELFTEST move ", _do_move_defense(0, first_def, -40.0, -30.0), " blocked ", _do_move_defense(0, second_def, -40.0, -30.0), " sell ", _do_sell_defense(0, second_def))
    var trucks: Array = me["mnodes"]
    var tid := int(trucks[0]["id"])
    print("SELFTEST truck move ", _do_move_truck(0, tid, -10.0, -62.0), " sell ", _do_sell_truck(0, int(trucks[1]["id"])))
    for k2 in range(120):
        _process(0.25)
    _refresh_ui()
    _begin_move("d", first_def)
    for k3 in range(3):
        await get_tree().process_frame
    _process(0.1)
    _place_tap(Vector2(640.0, 300.0))
    _place_confirm()
    print("SELFTEST place done, sat_open=", sat_open, " ok=", place_ok)
    if place_mode:
        _place_cancel()
    print("SELFTEST after cancel sat_open=", sat_open, " place_mode=", place_mode)
    _save_game()
    print("SELFTEST save/load ", _load_game())
    _build_world()
    _refresh_ui()
    me = emp[0]
    for r in range(1, 3):
        var re: Dictionary = emp[r]
        re["rest"] = 99999.0
    _open_sat()
    _sat_page(1)
    _sat_set_mult(1)
    for k4 in range(3):
        await get_tree().process_frame
    _sat_set_type(NM + 0)
    _route_mode_set(0)
    _sat_tap(Vector2(640.0, 360.0))
    sat_cool = 0.0
    _sat_set_type(NM + 1)
    _route_mode_set(1)
    _sat_tap(Vector2(700.0, 330.0))
    sat_cool = 0.0
    _sat_set_type(NM + 2)
    _route_mode_set(2)
    _sat_tap(Vector2(600.0, 380.0))
    sat_cool = 0.0
    _sat_set_type(NM + 3)
    _route_mode_set(3)
    _sat_tap(Vector2(500.0, 250.0))
    _sat_tap(Vector2(760.0, 300.0))
    _sat_tap(Vector2(640.0, 420.0))
    print("SELFTEST route wps ", route_wps.size(), " marks ", route_marks.size())
    await get_tree().process_frame
    _route_send()
    sat_cool = 0.0
    _sat_set_type(6)
    _route_mode_set(0)
    _sat_set_mult(5)
    _sat_tap(Vector2(640.0, 340.0))
    print("SELFTEST stealth ammo left ", emp[0]["ammo"][6])
    sat_cool = 0.0
    _sat_page(0)
    _sat_set_type(1)
    _sat_tap(Vector2(500.0, 300.0))
    _sat_pick_island(2)
    print("SELFTEST queued ", launch_queue.size())
    var mx1 := 0
    var cam_ok := 0
    for k6 in range(300):
        _process(0.25)
        mx1 = maxi(mx1, sorties.size())
        if cam_ok == 0 and sorties.size() > 0 and k6 > 20:
            _close_sat()
            _jetcam_enter()
            for kc in range(120):
                _process(0.1)
                _update_camera(0.1)
                if kc % 40 == 0:
                    _jetcam_next()
            cam_ok = 1 if jetcam_on else 0
            _jetcam_exit()
            _open_sat()
            print("SELFTEST jetcam ", cam_ok)
    print("SELFTEST peak ", emp[0]["peak"], " unlocked ICBM ", _unlocked(0, "m", 7))
    print("SELFTEST player sorties max ", mx1, " now ", sorties.size(), " my jets ", _jets_owned(0, -1), " proj ", projectiles.size())
    _close_sat()
    for t4 in range(1, 3):
        var ee: Dictionary = emp[t4]
        ee["money"] = 50000000
    for r2 in range(1, 3):
        var re2: Dictionary = emp[r2]
        re2["rest"] = 0.0
    me["money"] = 500000000
    var maxs := 0
    for k5 in range(2400):
        _process(0.25)
        maxs = maxi(maxs, sorties.size())
    print("SELFTEST max sorties ", maxs, " jets mine ", _jets_owned(0, -1), " e1 ", _jets_owned(1, -1), " e2 ", _jets_owned(2, -1))
    _refresh_ui()
    _save_game()
    print("SELFTEST load ", _load_game())
    _build_world()
    _refresh_ui()
    # phase 2: rivals play by themselves
    _start_new(3)
    elapsed = 4000.0
    var me2: Dictionary = emp[0]
    me2["money"] = 500000000
    for t5 in range(5):
        _do_buy_defense(0, t5)
        _do_buy_defense(0, t5)
    for hs in range(1, 50):
        var hp2 := _house_pos(hs)
        var nh := _add_struct(0, "house", 0, hp2.x, hp2.y, "ok", hs)
        nh["lvl"] = 5
        nh["maxhp"] = 900.0
        nh["hp"] = 900.0
        _spawn_struct_node(0, nh, 0.0)
    for r3 in range(1, 3):
        var re3: Dictionary = emp[r3]
        re3["money"] = 80000000
        re3["rest"] = 0.0
        _do_buy_jet(r3, 1)
        _do_buy_jet(r3, 4)
        _do_buy_jet(r3, 3)
    var mx2 := 0
    var shot := 0
    for k7 in range(2400):
        _process(0.25)
        mx2 = maxi(mx2, sorties.size())
        if k7 % 200 == 0:
            print("SELFTEST t=", k7, " ", game_state, " e1 money ", emp[1]["money"], " ammo ", _ammo_total(1), " jets ", _jets_owned(1, -1), " defs ", _count_structs(1, "defense", -1, false), " b ", emp[1]["builders"], " myhouses ", _count_structs(0, "house", -1, true), " proj ", projectiles.size())
    print("SELFTEST phase2 state ", game_state, " max sorties ", mx2, " e1 jets ", _jets_owned(1, -1), " e2 jets ", _jets_owned(2, -1), " e1 ammo ", _ammo_total(1), " me jets ", _jets_owned(0, -1))
    print("SELFTEST done")
    get_tree().quit()


func _collect_meshes(n: Node, xf: Transform3D, skip: Array, out: Array) -> void:
    for c in n.get_children():
        if skip.has(c):
            continue
        if c is MeshInstance3D:
            var mi: MeshInstance3D = c
            out.append({"mi": mi, "xf": xf * mi.transform})
        elif c is Node3D:
            var n3: Node3D = c
            _collect_meshes(c, xf * n3.transform, skip, out)


# merge all simple meshes below root into one mesh per material (far fewer draw calls)
func _merge_model(root: Node3D, skip: Array) -> void:
    var items: Array = []
    _collect_meshes(root, Transform3D.IDENTITY, skip, items)
    var groups := {}
    var merged: Array = []
    for itv in items:
        var it: Dictionary = itv
        var mi: MeshInstance3D = it["mi"]
        var mat = mi.material_override
        if mat == null or mi.mesh == null:
            continue
        var key: int = mat.get_instance_id()
        if not groups.has(key):
            var st := SurfaceTool.new()
            st.begin(Mesh.PRIMITIVE_TRIANGLES)
            groups[key] = {"mat": mat, "st": st}
        var g: Dictionary = groups[key]
        var stt: SurfaceTool = g["st"]
        stt.append_from(mi.mesh, 0, it["xf"])
        merged.append(mi)
    for gk in groups.keys():
        var gg: Dictionary = groups[gk]
        var s2: SurfaceTool = gg["st"]
        var am: ArrayMesh = s2.commit()
        var nm := MeshInstance3D.new()
        nm.mesh = am
        nm.material_override = gg["mat"]
        root.add_child(nm)
    for mv in merged:
        var old: MeshInstance3D = mv
        old.get_parent().remove_child(old)
        old.queue_free()


func _interceptor_model(dtype: int) -> Node3D:
    var root := Node3D.new()
    var sc: float = [1.0, 0.85, 1.05, 1.25, 1.5][dtype]
    var m := Node3D.new()
    m.scale = Vector3.ONE * sc
    root.add_child(m)
    var body := Color(0.92, 0.93, 0.95)
    var accent := Color(0.95, 0.75, 0.15) if dtype < 3 else Color(0.3, 0.55, 0.9)
    var fus := _cyl(m, 0.2, 0.2, 2.6, Vector3.ZERO, body)
    fus.rotation.x = PI / 2.0
    var nose := _cyl(m, 0.0, 0.2, 0.8, Vector3(0.0, 0.0, -1.6), accent)
    nose.rotation.x = -PI / 2.0
    _box(m, Vector3(1.0, 0.05, 0.5), Vector3(0.0, 0.0, 0.9), body.darkened(0.15))
    _box(m, Vector3(0.05, 1.0, 0.5), Vector3(0.0, 0.0, 0.9), body.darkened(0.15))
    _box(m, Vector3(0.7, 0.04, 0.35), Vector3(0.0, 0.0, -0.5), accent)
    var fl := _sphere(m, 0.3, Vector3(0.0, 0.0, 1.5), Color(1.0, 0.7, 0.25))
    fl.scale = Vector3(1.0, 1.0, 2.2)
    fl.material_override = _glow_mat(Color(1.0, 0.65, 0.2))
    _merge_model(m, [])
    return root


func _smoke_puff(pos: Vector3, size: float, life: float) -> void:
    var p := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 1.0
    sm.height = 2.0
    sm.radial_segments = 8
    sm.rings = 4
    p.mesh = sm
    var key := "puff"
    var mat: StandardMaterial3D
    if mat_cache.has(key):
        mat = mat_cache[key]
    else:
        mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.93, 0.93, 0.95, 0.75)
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mat_cache[key] = mat
    p.material_override = mat
    p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    p.position = pos
    p.scale = Vector3.ONE * size * 0.4
    level_root.add_child(p)
    var tw := p.create_tween()
    tw.set_parallel(true)
    tw.tween_property(p, "scale", Vector3.ONE * size, life)
    tw.tween_property(p, "position:y", pos.y + size * 0.6, life)
    tw.chain().tween_callback(p.queue_free)


func _spawn_interceptor(from_pos: Vector3, meet: Vector3, tm: float, dtype: int, success: bool) -> void:
    if dtype == 0:
        _ciws_burst(from_pos, meet, success)
        return
    var n := _interceptor_model(dtype)
    level_root.add_child(n)
    n.position = from_pos
    var aim_pt := meet
    if not success:
        aim_pt = meet + Vector3(randf_range(-1.0, 1.0), randf_range(-0.5, 1.0), randf_range(-1.0, 1.0)).normalized() * randf_range(7.0, 12.0)
    var dist := from_pos.distance_to(aim_pt)
    var ctrl := from_pos + Vector3(0.0, 8.0 + dist * 0.35, 0.0) + (aim_pt - from_pos) * 0.12
    # launch flash and a thick cloud of smoke at the launcher
    _explode(from_pos + Vector3(0.0, 1.0, 0.0), Color(1.0, 0.75, 0.35), 2.2)
    for k in range(5):
        _smoke_puff(from_pos + Vector3(randf_range(-1.5, 1.5), 0.5 + float(k) * 0.4, randf_range(-1.5, 1.5)), randf_range(2.0, 3.4), randf_range(1.4, 2.2))
    _play3d("launch", from_pos, 2.0, 1.5 + float(dtype) * 0.05)
    var tw := create_tween()
    tw.tween_method(_icp_step.bind(n, from_pos, ctrl, aim_pt), 0.0, 1.0, tm)
    tw.tween_callback(_icp_end.bind(n, aim_pt, success))


func _icp_step(t: float, n, p0: Vector3, c: Vector3, p2: Vector3) -> void:
    if n == null or not is_instance_valid(n):
        return
    var u := 1.0 - t
    var pos := u * u * p0 + 2.0 * u * t * c + t * t * p2
    var vel := 2.0 * u * (c - p0) + 2.0 * t * (p2 - c)
    n.position = pos
    if vel.length() > 0.01:
        var up := Vector3.UP
        if absf(vel.normalized().y) > 0.98:
            up = Vector3.RIGHT
        n.look_at(pos + vel, up)
    if randf() < 0.55:
        _smoke_puff(pos - vel.normalized() * 1.6, randf_range(0.9, 1.5), randf_range(0.9, 1.5))


func _icp_end(n, pos: Vector3, success: bool) -> void:
    if n != null and is_instance_valid(n):
        n.queue_free()
    if success:
        _explode(pos, Color(1.0, 0.85, 0.5), 3.4)
        _play3d("pop", pos, 6.0)
    else:
        _explode(pos, Color(0.9, 0.9, 0.9), 1.6)


func _ciws_burst(from_pos: Vector3, to_pos: Vector3, success: bool) -> void:
    # rapid-fire gun: a stream of glowing tracer rounds
    var dirv := (to_pos - from_pos)
    var dist := dirv.length()
    var dn := dirv.normalized()
    var tracer_col := Color(1.0, 0.85, 0.3)
    var tmat := _glow_mat(tracer_col)
    _play3d("launch", from_pos, 1.0, 2.4)
    for k in range(14):
        var tr := MeshInstance3D.new()
        var bm := BoxMesh.new()
        bm.size = Vector3(0.12, 0.12, 2.2)
        tr.mesh = bm
        tr.material_override = tmat
        tr.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        level_root.add_child(tr)
        tr.position = from_pos
        tr.visible = false
        var spread := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * (0.8 if success else 5.0)
        var tgt := to_pos + spread
        var tw := tr.create_tween()
        tw.tween_interval(0.035 * float(k))
        tw.tween_callback(func(): tr.visible = true)
        tw.tween_property(tr, "position", tgt, maxf(0.12, dist / 420.0))
        tw.tween_callback(tr.queue_free)
        tr.look_at_from_position(from_pos, tgt, Vector3.UP)
    # muzzle flash
    _explode(from_pos + dn * 2.0, Color(1.0, 0.8, 0.3), 1.2)
    if success:
        var tw2 := create_tween()
        tw2.tween_interval(0.035 * 14.0 + dist / 420.0)
        tw2.tween_callback(_explode.bind(to_pos, Color(1.0, 0.85, 0.5), 3.0))


func _build_jetcam_ui() -> void:
    jetcam_btn = _make_button("JET CAM", Color(0.75, 0.15, 0.15), _jetcam_toggle)
    jetcam_btn.custom_minimum_size = Vector2(190.0, 52.0)
    jetcam_btn.add_theme_font_size_override("font_size", 26)
    ui_root.add_child(jetcam_btn)
    jetcam_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
    jetcam_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    jetcam_btn.offset_top += 64.0
    jetcam_btn.offset_bottom += 64.0
    jetcam_btn.visible = false

    jetcam_layer = Control.new()
    jetcam_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(jetcam_layer)
    jetcam_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for top_bar in [true, false]:
        var bar := ColorRect.new()
        bar.color = Color(0.0, 0.0, 0.0, 0.9)
        bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        jetcam_layer.add_child(bar)
        if top_bar:
            bar.anchor_left = 0.0
            bar.anchor_right = 1.0
            bar.anchor_top = 0.0
            bar.anchor_bottom = 0.0
            bar.offset_left = 0.0
            bar.offset_right = 0.0
            bar.offset_top = 0.0
            bar.offset_bottom = 56.0
        else:
            bar.anchor_left = 0.0
            bar.anchor_right = 1.0
            bar.anchor_top = 1.0
            bar.anchor_bottom = 1.0
            bar.offset_left = 0.0
            bar.offset_right = 0.0
            bar.offset_top = -150.0
            bar.offset_bottom = 0.0
    var live := PanelContainer.new()
    _style_panel(live, Color(0.85, 0.08, 0.08, 0.95))
    live.mouse_filter = Control.MOUSE_FILTER_IGNORE
    jetcam_layer.add_child(live)
    live.position = Vector2(18.0, 64.0)
    jetcam_live = Label.new()
    jetcam_live.text = "LIVE"
    _style_text(jetcam_live, 30, Color(1.0, 1.0, 1.0))
    live.add_child(jetcam_live)
    var chan := Label.new()
    chan.text = "AIR CAM"
    _style_text(chan, 22, Color(0.8, 0.9, 1.0))
    chan.position = Vector2(130.0, 74.0)
    jetcam_layer.add_child(chan)
    jetcam_info = Label.new()
    jetcam_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    jetcam_info.custom_minimum_size = Vector2(900.0, 0.0)
    jetcam_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _style_text(jetcam_info, 30, Color(1.0, 1.0, 1.0))
    jetcam_layer.add_child(jetcam_info)
    jetcam_info.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 22)
    jetcam_info.offset_top -= 56.0
    jetcam_info.offset_bottom -= 56.0
    var nb := _make_button("NEXT JET", Color(0.1, 0.32, 0.95), _jetcam_next)
    nb.custom_minimum_size = Vector2(190.0, 56.0)
    nb.add_theme_font_size_override("font_size", 26)
    jetcam_layer.add_child(nb)
    nb.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 14)
    nb.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    nb.offset_left -= 210.0
    nb.offset_right -= 210.0
    var xb := _make_button("EXIT CAM", Color(0.6, 0.15, 0.15), _jetcam_exit)
    xb.custom_minimum_size = Vector2(190.0, 56.0)
    xb.add_theme_font_size_override("font_size", 26)
    jetcam_layer.add_child(xb)
    xb.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 14)
    xb.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    jetcam_panels = [jetcam_btn, nb, xb]
    jetcam_layer.visible = false


func _sortie_by_id(id: int) -> Dictionary:
    for sv in sorties:
        var so: Dictionary = sv
        if int(so["id"]) == id:
            return so
    return {}


func _jetcam_pick(after_id: int) -> int:
    if sorties.is_empty():
        return 0
    var ids: Array = []
    for sv in sorties:
        var so: Dictionary = sv
        if so["node"] != null and is_instance_valid(so["node"]):
            ids.append(int(so["id"]))
    if ids.is_empty():
        return 0
    var idx := ids.find(after_id)
    return int(ids[(idx + 1) % ids.size()])


func _jetcam_toggle() -> void:
    if jetcam_on:
        _jetcam_exit()
    else:
        _jetcam_enter()


func _jetcam_enter() -> void:
    if game_state != "playing" or sat_open or sorties.is_empty():
        return
    var id := _jetcam_pick(0)
    if id == 0:
        return
    _close_windows()
    jetcam_on = true
    jetcam_id = id
    jetcam_shot = 0
    jetcam_t = 0.0
    jetcam_fixed = Vector3.ZERO
    joy_id = -1
    look_id = -1
    joy_vec = Vector2.ZERO
    _reset_joystick()
    tabs_box.visible = false
    hot_box.visible = false
    stats_panel.visible = false
    joy_base.visible = false
    joy_knob.visible = false
    jetcam_layer.visible = true
    jetcam_btn.visible = false
    _play_ui("sat", -4.0)


func _jetcam_exit() -> void:
    if not jetcam_on:
        return
    jetcam_on = false
    camera.fov = 70.0
    jetcam_layer.visible = false
    if not sat_open:
        tabs_box.visible = true
        hot_box.visible = true
        stats_panel.visible = true
        joy_base.visible = true
        joy_knob.visible = true
    camera.position = _player_world() + Vector3(0.0, 6.0, 12.0)


func _jetcam_next() -> void:
    var id := _jetcam_pick(jetcam_id)
    if id != 0:
        jetcam_id = id
        jetcam_shot = 0
        jetcam_t = 0.0
        jetcam_fixed = Vector3.ZERO


func _jetcam_phase(so: Dictionary) -> String:
    var off: float = so["off"]
    if float(so["doom"]) >= 0.0:
        return "WARNING: SAM LOCK!"
    if off < float(so["taxi_end"]):
        return "TAXIING"
    if off < float(so["taxi_end"]) + 170.0:
        return "TAKE-OFF"
    if off < float(so["strike_off"]) - 110.0:
        return "TRANSIT TO TARGET"
    if off < float(so["strike_off"]) + 70.0:
        return "ATTACK RUN"
    if off < float(so["td"]) - 220.0:
        return "RETURNING HOME"
    if off < float(so["td"]):
        return "FINAL APPROACH"
    return "LANDING"


func _jetcam_update(delta: float) -> void:
    var so := _sortie_by_id(jetcam_id)
    if so.is_empty():
        var nid := _jetcam_pick(0)
        if nid == 0:
            _jetcam_exit()
            return
        jetcam_id = nid
        jetcam_t = 0.0
        jetcam_fixed = Vector3.ZERO
        so = _sortie_by_id(nid)
    var node: Node3D = so["node"]
    var pos := node.position
    var fwd := -node.global_transform.basis.z
    fwd.y = 0.0
    if fwd.length() < 0.01:
        fwd = Vector3(0.0, 0.0, -1.0)
    fwd = fwd.normalized()
    var rgt := Vector3(-fwd.z, 0.0, fwd.x) * -1.0
    jetcam_t += delta
    if jetcam_t > 5.0:
        jetcam_t = 0.0
        jetcam_shot = (jetcam_shot + 1) % 4
        jetcam_fixed = Vector3.ZERO
    var want := camera.position
    var look := pos
    var fov := 62.0
    if jetcam_shot == 0:
        want = pos - fwd * 15.0 + Vector3(0.0, 5.0, 0.0) + rgt * 3.0
        look = pos + fwd * 14.0
        want = camera.position.lerp(want, clampf(delta * 7.0, 0.0, 1.0))
    elif jetcam_shot == 1:
        if jetcam_fixed == Vector3.ZERO:
            jetcam_fixed = pos + fwd * 90.0 + rgt * 38.0
            jetcam_fixed.y = maxf(2.5, minf(pos.y - 10.0, 14.0))
        want = jetcam_fixed
        fov = 32.0
    elif jetcam_shot == 2:
        want = pos + fwd * 4.4 + Vector3(0.0, 1.5, 0.0)
        look = pos + fwd * 70.0
        fov = 82.0
    else:
        var ang := jetcam_t * 0.7
        want = pos + Vector3(cos(ang) * 26.0, 8.0, sin(ang) * 26.0)
        look = pos
        fov = 55.0
    want.y = maxf(want.y, 1.8)
    camera.position = want
    camera.fov = lerpf(camera.fov, fov, clampf(delta * 4.0, 0.0, 1.0))
    var upv := Vector3.UP
    camera.look_at(look, upv)
    var jt: int = so["jt"]
    var a: int = so["a"]
    var tg: int = so["tg"]
    var who := "YOUR" if a == 0 else "ENEMY %d" % a
    var dest := "TARGET: ENEMY %d" % tg if tg != 0 else "INBOUND TO YOUR ISLAND"
    var spd_kmh := int(_sortie_speed(so, float(so["off"])) * 9.0)
    var alt_m := int(maxf(0.0, pos.y - 1.0) * 40.0)
    jetcam_info.text = "%s  %s    %s\n%s   |   ALT %d m   |   SPEED %d km/h" % [who, JETS[jt]["name"], dest, _jetcam_phase(so), alt_m, spd_kmh]
    jetcam_live.modulate.a = 1.0 if int(jetcam_t * 2.0) % 2 == 0 else 0.55


func _jetcam_ui_tick() -> void:
    if jetcam_btn == null:
        return
    var any := false
    for sv in sorties:
        var so: Dictionary = sv
        if so["node"] != null and is_instance_valid(so["node"]):
            any = true
            break
    jetcam_btn.visible = any and not jetcam_on and not sat_open and game_state == "playing"
    if jetcam_on and not any:
        _jetcam_exit()


func _try_intercept(d: Dictionary, node: Node3D, t: float, dur: float, p0: Vector3, p1: Vector3, h: float) -> void:
    var target: int = d["target"]
    var wt: int = d["wt"]
    var te: Dictionary = emp[target]
    var structs: Array = te["structs"]
    var tried: Array = d["tried"]
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) != "defense" or str(s["state"]) != "ok":
            continue
        var sid: int = s["id"]
        if tried.has(sid):
            continue
        if int(s["mag"]) <= 0 or float(s["cd"]) > 0.0:
            continue
        var dpos := _struct_world(target, s)
        var dtype: int = s["sub"]
        var rng: float = DEFENSES[dtype]["range"]
        var flat := Vector2(node.position.x - dpos.x, node.position.z - dpos.z)
        if flat.length() > rng:
            continue
        tried.append(sid)
        s["mag"] = int(s["mag"]) - 1
        s["cd"] = float(DEFENSES[dtype]["cd"])
        var chance: float = DEF_TABLE[dtype][wt]
        var ok := randf() < chance
        # predict where the incoming missile will be and fly the interceptor there
        var from_p := dpos + Vector3(0.0, 4.0, 0.0)
        var vi: float = DEF_SPEED[dtype]
        var tm := from_p.distance_to(node.position) / vi
        for it in range(3):
            var ft := minf(t + tm / dur, 0.97)
            tm = from_p.distance_to(_arc(p0, p1, ft, h)) / vi
        var left := dur * (1.0 - t)
        tm = clampf(tm * 1.15, 0.7, maxf(0.7, left * 0.92))
        var meet := _arc(p0, p1, minf(t + tm / dur, 1.0), h)
        if dtype == 0:
            s["node"].rotation.y = atan2(-(meet.x - dpos.x), -(meet.z - dpos.z))
        _spawn_interceptor(from_p, meet, tm, dtype, ok)
        if ok:
            d["kill"] = tm
            return

