extends Node3D
## Missile Tycoon Islands 3.0
## Airport-sized islands, layered air defense, modern missiles and AI rivals that
## start from zero just like the player. (Godot 4.x, Compatibility renderer)
## Left half of the screen = floating joystick, right half = drag to look around.

const SAVE_PATH := "user://missile_tycoon_v3.json"
const ISLAND_R := 24.0
const RING := [0.0, 0.0, 55.0, 60.0, 72.0]
const WALK_SPEED := 9.0
const PLAYER_LIMIT := 22.0
const MAX_HOUSES := 18
const MAX_DEFENSES := 10
const PRICE_REPAIR := 100
const START_MONEY := 400
const LAUNCH_PRICES := [250, 500, 1000, 1800]
const TEAM_COLORS := [
    Color(0.2, 0.55, 1.0),
    Color(0.9, 0.22, 0.2),
    Color(0.7, 0.3, 0.9),
    Color(1.0, 0.6, 0.1),
]
const MISSILES := [
    {"name": "Cruise Missile", "cls": "Tomahawk class", "short": "Cruise", "price": 60, "dmg": 15,
        "speed": 38.0, "arc": 0.05, "resist": 1.0, "warheads": 1, "cool": 1.3},
    {"name": "Ballistic Missile", "cls": "Iskander class", "short": "Ballistic", "price": 150, "dmg": 30,
        "speed": 55.0, "arc": 0.45, "resist": 0.75, "warheads": 1, "cool": 2.2},
    {"name": "Hypersonic Missile", "cls": "Zircon / Kinzhal class", "short": "Hyper", "price": 320, "dmg": 45,
        "speed": 110.0, "arc": 0.12, "resist": 0.35, "warheads": 1, "cool": 3.5},
    {"name": "MIRV Strategic", "cls": "Sarmat class, 3 warheads", "short": "MIRV", "price": 650, "dmg": 26,
        "speed": 85.0, "arc": 0.55, "resist": 0.5, "warheads": 3, "cool": 5.0},
]
const DEFENSES := [
    {"name": "CIWS Gun", "cls": "Phalanx class", "price": 150, "range": 16.0, "chance": 0.6},
    {"name": "Short-Range SAM", "cls": "Pantsir / Tor class", "price": 300, "range": 30.0, "chance": 0.6},
    {"name": "Medium-Range SAM", "cls": "NASAMS / Patriot class", "price": 600, "range": 50.0, "chance": 0.7},
    {"name": "Long-Range SAM", "cls": "S-400 / THAAD class", "price": 1200, "range": 85.0, "chance": 0.8},
]

# ---- game state ----
var emp: Array = []  # one Dictionary per island; index 0 = the player
var island_count := 2
var island_hp: Array = [100, 100]
var selected_enemy := 1
var cur_ammo := 0
var game_state := "menu"  # menu, playing, paused, won, lost
var elapsed := 0.0
var income_timer := 0.0
var placing_type := -1

# ---- world ----
var level_root: Node3D
var camera: Camera3D
var island_nodes: Array = []
var island_pos: Array = []
var island_labels: Array = []
var launcher_pivots: Array = []
var npcs: Array = []
var clouds: Array = []
var projectiles: Array = []
var place_ring: MeshInstance3D
var player: Node3D
var player_off := Vector3(0.0, 0.0, 2.0)
var walk_amount := 0.0
var walk_phase := 0.0
var mat_cache := {}

# ---- camera ----
var cam_yaw := 0.0
var cam_pitch := 0.38
var cam_dist := 11.0
var cam_goal := 0.0
var cam_auto := 0.0

# ---- touch ----
var joy_id := -1
var joy_center := Vector2.ZERO
var joy_vec := Vector2.ZERO
var look_id := -1

# ---- ui ----
var ui_root: Control
var hud_panel: PanelContainer
var top_right: VBoxContainer
var bottom_right: VBoxContainer
var build_panel: PanelContainer
var place_bar: HBoxContainer
var overlay: Panel
var money_label: Label
var stats_label: Label
var status_label: Label
var target_button: Button
var build_toggle: Button
var ammo_button: Button
var fire_button: Button
var btn_house: Button
var btn_repair: Button
var btn_launcher: Button
var btn_missiles: Array = []
var btn_defenses: Array = []
var joy_base: Panel
var joy_knob: Panel
var ov_title: Label
var ov_sub: Label
var btn_resume: Button
var btn_continue: Button
var btn_place: Button


func _ready() -> void:
    randomize()
    _build_environment()
    _build_ui()
    _reset_state(2)
    _build_world()
    get_viewport().size_changed.connect(_reset_joystick)
    _show_overlay("MISSILE TYCOON", "Start from zero. Build houses, a launcher, missiles and air defense. Your rivals do the same!")
    _refresh_ui()


# =====================================================================
# Helpers
# =====================================================================
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


func _ammo_total(e: Dictionary) -> int:
    var a: Array = e["ammo"]
    var n := 0
    for v in a:
        n += int(v)
    return n


func _income(i: int) -> int:
    var e: Dictionary = emp[i]
    return 15 + int(e["houses"]) * 6


func _house_price(i: int) -> int:
    var e: Dictionary = emp[i]
    return 100 + int(e["houses"]) * 15


# =====================================================================
# Environment (sky, sun, water, clouds, camera)
# =====================================================================
func _build_environment() -> void:
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.2, 0.48, 0.9)
    sky_mat.sky_horizon_color = Color(0.72, 0.87, 0.98)
    sky_mat.ground_horizon_color = Color(0.72, 0.87, 0.98)
    sky_mat.ground_bottom_color = Color(0.3, 0.55, 0.78)
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.82, 0.9, 1.0)
    env.ambient_light_energy = 0.75
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.fog_enabled = true
    env.fog_light_color = Color(0.72, 0.87, 0.98)
    env.fog_density = 0.0022
    var we := WorldEnvironment.new()
    we.environment = env
    add_child(we)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50.0, -35.0, 0.0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 80.0
    add_child(sun)

    var water := MeshInstance3D.new()
    var pm := PlaneMesh.new()
    pm.size = Vector2(3000.0, 3000.0)
    water.mesh = pm
    water.position.y = -0.45
    var wm := StandardMaterial3D.new()
    wm.albedo_color = Color(0.1, 0.5, 0.82)
    wm.roughness = 0.12
    wm.metallic = 0.1
    water.material_override = wm
    water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(water)

    var cloud_mat := StandardMaterial3D.new()
    cloud_mat.albedo_color = Color(1.0, 1.0, 1.0)
    cloud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    for k in range(10):
        var c := Node3D.new()
        c.position = Vector3(randf_range(-300.0, 300.0), randf_range(70.0, 110.0), randf_range(-300.0, 300.0))
        for j in range(4):
            var m := MeshInstance3D.new()
            var s := SphereMesh.new()
            s.radius = 1.0
            s.height = 2.0
            s.radial_segments = 12
            s.rings = 6
            m.mesh = s
            m.scale = Vector3(randf_range(12.0, 20.0), randf_range(5.0, 7.0), randf_range(10.0, 16.0))
            m.position = Vector3(float(j) * 13.0 - 20.0, randf_range(-2.0, 2.0), randf_range(-6.0, 6.0))
            m.material_override = cloud_mat
            m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
            c.add_child(m)
        add_child(c)
        clouds.append(c)

    camera = Camera3D.new()
    camera.fov = 70.0
    camera.far = 1500.0
    camera.current = true
    add_child(camera)


# =====================================================================
# State
# =====================================================================
func _new_empire(aggr: float) -> Dictionary:
    return {
        "money": START_MONEY, "houses": 0, "launcher": 0, "ammo": [0, 0, 0, 0], "def": [],
        "cool": 4.0, "think": randf_range(2.0, 4.0), "aggr": aggr, "grudge": -1,
        "house_nodes": [], "launcher_node": null,
    }


