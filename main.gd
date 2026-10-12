extends Node3D

const SAVE_PATH := "user://missile_tycoon_save.json"
const ISLAND_SPACING := 12.5
var money := 400
var houses := 0
var launchers := 0
var missiles := 0
var defense_level := 0
var enemy_hp: Array[int] = [100, 100, 100]
var island_count := 2
var mode_selected := false
var selected_enemy := 1
var player_pos := Vector3(-12.5, 0.0, 0.0)
var move_dir := Vector2.ZERO
var joystick_origin := Vector2(380, 595)
var joystick_active := false
var joystick_id := -1
var shot_busy := false
var projectile: MeshInstance3D
var projectile_start := Vector3.ZERO
var projectile_end := Vector3.ZERO
var projectile_t := 0.0
var target_island := 1
var enemy_cooldown := 5.0
var enemy_projectiles: Array[Dictionary] = []
var world_root: Node3D
var islands: Array[Node3D] = []
var launcher_node: Node3D
var player_marker: MeshInstance3D
var camera: Camera3D
var money_label: Label
var stats_label: Label
var status_label: Label
var fire_button: Button
var joystick_base: ColorRect
var joystick_knob: ColorRect
var island_picker: OptionButton
var mode_picker: OptionButton
var ui_layer: CanvasLayer

func _ready() -> void:
    _load_game()
    _make_world()
    _make_ui()
    _refresh_ui()
    var timer := Timer.new()
    timer.wait_time = 2.0
    timer.autostart = true
    timer.timeout.connect(_earn_money)
    add_child(timer)

func _make_world() -> void:
    world_root = Node3D.new()
    add_child(world_root)
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.75, 0.86, 1.0)
    environment.ambient_light_energy = 0.8
    env.environment = environment
    world_root.add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.3
    world_root.add_child(sun)
    var water := MeshInstance3D.new()
    var water_mesh := PlaneMesh.new()
    water_mesh.size = Vector2(90, 55)
    water.mesh = water_mesh
    water.position.y = -0.55
    var water_mat := StandardMaterial3D.new()
    water_mat.albedo_color = Color(0.05, 0.42, 0.64)
    water_mat.roughness = 0.28
    water.material_override = water_mat
    world_root.add_child(water)
    _rebuild_islands()
    camera = Camera3D.new()
    camera.fov = 75.0
    camera.far = 200.0
    camera.current = true
    world_root.add_child(camera)
    _update_camera(1.0)

func _update_camera(delta: float) -> void:
    # Third-person view: camera sits behind and above the player, looking toward the enemy islands (+X).
    if camera == null:
        return
    var wanted := player_pos + Vector3(-7.0, 4.2, 0.0)
    camera.position = camera.position.lerp(wanted, clampf(delta * 6.0, 0.0, 1.0))
    camera.look_at(player_pos + Vector3(7.0, 0.6, 0.0), Vector3.UP)

func _rebuild_islands() -> void:
    for old in islands:
        if is_instance_valid(old):
            old.queue_free()
    islands.clear()
    for i in range(island_count):
        var x := (float(i) - float(island_count - 1) / 2.0) * ISLAND_SPACING
        var green := Color(0.28, 0.63, 0.24) if i == 0 else Color(0.32, 0.55, 0.25)
        var island := _make_island(Vector3(x, 0, 0), green, "Island_%d" % (i + 1))
        world_root.add_child(island)
        islands.append(island)
        _add_trees(island, x)
        if i == 0:
            _add_house(island, Vector3(x - 1.2, 0.65, -1.0), Color(0.9, 0.42, 0.18))
        else:
            _add_house(island, Vector3(x - 0.5, 0.65, -1.0), Color(0.65, 0.2, 0.18))
            _add_enemy_launcher(island, x)
    player_pos = Vector3(-float(island_count - 1) * ISLAND_SPACING / 2.0, 0.0, 0.0)
    if launchers > 0:
        _build_launcher_visual()
    _make_player_marker()

func _make_island(pos: Vector3, green: Color, island_name: String) -> Node3D:
    var root := Node3D.new()
    root.position = pos
    root.name = island_name
    var sand := MeshInstance3D.new()
    var sand_mesh := CylinderMesh.new()
    sand_mesh.top_radius = 5.4
    sand_mesh.bottom_radius = 4.9
    sand_mesh.height = 1.0
    sand.mesh = sand_mesh
    sand.position.y = -0.05
    var sand_mat := StandardMaterial3D.new()
    sand_mat.albedo_color = Color(0.83, 0.72, 0.47)
    sand.material_override = sand_mat
    root.add_child(sand)
    var grass := MeshInstance3D.new()
    var grass_mesh := CylinderMesh.new()
    grass_mesh.top_radius = 4.8
    grass_mesh.bottom_radius = 4.3
    grass_mesh.height = 0.32
    grass.mesh = grass_mesh
    grass.position.y = 0.52
    var grass_mat := StandardMaterial3D.new()
    grass_mat.albedo_color = green
    grass_mat.roughness = 1.0
    grass.material_override = grass_mat
    root.add_child(grass)
    return root

