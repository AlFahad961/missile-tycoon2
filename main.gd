extends Node3D
## Missile Tycoon Islands 6.0
## WW3-Commander style island war. Builders auto-build and upgrade houses, repairmen fix wrecks,
## buy missiles and air defense in MILITARY, fire from the satellite view with 1x / 5x taps.
## Procedural sound, layered air defense, drones. (Godot 4.x, Compatibility renderer)
## Left half of the screen = floating joystick, right half = drag to look around.

const SAVE_PATH := "user://missile_tycoon_v6.json"
const SETTINGS_PATH := "user://settings_v1.json"
const PLOT_HALF := 50.0
const PLAYER_HALF := 47.0
const RING := [0.0, 0.0, 100.0, 115.0, 135.0]
const WALK_SPEED := 12.0
const MAX_HOUSES := 50
const MAX_DEFENSES := 30
const MAX_MISSILES := 100
const MAX_BUILDERS := 5
const MAX_BREP := 5
const MAX_AREP := 3
const MAX_LEVEL := 5
const START_MONEY := 600
const PEACE_TIME := 300.0
const SPACING := 7.0
const SAT_HEIGHT := 150.0
const BUILDER_PRICES := [500, 900, 1500, 2400, 3600]
const BREP_PRICES := [700, 1200, 1900, 2800, 4000]
const AREP_PRICES := [3000, 6000, 10000]
const BUILDER_UPGRADE := [2500, 8000, 25000, 80000]
const LOOK_SENS := [0.006, 0.010, 0.016]
const SENS_NAMES := ["LOW", "MEDIUM", "HIGH"]
const RATE := 16000

const TIME_HOUSE := 12.0
const TIME_UPGRADE := 9.0
const TIME_REPAIR := 12.0

const HOUSE_INCOME := [2, 6, 14, 30, 60]
const HOUSE_HP := [150.0, 250.0, 400.0, 600.0, 900.0]
const DEFENSE_HP := 220.0

const TEAM_COLORS := [
    Color(0.2, 0.55, 1.0),
    Color(0.9, 0.22, 0.2),
    Color(0.7, 0.3, 0.9),
    Color(1.0, 0.6, 0.1),
]

# Weapon index: 0 cruise, 1 ballistic, 2 hypersonic, 3 MIRV, 4 drone
# Weapon index: 0 cruise, 1 ballistic, 2 hypersonic, 3 MIRV, 4 drone
const MISSILES := [
    {"name": "Cruise Missile", "cls": "Tomahawk / Babur class", "short": "Cruise", "price": 300,
        "dmg": 55.0, "radius": 5.0, "speed": 45.0, "arc": 0.05, "cep": 3.0, "count": 1},
    {"name": "Ballistic Missile", "cls": "Iskander / Fateh class", "short": "Ballistic", "price": 900,
        "dmg": 110.0, "radius": 8.0, "speed": 75.0, "arc": 0.45, "cep": 5.0, "count": 1},
    {"name": "Hypersonic Missile", "cls": "Kinzhal / Fattah class", "short": "Hypersonic", "price": 2200,
        "dmg": 190.0, "radius": 6.0, "speed": 150.0, "arc": 0.12, "cep": 3.0, "count": 1},
    {"name": "MIRV Strategic", "cls": "Sarmat class, 3 warheads", "short": "MIRV", "price": 5000,
        "dmg": 80.0, "radius": 7.0, "speed": 110.0, "arc": 0.5, "cep": 14.0, "count": 3},
    {"name": "Kamikaze Drone", "cls": "Shahed class", "short": "Drone", "price": 120,
        "dmg": 40.0, "radius": 3.5, "speed": 24.0, "arc": 0.03, "cep": 6.0, "count": 1},
]


const DEFENSES := [
    {"name": "CIWS Gun", "cls": "Phalanx / Pantsir-gun class", "short": "CIWS", "price": 800, "range": 22.0,
        "cd": 1.2, "mag": 40, "ref": 2},
    {"name": "Iron Dome", "cls": "Iron Dome / Tor class, short range", "short": "Iron Dome", "price": 2500, "range": 45.0,
        "cd": 2.0, "mag": 20, "ref": 20},
    {"name": "HQ-9 / Patriot", "cls": "HQ-9 / Patriot class, medium range", "short": "HQ-9", "price": 6000, "range": 75.0,
        "cd": 3.0, "mag": 12, "ref": 60},
    {"name": "S-400", "cls": "S-400 class, long range", "short": "S-400", "price": 12000, "range": 110.0,
        "cd": 3.5, "mag": 10, "ref": 110},
    {"name": "THAAD / S-500", "cls": "THAAD / S-500 class, anti-ballistic", "short": "THAAD", "price": 22000, "range": 130.0,
        "cd": 4.5, "mag": 8, "ref": 200},
]