func _reset_state(count: int) -> void:
    island_count = count
    island_hp = []
    emp = []
    for i in range(count):
        island_hp.append(100)
        emp.append(_new_empire(randf_range(0.3, 0.9)))
    selected_enemy = 1
    cur_ammo = 0
    elapsed = 0.0
    income_timer = 0.0
    placing_type = -1
    player_off = Vector3(0.0, 0.0, 2.0)


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
    island_labels.clear()
    launcher_pivots.clear()
    npcs.clear()
    projectiles.clear()
    place_ring = null
    placing_type = -1

    var radius: float = RING[island_count]
    for i in range(island_count):
        var ang: float = PI / 2.0 + float(i) * TAU / float(island_count)
        var p := Vector3(cos(ang) * radius, 0.0, sin(ang) * radius)
        island_pos.append(p)
        launcher_pivots.append(null)
        var isl := _make_island(i, p)
        level_root.add_child(isl)
        island_nodes.append(isl)

    player = _make_character(TEAM_COLORS[0])
    level_root.add_child(player)

    # rebuild every empire's buildings from its data
    for i in range(island_count):
        var e: Dictionary = emp[i]
        e["house_nodes"] = []
        e["launcher_node"] = null
        for k in range(int(e["houses"])):
            _build_house_node(i, k, false)
        _build_launcher(i)
        var defs: Array = e["def"]
        for df in defs:
            _build_defense_node(i, df)
        if int(island_hp[i]) <= 0:
            var dead: Node3D = island_nodes[i]
            dead.position.y = -6.0

    _ensure_target()
    _update_hp_widgets()
    _look_at_target(false)