func _add_trees(parent: Node3D, center_x: float) -> void:
    for p in [Vector3(-3.2,0,1.9), Vector3(3.0,0,2.2), Vector3(-2.8,0,-2.7), Vector3(2.7,0,-2.5)]:
        var trunk := MeshInstance3D.new()
        var tm := CylinderMesh.new()
        tm.top_radius = 0.12
        tm.bottom_radius = 0.18
        tm.height = 0.8
        trunk.mesh = tm
        trunk.position = Vector3(p.x, 0.9, p.z)
        var tmat := StandardMaterial3D.new()
        tmat.albedo_color = Color(0.35, 0.19, 0.08)
        trunk.material_override = tmat
        parent.add_child(trunk)
        var crown := MeshInstance3D.new()
        var cm := SphereMesh.new()
        cm.radius = 0.65
        cm.height = 1.15
        crown.mesh = cm
        crown.position = Vector3(p.x, 1.55, p.z)
        var cmat := StandardMaterial3D.new()
        cmat.albedo_color = Color(0.09, 0.42, 0.18)
        crown.material_override = cmat
        parent.add_child(crown)

func _add_house(parent: Node3D, pos: Vector3, color: Color) -> void:
    var house := Node3D.new()
    house.position = pos
    var body := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(1.15, 0.9, 0.95)
    body.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    body.material_override = mat
    house.add_child(body)
    var roof := MeshInstance3D.new()
    var roof_mesh := PrismMesh.new()
    roof_mesh.size = Vector3(1.35, 0.6, 1.15)
    roof.mesh = roof_mesh
    roof.position.y = 0.68
    var roof_mat := StandardMaterial3D.new()
    roof_mat.albedo_color = Color(0.38, 0.16, 0.12)
    roof.material_override = roof_mat
    house.add_child(roof)
    parent.add_child(house)

func _add_enemy_launcher(parent: Node3D, center_x: float) -> void:
    var node := Node3D.new()
    node.position = Vector3(-1.8, 0.8, 0.9)
    var base := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = Vector3(0.9, 0.3, 0.8)
    base.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.22, 0.25, 0.28)
    base.material_override = mat
    node.add_child(base)
    var tube := MeshInstance3D.new()
    var cm := CylinderMesh.new()
    cm.top_radius = 0.12
    cm.bottom_radius = 0.18
    cm.height = 1.1
    tube.mesh = cm
    tube.rotation.z = deg_to_rad(-50)
    tube.position.y = 0.35
    tube.material_override = mat
    node.add_child(tube)
    parent.add_child(node)

func _make_player_marker() -> void:
    if player_marker and is_instance_valid(player_marker):
        player_marker.queue_free()
    player_marker = MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.28
    mesh.height = 1.1
    player_marker.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.1, 0.65, 1.0)
    player_marker.material_override = mat
    player_marker.position = player_pos + Vector3(0, 1.0, 0)
    world_root.add_child(player_marker)

func _build_launcher_visual() -> void:
    if launcher_node and is_instance_valid(launcher_node):
        launcher_node.queue_free()
    launcher_node = Node3D.new()
    launcher_node.position = Vector3(player_pos.x + 2.0, 0.7, 0.0)
    var base := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = Vector3(1.2, 0.35, 1.0)
    base.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.22, 0.25, 0.28)
    base.material_override = mat
    launcher_node.add_child(base)
    var tube := MeshInstance3D.new()
    var tm := CylinderMesh.new()
    tm.top_radius = 0.18
    tm.bottom_radius = 0.24
    tm.height = 1.7
    tube.mesh = tm
    tube.rotation.z = deg_to_rad(-55)
    tube.position = Vector3(0.15, 0.55, 0)
    tube.material_override = mat
    launcher_node.add_child(tube)
    world_root.add_child(launcher_node)

