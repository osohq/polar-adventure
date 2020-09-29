_desc_effect("cat", "dog") if
    GAME.write("The cat and the dog are mad at each other\n");

_effect(a: Object, b: Object) if
    _desc_effect(a.desc, b.desc);

_effect(a: Animal, b: Food) if
    GAME.write("The {} is eyeing the {}\n", a.desc, b.desc);

# Info gathering
_contains(room: Room, object) if
    object in Objects.all() and
    object.id in room.objects;

_paths(room: Room, passage) if
    passage in Passages.all() and
    room.id in passage.rooms;

_player_has(obj_desc: String) if
    obj = Objects.get(obj_desc) and
    obj.id in PLAYER.objects;

# Rules

# Large oak door needs the key.
_unlock(_: Room{desc: "a living room"}, passage: Passage{desc: "large oak door"}) if
    _player_has("key") and
    GAME.write("  You unlock the door.\n") and
    passage.unlock() and cut;

# Garden gate only opens from the farm plot side.
_unlock(_: Room{desc: "a farm plot"}, passage: Passage{desc: "garden gate"}) if
    GAME.write("  You unlock the garden gate.\n") and passage.unlock() and cut;

# only take objects if they are takeable
_take(_: Takeable);

# _take(object: Object) if
#     not object.desc in ["fireplace"];

# using the map prints the game map.
_look(_: Object{desc: "map"}) if
    GAME.print_map();

# using the fireplace requires both wood and matches.
_use(_: Object{desc: "fireplace"}) if
    (_player_has("wood") and
    _player_has("matches") and
    GAME.write("You started a fire.\n") and
    PLAYER.remove_object(Objects.get("wood").id) and cut) or
    (GAME.write("You need wood and matches to use the fireplace.\n") and false);

# Actions

_unlock(_: Room, passage: Passage) if
    (not passage.locked and cut) or
    (GAME.write("  The {} is locked\n", passage.desc) and false) and cut;

_go(room: Room, passage: Passage, next_room) if
    next_room_id in passage.rooms and
    next_room_id != room.id and
    next_room = Rooms.get_by_id(next_room_id);

# Printing
_look_room_objects(room: Room) if
    _contains(room, object) and
    GAME.write("  You see a ") and
    GAME.write_blue("{}\n", object.desc)
    and false;

_look_player_objects() if
    object_id in PLAYER.objects and
    object = Objects.get_by_id(object_id) and
    GAME.write("  You have a ") and
    GAME.write_blue("{}\n", object.desc)
    and false;

_look_room_passages(room: Room) if
    _paths(room, passage) and
    GAME.write("  You see a ") and
    GAME.write_blue("{}\n", passage.desc)
    and false;

_notice_effects(room: Room) if
    forall(a_id in room.objects,
        a = Objects.get_by_id(a_id) and
        forall(b_id in room.objects,
            b = Objects.get_by_id(b_id) and
            _effect(a,b) or true
            )
    );

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
    GAME.write("You are in {}\n", room.desc) and
    _look_room_objects(room) or
    _look_room_passages(room) or
    _notice_effects(room) or true;

go(passage_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    _paths(room, passage) and
    passage.desc = passage_desc and
    _unlock(room, passage) and
    _go(room, passage, next_room) and
    GAME.write("You go through ") and
    GAME.write_blue("{}\n\n", passage.desc) and
    PLAYER.set_room(next_room.id) and
    look();

take(object_desc: String) if
    (
        room = Rooms.get_by_id(PLAYER.room) and
        obj = Objects.get(object_desc) and
        obj.id in room.objects and
        room.remove_object(obj.id) and
        PLAYER.add_object(obj.id) and
        _take(obj) and cut
    ) or (GAME.write("  You can't take a ") and GAME.write_blue("{}\n", object_desc) and false);

use(object_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    obj = Objects.get(object_desc) and
    (obj.id in room.objects or
    obj.id in PLAYER.objects) and
    _use(obj);

look(object_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    obj = Objects.get(object_desc) and
    (obj.id in room.objects or
    obj.id in PLAYER.objects) and
    _look(obj);

place(object_desc: String) if
    obj = Objects.get(object_desc) and
    obj.id in PLAYER.objects and
    room = Rooms.get_by_id(PLAYER.room) and
    PLAYER.remove_object(obj.id) and
    room.add_object(obj.id);


#slice(knife, apple);
#plant(mushroom);


# cooking game

# cheat codes
_cheat_teleport(room_desc: String) if
    room = Rooms.get(room_desc) and PLAYER.set_room(room.id);

# ?= _cheat_teleport("a living room") and take("key");
#?= _cheat_teleport("a kitchen") and take("matches");
#?= _cheat_teleport("a woodshed") and take("wood");

?= look();