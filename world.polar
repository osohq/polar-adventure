_desc_effect("cat", "dog") if
    GAME.write("  the ") and GAME.write_blue("cat") and GAME.write(" and the ") and GAME.write_blue("dog") and GAME.write(" are mad at each other\n");

_effect(a: Object, b: Object) if
    _desc_effect(a.desc, b.desc);

_effect(animal: Animal, food: Food) if
    GAME.write("  the ") and GAME.write_blue("{}", animal.desc) and GAME.write(" is eyeing the ") and GAME.write_blue("{}\n", food.desc);

_effect(animal: Animal{favorite_item: fav_item}, _: Object{desc: fav_item}) if
    GAME.write("  the ") and GAME.write_blue("{}", animal.desc) and GAME.write(" really wants the ") and GAME.write_blue("{}\n", fav_item);

_effect(_: Room{desc: "The Farm Plot"},_: Object{desc: "duck"}) if
    GAME.write("  the ") and GAME.write_blue("duck") and GAME.write(" loves to be in the farm plot\n");

_effect(obj: Mushroomy{}) if
    GAME.write("  the ") and GAME.write_blue(obj.desc) and GAME.write(" has little mushrooms growing out of it\n");

# Info gathering
_contains(room: Room, object) if
    object in Objects.all() and
    object.id in room.objects;

_paths(room: Room, passage) if
    passage in Passages.all() and
    room.id in passage.room_ids();

_player_has(obj_desc: String) if
    obj = Objects.get(obj_desc) and
    obj.id in PLAYER.objects;

# Rules

# Large oak door needs the key.
_unlock(_: Room{desc: "The Living Room"}, passage: Passage{desc: "large oak door"}) if
    _player_has("key") and
    GAME.write("  You unlock the door.\n") and
    passage.unlock() and cut;

# Garden gate only opens from the farm plot side.
_unlock(_: Room{desc: "The Farm Plot"}, passage: Passage{desc: "garden gate"}) if
    GAME.write("  You unlock the garden gate.\n") and passage.unlock() and cut;

# only take objects if they are takeable
_take(_: Takeable);

# using the map prints the game map.
_look(_: Object{desc: "map"}) if
    GAME.print_map();

_use(_: Object{desc: "spores"}, obj: Object{}) if
    (
        obj matches Mushroomy and
        GAME.write("  it doesn't seem like ") and GAME.write_blue("{}", obj.desc) and GAME.write(" needs any more") and
        cut
    ) or
    (
        Objects.add_class(obj.id, "Mushroomy") and
        GAME.write("  you sprinkle ") and GAME.write_blue("spores", obj.desc) and GAME.write(" on ") and GAME.write_blue("{}\n", obj.desc)
    );

# using the fireplace requires both wood and matches.
_use(_: Object{desc: "fireplace"}) if
    room = Rooms.get_by_id(PLAYER.room) and
    fire = Objects.get("fire") and
    (
        fire.id in room.objects and
        GAME.write("  There is already a ") and GAME.write_blue("fire\n") and
        cut
    ) or
    (
        _player_has("wood") and
        _player_has("matches") and
        room = Rooms.get_by_id(PLAYER.room) and
        room.add_object(Objects.get("fire").id) and
        PLAYER.remove_object(Objects.get("wood").id) and
        GAME.write("  You started a ") and GAME.write_blue("fire\n") and
        cut
    ) or (GAME.write("Wish you had wood and matches.\n") and false);

_use(_: Object{desc: fav_item}, animal: Animal{favorite_item: fav_item}) if
    GAME.write_blue("  {}", animal.desc) and GAME.write(" smiles, they love the ") and GAME.write_blue("{}\n", fav_item);

# Actions

_unlock(_: Room, passage: Passage) if
    (not passage.locked and cut) or
    (GAME.write("  The {} is locked\n", passage.desc) and false) and cut;

_go(room: Room, passage: Passage, next_room) if
    next_room_id in passage.room_ids() and
    next_room_id != room.id and
    next_room = Rooms.get_by_id(next_room_id);