func _make_ui() -> void:
    ui_layer = CanvasLayer.new()
    add_child(ui_layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(14, 12)
    panel.custom_minimum_size = Vector2(400, 135)
    ui_layer.add_child(panel)
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 4)
    panel.add_child(col)
    var title := Label.new()
    title.text = "MISSILE TYCOON: ISLAND WAR"
    title.add_theme_font_size_override("font_size", 19)
    col.add_child(title)
    money_label = Label.new()
    col.add_child(money_label)
    stats_label = Label.new()
    col.add_child(stats_label)
    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.text = "Choose 1v1, 1v1v1, or 1v1v1v1. Build and defend!"
    col.add_child(status_label)

    var top_right := VBoxContainer.new()
    top_right.position = Vector2(950, 15)
    top_right.custom_minimum_size = Vector2(300, 110)
    ui_layer.add_child(top_right)
    var mode_label := Label.new()
    mode_label.text = "Battle mode"
    top_right.add_child(mode_label)
    mode_picker = OptionButton.new()
    mode_picker.add_item("1 vs 1 (2 islands)", 2)
    mode_picker.add_item("1 vs 1 vs 1 (3 islands)", 3)
    mode_picker.add_item("1 vs 1 vs 1 vs 1 (4 islands)", 4)
    mode_picker.select(0 if island_count == 2 else island_count - 1)
    mode_picker.item_selected.connect(_on_mode_selected)
    top_right.add_child(mode_picker)
    var target_label := Label.new()
    target_label.text = "Target enemy"
    top_right.add_child(target_label)
    island_picker = OptionButton.new()
    island_picker.item_selected.connect(func(idx: int): selected_enemy = int(island_picker.get_item_id(idx)))
    top_right.add_child(island_picker)
    _refresh_target_picker()

    var buttons := VBoxContainer.new()
    buttons.position = Vector2(14, 455)
    buttons.custom_minimum_size = Vector2(285, 250)
    ui_layer.add_child(buttons)
    _add_button(buttons, "Build House - $100", _buy_house)
    _add_button(buttons, "Buy Missile - $75", _buy_missile)
    _add_button(buttons, "Build Launcher - $250", _buy_launcher)
    _add_button(buttons, "Build Air Defense - $200", _buy_defense)
    fire_button = _add_button(buttons, "FIRE AT SELECTED ENEMY", _fire_missile)
    _add_button(buttons, "Save Game", _save_game)

    joystick_base = ColorRect.new()
    joystick_base.color = Color(0.08, 0.12, 0.18, 0.6)
    joystick_base.position = Vector2(320, 535)
    joystick_base.size = Vector2(120, 120)
    joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_layer.add_child(joystick_base)
    joystick_knob = ColorRect.new()
    joystick_knob.color = Color(0.65, 0.82, 0.95, 0.9)
    joystick_knob.position = Vector2(355, 570)
    joystick_knob.size = Vector2(50, 50)
    joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_layer.add_child(joystick_knob)
    var hint := Label.new()
    hint.text = "JOYSTICK (up = forward)"
    hint.position = Vector2(340, 655)
    ui_layer.add_child(hint)

func _add_button(parent: Control, caption: String, callback: Callable) -> Button:
    var b := Button.new()
    b.text = caption
    b.custom_minimum_size = Vector2(270, 36)
    b.pressed.connect(callback)
    parent.add_child(b)
    return b

func _on_mode_selected(index: int) -> void:
    island_count = int(mode_picker.get_item_id(index))
    enemy_hp.clear()
    for i in range(island_count - 1):
        enemy_hp.append(100)
    if world_root:
        _rebuild_islands()
        _refresh_target_picker()
    _say("Battle mode changed. Your island and enemy islands are ready.")
    _refresh_ui()
    _save_game()

func _refresh_target_picker() -> void:
    if not island_picker:
        return
    island_picker.clear()
    for i in range(1, island_count):
        island_picker.add_item("Enemy Island %d (%d%% HP)" % [i, enemy_hp[i - 1]], i)
    if island_picker.item_count > 0:
        island_picker.select(clampi(selected_enemy - 1, 0, island_picker.item_count - 1))
        selected_enemy = int(island_picker.get_selected_id())

func _earn_money() -> void:
    money += 10 + houses * 5
    _refresh_ui()

func _buy_house() -> void:
    if money < 100:
        _say("Not enough cash. Wait for income!")
        return
    money -= 100
    houses += 1
    if not islands.is_empty():
        _add_house(islands[0], Vector3(-1.8 + float((houses - 1) % 3) * 1.4, 0.65, 1.0 + float((houses - 1) / 3) * 1.3), Color(0.95, 0.68, 0.24))
    _say("House built! Your income is higher.")
    _refresh_ui()
    _save_game()

