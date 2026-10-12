extends Node3D
## Missile Tycoon Islands 2.0
## Third-person island battle for phones (Godot 4.x, Compatibility renderer).
## Left half of the screen = floating joystick, right half = drag to look around.

const SAVE_PATH := "user://missile_tycoon_v2.json"
const RING := [0.0, 0.0, 15.0, 17.0, 18.5]
const WALK_SPEED := 5.5
const PLAYER_LIMIT := 4.2
const MAX_HOUSES := 9
const FIRE_COOLDOWN := 1.3
const PRICE_HOUSE := 100
const PRICE_MISSILE := 60
const PRICE_LAUNCHER := 250
const PRICE_DEFENSE := 200
const PRICE_WARHEAD := 150
const PRICE_REPAIR := 100
const TEAM_COLORS := [
    Color(0.2, 0.55, 1.0),
    Color(0.9, 0.22, 0.2),
    Color(0.7, 0.3, 0.9),
    Color(1.0, 0.6, 0.1),
]

# ---- game state ----
var money := 400
var houses := 0
var missiles := 0
var launcher_level := 0
var defense_level := 0
var damage_level := 0
var island_count := 2
var island_hp: Array = [100, 100]
var selected_enemy := 1
var game_state := "menu"  # menu, playing, paused, won, lost
var elapsed := 0.0
var fire_timer := 0.0
var enemy_timer := 8.0

# ---- world ----
var level_root: Node3D
var camera: Camera3D
var island_nodes: Array = []
var island_pos: Array = []
var island_labels: Array = []
var launcher_pivots: Array = []
var house_nodes: Array = []
var npcs: Array = []
var clouds: Array = []
var projectiles: Array = []
var defense_node: Node3D
var dish_node: Node3D
var player: Node3D
var player_off := Vector3(0.0, 0.0, 1.0)
var walk_amount := 0.0
var walk_phase := 0.0

# ---- camera ----
var cam_yaw := 0.0
var cam_pitch := 0.42
var cam_dist := 9.5
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
var overlay: Panel
var money_label: Label
var stats_label: Label
var status_label: Label
var target_button: Button
var build_toggle: Button
var fire_button: Button
var btn_house: Button
var btn_missile: Button
var btn_launcher: Button
var btn_defense: Button
var btn_warhead: Button
var btn_repair: Button
var joy_base: Panel
var joy_knob: Panel
var ov_title: Label
var ov_sub: Label
var btn_resume: Button
var btn_continue: Button


func _ready() -> void:
    randomize()
    _build_environment()
    _build_ui()
    _reset_state(2)
    _build_world()
    get_viewport().size_changed.connect(_reset_joystick)
    var t := Timer.new()
    t.wait_time = 2.0
    t.autostart = true
    t.timeout.connect(_earn_money)
    add_child(t)
    _show_overlay("MISSILE TYCOON", "Build your island, buy missiles and destroy the enemy islands!")
    _refresh_ui()


# =====================================================================
# Helpers
# =====================================================================
func _yaw_to(d: Vector3) -> float:
    return atan2(-d.x, -d.z)


func _mat(color: Color, rough: float = 0.85) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = rough
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
    m.mesh = s
    m.position = pos
    m.material_override = _mat(color)
    parent.add_child(m)
    return m


func _vibrate(ms: int) -> void:
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(ms)


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
    env.fog_density = 0.006
    var we := WorldEnvironment.new()
    we.environment = env
    add_child(we)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50.0, -35.0, 0.0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 70.0
    add_child(sun)

    var water := MeshInstance3D.new()
    var pm := PlaneMesh.new()
    pm.size = Vector2(400.0, 400.0)
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
    for k in range(9):
        var c := Node3D.new()
        c.position = Vector3(randf_range(-80.0, 80.0), randf_range(22.0, 34.0), randf_range(-80.0, 80.0))
        for j in range(4):
            var m := MeshInstance3D.new()
            var s := SphereMesh.new()
            s.radius = 1.0
            s.height = 2.0
            m.mesh = s
            m.scale = Vector3(randf_range(3.0, 5.0), randf_range(1.2, 1.8), randf_range(2.5, 4.0))
            m.position = Vector3(float(j) * 3.2 - 5.0, randf_range(-0.5, 0.5), randf_range(-1.5, 1.5))
            m.material_override = cloud_mat
            m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
            c.add_child(m)
        add_child(c)
        clouds.append(c)

    camera = Camera3D.new()
    camera.fov = 70.0
    camera.far = 400.0
    camera.current = true
    add_child(camera)