func _make_island(i: int, p: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Island_%d" % i
    root.position = p
    root.rotation.y = _yaw_to(-p)
    var team := _team(i)

    _cyl(root, ISLAND_R + 2.5, ISLAND_R, 1.0, Vector3(0.0, -0.2, 0.0), Color(0.86, 0.75, 0.5))
    var grass_col := Color(0.3, 0.7, 0.28) if i == 0 else Color(0.36, 0.62, 0.28)
    _cyl(root, ISLAND_R, ISLAND_R - 0.4, 0.4, Vector3(0.0, 0.4, 0.0), grass_col)

    for k in range(12):
        var a: float = float(k) * 0.55 + 0.3
        var rock := _sphere(root, 1.6, Vector3(cos(a) * (ISLAND_R + 3.0), 0.2, sin(a) * (ISLAND_R + 3.0)), Color(0.5, 0.52, 0.55))
        rock.scale = Vector3(1.0, 0.6, 0.8)

    for k in range(10):
        var a2: float = float(k) * TAU / 10.0 + 0.2
        _add_palm(root, Vector3(cos(a2) * (ISLAND_R - 3.0), 0.6, sin(a2) * (ISLAND_R - 3.0)))

    # airport: runway, markings, tower and a parked plane
    _box(root, Vector3(32.0, 0.08, 5.0), Vector3(0.0, 0.62, 16.0), Color(0.18, 0.19, 0.21))
    for k in range(8):
        _box(root, Vector3(2.0, 0.09, 0.3), Vector3(-14.0 + float(k) * 4.0, 0.64, 16.0), Color(0.95, 0.95, 0.95))
    _box(root, Vector3(1.8, 6.0, 1.8), Vector3(-17.0, 3.6, 11.5), Color(0.8, 0.8, 0.82))
    _box(root, Vector3(3.4, 1.4, 3.4), Vector3(-17.0, 7.0, 11.5), Color(0.35, 0.55, 0.7))
    _box(root, Vector3(3.6, 0.3, 3.6), Vector3(-17.0, 7.9, 11.5), Color(0.25, 0.25, 0.28))
    var plane := Node3D.new()
    plane.position = Vector3(-4.0, 1.5, 20.2)
    root.add_child(plane)
    var fus := _cyl(plane, 0.9, 0.9, 8.0, Vector3.ZERO, Color(0.92, 0.92, 0.95))
    fus.rotation.z = PI / 2.0
    _box(plane, Vector3(1.8, 0.15, 10.0), Vector3(0.5, 0.0, 0.0), Color(0.85, 0.86, 0.9))
    _box(plane, Vector3(1.4, 0.12, 3.6), Vector3(-3.4, 0.2, 0.0), Color(0.85, 0.86, 0.9))
    _box(plane, Vector3(1.4, 1.8, 0.12), Vector3(-3.4, 1.0, 0.0), team)

    # team flag
    _cyl(root, 0.1, 0.1, 8.0, Vector3(-5.0, 4.6, -14.0), Color(0.8, 0.8, 0.8))
    _box(root, Vector3(0.1, 1.6, 2.6), Vector3(-5.0, 7.8, -15.4), team)

    var title := "YOU" if i == 0 else "ENEMY %d" % i
    island_labels.append(_make_hp_widget(root, title, team))

    if i > 0:
        var guard := _make_character(team)
        guard.position = Vector3(3.0, 0.6, 3.0)
        root.add_child(guard)
        npcs.append(guard)
    return root


func _add_palm(parent: Node3D, pos: Vector3) -> void:
    var palm := Node3D.new()
    palm.position = pos
    palm.rotation.z = randf_range(-0.12, 0.12)
    palm.scale = Vector3.ONE * 2.2
    parent.add_child(palm)
    _cyl(palm, 0.12, 0.2, 2.6, Vector3(0.0, 1.3, 0.0), Color(0.5, 0.33, 0.16))
    var top := Node3D.new()
    top.position = Vector3(0.0, 2.6, 0.0)
    palm.add_child(top)
    for k in range(5):
        var piv := Node3D.new()
        piv.rotation.y = float(k) * TAU / 5.0
        top.add_child(piv)
        var leaf := _box(piv, Vector3(1.6, 0.06, 0.55), Vector3(0.8, 0.0, 0.0), Color(0.14, 0.55, 0.2))
        leaf.rotation.z = -0.35


func _add_house(parent: Node3D, pos: Vector3, color: Color) -> Node3D:
    var h := Node3D.new()
    h.position = pos
    parent.add_child(h)
    _box(h, Vector3(1.5, 1.1, 1.3), Vector3(0.0, 0.55, 0.0), color)
    var roof := MeshInstance3D.new()
    var pr := PrismMesh.new()
    pr.size = Vector3(1.8, 0.7, 1.55)
    roof.mesh = pr
    roof.position = Vector3(0.0, 1.45, 0.0)
    roof.material_override = _mat(Color(0.45, 0.17, 0.12))
    h.add_child(roof)
    _box(h, Vector3(0.38, 0.65, 0.05), Vector3(0.0, 0.33, -0.66), Color(0.3, 0.18, 0.08))
    var win := _glow_mat(Color(0.7, 0.9, 1.0))
    for sx in [-0.5, 0.5]:
        var wm := _box(h, Vector3(0.3, 0.3, 0.05), Vector3(sx, 0.7, -0.66), Color.WHITE)
        wm.material_override = win
    return h


func _house_pos(k: int) -> Vector3:
    var col := k % 6
    var row := int(floor(float(k) / 6.0))
    return Vector3(-17.0 + float(col) * 3.8, 0.6, -6.0 + float(row) * 3.8)


func _build_house_node(i: int, k: int, animate: bool) -> void:
    var e: Dictionary = emp[i]
    var palette := [Color(0.95, 0.68, 0.24), Color(0.9, 0.45, 0.25), Color(0.35, 0.65, 0.9), Color(0.85, 0.85, 0.5)]
    var color: Color = palette[k % 4]
    if i > 0:
        color = _team(i).lightened(0.15 * float(k % 3))
    var h := _add_house(_isl(i), _house_pos(k), color)
    h.scale = Vector3.ONE * 1.6
    var nodes: Array = e["house_nodes"]
    nodes.append(h)
    if animate:
        h.scale = Vector3(0.01, 0.01, 0.01)
        var tw := create_tween()
        tw.tween_property(h, "scale", Vector3.ONE * 1.6, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _build_launcher(i: int) -> void:
    var e: Dictionary = emp[i]
    var old = e["launcher_node"]
    if old != null and is_instance_valid(old):
        var o: Node3D = old
        o.queue_free()
    e["launcher_node"] = null
    launcher_pivots[i] = null
    var level: int = e["launcher"]
    if level <= 0:
        return
    var team := _team(i)
    var piv := Node3D.new()
    piv.position = Vector3(6.0, 0.6, -13.0)
    piv.scale = Vector3.ONE * 2.0
    _isl(i).add_child(piv)
    _cyl(piv, 1.2, 1.4, 0.5, Vector3(0.0, 0.25, 0.0), Color(0.25, 0.27, 0.3))
    _box(piv, Vector3(0.8 + 0.7 * float(level), 0.6, 1.4), Vector3(0.0, 0.8, 0.0), team.darkened(0.3))
    for k in range(level):
        var x: float = (float(k) - float(level - 1) / 2.0) * 0.75
        var tube := _cyl(piv, 0.22, 0.28, 1.6, Vector3(x, 1.4, -0.5), Color(0.75, 0.77, 0.8))
        tube.rotation.x = deg_to_rad(-40.0)
        var tip := _cyl(piv, 0.26, 0.26, 0.2, Vector3(x, 1.92, -0.9), Color(0.9, 0.3, 0.2))
        tip.rotation.x = deg_to_rad(-40.0)
    if level >= 3:
        var dish := _sphere(piv, 0.5, Vector3(0.0, 1.5, 0.8), Color(0.85, 0.87, 0.9))
        dish.scale = Vector3(1.0, 0.3, 1.0)
    e["launcher_node"] = piv
    launcher_pivots[i] = piv


func _make_ring(radius: float, col: Color) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var t := TorusMesh.new()
    t.inner_radius = maxf(radius - 0.3, 0.1)
    t.outer_radius = radius + 0.3
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


func _defense_model(n: Node3D, t: int, team: Color) -> void:
    var s: float = [1.4, 1.7, 2.0, 2.4][t]
    n.scale = Vector3.ONE * s
    var gray := Color(0.35, 0.38, 0.4)
    var white := Color(0.9, 0.92, 0.95)
    if t == 0:
        _cyl(n, 0.6, 0.75, 0.6, Vector3(0.0, 0.3, 0.0), gray)
        _sphere(n, 0.5, Vector3(0.0, 0.85, 0.0), white)
        _box(n, Vector3(0.14, 0.14, 1.1), Vector3(0.0, 0.95, -0.6), Color(0.2, 0.2, 0.22))
    elif t == 1:
        _box(n, Vector3(1.2, 0.5, 2.2), Vector3(0.0, 0.45, 0.0), Color(0.3, 0.38, 0.28))
        for k in range(4):
            var x: float = (float(k % 2) - 0.5) * 0.55
            var z: float = (float(int(k / 2)) - 0.5) * 0.5
            var c := _cyl(n, 0.12, 0.12, 1.3, Vector3(x, 1.0, z), white)
            c.rotation.x = deg_to_rad(-55.0)
        _cyl(n, 0.05, 0.05, 1.0, Vector3(0.0, 1.3, 0.8), gray)
    elif t == 2:
        _box(n, Vector3(1.6, 0.4, 2.6), Vector3(0.0, 0.35, 0.0), Color(0.28, 0.33, 0.3))
        for k in range(6):
            var x2: float = (float(k % 3) - 1.0) * 0.5
            var z2: float = (float(int(k / 3)) - 0.5) * 0.7
            var c2 := _cyl(n, 0.13, 0.13, 1.6, Vector3(x2, 1.0, z2), white)
            c2.rotation.x = deg_to_rad(-60.0)
        _cyl(n, 0.08, 0.08, 1.8, Vector3(-0.9, 1.2, 1.0), gray)
        _box(n, Vector3(0.8, 0.5, 0.1), Vector3(-0.9, 2.2, 1.0), gray)
    else:
        _box(n, Vector3(2.0, 0.5, 3.2), Vector3(0.0, 0.4, 0.0), Color(0.25, 0.3, 0.28))
        for k in range(8):
            var x3: float = (float(k % 4) - 1.5) * 0.42
            var z3: float = (float(int(k / 4)) - 0.5) * 0.8
            var c3 := _cyl(n, 0.15, 0.15, 2.0, Vector3(x3, 1.2, z3), white)
            c3.rotation.x = deg_to_rad(-65.0)
        _cyl(n, 0.1, 0.1, 2.6, Vector3(1.1, 1.5, 1.2), gray)
        var dish := _sphere(n, 0.7, Vector3(1.1, 2.9, 1.2), white)
        dish.scale = Vector3(1.0, 0.25, 1.0)
        dish.rotation.x = deg_to_rad(-30.0)
    _sphere(n, 0.14, Vector3(0.0, 0.1, 0.0), team)


func _build_defense_node(i: int, df: Dictionary) -> void:
    var isl := _isl(i)
    var t: int = df["type"]
    var node := Node3D.new()
    node.position = Vector3(float(df["lx"]), 0.6, float(df["lz"]))
    isl.add_child(node)
    _defense_model(node, t, _team(i))
    df["node"] = node
    var rng: float = DEFENSES[t]["range"]
    var ring := _make_ring(rng, Color(0.3, 0.9, 1.0, 0.45) if i == 0 else Color(1.0, 0.35, 0.3, 0.3))
    ring.position = Vector3(float(df["lx"]), 0.7, float(df["lz"]))
    isl.add_child(ring)
    df["ring"] = ring


func _def_world(i: int, df: Dictionary) -> Vector3:
    return _isl(i).to_global(Vector3(float(df["lx"]), 0.6, float(df["lz"])))


func _make_character(shirt: Color) -> Node3D:
    var root := Node3D.new()
    var skin := Color(1.0, 0.82, 0.3)
    _box(root, Vector3(0.9, 0.95, 0.45), Vector3(0.0, 1.25, 0.0), shirt)
    _box(root, Vector3(0.65, 0.65, 0.65), Vector3(0.0, 2.05, 0.0), skin)
    _box(root, Vector3(0.1, 0.12, 0.04), Vector3(-0.15, 2.12, -0.33), Color(0.05, 0.05, 0.05))
    _box(root, Vector3(0.1, 0.12, 0.04), Vector3(0.15, 2.12, -0.33), Color(0.05, 0.05, 0.05))
    _box(root, Vector3(0.28, 0.06, 0.04), Vector3(0.0, 1.93, -0.33), Color(0.3, 0.1, 0.05))
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


func _make_hp_widget(parent: Node3D, title: String, col: Color) -> Dictionary:
    var root := Node3D.new()
    root.position = Vector3(0.0, 17.0, 0.0)
    parent.add_child(root)
    var lab := Label3D.new()
    lab.text = title
    lab.font_size = 72
    lab.pixel_size = 0.05
    lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    lab.no_depth_test = true
    lab.render_priority = 3
    lab.outline_size = 16
    lab.modulate = col.lightened(0.3)
    lab.position = Vector3(0.0, 3.4, 0.0)
    root.add_child(lab)
    var bg := _bar_quad(Vector2(18.8, 2.1), Color(0.0, 0.0, 0.0, 0.6), 0)
    root.add_child(bg)
    var fg := _bar_quad(Vector2(18.0, 1.6), Color(0.2, 0.9, 0.3, 0.95), 1)
    root.add_child(fg)
    return {"root": root, "label": lab, "bar": fg, "name": title}


func _bar_quad(size: Vector2, col: Color, prio: int) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var q := QuadMesh.new()
    q.size = size
    m.mesh = q
    var mat := StandardMaterial3D.new()
    mat.albedo_color = col
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
    mat.billboard_keep_scale = true
    mat.no_depth_test = true
    mat.render_priority = prio
    m.material_override = mat
    m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    return m


func _update_hp_widgets() -> void:
    for i in range(island_labels.size()):
        var w: Dictionary = island_labels[i]
        var hp: int = int(island_hp[i])
        var frac: float = clampf(float(hp) / 100.0, 0.0, 1.0)
        var bar: MeshInstance3D = w["bar"]
        bar.scale.x = maxf(frac, 0.001)
        var mat := bar.material_override as StandardMaterial3D
        if frac < 0.35:
            mat.albedo_color = Color(0.9, 0.2, 0.2, 0.95)
        elif frac < 0.65:
            mat.albedo_color = Color(0.95, 0.8, 0.2, 0.95)
        else:
            mat.albedo_color = Color(0.2, 0.9, 0.3, 0.95)
        var lab: Label3D = w["label"]
        if hp > 0:
            lab.text = "%s  %d" % [w["name"], hp]
        else:
            lab.text = "%s  DESTROYED" % w["name"]


# =====================================================================
# Empire actions (used by the player AND the AI rivals)
# Return codes: 0 = ok, other = reason
# =====================================================================
func _do_build_house(i: int) -> int:
    var e: Dictionary = emp[i]
    if int(e["houses"]) >= MAX_HOUSES:
        return 2
    var price := _house_price(i)
    if int(e["money"]) < price:
        return 1
    e["money"] = int(e["money"]) - price
    _build_house_node(i, int(e["houses"]), true)
    e["houses"] = int(e["houses"]) + 1
    return 0


func _do_launcher(i: int) -> int:
    var e: Dictionary = emp[i]
    var lvl: int = e["launcher"]
    if lvl >= 4:
        return 2
    var price: int = LAUNCH_PRICES[lvl]
    if int(e["money"]) < price:
        return 1
    e["money"] = int(e["money"]) - price
    e["launcher"] = lvl + 1
    _build_launcher(i)
    return 0


func _do_buy_missile(i: int, t: int) -> int:
    var e: Dictionary = emp[i]
    if int(e["launcher"]) < t + 1:
        return 2
    var price: int = MISSILES[t]["price"]
    if int(e["money"]) < price:
        return 1
    e["money"] = int(e["money"]) - price
    var ammo: Array = e["ammo"]
    ammo[t] = int(ammo[t]) + 1
    return 0


func _do_build_defense(i: int, t: int, lx: float, lz: float) -> int:
    var e: Dictionary = emp[i]
    var defs: Array = e["def"]
    if defs.size() >= MAX_DEFENSES:
        return 3
    var price: int = DEFENSES[t]["price"]
    if int(e["money"]) < price:
        return 1
    for d in defs:
        var dd: Dictionary = d
        if Vector2(float(dd["lx"]) - lx, float(dd["lz"]) - lz).length() < 5.0:
            return 2
    e["money"] = int(e["money"]) - price
    var df := {"type": t, "lx": lx, "lz": lz, "node": null, "ring": null}
    defs.append(df)
    _build_defense_node(i, df)
    return 0


func _do_repair(i: int) -> int:
    var e: Dictionary = emp[i]
    if int(island_hp[i]) >= 100:
        return 2
    if int(e["money"]) < PRICE_REPAIR:
        return 1
    e["money"] = int(e["money"]) - PRICE_REPAIR
    island_hp[i] = mini(100, int(island_hp[i]) + 30)
    _update_hp_widgets()
    return 0


# =====================================================================
# Rival AI: starts from zero, builds an economy, then an army
# =====================================================================
func _ai_tick(i: int, delta: float) -> void:
    if int(island_hp[i]) <= 0:
        return
    var e: Dictionary = emp[i]
    e["think"] = float(e["think"]) - delta
    e["cool"] = float(e["cool"]) - delta
    if float(e["think"]) <= 0.0:
        e["think"] = randf_range(2.5, 4.5)
        _ai_think(i)
    if float(e["cool"]) <= 0.0:
        _ai_attack(i)


func _ai_best_missile(i: int) -> int:
    var e: Dictionary = emp[i]
    var top: int = int(e["launcher"]) - 1
    var pick := -1
    for t in range(top, -1, -1):
        if int(e["money"]) >= int(MISSILES[t]["price"]):
            pick = t
            break
    if pick > 0 and randf() < 0.25:
        pick -= 1
    return pick


func _ai_think(i: int) -> void:
    var e: Dictionary = emp[i]
    var money_i: int = e["money"]
    var houses_i: int = e["houses"]
    var launcher_i: int = e["launcher"]
    var aggr: float = e["aggr"]
    var defs: Array = e["def"]
    # 1. get an economy and a launcher
    if houses_i < 1 and money_i >= _house_price(i):
        _do_build_house(i)
        return
    if launcher_i == 0:
        if money_i >= int(LAUNCH_PRICES[0]):
            _do_launcher(i)
        elif houses_i < 3 and money_i >= _house_price(i):
            _do_build_house(i)
        return
    # 2. emergency repair
    if int(island_hp[i]) < 50 and money_i >= PRICE_REPAIR:
        _do_repair(i)
        return
    # 3. keep a few missiles in stock
    if _ammo_total(e) < 2:
        var t := _ai_best_missile(i)
        if t >= 0:
            _do_buy_missile(i, t)
            return
    # 4. air defense grows with time (cautious rivals build more)
    var want_def: int = mini(8, 1 + int(elapsed / 70.0) - int(aggr * 1.5))
    if defs.size() < want_def:
        var tier: int = mini(3, int(elapsed / 150.0))
        var dt := -1
        for t2 in range(tier, -1, -1):
            if money_i >= int(DEFENSES[t2]["price"]):
                dt = t2
                break
        if dt >= 0:
            for attempt in range(12):
                var a: float = randf() * TAU
                var r: float = sqrt(randf()) * 17.0
                var lx: float = cos(a) * r
                var lz: float = sin(a) * r
                if _do_build_defense(i, dt, lx, lz) == 0:
                    return
    # 5. economy
    if houses_i < 5 + int(aggr * 6.0) and money_i >= _house_price(i):
        _do_build_house(i)
        return
    # 6. better launcher unlocks better missiles
    if launcher_i < 4 and houses_i >= 3 + launcher_i * 2 and money_i >= int(LAUNCH_PRICES[launcher_i]):
        _do_launcher(i)
        return
    # 7. stock up
    if _ammo_total(e) < 6:
        var t3 := _ai_best_missile(i)
        if t3 >= 0:
            _do_buy_missile(i, t3)


func _ai_pick_target(i: int) -> int:
    var e: Dictionary = emp[i]
    var gr: int = e["grudge"]
    if gr >= 0 and gr != i and int(island_hp[gr]) > 0 and randf() < 0.6:
        return gr
    var cands: Array = []
    for k in range(island_count):
        if k != i and int(island_hp[k]) > 0:
            cands.append(k)
    if cands.is_empty():
        return -1
    if cands.has(0) and randf() < 0.5:
        return 0
    return cands[randi() % cands.size()]


func _ai_attack(i: int) -> void:
    var e: Dictionary = emp[i]
    if int(e["launcher"]) < 1:
        return
    var ammo: Array = e["ammo"]
    var have: Array = []
    for t in range(4):
        if int(ammo[t]) > 0:
            have.append(t)
    if have.is_empty():
        return
    var mt: int = have[have.size() - 1] if randf() < 0.7 else have[randi() % have.size()]
    var target := _ai_pick_target(i)
    if target < 0:
        return
    ammo[mt] = int(ammo[mt]) - 1
    e["cool"] = float(MISSILES[mt]["cool"]) * randf_range(1.5, 2.5)
    _launch(i, target, mt)


# =====================================================================
# Main loop
# =====================================================================
func _process(delta: float) -> void:
    _animate_world(delta)
    if game_state == "playing":
        elapsed += delta
        income_timer += delta
        if income_timer >= 2.0:
            income_timer -= 2.0
            _pay_income()
        _move_player(delta)
        for i in range(1, island_count):
            _ai_tick(i, delta)
        var pe: Dictionary = emp[0]
        pe["cool"] = maxf(0.0, float(pe["cool"]) - delta)
        _update_projectiles(delta)
        _update_place_ring()
    elif game_state == "menu":
        cam_yaw += delta * 0.12
    _update_camera(delta)
    _update_fire_button()


func _pay_income() -> void:
    for i in range(island_count):
        if int(island_hp[i]) > 0:
            var e: Dictionary = emp[i]
            e["money"] = int(e["money"]) + _income(i)
    _refresh_ui()


func _animate_world(delta: float) -> void:
    for c in clouds:
        var cn: Node3D = c
        cn.position.x += delta * 2.0
        if cn.position.x > 330.0:
            cn.position.x = -330.0
    var tt: float = Time.get_ticks_msec() * 0.001
    for k in range(npcs.size()):
        var n: Node3D = npcs[k]
        if is_instance_valid(n):
            n.rotation.y = sin(tt * 0.7 + float(k) * 2.0) * 0.9


func _player_world() -> Vector3:
    var base: Vector3 = island_pos[0]
    return base + player_off + Vector3(0.0, 0.6, 0.0)


func _move_player(delta: float) -> void:
    var fwd := Vector3(-sin(cam_yaw), 0.0, -cos(cam_yaw))
    var right := Vector3(cos(cam_yaw), 0.0, -sin(cam_yaw))
    var mv := joy_vec
    var moving := mv.length() > 0.12
    if moving:
        var dir := right * mv.x + fwd * (-mv.y)
        if dir.length() > 1.0:
            dir = dir.normalized()
        player_off += dir * WALK_SPEED * delta
        if player_off.length() > PLAYER_LIMIT:
            player_off = player_off.normalized() * PLAYER_LIMIT
        if dir.length() > 0.05:
            player.rotation.y = lerp_angle(player.rotation.y, _yaw_to(dir), clampf(delta * 12.0, 0.0, 1.0))
        walk_amount = minf(1.0, walk_amount + delta * 6.0)
        walk_phase += delta * 11.0
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


func _update_camera(delta: float) -> void:
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


# =====================================================================
# Missiles and air defense
# =====================================================================
func _make_missile_model(friendly: bool, mtype: int) -> Node3D:
    var root := Node3D.new()
    var model := Node3D.new()
    var sc: float = [1.5, 2.0, 1.8, 2.2][mtype]
    model.scale = Vector3.ONE * sc
    root.add_child(model)
    var body_col := Color(0.93, 0.93, 0.96) if friendly else Color(0.4, 0.08, 0.08)
    var tip_col := Color(1.0, 0.45, 0.1) if friendly else Color(0.95, 0.15, 0.15)
    var flame_col := Color(1.0, 0.6, 0.1)
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
    _add_trail(model, 0.7 if mtype == 2 else 0.4)
    return root


func _add_trail(parent: Node3D, size: float) -> void:
    var p := CPUParticles3D.new()
    p.amount = 36
    p.lifetime = 0.9
    p.local_coords = false
    p.direction = Vector3(0.0, 0.0, 1.0)
    p.spread = 20.0
    p.initial_velocity_min = 0.3
    p.initial_velocity_max = 0.8
    p.gravity = Vector3.ZERO
    var pm := SphereMesh.new()
    pm.radius = size * 0.35
    pm.height = size * 0.7
    var pmat := StandardMaterial3D.new()
    pmat.albedo_color = Color(0.9, 0.9, 0.9)
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


func _aim_launcher(i: int, target: Vector3) -> void:
    var piv = launcher_pivots[i]
    if piv == null or not is_instance_valid(piv):
        return
    var p: Node3D = piv
    var d: Vector3 = target - p.global_position
    p.global_rotation = Vector3(0.0, _yaw_to(d), 0.0)


func _muzzle(i: int) -> Vector3:
    var piv: Node3D = launcher_pivots[i]
    var yaw := piv.global_rotation.y
    var fwd := Vector3(-sin(yaw), 0.0, -cos(yaw))
    return piv.global_position + Vector3(0.0, 3.6, 0.0) + fwd * 2.0


func _launch(attacker: int, target: int, mtype: int) -> void:
    var info: Dictionary = MISSILES[mtype]
    var tpos: Vector3 = island_pos[target]
    var wh: int = info["warheads"]
    var spread := 6.0 if wh == 1 else 14.0
    for w in range(wh):
        var to_pos := tpos + Vector3(randf_range(-1.0, 1.0) * spread, 1.4, randf_range(-1.0, 1.0) * spread)
        _aim_launcher(attacker, to_pos)
        var from_pos := _muzzle(attacker)
        var m := _make_missile_model(attacker == 0, mtype)
        level_root.add_child(m)
        m.position = from_pos
        var dist := from_pos.distance_to(to_pos)
        projectiles.append({
            "node": m, "start": from_pos, "end": to_pos, "t": 0.0,
            "dur": maxf(0.8, dist / float(info["speed"])), "h": dist * float(info["arc"]),
            "attacker": attacker, "target": target, "dmg": int(info["dmg"]),
            "resist": float(info["resist"]), "tried": [], "kill": -1.0,
        })


func _spawn_interceptor(from_pos: Vector3, to_pos: Vector3, success: bool) -> void:
    var n := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 0.5
    sm.height = 1.0
    n.mesh = sm
    n.material_override = _glow_mat(Color(0.5, 0.95, 1.0))
    n.position = from_pos
    level_root.add_child(n)
    _add_trail(n, 0.5)
    var tw := create_tween()
    tw.tween_property(n, "position", to_pos, 0.35)
    if not success:
        tw.tween_callback(_explode.bind(to_pos, Color(0.9, 0.9, 0.9), 0.8))
    tw.tween_callback(n.queue_free)


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
        var s: Vector3 = d["start"]
        var e: Vector3 = d["end"]
        var h: float = d["h"]
        var target: int = d["target"]
        var tt: float = minf(t, 1.0)
        node.position = _arc(s, e, tt, h)
        var ahead := _arc(s, e, minf(tt + 0.03, 1.0), h)
        if ahead.distance_to(node.position) > 0.01:
            node.look_at(ahead, Vector3.UP)
        if t >= 1.0:
            node.queue_free()
            projectiles.remove_at(i)
            _on_hit(d)
            continue
        var kill: float = d["kill"]
        if kill >= 0.0:
            kill -= delta
            d["kill"] = kill
            if kill <= 0.0:
                _explode(node.position, Color(0.6, 0.9, 1.0), 2.5)
                node.queue_free()
                projectiles.remove_at(i)
                if target == 0:
                    _say("AIR DEFENSE intercepted an incoming missile!")
                elif int(d["attacker"]) == 0:
                    _say("Enemy air defense shot down your missile!")
            continue
        if dur * (1.0 - t) < 0.5:
            continue
        # layered air defense: each system gets one chance when the missile enters its range
        var defs: Array = emp[target]["def"]
        var tried: Array = d["tried"]
        for di in range(defs.size()):
            if tried.has(di):
                continue
            var df: Dictionary = defs[di]
            var dpos := _def_world(target, df)
            var dtype: int = df["type"]
            var rng: float = DEFENSES[dtype]["range"]
            var flat := Vector2(node.position.x - dpos.x, node.position.z - dpos.z)
            if flat.length() <= rng:
                tried.append(di)
                var chance: float = float(DEFENSES[dtype]["chance"]) * float(d["resist"])
                var ok := randf() < chance
                var meet := _arc(s, e, minf(t + 0.35 / dur, 1.0), h)
                _spawn_interceptor(dpos + Vector3(0.0, 3.0, 0.0), meet, ok)
                if ok:
                    d["kill"] = 0.35
                    break


func _on_hit(d: Dictionary) -> void:
    var target: int = d["target"]
    var attacker: int = d["attacker"]
    var dmg: int = d["dmg"]
    var pos: Vector3 = d["end"]
    _explode(pos, Color(1.0, 0.5, 0.1), 3.0)
    if int(island_hp[target]) <= 0 or game_state != "playing":
        return
    island_hp[target] = maxi(0, int(island_hp[target]) - dmg)
    var te: Dictionary = emp[target]
    te["grudge"] = attacker
    if target == 0:
        _vibrate(150)
        _say("Your base was hit by Enemy %d! -%d HP" % [attacker, dmg])
    elif attacker == 0:
        _say("Direct hit on Enemy %d! (%d HP left)" % [target, int(island_hp[target])])
    if int(island_hp[target]) <= 0:
        _island_destroyed(target, attacker)
    _update_hp_widgets()
    _refresh_ui()
    _save_game()


func _island_destroyed(i: int, by: int) -> void:
    if i == 0:
        _game_over(false)
        return
    var be: Dictionary = emp[by]
    be["money"] = int(be["money"]) + 200
    if by == 0:
        _say("Enemy %d destroyed! +$200" % i)
    else:
        _say("Enemy %d was destroyed by Enemy %d!" % [i, by])
    var isl: Node3D = island_nodes[i]
    var tw := create_tween()
    tw.tween_property(isl, "position:y", -6.0, 3.0)
    var any_alive := false
    for k in range(1, island_count):
        if int(island_hp[k]) > 0:
            any_alive = true
    if not any_alive:
        _game_over(true)
    else:
        _ensure_target()
        _look_at_target(true)


func _fire() -> void:
    if game_state != "playing":
        return
    var e: Dictionary = emp[0]
    if float(e["cool"]) > 0.0:
        return
    if int(e["launcher"]) < 1:
        _say("Build a launcher first (BUILD menu, MISSILES tab).")
        return
    var ammo: Array = e["ammo"]
    if cur_ammo >= int(e["launcher"]) or int(ammo[cur_ammo]) < 1:
        _say("No %s left! Buy more, or tap AMMO to switch." % MISSILES[cur_ammo]["short"])
        return
    _ensure_target()
    if int(island_hp[selected_enemy]) <= 0:
        return
    ammo[cur_ammo] = int(ammo[cur_ammo]) - 1
    e["cool"] = float(MISSILES[cur_ammo]["cool"])
    _launch(0, selected_enemy, cur_ammo)
    _look_at_target(true)
    _vibrate(40)
    _say("%s launched at Enemy %d!" % [MISSILES[cur_ammo]["name"], selected_enemy])
    _refresh_ui()


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

    var p := CPUParticles3D.new()
    p.one_shot = true
    p.amount = 40
    p.lifetime = 1.0
    p.explosiveness = 1.0
    p.direction = Vector3.UP
    p.spread = 180.0
    p.initial_velocity_min = 3.0 * size
    p.initial_velocity_max = 8.0 * size
    p.gravity = Vector3(0.0, -7.0, 0.0)
    var pm := SphereMesh.new()
    pm.radius = 0.16 * size
    pm.height = 0.32 * size
    pm.material = _glow_mat(color)
    p.mesh = pm
    p.position = pos
    level_root.add_child(p)
    p.emitting = true
    get_tree().create_timer(1.8).timeout.connect(p.queue_free)


# =====================================================================
# Targets / game flow
# =====================================================================
func _ensure_target() -> void:
    if island_count < 2:
        return
    selected_enemy = clampi(selected_enemy, 1, island_count - 1)
    if int(island_hp[selected_enemy]) > 0:
        return
    for k in range(1, island_count):
        if int(island_hp[k]) > 0:
            selected_enemy = k
            return


func _cycle_target() -> void:
    if island_count < 3:
        _look_at_target(true)
        return
    for step in range(1, island_count):
        var k: int = ((selected_enemy - 1 + step) % (island_count - 1)) + 1
        if int(island_hp[k]) > 0:
            selected_enemy = k
            break
    _look_at_target(true)
    _refresh_ui()


func _cycle_ammo() -> void:
    var e: Dictionary = emp[0]
    var lvl: int = e["launcher"]
    if lvl < 1:
        _say("Build a launcher first.")
        return
    cur_ammo = (cur_ammo + 1) % lvl
    _refresh_ui()


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


func _start_new(count: int) -> void:
    _reset_state(count)
    _build_world()
    overlay.hide()
    build_panel.hide()
    game_state = "playing"
    _say("Walk with the joystick, drag the right side to look around. Start with a house, then a launcher!")
    _refresh_ui()
    _save_game()


func _continue_game() -> void:
    if _load_game():
        _build_world()
        overlay.hide()
        game_state = "playing"
        _say("Welcome back!")
        _refresh_ui()
    else:
        _start_new(2)


func _resume_game() -> void:
    overlay.hide()
    game_state = "playing"


func _game_over(won: bool) -> void:
    game_state = "won" if won else "lost"
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
    _vibrate(300)
    _cancel_place()
    build_panel.hide()
    await get_tree().create_timer(1.8).timeout
    if game_state == "won":
        _show_overlay("VICTORY!", "All rival islands are destroyed. You are the missile tycoon!")
    elif game_state == "lost":
        _show_overlay("YOUR ISLAND FELL", "Layer your air defense and keep your base repaired next time.")


# =====================================================================
# Player purchases
# =====================================================================
func _after_buy() -> void:
    _refresh_ui()
    _save_game()


func _buy_house() -> void:
    var code := _do_build_house(0)
    if code == 0:
        _say("House built! Income is now $%d / 2s." % _income(0))
    elif code == 1:
        _say("Need $%d for a house." % _house_price(0))
    else:
        _say("Your island is full of houses!")
    _after_buy()


func _buy_repair() -> void:
    var code := _do_repair(0)
    if code == 0:
        _say("Base repaired.")
    elif code == 1:
        _say("Need $%d to repair." % PRICE_REPAIR)
    else:
        _say("Your base is already at full health.")
    _after_buy()


func _buy_launcher() -> void:
    var e: Dictionary = emp[0]
    var lvl: int = e["launcher"]
    var code := _do_launcher(0)
    if code == 0:
        _say("Launcher level %d ready. %s unlocked!" % [lvl + 1, MISSILES[lvl]["name"]])
    elif code == 1:
        _say("Need $%d for the launcher." % int(LAUNCH_PRICES[lvl]))
    else:
        _say("Launcher is at maximum level.")
    _after_buy()


func _buy_missile(t: int) -> void:
    var code := _do_buy_missile(0, t)
    if code == 0:
        cur_ammo = t
        _say("%s bought." % MISSILES[t]["name"])
    elif code == 1:
        _say("Need $%d for a %s." % [int(MISSILES[t]["price"]), MISSILES[t]["name"]])
    else:
        _say("Upgrade your launcher to Lv %d to use this missile." % (t + 1))
    _after_buy()


func _begin_place(t: int) -> void:
    var e: Dictionary = emp[0]
    var defs: Array = e["def"]
    if defs.size() >= MAX_DEFENSES:
        _say("You have the maximum number of air defense sites.")
        return
    if int(e["money"]) < int(DEFENSES[t]["price"]):
        _say("Need $%d for a %s." % [int(DEFENSES[t]["price"]), DEFENSES[t]["name"]])
        return
    _cancel_place()
    placing_type = t
    build_panel.hide()
    var rng: float = DEFENSES[t]["range"]
    place_ring = _make_ring(rng, Color(1.0, 1.0, 1.0, 0.6))
    _isl(0).add_child(place_ring)
    place_bar.show()
    btn_place.text = "PLACE %s HERE  ($%d)" % [DEFENSES[t]["name"], int(DEFENSES[t]["price"])]
    _say("Walk to the spot. The white ring shows the range. Tap PLACE when ready.")


func _update_place_ring() -> void:
    if placing_type < 0 or place_ring == null or not is_instance_valid(place_ring):
        return
    var local := _isl(0).to_local(_player_world())
    place_ring.position = Vector3(local.x, 0.8, local.z)


func _confirm_place() -> void:
    if placing_type < 0:
        return
    var local := _isl(0).to_local(_player_world())
    var t := placing_type
    var code := _do_build_defense(0, t, local.x, local.z)
    if code == 0:
        _say("%s built. Range %d." % [DEFENSES[t]["name"], int(DEFENSES[t]["range"])])
        _cancel_place()
        _after_buy()
    elif code == 2:
        _say("Too close to another defense. Walk a few steps away and try again.")
    elif code == 1:
        _say("Not enough money.")
    else:
        _say("Maximum number of defenses reached.")


func _cancel_place() -> void:
    placing_type = -1
    if place_ring != null and is_instance_valid(place_ring):
        place_ring.queue_free()
    place_ring = null
    if place_bar != null:
        place_bar.hide()


# =====================================================================
# Save / load
# =====================================================================
func _has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)


func _save_game() -> void:
    if game_state != "playing":
        return
    var arr: Array = []
    for i in range(island_count):
        var e: Dictionary = emp[i]
        var defs: Array = []
        var src_defs: Array = e["def"]
        for df in src_defs:
            defs.append({"type": df["type"], "lx": df["lx"], "lz": df["lz"]})
        arr.append({
            "money": e["money"], "houses": e["houses"], "launcher": e["launcher"],
            "ammo": e["ammo"], "def": defs, "aggr": e["aggr"], "grudge": e["grudge"],
        })
    var data := {
        "v": 3, "island_count": island_count, "hp": island_hp, "emp": arr,
        "selected": selected_enemy, "elapsed": elapsed, "cur_ammo": cur_ammo,
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
    if int(parsed.get("v", 0)) != 3:
        return false
    var count := clampi(int(parsed.get("island_count", 2)), 2, 4)
    var hp_raw = parsed.get("hp", [])
    var emp_raw = parsed.get("emp", [])
    if typeof(hp_raw) != TYPE_ARRAY or typeof(emp_raw) != TYPE_ARRAY:
        return false
    if hp_raw.size() != count or emp_raw.size() != count:
        return false
    if int(hp_raw[0]) <= 0:
        return false
    _reset_state(count)
    for i in range(count):
        island_hp[i] = clampi(int(hp_raw[i]), 0, 100)
        var src: Dictionary = emp_raw[i]
        var e: Dictionary = emp[i]
        e["money"] = int(src.get("money", START_MONEY))
        e["houses"] = clampi(int(src.get("houses", 0)), 0, MAX_HOUSES)
        e["launcher"] = clampi(int(src.get("launcher", 0)), 0, 4)
        e["aggr"] = float(src.get("aggr", 0.5))
        e["grudge"] = int(src.get("grudge", -1))
        var am = src.get("ammo", [])
        var ammo: Array = e["ammo"]
        for t in range(4):
            ammo[t] = int(am[t]) if t < am.size() else 0
        var defs: Array = e["def"]
        var draw = src.get("def", [])
        for dr in draw:
            var dd: Dictionary = dr
            defs.append({
                "type": clampi(int(dd.get("type", 0)), 0, 3),
                "lx": float(dd.get("lx", 0.0)), "lz": float(dd.get("lz", 0.0)),
                "node": null, "ring": null,
            })
    selected_enemy = int(parsed.get("selected", 1))
    elapsed = float(parsed.get("elapsed", 0.0))
    cur_ammo = clampi(int(parsed.get("cur_ammo", 0)), 0, 3)
    return true


# =====================================================================
# UI
# =====================================================================
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
    b.pressed.connect(cb)
    return b


func _round_style(alpha: float) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(1.0, 1.0, 1.0, alpha)
    sb.set_corner_radius_all(120)
    sb.set_border_width_all(3)
    sb.border_color = Color(1.0, 1.0, 1.0, 0.45)
    return sb


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

    # --- HUD (top left) ---
    hud_panel = PanelContainer.new()
    _style_panel(hud_panel)
    hud_panel.position = Vector2(24.0, 16.0)
    ui_root.add_child(hud_panel)
    var hv := VBoxContainer.new()
    hud_panel.add_child(hv)
    money_label = Label.new()
    money_label.add_theme_font_size_override("font_size", 32)
    hv.add_child(money_label)
    stats_label = Label.new()
    hv.add_child(stats_label)
    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.custom_minimum_size = Vector2(520.0, 0.0)
    status_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
    hv.add_child(status_label)

    # --- target + menu (top right) ---
    top_right = VBoxContainer.new()
    ui_root.add_child(top_right)
    target_button = _make_button("", Color(0.75, 0.2, 0.2), _cycle_target)
    target_button.custom_minimum_size = Vector2(380.0, 84.0)
    top_right.add_child(target_button)
    top_right.add_child(_make_button("MENU", Color(0.25, 0.3, 0.42), _on_menu_pressed))
    top_right.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
    top_right.grow_horizontal = Control.GROW_DIRECTION_BEGIN

    # --- build / ammo / fire (bottom right) ---
    bottom_right = VBoxContainer.new()
    bottom_right.add_theme_constant_override("separation", 10)
    ui_root.add_child(bottom_right)
    build_toggle = _make_button("BUILD / UPGRADE", Color(0.2, 0.5, 0.85), _on_build_toggle)
    build_toggle.custom_minimum_size = Vector2(380.0, 66.0)
    bottom_right.add_child(build_toggle)
    ammo_button = _make_button("", Color(0.45, 0.4, 0.15), _cycle_ammo)
    ammo_button.custom_minimum_size = Vector2(380.0, 76.0)
    bottom_right.add_child(ammo_button)
    fire_button = _make_button("FIRE!", Color(0.85, 0.25, 0.15), _fire)
    fire_button.custom_minimum_size = Vector2(380.0, 100.0)
    fire_button.add_theme_font_size_override("font_size", 38)
    bottom_right.add_child(fire_button)
    bottom_right.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
    bottom_right.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    bottom_right.grow_vertical = Control.GROW_DIRECTION_BEGIN

    # --- build menu (modal, centre) ---
    build_panel = PanelContainer.new()
    _style_panel(build_panel, Color(0.04, 0.08, 0.14, 0.95))
    ui_root.add_child(build_panel)
    var bp := VBoxContainer.new()
    build_panel.add_child(bp)
    var head := HBoxContainer.new()
    bp.add_child(head)
    var ttl := Label.new()
    ttl.text = "BUILD / UPGRADE"
    ttl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ttl.add_theme_font_size_override("font_size", 30)
    head.add_child(ttl)
    var close_btn := _make_button("CLOSE", Color(0.55, 0.2, 0.2), _on_build_toggle)
    close_btn.custom_minimum_size = Vector2(140.0, 54.0)
    head.add_child(close_btn)
    var tabs := TabContainer.new()
    bp.add_child(tabs)

    var eco := VBoxContainer.new()
    eco.name = "ECONOMY"
    tabs.add_child(eco)
    btn_house = _make_button("", Color(0.2, 0.55, 0.35), _buy_house)
    btn_repair = _make_button("", Color(0.2, 0.55, 0.35), _buy_repair)
    for b in [btn_house, btn_repair]:
        var bb: Button = b
        bb.custom_minimum_size = Vector2(540.0, 76.0)
        eco.add_child(bb)

    var mis := VBoxContainer.new()
    mis.name = "MISSILES"
    tabs.add_child(mis)
    btn_launcher = _make_button("", Color(0.25, 0.45, 0.7), _buy_launcher)
    btn_launcher.custom_minimum_size = Vector2(540.0, 76.0)
    mis.add_child(btn_launcher)
    btn_missiles = []
    for t in range(4):
        var mb := _make_button("", Color(0.2, 0.55, 0.35), _buy_missile.bind(t))
        mb.custom_minimum_size = Vector2(540.0, 76.0)
        mis.add_child(mb)
        btn_missiles.append(mb)

    var dfn := VBoxContainer.new()
    dfn.name = "AIR DEFENSE"
    tabs.add_child(dfn)
    btn_defenses = []
    for t in range(4):
        var db := _make_button("", Color(0.2, 0.5, 0.55), _begin_place.bind(t))
        db.custom_minimum_size = Vector2(540.0, 76.0)
        dfn.add_child(db)
        btn_defenses.append(db)
    build_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
    build_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    build_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    build_panel.visible = false

    # --- placement bar (bottom centre) ---
    place_bar = HBoxContainer.new()
    place_bar.add_theme_constant_override("separation", 14)
    ui_root.add_child(place_bar)
    btn_place = _make_button("PLACE HERE", Color(0.2, 0.65, 0.3), _confirm_place)
    btn_place.custom_minimum_size = Vector2(520.0, 84.0)
    place_bar.add_child(btn_place)
    var cancel_btn := _make_button("CANCEL", Color(0.55, 0.2, 0.2), _cancel_place)
    cancel_btn.custom_minimum_size = Vector2(200.0, 84.0)
    place_bar.add_child(cancel_btn)
    place_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 24)
    place_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
    place_bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
    place_bar.visible = false

    # --- joystick ---
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

    # --- overlay (menu / win / lose) ---
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
    ov.add_theme_constant_override("separation", 14)
    cc.add_child(ov)
    ov_title = Label.new()
    ov_title.add_theme_font_size_override("font_size", 60)
    ov_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ov.add_child(ov_title)
    ov_sub = Label.new()
    ov_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    ov_sub.custom_minimum_size = Vector2(720.0, 0.0)
    ov_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    ov.add_child(ov_sub)
    btn_resume = _make_button("RESUME", Color(0.2, 0.6, 0.35), _resume_game)
    btn_continue = _make_button("CONTINUE SAVED GAME", Color(0.2, 0.5, 0.85), _continue_game)
    ov.add_child(btn_resume)
    ov.add_child(btn_continue)
    ov.add_child(_make_button("NEW GAME: 1 vs 1 (2 islands)", Color(0.8, 0.35, 0.2), _start_new.bind(2)))
    ov.add_child(_make_button("NEW GAME: 1 vs 1 vs 1 (3 islands)", Color(0.8, 0.35, 0.2), _start_new.bind(3)))
    ov.add_child(_make_button("NEW GAME: 4 islands battle", Color(0.8, 0.35, 0.2), _start_new.bind(4)))
    for c in ov.get_children():
        if c is Button:
            var cb: Button = c
            cb.custom_minimum_size = Vector2(520.0, 66.0)


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
    build_panel.hide()
    game_state = "paused"
    _show_overlay("PAUSED", "Your progress is saved automatically.")


func _on_build_toggle() -> void:
    if game_state != "playing":
        return
    _cancel_place()
    build_panel.visible = not build_panel.visible
    _refresh_ui()


func _say(message: String) -> void:
    if status_label:
        status_label.text = message


func _refresh_ui() -> void:
    if money_label == null or emp.is_empty():
        return
    var e: Dictionary = emp[0]
    var money: int = e["money"]
    var launcher: int = e["launcher"]
    var ammo: Array = e["ammo"]
    var defs: Array = e["def"]
    var hp0: int = int(island_hp[0])
    money_label.text = "$%d   (+$%d / 2s)" % [money, _income(0)]
    stats_label.text = "HP %d   Launcher Lv%d   Air defense %d/%d\nCruise %d  Ballistic %d  Hyper %d  MIRV %d" % [
        hp0, launcher, defs.size(), MAX_DEFENSES, int(ammo[0]), int(ammo[1]), int(ammo[2]), int(ammo[3])]
    if island_count > 1 and selected_enemy < island_hp.size():
        var te: Dictionary = emp[selected_enemy]
        var tdefs: Array = te["def"]
        target_button.text = "TARGET: Enemy %d (%d HP)\nLauncher %d  Houses %d  Defense %d" % [
            selected_enemy, int(island_hp[selected_enemy]), int(te["launcher"]), int(te["houses"]), tdefs.size()]
    if launcher >= 1 and cur_ammo < launcher:
        ammo_button.text = "AMMO: %s x%d\ntap to switch" % [MISSILES[cur_ammo]["short"], int(ammo[cur_ammo])]
    else:
        ammo_button.text = "AMMO: none\nbuild a launcher"
    # economy tab
    btn_house.text = "Build House  $%d   (%d/%d)\nIncome +$6 per 2s" % [_house_price(0), int(e["houses"]), MAX_HOUSES]
    btn_house.disabled = int(e["houses"]) >= MAX_HOUSES or money < _house_price(0)
    btn_repair.text = "Repair Base +30 HP  $%d\nBase HP %d / 100" % [PRICE_REPAIR, hp0]
    btn_repair.disabled = hp0 >= 100 or money < PRICE_REPAIR
    # missiles tab
    if launcher < 4:
        btn_launcher.text = "Launcher Lv%d -> Lv%d  $%d\nUnlocks %s" % [launcher, launcher + 1, int(LAUNCH_PRICES[launcher]), MISSILES[launcher]["name"]]
        btn_launcher.disabled = money < int(LAUNCH_PRICES[launcher])
    else:
        btn_launcher.text = "Launcher: MAX LEVEL\nAll missiles unlocked"
        btn_launcher.disabled = true
    for t in range(4):
        var mb: Button = btn_missiles[t]
        var info: Dictionary = MISSILES[t]
        if launcher >= t + 1:
            mb.text = "%s  $%d   (have %d)\n%s, %d dmg" % [info["name"], int(info["price"]), int(ammo[t]), info["cls"], int(info["dmg"]) * int(info["warheads"])]
            mb.disabled = money < int(info["price"])
        else:
            mb.text = "%s  LOCKED\nNeeds Launcher Lv%d" % [info["name"], t + 1]
            mb.disabled = true
    # defense tab
    for t in range(4):
        var db: Button = btn_defenses[t]
        var di: Dictionary = DEFENSES[t]
        db.text = "%s  $%d\n%s, range %d, %d%% hit" % [di["name"], int(di["price"]), di["cls"], int(di["range"]), int(float(di["chance"]) * 100.0)]
        db.disabled = money < int(di["price"]) or defs.size() >= MAX_DEFENSES


func _update_fire_button() -> void:
    if fire_button == null or emp.is_empty():
        return
    var e: Dictionary = emp[0]
    if float(e["cool"]) > 0.0:
        fire_button.text = "RELOADING"
        fire_button.disabled = true
    else:
        fire_button.text = "FIRE!"
        fire_button.disabled = false


# =====================================================================
# Touch input: left = floating joystick, right = camera drag
# =====================================================================
func _over_ui(pos: Vector2) -> bool:
    for c in [hud_panel, top_right, bottom_right, build_panel, place_bar, overlay]:
        var ctl: Control = c
        if ctl.is_visible_in_tree() and ctl.get_global_rect().has_point(pos):
            return true
    return false


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
    if d.length() > 80.0:
        d = d.normalized() * 80.0
    joy_vec = d / 80.0
    joy_knob.position = joy_center + d - joy_knob.size / 2.0


func _input(event: InputEvent) -> void:
    if game_state != "playing":
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
            cam_yaw += de.relative.x * 0.006
            cam_pitch = clampf(cam_pitch - de.relative.y * 0.004, 0.12, 1.1)
            cam_auto = 0.0