func _buy_missile() -> void:
    if money < 75:
        _say("You need $75 to buy a missile.")
        return
    money -= 75
    missiles += 1
    _say("Missile bought. Build a launcher if you have not.")
    _refresh_ui()
    _save_game()

func _buy_launcher() -> void:
    if launchers > 0:
        _say("You already have a launcher.")
        return
    if money < 250:
        _say("You need $250 to build a launcher.")
        return
    money -= 250
    launchers = 1
    _build_launcher_visual()
    _say("Launcher built. You can now fire missiles.")
    _refresh_ui()
    _save_game()

func _buy_defense() -> void:
    if defense_level >= 3:
        _say("Air defense is fully upgraded!")
        return
    if money < 200:
        _say("You need $200 to build or upgrade air defense.")
        return
    money -= 200
    defense_level += 1
    _say("Air defense upgraded to level %d. It can intercept enemy missiles." % defense_level)
    _refresh_ui()
    _save_game()

func _fire_missile() -> void:
    if shot_busy:
        return
    if launchers < 1:
        _say("First build a launcher for $250.")
        return
    if missiles < 1:
        _say("Buy a missile for $75 first.")
        return
    if selected_enemy < 1 or selected_enemy >= island_count:
        selected_enemy = 1
    missiles -= 1
    shot_busy = true
    projectile = _make_projectile(Color(1.0, 0.32, 0.08))
    projectile_start = Vector3(player_pos.x + 2.0, 1.5, 0.0)
    var target_x := (float(selected_enemy) - float(island_count - 1) / 2.0) * ISLAND_SPACING
    projectile_end = Vector3(target_x, 1.0, -0.8)
    projectile.position = projectile_start
    world_root.add_child(projectile)
    projectile_t = 0.0
    target_island = selected_enemy
    _say("Missile launched at Enemy Island %d!" % selected_enemy)
    _refresh_ui()

func _make_projectile(color: Color) -> MeshInstance3D:
    var p := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.22
    mesh.height = 0.44
    p.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    p.material_override = mat
    return p

func _process(delta: float) -> void:
    _move_player(delta)
    _update_camera(delta)
    if shot_busy and projectile != null and is_instance_valid(projectile):
        projectile_t += delta / 1.25
        var t := clampf(projectile_t, 0.0, 1.0)
        var pos := projectile_start.lerp(projectile_end, t)
        pos.y += sin(t * PI) * 5.0
        projectile.position = pos
        if t >= 1.0:
            projectile.queue_free()
            shot_busy = false
            _damage_enemy(target_island, 25)
            _make_explosion(projectile_end)
            _refresh_ui()
            _save_game()
    _process_enemy_missiles(delta)
    enemy_cooldown -= delta
    if enemy_cooldown <= 0.0:
        enemy_cooldown = randf_range(5.0, 9.0)
        _enemy_attack()

func _damage_enemy(index: int, damage: int) -> void:
    var hp_index := index - 1
    if hp_index < 0 or hp_index >= enemy_hp.size():
        return
    enemy_hp[hp_index] = maxi(0, enemy_hp[hp_index] - damage)
    if enemy_hp[hp_index] == 0:
        _say("Enemy Island %d defeated! Choose another target." % index)
        money += 200
    else:
        _say("Direct hit! Enemy Island %d HP: %d%%" % [index, enemy_hp[hp_index]])
    _refresh_target_picker()

func _enemy_attack() -> void:
    if island_count < 2:
        return
    var alive: Array[int] = []
    for i in range(enemy_hp.size()):
        if enemy_hp[i] > 0:
            alive.append(i + 1)
    if alive.is_empty():
        return
    var enemy := alive[randi_range(0, alive.size() - 1)]
    var start_x := (float(enemy) - float(island_count - 1) / 2.0) * ISLAND_SPACING
    var p := _make_projectile(Color(1.0, 0.05, 0.15))
    world_root.add_child(p)
    p.position = Vector3(start_x - 1.8, 1.4, 0.0)
    var dest := player_pos + Vector3(0, 1.0, 0)
    enemy_projectiles.append({"node": p, "start": p.position, "end": dest, "t": 0.0, "enemy": enemy})