# Printing
_describe_room_objects(room: Room) if
    _contains(room, object) and
    _describe(object) and
    false;

_look_player_objects() if
    object_id in PLAYER.objects and
    object = Objects.get_by_id(object_id) and
    GAME.write("  You have a ") and
    GAME.write_blue("{}\n", object.desc)
    and false;


_notice_effects(room: Room) if
    forall(a_id in room.objects,
        a = Objects.get_by_id(a_id) and
        _effect(a) or true and
        _effect(room, a) or true and
        forall(b_id in room.objects,
            b = Objects.get_by_id(b_id) and
            _effect(a,b) or true
            )
    ) and false or
    forall(a_id in PLAYER.objects,
        a = Objects.get_by_id(a_id) and
        _effect(a) or true and
        _effect(room, a) or true and
        forall(b_id in room.objects,
            b = Objects.get_by_id(b_id) and
            _effect(a,b) or _effect(b,a) or true
            )
    ) and false;

_player_inventory(_: []) if GAME.write("  You don't have anything.\n") and cut;
_player_inventory(obj_ids: List) if
    forall(obj_id in obj_ids,
        object = Objects.get_by_id(obj_id) and
        GAME.write("  You have a ") and
        GAME.write_blue("{}\n", object.desc));

_inventory() if
    GAME.write("You check your pockets\n") and _player_inventory(PLAYER.objects);

inventory() if _inventory();

look() if
    room = Rooms.get_by_id(PLAYER.room) and
    GAME.write("\n{}\n", room.desc) and
    _describe_room(room) or
    _describe_room_passages(room) or
    _describe_room_objects(room) or
    _notice_effects(room) or true;

go(passage_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    _paths(room, passage) and
    passage.desc = passage_desc and
    _unlock(room, passage) and
    _go(room, passage, next_room) and
    PLAYER.set_room(next_room.id) and
    look();

take(object_desc: String) if
    (
        room = Rooms.get_by_id(PLAYER.room) and
        obj = Objects.get(object_desc) and
        obj matches Object{} and
        obj.id in room.objects and
        room.remove_object(obj.id) and
        PLAYER.add_object(obj.id) and
        _take(obj) and cut
    ) or (GAME.write("  You can't take ") and GAME.write_blue("{}\n", object_desc) and false);

place(object_desc: String) if
    (
        obj = Objects.get(object_desc) and
        obj matches Object{} and
        obj.id in PLAYER.objects and
        room = Rooms.get_by_id(PLAYER.room) and
        PLAYER.remove_object(obj.id) and
        room.add_object(obj.id) and cut
    ) or (GAME.write("  You can't place ") and GAME.write_blue("{}\n", object_desc) and false);

use(object_desc: String) if
    (
        obj = Objects.get(object_desc) and
        obj matches Object{} and
        room = Rooms.get_by_id(PLAYER.room) and
        (obj.id in room.objects or
        obj.id in PLAYER.objects) and
        _use(obj) and cut
    ) or (GAME.write("  You can't use ") and GAME.write_blue("{}\n", object_desc) and false);

use(object_desc: String, on_desc: String) if
    (
        obj = Objects.get(object_desc) and
        obj matches Object{} and
        on = Objects.get(on_desc) and
        on matches Object{} and
        room = Rooms.get_by_id(PLAYER.room) and
        (obj.id in room.objects or
        obj.id in PLAYER.objects) and
        (on.id in room.objects or
        on.id in PLAYER.objects) and
        _use(obj, on) and cut
    ) or (GAME.write("  You can't use ") and GAME.write_blue("{}", object_desc) and GAME.write(" on ") and GAME.write_blue("{}\n", on_desc) and false);

look(object_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    obj = Objects.get(object_desc) and
    (obj.id in room.objects or
    obj.id in PLAYER.objects) and
    _look(obj);

# cheat codes
_cheat_teleport(room_desc: String) if
    room = Rooms.get(room_desc) and PLAYER.set_room(room.id);


#?= _cheat_teleport("a kitchen") and take("matches") and _cheat_teleport("a woodshed") and take("wood") and _cheat_teleport("a library");
#?= _take("spores") and look();