const DEF_TABLE := [
    [0.55, 0.05, 0.0, 0.0, 0.85],
    [0.75, 0.25, 0.05, 0.1, 0.9],
    [0.8, 0.6, 0.2, 0.35, 0.6],
    [0.85, 0.75, 0.45, 0.55, 0.5],
    [0.3, 0.9, 0.6, 0.7, 0.05],
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
    mat_cache[key] = m
    return m


func _glow_mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
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
    sky_mat.sky_top_color = Color(0.16, 0.42, 0.88)
    sky_mat.sky_horizon_color = Color(0.74, 0.88, 0.98)
    sky_mat.ground_horizon_color = Color(0.74, 0.88, 0.98)
    sky_mat.ground_bottom_color = Color(0.3, 0.55, 0.78)
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.82, 0.9, 1.0)
    env.ambient_light_energy = 0.8
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.fog_enabled = true
    env.fog_light_color = Color(0.74, 0.88, 0.98)
    env.fog_density = 0.0012
    var we := WorldEnvironment.new()
    we.environment = env
    add_child(we)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48.0, -35.0, 0.0)
    sun.light_energy = 1.3
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 90.0
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
    for k in range(12):
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
        "money": START_MONEY, "builders": 0, "brep": 0, "arep": 0, "blevel": 1,
        "structs": [], "jobs": [],
        "ammo": [0, 0, 0, 0, 0], "aggr": aggr, "grudge": -1, "phase": "build",
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
    player_off = Vector3(0.0, 0.0, 5.0)


func _house_pos(slot: int) -> Vector2:
    var col := slot % 10
    var row := int(slot / 10)
    return Vector2(-45.0 + float(col) * 5.0, 12.0 + float(row) * 6.0)


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
        _sync_missiles(i)
        if bool(e["dead"]):
            var dead: Node3D = island_nodes[i]
            dead.position.y = -8.0

    _ensure_target()
    _update_rings()
    _look_at_target(false)