# =====================================================================
# World building
# =====================================================================
func _reset_state(count: int) -> void:
    money = 400
    houses = 0
    missiles = 0
    launcher_level = 0
    defense_level = 0
    damage_level = 0
    island_count = count
    island_hp = []
    for i in range(count):
        island_hp.append(100)
    selected_enemy = 1
    elapsed = 0.0
    fire_timer = 0.0
    enemy_timer = 8.0
    player_off = Vector3(0.0, 0.0, 1.0)


func _build_world() -> void:
    if level_root != null and is_instance_valid(level_root):
        level_root.queue_free()
    level_root = Node3D.new()
    add_child(level_root)
    island_nodes.clear()
    island_pos.clear()
    island_labels.clear()
    launcher_pivots.clear()
    house_nodes.clear()
    npcs.clear()
    projectiles.clear()
    defense_node = null
    dish_node = null

    var radius: float = RING[island_count]
    for i in range(island_count):
        var ang: float = PI / 2.0 + float(i) * TAU / float(island_count)
        var p := Vector3(cos(ang) * radius, 0.0, sin(ang) * radius)
        island_pos.append(p)
        launcher_pivots.append(null)
        var isl := _make_island(i, p)
        level_root.add_child(isl)
        island_nodes.append(isl)

    # player
    player = _make_character(TEAM_COLORS[0])
    level_root.add_child(player)

    # restore purchases on the player island
    var home: Node3D = island_nodes[0]
    for k in range(houses):
        _add_house_at(k, false)
    if launcher_level > 0:
        launcher_pivots[0] = _build_launcher(home, TEAM_COLORS[0])
    if defense_level > 0:
        _build_defense()

    # hp bars for destroyed islands
    for i in range(island_count):
        if int(island_hp[i]) <= 0:
            var isl2: Node3D = island_nodes[i]
            isl2.position.y = -4.0
    _ensure_target()
    _update_hp_widgets()
    _look_at_target(false)


