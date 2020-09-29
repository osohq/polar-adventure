# ------------------
# LOOKING AT A ROOM
# ------------------
_look_room() if
    room = Rooms.get_by_id(PLAYER.room) and
    GAME.write("\n{}\n", room.desc) and
    # describe room
    _room_overview(room) and
    # describe all passages
    forall(
        passage in Passages.all(),
        (room.id in passage.room_ids() and
        GAME.write("To the {} you see ", passage.get_direction(room.id)) and
        _passage_overview(passage, room)) or true
    ) and
    # describe objects in room
    forall(
        obj_id in room.objects,
        object = Objects.get_by_id(obj_id) and
        _object_overview(object) and
        forall(_object_extras(object), true) and
        forall(_object_extras(object, room), true) and
        forall(
            other_obj_id in room.objects,
            other_object = Objects.get_by_id(other_obj_id) and
            _object_interaction(object, other_object) or true
        ) and
        forall(
            player_obj_id in PLAYER.objects,
            player_object = Objects.get_by_id(player_obj_id) and
            _object_interaction(object, player_object) or true
        )
    );

# Room descriptions get shown every time you "look()"
_room_overview(_: Room) if
    GAME.write("This is a room.\n");

_room_overview(_: Room{desc: "The Clearing"}) if
    GAME.write("\nYou are standing at the edge of a forest.\n") and
    GAME.write("Dappled sunlight filters through the trees, and you realize it is daybreak.\n") and
    GAME.write("Your legs feel tired, as though they've walked many miles.\n\n") and cut;

_room_overview(_: Room{desc: "The Garden"}) if
    GAME.write("\nYou're surrounded by what was once a lovely garden.\n") and
    GAME.write("The garden is crowded with flower beds and planters that appear long abandoned.\n\n") and cut;

# Passage Descriptions
_passage_overview(passage: Passage, _) if
    GAME.write("a ") and GAME.write_blue("{}.\n", passage.desc);

_passage_overview(passage: Passage{desc: "iron gate"}, room: Room) if
    ((room.desc = "The Clearing" and
    GAME.write("an overgrown path, leading toward an imposing")) or
    GAME.write("an")) and
    GAME.write_blue(" {}.\n", passage.desc) and cut;

# Object overviews
_object_overview(object: Object) if
    GAME.write("  You see a ") and
    GAME.write_blue("{}.\n", object.desc);

_object_overview(dog: Animal{desc: "dog"}) if
    GAME.write("  A shepherd ") and
    GAME.write_blue("{}", dog.desc) and
    GAME.write(" lays sleepily in the corner.\n") and cut;

_object_overview(animal: Animal) if
    GAME.write("  A ") and
    GAME.write_blue("{}", animal.desc) and
    GAME.write(" looks at you curiously.\n") and cut;

# Object Extras
_object_extras(obj: Mushroomy{}) if
    GAME.write("    The ") and GAME.write_blue(obj.desc) and GAME.write(" has little mushrooms growing out of it.\n");

_object_extras(_: Object{desc: "duck"}, _: Room{desc: "The Farm Plot"}) if
    GAME.write("    The ") and GAME.write_blue("duck") and GAME.write(" loves to be in the farm plot.\n");

# Object Interactions
_desc_object_interaction("cat", "dog") if
    GAME.write("    The ") and GAME.write_blue("cat") and GAME.write(" and the ") and GAME.write_blue("dog") and GAME.write(" are mad at each other.\n");

_object_interaction(a: Object, b: Object) if
    _desc_object_interaction(a.desc, b.desc);

_object_interaction(animal: Animal, food: Food) if
    GAME.write("    The ") and GAME.write_blue("{}", animal.desc) and GAME.write(" is eyeing the ") and GAME.write_blue("{}.\n", food.desc);

_object_interaction(animal: Animal{favorite_item: fav_item}, _: Object{desc: fav_item}) if
    GAME.write("    The ") and GAME.write_blue("{}", animal.desc) and GAME.write(" really wants the ") and GAME.write_blue("{}.\n", fav_item);


# --------------------
# LOOKING AT AN OBJECT
# --------------------
_look_object(object_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    obj = Objects.get(object_desc) and
    obj matches Object{} and
    (obj.id in room.objects or
    obj.id in PLAYER.objects) and
    _object_detail(obj) and
    forall(_object_extras(obj), true);

# Object details
_object_detail(obj: Object) if
    GAME.write("  The ") and GAME.write_blue("{}", obj.desc) and GAME.write(" isn't very interesting to look at.\n");

_object_detail(_: Object{desc: "map"}) if
    GAME.print_map() and cut;

_object_detail(_: Object{desc: "watch"}) if
    GAME.write("  The ") and GAME.write_blue("watch") and GAME.write("  says ") and GAME.write_red("{}\n", GAME.time) and cut;


# Info gathering
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
_look_player_objects() if
    object_id in PLAYER.objects and
    object = Objects.get_by_id(object_id) and
    GAME.write("  You have a ") and
    GAME.write_blue("{}\n", object.desc)
    and false;



_player_inventory(_: []) if GAME.write("  You don't have anything.\n") and cut;
_player_inventory(obj_ids: List) if
    forall(obj_id in obj_ids,
        object = Objects.get_by_id(obj_id) and
        GAME.write("  You have a ") and
        GAME.write_blue("{}\n", object.desc));

_inventory() if
    GAME.write("You check your pockets\n") and _player_inventory(PLAYER.objects);

# COMMANDS
inventory() if _inventory();
look() if _look_room();

look(object_desc: String) if
    _look_object(object_desc);

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
        obj matches Takeable{} and
        obj.id in room.objects and
        room.remove_object(obj.id) and
        PLAYER.add_object(obj.id) and cut
    ) or (GAME.write("  You can't take ") and GAME.write_blue("{}\n", object_desc) and false);

place(object_desc: String) if
    (
        obj = Objects.get(object_desc) and
        obj matches Object{} and
        obj matches Takeable{} and
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


# cheat codes
_cheat_teleport(room_desc: String) if
    room = Rooms.get(room_desc) and PLAYER.set_room(room.id);


#?= _cheat_teleport("a kitchen") and take("matches") and _cheat_teleport("a woodshed") and take("wood") and _cheat_teleport("a library");
#?= _take("spores") and look();