func _make_island(i: int, p: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Island_%d" % i
    root.position = p
    root.rotation.y = _yaw_to(-p)
    var team := _team(i)
    var side := PLOT_HALF * 2.0
    # team-coloured rim, then a checkered grass baseplate on top (completely empty)
    _box(root, Vector3(side + 4.0, 1.2, side + 4.0), Vector3(0.0, -0.3, 0.0), team.darkened(0.25))
    var top := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = Vector3(side, 0.3, side)
    top.mesh = bm
    top.position = Vector3(0.0, 0.45, 0.0)
    top.material_override = _checker_mat(i)
    root.add_child(top)
    # grey military apron behind the houses (missiles and air defense stand here)
    _box(root, Vector3(side - 4.0, 0.06, 50.0), Vector3(0.0, 0.63, -23.0), Color(0.34, 0.36, 0.41))
    var lab := Label3D.new()
    lab.text = "YOU" if i == 0 else "ENEMY %d" % i
    lab.font_size = 72
    lab.pixel_size = 0.08
    lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    lab.no_depth_test = true
    lab.render_priority = 3
    lab.outline_size = 16
    lab.modulate = team.lightened(0.3)
    lab.position = Vector3(0.0, 30.0, 0.0)
    root.add_child(lab)
    return root


# =====================================================================
# Structures: visuals
# =====================================================================
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
        var floors := lvl + 1
        var fh := 0.7
        var body := Color(0.27, 0.34, 0.5).lerp(color, 0.15)
        var total := fh * float(floors)
        _box(n, Vector3(1.3, total, 1.1), Vector3(0.0, 0.1 + total * 0.5, 0.0), body)
        for f2 in range(floors):
            var y2 := 0.1 + fh * (float(f2) + 0.55)
            for sx2 in [-0.38, 0.0, 0.38]:
                var wm2 := _box(n, Vector3(0.22, 0.28, 0.05), Vector3(sx2, y2, -0.57), Color.WHITE)
                wm2.material_override = glow
        var cap := _box(n, Vector3(1.4, 0.16, 1.2), Vector3(0.0, 0.1 + total + 0.08, 0.0), Color.WHITE)
        cap.material_override = _glow_mat(Color(1.0, 0.3, 0.85) if lvl >= 4 else Color(0.3, 0.8, 1.0))
        _cyl(n, 0.03, 0.03, 0.6, Vector3(0.0, total + 0.5, 0.0), Color(0.6, 0.6, 0.65))


func _defense_model(n: Node3D, t: int, team: Color) -> void:
    var gray := Color(0.35, 0.38, 0.4)
    var white := Color(0.9, 0.92, 0.95)
    if t == 0:
        _cyl(n, 0.6, 0.75, 0.6, Vector3(0.0, 0.3, 0.0), gray)
        _sphere(n, 0.5, Vector3(0.0, 0.85, 0.0), white)
        _box(n, Vector3(0.14, 0.14, 1.1), Vector3(0.0, 0.95, -0.6), Color(0.2, 0.2, 0.22))
    elif t == 1:
        _box(n, Vector3(1.4, 0.5, 2.0), Vector3(0.0, 0.45, 0.0), Color(0.3, 0.38, 0.28))
        for k in range(3):
            var c1 := _cyl(n, 0.14, 0.14, 1.4, Vector3((float(k) - 1.0) * 0.5, 1.1, 0.0), white)
            c1.rotation.x = deg_to_rad(-60.0)
        _box(n, Vector3(0.9, 0.9, 0.15), Vector3(-1.0, 1.0, 0.9), gray)
    elif t == 2:
        _box(n, Vector3(1.6, 0.4, 2.6), Vector3(0.0, 0.35, 0.0), Color(0.28, 0.33, 0.3))
        for k in range(4):
            var x2: float = (float(k % 2) - 0.5) * 0.8
            var z2: float = (float(int(k / 2)) - 0.5) * 0.9
            var c2 := _cyl(n, 0.15, 0.15, 1.7, Vector3(x2, 1.0, z2), white)
            c2.rotation.x = deg_to_rad(-65.0)
        _cyl(n, 0.08, 0.08, 1.8, Vector3(-1.1, 1.2, 1.0), gray)
        _box(n, Vector3(0.9, 0.6, 0.1), Vector3(-1.1, 2.2, 1.0), gray)
    elif t == 3:
        _box(n, Vector3(2.0, 0.5, 3.2), Vector3(0.0, 0.4, 0.0), Color(0.25, 0.3, 0.28))
        for k in range(6):
            var x3: float = (float(k % 3) - 1.0) * 0.55
            var z3: float = (float(int(k / 3)) - 0.5) * 0.9
            var c3 := _cyl(n, 0.16, 0.16, 2.0, Vector3(x3, 1.2, z3), white)
            c3.rotation.x = deg_to_rad(-70.0)
        _cyl(n, 0.1, 0.1, 2.6, Vector3(1.2, 1.5, 1.2), gray)
        var dish3 := _sphere(n, 0.7, Vector3(1.2, 2.9, 1.2), white)
        dish3.scale = Vector3(1.0, 0.25, 1.0)
    else:
        _box(n, Vector3(2.4, 0.5, 3.6), Vector3(0.0, 0.4, 0.0), Color(0.22, 0.27, 0.25))
        for k in range(8):
            var x4: float = (float(k % 4) - 1.5) * 0.5
            var z4: float = (float(int(k / 4)) - 0.5) * 1.0
            var c4 := _cyl(n, 0.18, 0.18, 2.4, Vector3(x4, 1.4, z4), white)
            c4.rotation.x = deg_to_rad(-72.0)
        _box(n, Vector3(1.6, 1.8, 0.2), Vector3(0.0, 1.6, 2.2), gray)
        _box(n, Vector3(1.2, 1.2, 0.1), Vector3(0.0, 1.6, 2.35), Color(0.3, 0.7, 0.9))
    _sphere(n, 0.14, Vector3(0.0, 0.1, 0.0), team)


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
        s["bs"] = 2.2
    else:
        _defense_model(node, sub, team)
        var dscale := [1.4, 1.7, 2.0, 2.4, 2.8]
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
            ch.position = Vector3(12.0 + float(k) * 4.0, 0.6, 14.0 + float(kind) * 7.0)
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


func _do_buy_missile(i: int, t: int, n: int = 1) -> int:
    var e: Dictionary = emp[i]
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
    return "Nothing to do for %s." % what


const AI_PAD_UNLOCK := [0.0, 120.0, 330.0, 650.0, 30.0]
const AI_PAD_ORDER := [0, 4, 1, 2, 3]


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
    if nb < 2 and elapsed > 45.0:
        if _do_hire(i, "builder") == 0:
            return
    # 2. a repair crew once something is broken (or after a while)
    var hurt := _count_destroyed(i) > 0 or _damaged_count(i) > 0
    if int(e["brep"]) < 1 and (hurt or elapsed > 160.0):
        if _do_hire(i, "brep") == 0:
            return
    # 3. build a stockpile before the war starts
    if elapsed > 150.0 and _ammo_total(i) < int(e["salvo"]):
        var mt0 := _ai_pick_weapon(i)
        if mt0 >= 0 and _do_buy_missile(i, mt0) == 0:
            return
    # 4. air defense grows with time (cautious rivals build earlier)
    var want_def := mini(MAX_DEFENSES, int((elapsed - 60.0) / 70.0) + (1 if aggr < 0.5 else 0))
    if defs_all < want_def:
        var tier := mini(4, int(elapsed / 220.0))
        var dt := -1
        for t2 in range(tier, -1, -1):
            if money_i >= int(DEFENSES[t2]["price"]):
                dt = t2
                break
        if dt >= 0:
            if _do_buy_defense(i, dt) == 0:
                return
    if int(e["arep"]) < 1 and defs_all >= 2:
        if _do_hire(i, "arep") == 0:
            return
    # 5. better builders = better houses = more money
    if lvl < MAX_LEVEL and elapsed > 80.0 * float(lvl):
        var need := int(float(BUILDER_UPGRADE[lvl - 1]) * 1.2)
        if money_i >= need:
            if _do_upgrade_builder(i) == 0:
                return
    # 6. more crews as the game goes on
    var goal_b := mini(MAX_BUILDERS, 2 + int(elapsed / 150.0))
    if nb < goal_b and money_i >= int(float(_worker_price(i, "builder")) * 1.2):
        if _do_hire(i, "builder") == 0:
            return
    var goal_r := mini(MAX_BREP, 1 + int(elapsed / 300.0))
    if int(e["brep"]) < goal_r and money_i >= int(float(_worker_price(i, "brep")) * 1.5):
        if _do_hire(i, "brep") == 0:
            return
    # 7. keep stockpiling weapons for the next salvo
    if _ammo_total(i) < int(e["salvo"]) + 3:
        var mt := _ai_pick_weapon(i)
        if mt >= 0:
            _do_buy_missile(i, mt)


func _damaged_count(i: int) -> int:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var n := 0
    for sv in structs:
        var s: Dictionary = sv
        if str(s["state"]) == "ok" and float(s["hp"]) < float(s["maxhp"]) - 0.5:
            n += 1
    return n


func _ai_pick_weapon(i: int) -> int:
    var e: Dictionary = emp[i]
    if _ammo_total(i) >= MAX_MISSILES:
        return -1
    var options: Array = []
    for t in AI_PAD_ORDER:
        if elapsed < float(AI_PAD_UNLOCK[t]):
            continue
        if int(e["money"]) < int(MISSILES[t]["price"]):
            continue
        options.append(t)
    if options.is_empty():
        return -1
    if options.size() > 1 and randf() < 0.65:
        return int(options[options.size() - 1])
    return int(options[randi() % options.size()])


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
    for t in range(5):
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
    var aggr: float = e["aggr"]
    var base_rest := randf_range(70.0, 115.0) * (1.3 - 0.6 * aggr)
    e["rest"] = base_rest * maxf(0.55, 1.0 - elapsed / 1500.0)
    e["salvo"] = randi_range(5, 8) + int(elapsed / 240.0)
    e["grudge"] = target
    if target == 0 and fired > 0:
        _say("WARNING! Enemy %d launched %d missiles/drones at you!" % [i, fired])
        _play_ui("siren", -3.0)



# =====================================================================
# Combat: launch queue, flight, air defense, blasts, collapse
# =====================================================================
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
        _spawn_missile(int(q["a"]), int(q["tg"]), int(q["t"]), q["aim"])


func _make_missile_model(friendly: bool, mtype: int, with_trail: bool = true) -> Node3D:
    var root := Node3D.new()
    var model := Node3D.new()
    var sc: float = [2.2, 2.8, 2.6, 3.0, 2.2][mtype]
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
    var from_pos := _take_missile_pos(attacker, t) + Vector3(0.0, 4.0, 0.0)
    var warheads: int = info["count"]
    var cep: float = info["cep"]
    var isl_t := _isl(target)
    for w in range(warheads):
        var lp := aim_local + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * cep
        lp.x = clampf(lp.x, -48.0, 48.0)
        lp.y = clampf(lp.y, -48.0, 48.0)
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
        if dur * (1.0 - t) < 0.5:
            continue
        _try_intercept(d, node, t, dur, p0, p1, h)


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
        var meet := _arc(p0, p1, minf(t + 0.3 / dur, 1.0), h)
        _spawn_interceptor(dpos + Vector3(0.0, 5.0, 0.0), meet, ok)
        if ok:
            d["kill"] = 0.3
            return


func _on_impact(d: Dictionary) -> void:
    var target: int = d["target"]
    var attacker: int = d["attacker"]
    var wt: int = d["wt"]
    var lp: Vector2 = d["lp"]
    var info: Dictionary = MISSILES[wt]
    var pos: Vector3 = d["end"]
    var sizes := [4.0, 5.5, 5.0, 4.5, 2.4]
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
    _apply_blast(target, lp, float(info["radius"]), float(info["dmg"]), attacker)
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


func _spawn_interceptor(from_pos: Vector3, to_pos: Vector3, success: bool) -> void:
    var n := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 0.8
    sm.height = 1.6
    n.mesh = sm
    n.material_override = _glow_mat(Color(0.5, 0.95, 1.0))
    n.position = from_pos
    level_root.add_child(n)
    _add_trail(n, 0.7)
    _play3d("blip", from_pos, 0.0)
    var tw := create_tween()
    tw.tween_property(n, "position", to_pos, 0.35)
    if not success:
        tw.tween_callback(_explode.bind(to_pos, Color(0.9, 0.9, 0.9), 1.2))
    tw.tween_callback(n.queue_free)


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
    _close_windows()
    _ensure_target()
    sat_open = true
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
    sat_drag_id = -1
    camera.fov = 70.0
    _remove_sat_marker()
    _update_rings()
    _sat_ui_show(false)
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
    return Vector2(clampf(local.x, -48.0, 48.0), clampf(local.z, -48.0, 48.0))


func _sat_set_point(pos: Vector2) -> void:
    sat_local = _sat_screen_to_local(pos)
    sat_has_point = true
    _update_sat_marker()
    _refresh_sat()


func _sat_blast_radius() -> float:
    var info: Dictionary = MISSILES[sat_type]
    return maxf(4.0, float(info["radius"]) + float(info["cep"]) * 0.5)


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
        arr.append({
            "money": e["money"], "builders": e["builders"], "brep": e["brep"], "arep": e["arep"],
            "blevel": e["blevel"], "ammo": e["ammo"], "aggr": e["aggr"], "grudge": e["grudge"],
            "salvo": e["salvo"], "rest": e["rest"], "dead": e["dead"], "structs": sl,
        })
    var data := {
        "v": 6, "island_count": island_count, "emp": arr,
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
    if int(parsed.get("v", 0)) != 6:
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
        for t in range(5):
            ammo[t] = int(am[t]) if t < am.size() else 0
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
    lp.add_theme_constant_override("separation", 6)
    lp.position = Vector2(12.0, 70.0)
    sat_root.add_child(lp)
    sat_panels.append(lp)
    sat_type_btns = []
    for t in range(5):
        var tb := Button.new()
        tb.custom_minimum_size = Vector2(310.0, 78.0)
        _style_button(tb, Color(0.07, 0.12, 0.2, 0.88))
        for stn in ["normal", "hover", "pressed", "disabled", "focus"]:
            var sbx: StyleBoxFlat = tb.get_theme_stylebox(stn)
            sbx.content_margin_left = 84.0
        tb.alignment = HORIZONTAL_ALIGNMENT_LEFT
        tb.add_theme_font_size_override("font_size", 20)
        tb.pressed.connect(_play_ui.bind("click", -8.0))
        tb.pressed.connect(_sat_set_type.bind(t))
        var ic := MiniIcon.new()
        ic.kind = 0
        ic.sub = t
        ic.position = Vector2(8.0, 7.0)
        ic.size = Vector2(64.0, 64.0)
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
    sat_root.visible = false


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


func _refresh_sat() -> void:
    if sat_root == null or emp.is_empty():
        return
    var e: Dictionary = emp[0]
    var ammo: Array = e["ammo"]
    sat_money.text = "$ %s" % _fmt_money(int(e["money"]))
    sat_title.text = "SELECT TARGET  -  ENEMY %d" % sat_island
    for t in range(5):
        var b: Button = sat_type_btns[t]
        var info: Dictionary = MISSILES[t]
        b.text = "%s\nDMG %d      x%d" % [info["short"], int(float(info["dmg"]) * float(info["count"])), int(ammo[t])]
        if t == sat_type:
            b.modulate = Color(1.0, 1.0, 1.0)
        elif int(ammo[t]) > 0:
            b.modulate = Color(0.72, 0.72, 0.78)
        else:
            b.modulate = Color(0.45, 0.45, 0.5)
    for k in range(sat_island_btns.size()):
        var ib: Button = sat_island_btns[k]
        var idx := k + 1
        if idx >= island_count:
            ib.visible = false
            continue
        ib.visible = true
        var te: Dictionary = emp[idx]
        ib.disabled = bool(te["dead"])
        ib.modulate = Color(1.0, 1.0, 1.0) if idx == sat_island else Color(0.7, 0.7, 0.7)


# =====================================================================
# Window and hotbar logic
# =====================================================================


func _refresh_ui() -> void:
    if money_label == null or emp.is_empty():
        return
    var e: Dictionary = emp[0]
    var money: int = e["money"]
    var ammo: Array = e["ammo"]
    var total := _ammo_total(0)
    stat_missile.text = "Missiles   %d/%d" % [total, MAX_MISSILES]
    stat_aa.text = "Air defense   %d/%d" % [_count_structs(0, "defense", -1, true), MAX_DEFENSES]
    stat_house.text = "Houses   %d/%d" % [_count_structs(0, "house", -1, true), MAX_HOUSES]
    money_label.text = "$ %s" % _fmt_money(money)
    income_label.text = "%s/s" % _fmt_money(_income(0))
    if elapsed < PEACE_TIME:
        var left := int(PEACE_TIME - elapsed)
        stats_label.text = "Peace time  %d:%02d" % [int(left / 60), left % 60]
    else:
        stats_label.text = "WAR! Rivals can attack"

    # military window
    for t in range(5):
        var c: Dictionary = cards_missile[t]
        var m: Dictionary = MISSILES[t]
        var price: int = m["price"]
        var info: Label = c["info"]
        info.text = "DMG %d\nRadius %d    Evade %d%%\nOwned: %d" % [int(float(m["dmg"]) * float(m["count"])), int(m["radius"]), _evade(t), int(ammo[t])]
        var b1: Button = c["b1"]
        var b5: Button = c["b5"]
        b1.text = "$%s   X1" % _fmt_money(price)
        b5.text = "$%s   X5" % _fmt_money(price * 5)
        b1.disabled = money < price or total >= MAX_MISSILES
        b5.disabled = money < price * 5 or total + 5 > MAX_MISSILES
    for t2 in range(5):
        var c2: Dictionary = cards_aa[t2]
        var d: Dictionary = DEFENSES[t2]
        var dprice: int = d["price"]
        var info2: Label = c2["info"]
        info2.text = "Range %d    Shots %d\nReload %.1fs    Refill $%d\nOwned: %d" % [int(d["range"]), int(d["mag"]), float(d["cd"]), int(d["ref"]), _count_structs(0, "defense", t2, false)]
        var db: Button = c2["b1"]
        db.text = "$%s   BUY" % _fmt_money(dprice)
        db.disabled = money < dprice or _count_structs(0, "defense", -1, false) >= MAX_DEFENSES

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


# =====================================================================
# Touch helpers
# =====================================================================


func _over_ui(pos: Vector2) -> bool:
    for c in [stats_panel, tabs_box, hot_box, menu_btn, mil_panel, work_panel, overlay]:
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


func _def_pos(slot: int) -> Vector2:
    var col := slot % 10
    var row := int(slot / 10)
    return Vector2(-45.0 + float(col) * 10.0, -4.0 - float(row) * 7.0)


func _missile_pos(slot: int) -> Vector2:
    var col := slot % 25
    var row := int(slot / 25)
    return Vector2(-46.0 + float(col) * 3.8, -26.0 - float(row) * 4.5)


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


func _free_def_slot(i: int) -> int:
    var e: Dictionary = emp[i]
    var structs: Array = e["structs"]
    var used := {}
    for sv in structs:
        var s: Dictionary = sv
        if str(s["kind"]) == "defense":
            used[int(s["slot"])] = true
    for slot in range(MAX_DEFENSES):
        if not used.has(slot):
            return slot
    return -1


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


func _do_buy_defense(i: int, t: int) -> int:
    var e: Dictionary = emp[i]
    if _count_structs(i, "defense", -1, false) >= MAX_DEFENSES:
        return 2
    var price: int = DEFENSES[t]["price"]
    if int(e["money"]) < price:
        return 1
    var slot := _free_def_slot(i)
    if slot < 0:
        return 2
    e["money"] = int(e["money"]) - price
    var dp := _def_pos(slot)
    var s := _add_struct(i, "defense", t, dp.x, dp.y, "ok", slot)
    _spawn_struct_node(i, s, 1.2)
    _refresh_struct_label(i, s)
    if i == 0:
        _play_ui("hammer", -2.0)
    return 0


# ---------- automatic workers ----------


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


func _sync_missiles(i: int) -> void:
    var e: Dictionary = emp[i]
    var ammo: Array = e["ammo"]
    var nodes: Array = e["mnodes"]
    var used := {}
    for nv in nodes:
        var nd: Dictionary = nv
        used[int(nd["slot"])] = true
    var cursor := 0
    for t in range(5):
        var have := 0
        for nv2 in nodes:
            var nd2: Dictionary = nv2
            if int(nd2["t"]) == t:
                have += 1
        while have < int(ammo[t]):
            while cursor < MAX_MISSILES and used.has(cursor):
                cursor += 1
            if cursor >= MAX_MISSILES:
                return
            used[cursor] = true
            var mp := _missile_pos(cursor)
            var m := _make_missile_model(i == 0, t, false)
            if t < 4:
                m.rotation.x = PI / 2.0
                m.position = Vector3(mp.x, 2.7, mp.y)
            else:
                m.position = Vector3(mp.x, 1.4, mp.y)
            m.scale = Vector3.ONE * 0.9
            _isl(i).add_child(m)
            nodes.append({"t": t, "slot": cursor, "node": m})
            have += 1


func _take_missile_pos(i: int, t: int) -> Vector3:
    var e: Dictionary = emp[i]
    var nodes: Array = e["mnodes"]
    for k in range(nodes.size() - 1, -1, -1):
        var nd: Dictionary = nodes[k]
        if int(nd["t"]) != t:
            continue
        nodes.remove_at(k)
        var nn = nd["node"]
        if nn != null and is_instance_valid(nn):
            var n3: Node3D = nn
            var p := n3.global_position
            n3.queue_free()
            return p
        break
    return _isl(i).to_global(Vector3(0.0, 3.0, -30.0))


func _rebuild_node(i: int, s: Dictionary, anim: float) -> void:
    var old = s["node"]
    if old != null and is_instance_valid(old):
        var o: Node3D = old
        o.queue_free()
    s["node"] = null
    _spawn_struct_node(i, s, anim)


func _open_sat_with(t: int) -> void:
    _open_sat()
    if sat_open:
        sat_type = t
        _refresh_sat()


func _sat_tap(pos: Vector2) -> void:
    if game_state != "playing" or not sat_open or sat_cool > 0.0:
        return
    var e: Dictionary = emp[0]
    var ammo: Array = e["ammo"]
    var have: int = ammo[sat_type]
    sat_local = _sat_screen_to_local(pos)
    sat_has_point = true
    _update_sat_marker()
    if have < 1:
        _play_ui("error")
        _say("No %s left. Buy more in MILITARY, or pick another weapon." % MISSILES[sat_type]["short"])
        _refresh_sat()
        return
    var n := mini(sat_mult, have)
    var delay := 0.0
    for k in range(n):
        _queue_launch(0, sat_island, sat_type, sat_local, delay)
        delay += 0.14
    ammo[sat_type] = have - n
    sat_cool = 0.22
    _say("%d x %s launched at Enemy %d!" % [n, MISSILES[sat_type]["short"], sat_island])
    _vibrate(40)
    _refresh_sat()
    _refresh_ui()


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


func _build_hotbar() -> void:
    hot_box = HBoxContainer.new()
    hot_box.add_theme_constant_override("separation", 6)
    ui_root.add_child(hot_box)
    var bag := Button.new()
    bag.custom_minimum_size = Vector2(74.0, 74.0)
    _style_button(bag, Color(0.14, 0.18, 0.26, 0.9))
    var bi := MiniIcon.new()
    bi.kind = 6
    bag.add_child(bi)
    bi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
    hot_box.add_child(bag)
    hot_slots = []
    for k in range(10):
        var d := _make_slot(k)
        var sb: Button = d["btn"]
        hot_box.add_child(sb)
        hot_slots.append(d)
    hot_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 6)
    hot_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
    hot_box.grow_vertical = Control.GROW_DIRECTION_BEGIN


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
        tb.custom_minimum_size = Vector2(220.0, 54.0)
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


func _evade(t: int) -> int:
    var sum := 0.0
    for d in range(5):
        sum += float(DEF_TABLE[d][t])
    return int(round((1.0 - sum / 5.0) * 100.0))


func _build_military_window() -> void:
    mil_tab_btns = []
    var w := _make_window(["MISSILE", "ANTI - AIR"], _mil_tab, mil_tab_btns)
    mil_panel = w["panel"]
    var v: VBoxContainer = w["vbox"]
    var gm := _make_grid(v)
    mil_body_missile = gm.get_parent()
    cards_missile = []
    for t in range(5):
        var m: Dictionary = MISSILES[t]
        var c := _make_card(0, t, str(m["name"]), [
            "DMG %d" % int(float(m["dmg"]) * float(m["count"])),
            "Radius %d    Evade %d%%" % [int(m["radius"]), _evade(t)],
            str(m["cls"])],
            _ui_buy_missile.bind(t, 1), _ui_buy_missile.bind(t, 5))
        gm.add_child(c["card"])
        cards_missile.append(c)
    var ga := _make_grid(v)
    mil_body_aa = ga.get_parent()
    cards_aa = []
    for t in range(5):
        var d: Dictionary = DEFENSES[t]
        var c2 := _make_card(1, t, str(d["name"]), [
            "Range %d    Shots %d" % [int(d["range"]), int(d["mag"])],
            "Reload %.1fs    Refill $%d" % [float(d["cd"]), int(d["ref"])],
            str(d["cls"])],
            _ui_buy_def.bind(t), Callable())
        ga.add_child(c2["card"])
        cards_aa.append(c2)
    mil_body_aa.hide()


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


func _mil_tab(k: int) -> void:
    mil_tab = k
    mil_body_missile.visible = k == 0
    mil_body_aa.visible = k == 1
    _tab_style(mil_tab_btns, k)


func _work_tab(k: int) -> void:
    work_tab = k
    work_body_hire.visible = k == 0
    work_body_up.visible = k == 1
    _tab_style(work_tab_btns, k)


func _on_hot_slot(idx: int) -> void:
    if game_state != "playing" or idx >= hot_items.size():
        return
    var it: Dictionary = hot_items[idx]
    if str(it["k"]) == "m":
        _open_sat_with(int(it["t"]))
    else:
        _say("%s x%d on your island. Air defense shoots incoming missiles by itself." % [DEFENSES[int(it["t"])]["short"], int(it["n"])])


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


func _refresh_hotbar() -> void:
    var e: Dictionary = emp[0]
    var ammo: Array = e["ammo"]
    hot_items = []
    for t in range(5):
        if int(ammo[t]) > 0:
            hot_items.append({"k": "m", "t": t, "n": int(ammo[t])})
    for t2 in range(5):
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
            ic.kind = 0 if str(it["k"]) == "m" else 1
            ic.sub = int(it["t"])
            ic.queue_redraw()
            lbl.text = "x%d" % int(it["n"])
        else:
            ic.visible = false
            lbl.text = ""
            b.visible = idx < 8