func _make_island(i: int, p: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Island_%d" % i
    root.position = p
    root.rotation.y = _yaw_to(-p)
    var team: Color = TEAM_COLORS[i % 4]

    var sand := _cyl(root, 6.0, 5.2, 1.0, Vector3(0.0, -0.2, 0.0), Color(0.86, 0.75, 0.5))
    sand.name = "Sand"
    var grass_col := Color(0.3, 0.7, 0.28) if i == 0 else Color(0.36, 0.62, 0.28)
    _cyl(root, 5.2, 5.0, 0.4, Vector3(0.0, 0.4, 0.0), grass_col)

    for k in range(7):
        var a: float = float(k) * 0.9 + 0.3
        var rock := _sphere(root, 0.7, Vector3(cos(a) * 5.5, 0.15, sin(a) * 5.5), Color(0.5, 0.52, 0.55))
        rock.scale = Vector3(1.0, 0.6, 0.8)

    for pp in [Vector3(-4.0, 0.6, 1.6), Vector3(4.0, 0.6, 1.4), Vector3(3.4, 0.6, -2.8), Vector3(-2.8, 0.6, -3.4)]:
        _add_palm(root, pp)

    # team flag
    _cyl(root, 0.05, 0.05, 3.0, Vector3(-3.6, 2.1, -0.4), Color(0.8, 0.8, 0.8))
    _box(root, Vector3(0.05, 0.6, 1.0), Vector3(-3.6, 3.3, -0.9), team)

    # hp widget
    var title := "YOU" if i == 0 else "ENEMY %d" % i
    var w := _make_hp_widget(root, title, team)
    island_labels.append(w)

    if i > 0:
        # enemy base: two houses, a launcher and a guard
        _add_house(root, Vector3(-1.5, 0.6, 2.2), team.darkened(0.2))
        _add_house(root, Vector3(1.5, 0.6, 2.8), team.darkened(0.35))
        launcher_pivots[i] = _build_launcher(root, team)
        var guard := _make_character(team)
        guard.position = Vector3(0.6, 0.6, 0.6)
        root.add_child(guard)
        npcs.append(guard)
    return root


func _add_palm(parent: Node3D, pos: Vector3) -> void:
    var palm := Node3D.new()
    palm.position = pos
    palm.rotation.z = randf_range(-0.12, 0.12)
    parent.add_child(palm)
    _cyl(palm, 0.12, 0.2, 2.6, Vector3(0.0, 1.3, 0.0), Color(0.5, 0.33, 0.16))
    var top := Node3D.new()
    top.position = Vector3(0.0, 2.6, 0.0)
    palm.add_child(top)
    for k in range(6):
        var piv := Node3D.new()
        piv.rotation.y = float(k) * TAU / 6.0
        top.add_child(piv)
        var leaf := _box(piv, Vector3(1.5, 0.06, 0.5), Vector3(0.75, 0.0, 0.0), Color(0.14, 0.55, 0.2))
        leaf.rotation.z = -0.35
    _sphere(top, 0.2, Vector3(0.0, -0.1, 0.0), Color(0.4, 0.25, 0.1))


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
    _box(h, Vector3(0.22, 0.5, 0.22), Vector3(0.45, 1.6, 0.25), Color(0.4, 0.4, 0.42))
    return h


func _add_house_at(k: int, animate: bool) -> void:
    var home: Node3D = island_nodes[0]
    var col := (k % 3)
    var row := int(floor(float(k) / 3.0))
    var pos := Vector3(float(col - 1) * 1.8, 0.6, 1.4 + float(row) * 1.5)
    var palette := [Color(0.95, 0.68, 0.24), Color(0.9, 0.45, 0.25), Color(0.35, 0.65, 0.9), Color(0.85, 0.85, 0.5)]
    var h := _add_house(home, pos, palette[k % 4])
    house_nodes.append(h)
    if animate:
        h.scale = Vector3(0.01, 0.01, 0.01)
        var tw := create_tween()
        tw.tween_property(h, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _build_launcher(parent: Node3D, team: Color) -> Node3D:
    var piv := Node3D.new()
    piv.position = Vector3(0.0, 0.6, -2.6)
    parent.add_child(piv)
    _cyl(piv, 0.95, 1.1, 0.4, Vector3(0.0, 0.2, 0.0), Color(0.25, 0.27, 0.3))
    _box(piv, Vector3(1.0, 0.5, 1.0), Vector3(0.0, 0.65, 0.0), team.darkened(0.3))
    var tube := _cyl(piv, 0.22, 0.28, 1.6, Vector3(0.0, 1.1, -0.5), Color(0.75, 0.77, 0.8))
    tube.rotation.x = deg_to_rad(-40.0)
    var tip := _cyl(piv, 0.26, 0.26, 0.2, Vector3(0.0, 1.62, -0.9), Color(0.9, 0.3, 0.2))
    tip.rotation.x = deg_to_rad(-40.0)
    return piv


func _build_defense() -> void:
    if defense_node != null and is_instance_valid(defense_node):
        defense_node.queue_free()
    var home: Node3D = island_nodes[0]
    defense_node = Node3D.new()
    defense_node.position = Vector3(3.6, 0.6, -0.6)
    home.add_child(defense_node)
    _cyl(defense_node, 0.6, 0.75, 0.5, Vector3(0.0, 0.25, 0.0), Color(0.3, 0.32, 0.36))
    _cyl(defense_node, 0.18, 0.25, 2.2, Vector3(0.0, 1.5, 0.0), Color(0.6, 0.62, 0.66))
    dish_node = Node3D.new()
    dish_node.position = Vector3(0.0, 2.7, 0.0)
    defense_node.add_child(dish_node)
    var dish := _sphere(dish_node, 0.7, Vector3(0.0, 0.0, 0.0), Color(0.85, 0.87, 0.9))
    dish.scale = Vector3(1.0, 0.25, 1.0)
    _box(dish_node, Vector3(0.1, 0.1, 0.9), Vector3(0.0, 0.25, -0.5), Color(0.9, 0.3, 0.2))
    for k in range(defense_level):
        _sphere(defense_node, 0.14, Vector3(-0.5 + float(k) * 0.5, 0.65, 0.5), Color(0.2, 0.95, 0.4))


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
    root.position = Vector3(0.0, 6.2, 0.0)
    parent.add_child(root)
    var lab := Label3D.new()
    lab.text = title
    lab.font_size = 72
    lab.pixel_size = 0.012
    lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    lab.no_depth_test = true
    lab.render_priority = 3
    lab.outline_size = 16
    lab.modulate = col.lightened(0.3)
    lab.position = Vector3(0.0, 0.7, 0.0)
    root.add_child(lab)
    var bg := _bar_quad(Vector2(4.4, 0.5), Color(0.0, 0.0, 0.0, 0.6), 0)
    root.add_child(bg)
    var fg := _bar_quad(Vector2(4.0, 0.3), Color(0.2, 0.9, 0.3, 0.95), 1)
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
# Main loop
# =====================================================================
func _process(delta: float) -> void:
    elapsed += delta if game_state == "playing" else 0.0
    _animate_world(delta)
    if game_state == "playing":
        _move_player(delta)
        fire_timer = maxf(0.0, fire_timer - delta)
        enemy_timer -= delta
        if enemy_timer <= 0.0:
            _enemy_attack()
            enemy_timer = randf_range(4.0, 7.0) * maxf(0.55, 1.0 - elapsed / 420.0)
        _update_projectiles(delta)
    elif game_state == "menu":
        cam_yaw += delta * 0.12
    _update_camera(delta)
    _update_fire_button()


func _animate_world(delta: float) -> void:
    for c in clouds:
        var cn: Node3D = c
        cn.position.x += delta * 1.2
        if cn.position.x > 90.0:
            cn.position.x = -90.0
    if dish_node != null and is_instance_valid(dish_node):
        dish_node.rotation.y += delta * 2.0
    for k in range(npcs.size()):
        var n: Node3D = npcs[k]
        if is_instance_valid(n):
            n.rotation.y = sin(elapsed * 0.7 + float(k) * 2.0 + Time.get_ticks_msec() * 0.0004) * 0.9


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
    camera.look_at(focus + fwd * 2.5 + Vector3(0.0, 0.4, 0.0), Vector3.UP)


# =====================================================================
# Combat
# =====================================================================
func _make_missile_model(friendly: bool) -> Node3D:
    var root := Node3D.new()
    var body_col := Color(0.93, 0.93, 0.96) if friendly else Color(0.4, 0.08, 0.08)
    var tip_col := Color(1.0, 0.45, 0.1) if friendly else Color(0.95, 0.15, 0.15)
    var body := _cyl(root, 0.2, 0.2, 1.2, Vector3.ZERO, body_col)
    body.rotation.x = PI / 2.0
    var nose := _cyl(root, 0.0, 0.2, 0.45, Vector3(0.0, 0.0, -0.82), tip_col)
    nose.rotation.x = -PI / 2.0
    _box(root, Vector3(0.7, 0.04, 0.3), Vector3(0.0, 0.0, 0.45), tip_col)
    _box(root, Vector3(0.04, 0.7, 0.3), Vector3(0.0, 0.0, 0.45), tip_col)
    var flame := MeshInstance3D.new()
    var fs := SphereMesh.new()
    fs.radius = 0.18
    fs.height = 0.36
    flame.mesh = fs
    flame.position = Vector3(0.0, 0.0, 0.75)
    flame.scale = Vector3(1.0, 1.0, 1.8)
    flame.material_override = _glow_mat(Color(1.0, 0.6, 0.1))
    root.add_child(flame)
    _add_trail(root)
    return root


func _add_trail(parent: Node3D) -> void:
    var p := CPUParticles3D.new()
    p.amount = 30
    p.lifetime = 0.7
    p.local_coords = false
    p.direction = Vector3(0.0, 0.0, 1.0)
    p.spread = 20.0
    p.initial_velocity_min = 0.3
    p.initial_velocity_max = 0.8
    p.gravity = Vector3.ZERO
    var pm := SphereMesh.new()
    pm.radius = 0.14
    pm.height = 0.28
    var pmat := StandardMaterial3D.new()
    pmat.albedo_color = Color(0.85, 0.85, 0.85)
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
    return piv.global_position + Vector3(0.0, 1.7, 0.0) + fwd * 1.0


func _spawn_missile(attacker: int, target: int, dmg: int) -> void:
    var tpos: Vector3 = island_pos[target]
    var to_pos := tpos + Vector3(randf_range(-1.2, 1.2), 1.4, randf_range(-1.2, 1.2))
    _aim_launcher(attacker, to_pos)
    var from_pos := _muzzle(attacker)
    var m := _make_missile_model(attacker == 0)
    level_root.add_child(m)
    m.position = from_pos
    var dist := from_pos.distance_to(to_pos)
    var intercept := false
    if target == 0 and attacker != 0:
        intercept = randf() < minf(0.85, float(defense_level) * 0.28)
    projectiles.append({
        "node": m, "start": from_pos, "end": to_pos, "t": 0.0,
        "dur": clampf(dist / 20.0, 1.2, 2.4), "h": 5.0 + dist * 0.18,
        "attacker": attacker, "target": target, "dmg": dmg, "intercept": intercept,
    })


func _update_projectiles(delta: float) -> void:
    for i in range(projectiles.size() - 1, -1, -1):
        var d: Dictionary = projectiles[i]
        var node: Node3D = d["node"]
        if not is_instance_valid(node):
            projectiles.remove_at(i)
            continue
        var t: float = float(d["t"]) + delta / float(d["dur"])
        d["t"] = t
        var s: Vector3 = d["start"]
        var e: Vector3 = d["end"]
        var h: float = d["h"]
        var tt: float = minf(t, 1.0)
        node.position = _arc(s, e, tt, h)
        var ahead := _arc(s, e, minf(tt + 0.03, 1.0), h)
        if ahead.distance_to(node.position) > 0.01:
            node.look_at(ahead, Vector3.UP)
        if bool(d["intercept"]) and t >= 0.72:
            _explode(node.position, Color(0.6, 0.9, 1.0), 0.8)
            node.queue_free()
            projectiles.remove_at(i)
            _say("AIR DEFENSE intercepted an enemy missile!")
            continue
        if t >= 1.0:
            node.queue_free()
            projectiles.remove_at(i)
            _on_hit(d)


func _on_hit(d: Dictionary) -> void:
    var target: int = d["target"]
    var attacker: int = d["attacker"]
    var dmg: int = d["dmg"]
    var pos: Vector3 = d["end"]
    _explode(pos, Color(1.0, 0.5, 0.1), 1.2)
    if int(island_hp[target]) <= 0 or game_state != "playing":
        return
    island_hp[target] = maxi(0, int(island_hp[target]) - dmg)
    if target == 0:
        _vibrate(150)
        _say("Your base was hit! -%d HP" % dmg)
    elif attacker == 0:
        _say("Direct hit on Enemy %d! (%d HP left)" % [target, int(island_hp[target])])
    if int(island_hp[target]) <= 0:
        _island_destroyed(target)
    _update_hp_widgets()
    _refresh_ui()
    _save_game()


func _island_destroyed(i: int) -> void:
    if i == 0:
        _game_over(false)
        return
    money += 200
    _say("Enemy %d destroyed! +$200" % i)
    var isl: Node3D = island_nodes[i]
    var tw := create_tween()
    tw.tween_property(isl, "position:y", -4.0, 2.5)
    var any_alive := false
    for k in range(1, island_count):
        if int(island_hp[k]) > 0:
            any_alive = true
    if not any_alive:
        _game_over(true)
    else:
        _ensure_target()
        _look_at_target(true)


func _enemy_attack() -> void:
    var alive: Array = []
    for i in range(1, island_count):
        if int(island_hp[i]) > 0:
            alive.append(i)
    if alive.is_empty():
        return
    var attacker: int = alive[randi() % alive.size()]
    var target: int = 0
    if alive.size() > 1 and randf() < 0.4:
        var others: Array = alive.duplicate()
        others.erase(attacker)
        target = others[randi() % others.size()]
    var dmg: int = mini(25, 10 + int(elapsed / 90.0))
    _spawn_missile(attacker, target, dmg)


func _fire() -> void:
    if game_state != "playing" or fire_timer > 0.0:
        return
    if launcher_level < 1:
        _say("Build a launcher first (BUILD / UPGRADE menu).")
        return
    if missiles < 1:
        _say("No missiles! Buy one in the BUILD / UPGRADE menu.")
        return
    _ensure_target()
    if int(island_hp[selected_enemy]) <= 0:
        return
    missiles -= 1
    fire_timer = FIRE_COOLDOWN
    _spawn_missile(0, selected_enemy, 20 + damage_level * 10)
    _vibrate(40)
    _say("Missile away!")
    _refresh_ui()


func _explode(pos: Vector3, color: Color, size: float) -> void:
    var flash := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 1.0
    sm.height = 2.0
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
    tw.tween_property(flash, "scale", Vector3.ONE * 2.2 * size, 0.35)
    tw.tween_property(mat, "albedo_color:a", 0.0, 0.35)
    tw.chain().tween_callback(flash.queue_free)

    var p := CPUParticles3D.new()
    p.one_shot = true
    p.amount = 36
    p.lifetime = 0.9
    p.explosiveness = 1.0
    p.direction = Vector3.UP
    p.spread = 180.0
    p.initial_velocity_min = 3.0 * size
    p.initial_velocity_max = 8.0 * size
    p.gravity = Vector3(0.0, -7.0, 0.0)
    var pm := SphereMesh.new()
    pm.radius = 0.16
    pm.height = 0.32
    pm.material = _glow_mat(color)
    p.mesh = pm
    p.position = pos
    level_root.add_child(p)
    p.emitting = true
    get_tree().create_timer(1.6).timeout.connect(p.queue_free)


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
    game_state = "playing"
    _say("Walk with the joystick, drag the right side to look around. Build a launcher, buy missiles, destroy the enemies!")
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
    await get_tree().create_timer(1.6).timeout
    if game_state == "won":
        _show_overlay("VICTORY!", "All enemy islands are destroyed. You are the missile tycoon!")
    elif game_state == "lost":
        _show_overlay("YOUR ISLAND FELL", "Build air defense and repair your base next time.")


func _earn_money() -> void:
    if game_state != "playing":
        return
    money += _income()
    _refresh_ui()


func _income() -> int:
    return 15 + houses * 6


# =====================================================================
# Purchases
# =====================================================================
func _buy_house() -> void:
    if houses >= MAX_HOUSES:
        _say("Island is full of houses!")
        return
    if money < PRICE_HOUSE:
        _say("Need $%d for a house." % PRICE_HOUSE)
        return
    money -= PRICE_HOUSE
    _add_house_at(houses, true)
    houses += 1
    _say("House built! Income is now $%d / 2s." % _income())
    _after_buy()


func _buy_missile() -> void:
    if money < PRICE_MISSILE:
        _say("Need $%d for a missile." % PRICE_MISSILE)
        return
    money -= PRICE_MISSILE
    missiles += 1
    _say("Missile bought.")
    _after_buy()


func _buy_launcher() -> void:
    if launcher_level > 0:
        return
    if money < PRICE_LAUNCHER:
        _say("Need $%d for a launcher." % PRICE_LAUNCHER)
        return
    money -= PRICE_LAUNCHER
    launcher_level = 1
    var home: Node3D = island_nodes[0]
    launcher_pivots[0] = _build_launcher(home, TEAM_COLORS[0])
    _say("Launcher built. You can fire missiles now!")
    _after_buy()


func _buy_defense() -> void:
    if defense_level >= 3:
        return
    if money < PRICE_DEFENSE:
        _say("Need $%d for air defense." % PRICE_DEFENSE)
        return
    money -= PRICE_DEFENSE
    defense_level += 1
    _build_defense()
    _say("Air defense level %d. It can intercept enemy missiles." % defense_level)
    _after_buy()


func _buy_warhead() -> void:
    if damage_level >= 3:
        return
    if money < PRICE_WARHEAD:
        _say("Need $%d for a warhead upgrade." % PRICE_WARHEAD)
        return
    money -= PRICE_WARHEAD
    damage_level += 1
    _say("Warhead level %d. Your missiles hit harder (%d damage)." % [damage_level, 20 + damage_level * 10])
    _after_buy()


func _buy_repair() -> void:
    if int(island_hp[0]) >= 100:
        _say("Your base is already at full health.")
        return
    if money < PRICE_REPAIR:
        _say("Need $%d to repair." % PRICE_REPAIR)
        return
    money -= PRICE_REPAIR
    island_hp[0] = mini(100, int(island_hp[0]) + 30)
    _say("Base repaired.")
    _update_hp_widgets()
    _after_buy()


func _after_buy() -> void:
    _refresh_ui()
    _save_game()


# =====================================================================
# Save / load
# =====================================================================
func _has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)


func _save_game() -> void:
    if game_state != "playing":
        return
    var data := {
        "money": money, "houses": houses, "missiles": missiles,
        "launcher_level": launcher_level, "defense_level": defense_level,
        "damage_level": damage_level, "island_count": island_count,
        "island_hp": island_hp, "selected_enemy": selected_enemy, "elapsed": elapsed,
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
    var count := clampi(int(parsed.get("island_count", 2)), 2, 4)
    var hp_raw = parsed.get("island_hp", [])
    if typeof(hp_raw) != TYPE_ARRAY or hp_raw.size() != count:
        return false
    if int(hp_raw[0]) <= 0:
        return false
    _reset_state(count)
    money = int(parsed.get("money", 400))
    houses = clampi(int(parsed.get("houses", 0)), 0, MAX_HOUSES)
    missiles = int(parsed.get("missiles", 0))
    launcher_level = clampi(int(parsed.get("launcher_level", 0)), 0, 1)
    defense_level = clampi(int(parsed.get("defense_level", 0)), 0, 3)
    damage_level = clampi(int(parsed.get("damage_level", 0)), 0, 3)
    selected_enemy = int(parsed.get("selected_enemy", 1))
    elapsed = float(parsed.get("elapsed", 0.0))
    island_hp = []
    for v in hp_raw:
        island_hp.append(clampi(int(v), 0, 100))
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
        sb.content_margin_top = 10.0
        sb.content_margin_bottom = 10.0
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
    status_label.custom_minimum_size = Vector2(470.0, 0.0)
    status_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
    hv.add_child(status_label)

    # --- target + menu (top right) ---
    top_right = VBoxContainer.new()
    ui_root.add_child(top_right)
    target_button = _make_button("", Color(0.75, 0.2, 0.2), _cycle_target)
    target_button.custom_minimum_size = Vector2(340.0, 84.0)
    top_right.add_child(target_button)
    top_right.add_child(_make_button("MENU", Color(0.25, 0.3, 0.42), _on_menu_pressed))
    top_right.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
    top_right.grow_horizontal = Control.GROW_DIRECTION_BEGIN

    # --- build menu + fire (bottom right) ---
    bottom_right = VBoxContainer.new()
    bottom_right.add_theme_constant_override("separation", 10)
    ui_root.add_child(bottom_right)
    build_panel = PanelContainer.new()
    _style_panel(build_panel)
    build_panel.visible = false
    bottom_right.add_child(build_panel)
    var bv := VBoxContainer.new()
    build_panel.add_child(bv)
    btn_house = _make_button("", Color(0.2, 0.55, 0.35), _buy_house)
    btn_missile = _make_button("", Color(0.2, 0.55, 0.35), _buy_missile)
    btn_launcher = _make_button("", Color(0.2, 0.55, 0.35), _buy_launcher)
    btn_defense = _make_button("", Color(0.2, 0.55, 0.35), _buy_defense)
    btn_warhead = _make_button("", Color(0.2, 0.55, 0.35), _buy_warhead)
    btn_repair = _make_button("", Color(0.2, 0.55, 0.35), _buy_repair)
    for b in [btn_house, btn_missile, btn_launcher, btn_defense, btn_warhead, btn_repair]:
        var bb: Button = b
        bb.custom_minimum_size = Vector2(380.0, 56.0)
        bv.add_child(bb)
    build_toggle = _make_button("BUILD / UPGRADE", Color(0.2, 0.5, 0.85), _on_build_toggle)
    build_toggle.custom_minimum_size = Vector2(380.0, 70.0)
    bottom_right.add_child(build_toggle)
    fire_button = _make_button("FIRE!", Color(0.85, 0.25, 0.15), _fire)
    fire_button.custom_minimum_size = Vector2(380.0, 110.0)
    fire_button.add_theme_font_size_override("font_size", 38)
    bottom_right.add_child(fire_button)
    bottom_right.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
    bottom_right.grow_horizontal = Control.GROW_DIRECTION_BEGIN
    bottom_right.grow_vertical = Control.GROW_DIRECTION_BEGIN

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
    btn_resume.visible = game_state == "paused"
    btn_continue.visible = _has_save() and game_state != "paused"
    overlay.show()
    if game_state == "playing":
        game_state = "paused"
        btn_resume.visible = true
        btn_continue.visible = false


func _on_menu_pressed() -> void:
    if game_state != "playing":
        return
    build_panel.visible = false
    game_state = "paused"
    _show_overlay("PAUSED", "Your progress is saved automatically.")


func _on_build_toggle() -> void:
    build_panel.visible = not build_panel.visible


func _say(message: String) -> void:
    if status_label:
        status_label.text = message


func _refresh_ui() -> void:
    if money_label == null:
        return
    money_label.text = "$%d   (+$%d / 2s)" % [money, _income()]
    var hp0: int = int(island_hp[0]) if island_hp.size() > 0 else 100
    stats_label.text = "Base HP %d   Missiles %d\nLauncher %s   Air Def %d/3   Warhead %d/3" % [
        hp0, missiles, "YES" if launcher_level > 0 else "NO", defense_level, damage_level]
    if island_count > 1 and selected_enemy < island_hp.size():
        target_button.text = "TARGET: Enemy %d (%d HP)\ntap to switch" % [selected_enemy, int(island_hp[selected_enemy])]
    btn_house.text = "House  $%d   (%d/%d)" % [PRICE_HOUSE, houses, MAX_HOUSES]
    btn_house.disabled = houses >= MAX_HOUSES or money < PRICE_HOUSE
    btn_missile.text = "Missile  $%d" % PRICE_MISSILE
    btn_missile.disabled = money < PRICE_MISSILE
    btn_launcher.text = "Launcher  $%d" % PRICE_LAUNCHER if launcher_level == 0 else "Launcher: BUILT"
    btn_launcher.disabled = launcher_level > 0 or money < PRICE_LAUNCHER
    btn_defense.text = "Air Defense  $%d   (Lv %d/3)" % [PRICE_DEFENSE, defense_level] if defense_level < 3 else "Air Defense: MAX"
    btn_defense.disabled = defense_level >= 3 or money < PRICE_DEFENSE
    btn_warhead.text = "Warhead  $%d   (Lv %d/3)" % [PRICE_WARHEAD, damage_level] if damage_level < 3 else "Warhead: MAX"
    btn_warhead.disabled = damage_level >= 3 or money < PRICE_WARHEAD
    btn_repair.text = "Repair base +30 HP  $%d" % PRICE_REPAIR
    btn_repair.disabled = hp0 >= 100 or money < PRICE_REPAIR


func _update_fire_button() -> void:
    if fire_button == null:
        return
    if fire_timer > 0.0:
        fire_button.text = "RELOADING"
        fire_button.disabled = true
    else:
        fire_button.text = "FIRE!"
        fire_button.disabled = false


# =====================================================================
# Touch input: left = floating joystick, right = camera drag
# =====================================================================
func _over_ui(pos: Vector2) -> bool:
    for c in [hud_panel, top_right, bottom_right, overlay]:
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