func _process_enemy_missiles(delta: float) -> void:
    for i in range(enemy_projectiles.size() - 1, -1, -1):
        var item: Dictionary = enemy_projectiles[i]
        var p: MeshInstance3D = item["node"]
        if not is_instance_valid(p):
            enemy_projectiles.remove_at(i)
            continue
        item["t"] = float(item["t"]) + delta / 1.6
        var t := clampf(float(item["t"]), 0.0, 1.0)
        var pos: Vector3 = item["start"].lerp(item["end"], t)
        pos.y += sin(t * PI) * 4.0
        p.position = pos
        enemy_projectiles[i] = item
        if t >= 1.0:
            p.queue_free()
            enemy_projectiles.remove_at(i)
            var chance := minf(0.85, float(defense_level) * 0.28)
            if randf() < chance:
                _say("AIR DEFENSE intercepted an enemy missile!")
            else:
                money = maxi(0, money - 25)
                _say("Enemy missile hit your base! Repair cost: $25.")
            _refresh_ui()
            _save_game()

func _make_explosion(pos: Vector3) -> void:
    var boom := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.8
    sphere.height = 1.6
    boom.mesh = sphere
    boom.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.48, 0.05, 0.7)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    boom.material_override = mat
    world_root.add_child(boom)
    var tween := create_tween()
    tween.tween_property(boom, "scale", Vector3(2.0, 2.0, 2.0), 0.35)
    tween.tween_callback(boom.queue_free)

func _move_player(delta: float) -> void:
    if move_dir.length() > 0.1:
        # Camera looks toward +X, so joystick up = forward (+X), right = +Z.
        player_pos.x += -move_dir.y * delta * 4.0
        player_pos.z += move_dir.x * delta * 4.0
        var center_x := -float(island_count - 1) * ISLAND_SPACING / 2.0
        player_pos.x = clampf(player_pos.x, center_x - 3.8, center_x + 3.8)
        player_pos.z = clampf(player_pos.z, -3.8, 3.8)
        if player_marker and is_instance_valid(player_marker):
            player_marker.position = player_pos + Vector3(0, 1.0, 0)
        if launcher_node and is_instance_valid(launcher_node):
            launcher_node.position.x = player_pos.x + 2.0

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and event.position.distance_to(joystick_origin) < 115.0:
            joystick_active = true
            joystick_id = event.index
            _update_joystick(event.position)
        elif not event.pressed and event.index == joystick_id:
            joystick_active = false
            joystick_id = -1
            move_dir = Vector2.ZERO
            _reset_joystick()
    elif event is InputEventScreenDrag and joystick_active and event.index == joystick_id:
        _update_joystick(event.position)

func _update_joystick(screen_pos: Vector2) -> void:
    var center := joystick_origin
    var delta := screen_pos - center
    if delta.length() > 45.0:
        delta = delta.normalized() * 45.0
    move_dir = Vector2(delta.x, delta.y).normalized() if delta.length() > 8.0 else Vector2.ZERO
    joystick_knob.position = center + delta - Vector2(25, 25)

func _reset_joystick() -> void:
    joystick_knob.position = joystick_origin - Vector2(25, 25)

func _refresh_ui() -> void:
    if money_label:
        money_label.text = "Cash: $%d  |  Income: $%d / 2 sec" % [money, 10 + houses * 5]
    if stats_label:
        stats_label.text = "Houses %d | Missiles %d | Launcher %s | Air Defense Lv.%d" % [houses, missiles, "YES" if launchers > 0 else "NO", defense_level]
    if fire_button:
        fire_button.disabled = shot_busy
    if island_picker and island_picker.item_count > 0:
        for i in range(island_picker.item_count):
            var enemy_id := int(island_picker.get_item_id(i))
            island_picker.set_item_text(i, "Enemy Island %d (%d%% HP)" % [enemy_id, enemy_hp[enemy_id - 1]])

func _say(message: String) -> void:
    if status_label:
        status_label.text = message

func _save_game() -> void:
    var data := {"money": money, "houses": houses, "launchers": launchers, "missiles": missiles, "defense_level": defense_level, "enemy_hp": enemy_hp, "island_count": island_count}
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))
    _refresh_ui()

func _load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not f:
        return
    var parsed = JSON.parse_string(f.get_as_text())
    if typeof(parsed) == TYPE_DICTIONARY:
        money = int(parsed.get("money", 400))
        houses = int(parsed.get("houses", 0))
        launchers = int(parsed.get("launchers", 0))
        missiles = int(parsed.get("missiles", 0))
        defense_level = int(parsed.get("defense_level", 0))
        island_count = clampi(int(parsed.get("island_count", 2)), 2, 4)
        enemy_hp.clear()
        var saved_hp = parsed.get("enemy_hp", [])
        for i in range(island_count - 1):
            enemy_hp.append(int(saved_hp[i]) if i < saved_hp.size() else 100)
