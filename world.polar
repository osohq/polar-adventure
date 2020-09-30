# ----------
# NAVIGATION
# ----------
_go(room: Room, passage: Passage) if
    _unlock(room, passage) and
    next_room_id in passage.room_ids() and
    next_room_id != room.id and
    next_room = Rooms.get_by_id(next_room_id) and
    PLAYER.set_room(next_room.id) and
    look();

_go_passage(passage_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    passage = Passages.get(passage_desc) and
    passage matches Passage{} and
    passage.id in room.passages and
    _go(room, passage);

_go_direction(direction_str: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    passage_id in room.passages and
    passage = Passages.get_by_id(passage_id) and
    direction_str = passage.get_direction(room.id) and
    _go(room, passage);

# ------------------
# LOOKING AT A ROOM
# ------------------
_look_room() if
    room = Rooms.get_by_id(PLAYER.room) and
    GAME.write("\n{}\n\n", room.desc) and
    # describe room
    _room_overview(room) and
    GAME.write("\n\n", room.desc) and
    # describe all passages
    forall(
        passage_id in room.passages,
        passage = Passages.get_by_id(passage_id) and
        GAME.write("To the {} you see ", GAME.green(passage.get_direction(room.id))) and
        _passage_overview(passage, room)
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
    GAME.write("This is a room.");

_room_overview(_: Room{desc: "The Clearing"}) if
    GAME.write("You are standing at the edge of a forest.\n") and
    GAME.write("Dappled sunlight filters through the trees, and you realize it is daybreak.\n") and
    GAME.write("Your legs feel tired, as though they've walked many miles.") and cut;

_room_overview(_: Room{desc: "The Garden"}) if
    GAME.write("You're surrounded by what was once a lovely garden.\n") and
    GAME.write("The garden is crowded with flower beds and planters that appear long abandoned.") and cut;

# Passage Descriptions
_passage_overview(passage: Passage, _) if
    GAME.write("a {}\n", GAME.blue(passage.desc));

_passage_overview(passage: Passage{desc: "iron gate"}, room: Room) if
    ((room.desc = "The Clearing" and
    GAME.write("an overgrown path, leading toward an imposing")) or
    GAME.write("an")) and
    GAME.write(" {}.\n", GAME.blue(passage.desc)) and cut;

# Object overviews
_object_overview(object: Object) if
    GAME.write("  You see a {}.\n", GAME.blue(object.desc));

_object_overview(_: Object{desc: "letter"}) if
    GAME.write("  A folded {} ", GAME.blue("letter"));

_object_overview(dog: Animal{desc: "dog"}) if
    GAME.write("  A shepherd {} lays sleepily in the corner.\n", GAME.blue(dog.desc)) and cut;

_object_overview(animal: Animal) if
    GAME.write("  A {} looks at you curiously.\n", GAME.blue(animal.desc)) and cut;

# Object Extras
_object_extras(_: Object{desc: "letter"}, _: Room{desc: "The Garden"}) if
    GAME.write("is taped to the front door of the cabin.\n") and cut;

_object_extras(_: Object{desc: "letter"}, _: Room) if
    GAME.write("is lying on the floor.\n");

_object_extras(obj: Mushroomy) if
    GAME.write("    The {} has little mushrooms growing out of it.\n", GAME.blue(obj.desc));

_object_extras(_: Object{desc: "duck"}, _: Room{desc: "The Farm Plot"}) if
    GAME.write("    The {} loves to be in the farm plot.\n", GAME.blue("duck"));

# Object Interactions
_desc_object_interaction("cat", "dog") if
    GAME.write("    The {} and the {} are mad at each other.\n", GAME.blue("cat"), GAME.blue("dog"));

_object_interaction(a: Object, b: Object) if
    _desc_object_interaction(a.desc, b.desc);

_object_interaction(animal: Animal, food: Food) if
    GAME.write("    The {} is eyeing the {}\n", GAME.blue(animal.desc), GAME.blue(food.desc));

_object_interaction(animal: Animal{favorite_item: fav_item}, _: Object{desc: fav_item}) if
    GAME.write("    The {} really wants the {}.\n", GAME.blue(animal.desc), GAME.blue(fav_item));

# --------------------
# LOOKING AT AN OBJECT
# --------------------
_look_object(object_desc: String) if
    room = Rooms.get_by_id(PLAYER.room) and
    obj = Objects.get(object_desc) and
    obj matches Object{} and
    (_room_has(room, obj) or
    _player_has(obj)) and
    _object_detail(obj) and
    forall(_object_extras(obj), true);

# Object details
_object_detail(obj: Object) if
    GAME.write("  The {} isn't very interesting to look at.\n", GAME.blue(obj.desc));

_object_detail(_: Object{desc: "map"}) if
    GAME.print_map() and cut;

_object_detail(_: Object{desc: "watch"}) if
    GAME.write("  The {} says {}\n", GAME.blue("watch"), GAME.red(GAME.time)) and cut;

_object_detail(obj: Object{desc: "letter"}) if
    GAME.write("  The {} has your name on it.\n", GAME.blue(obj.desc)) and cut;

_object_detail(container: Container) if
    (
        container.is_open and
        (
            container.objects matches [] and
            GAME.write("The {} is empty.\n", GAME.blue(container.desc)) and cut
        ) or (
            GAME.write("  The {} contains: ", GAME.blue(container.desc)) and
            obj_id in container.objects and
            object = Objects.get_by_id(obj_id) and
            GAME.write("\n    a {}", GAME.blue(object.desc)) and
            GAME.write("\n")
        ) and cut
    ) or (
        GAME.write("You can't see into the {}.\n", GAME.blue(container.desc)) and cut
    ) and cut;



# ------------------------
# INTERACTING WITH OBJECTS
# ------------------------
# Helpers
_player_has(obj: Object) if
    obj.id in PLAYER.objects;

_room_has(room: Room, obj: Object) if
    _room_has(room, obj, _container);

_room_has(room: Room, obj: Object, container) if
    (
        obj.id in room.objects and
        container = {}
    ) or (
        obj_id in room.objects and
        container = Objects.get_by_id(obj_id) and
        container matches Container{is_open: true} and
        obj.id in container.objects
    );

# Unlock

_unlock(_: Room, passage: Passage) if
    (not passage.locked and cut) or
    (GAME.write("  The {} is locked\n", GAME.blue(passage.desc)) and false) and cut;

# Large oak door needs the key.
_unlock(_: Room{desc: "The Living Room"}, passage: Passage{desc: "large oak door"}) if
    _player_has(Objects.get("key")) and
    passage.unlock() and
    GAME.write("  You unlock the {} with the {}.\n", GAME.blue(passage.desc), GAME.blue("key")) and cut;

# Garden gate only opens from the farm plot side.
_unlock(_: Room{desc: "The Farm Plot"}, passage: Passage{desc: "garden gate"}) if
    passage.unlock() and
    GAME.write("  You unlock the {}.\n", GAME.blue(passage.desc)) and cut;

# Actions

_action(action: String, object_desc: String) if
    (
        obj = Objects.get(object_desc) and
        obj matches Object{} and
        room = Rooms.get_by_id(PLAYER.room) and
        (_room_has(room, obj) or _player_has(obj)) and
        _action_object(action, room, obj) and cut
    ) or (GAME.write("  You can't {} {}\n", action, GAME.blue(object_desc)) and false);

_action(action: String, object_desc: String, on_desc: String) if
    (
        obj = Objects.get(object_desc) and
        obj matches Object{} and
        on = Objects.get(on_desc) and
        on matches Object{} and
        room = Rooms.get_by_id(PLAYER.room) and
        (_room_has(room, obj) or _player_has(obj)) and
        (_room_has(room, on) or _player_has(on)) and
        _action_object(action, room, obj, on) and cut
    ) or (GAME.write("  You can't {} {} on {}\n", action, GAME.blue(object_desc), GAME.blue(on_desc)) and false);

_action_object("take", room: Room, obj: Takeable) if _take(room, obj);

_action_object("place", room: Room, obj: Takeable) if _place(room, obj);
_action_object("place", _: Room, obj: Takeable, container: Container) if _place(obj, container);

_action_object("use", _: Room, obj: Object) if _use(obj);
_action_object("use", _: Room, obj: Object, on: Object) if _use(obj, on);

_action_object("feed", room: Room, food: Food, animal: Animal) if
    (
        (food.id in room.objects and room.remove_object(food.id)) or
        (food.id in PLAYER.objects and PLAYER.remove_object(food.id))
    ) and GAME.write("  the {} ate the {}\n", GAME.blue(animal.desc), GAME.blue(food.desc));

_action_object("open", _: Room, obj: Container) if
    not obj.is_open and
    _open(obj) and
    obj.open() and
    _look_object(obj.desc);

_action_object("close", _: Room, obj: Container) if
    obj.is_open and
    _close(obj) and
    obj.close();

_take(room: Room, obj: Takeable) if
    _room_has(room, obj, container) and
    ((container matches Container{} and
    container.remove_object(obj.id)) or
    room.remove_object(obj.id)) and
    PLAYER.add_object(obj.id);

_place(room: Room, obj: Takeable) if
    obj.id in PLAYER.objects and
    PLAYER.remove_object(obj.id) and
    room.add_object(obj.id);

_place(obj: Takeable, container: Container) if
    obj.id in PLAYER.objects and
    (container.is_open and cut or
    GAME.write("The {} is closed.\n", GAME.blue(container.desc)) and false) and
    PLAYER.remove_object(obj.id) and
    container.add_object(obj.id);

_use(_: Object{desc: "bag of mushroom spores"}, obj: Object{}) if
    (
        obj matches Mushroomy and
        GAME.write("  it doesn't seem like {} needs any more.\n", GAME.blue(obj.desc)) and cut
    ) or
    (
        Objects.add_class(obj.id, "Mushroomy") and
        GAME.write("  you sprinkle mushroom spores on {}\n.", GAME.blue(obj.desc))
    );



# using the fireplace requires both wood and matches.
_use(_: Object{desc: "fireplace"}) if
    room = Rooms.get_by_id(PLAYER.room) and
    fire = Objects.get("fire") and
    (
        fire.id in room.objects and
        GAME.write("  There is already a {}.\n", GAME.blue("fire")) and cut
    ) or
    (
        _player_has(Objects.get("wood")) and
        _player_has(Objects.get("matches")) and
        room = Rooms.get_by_id(PLAYER.room) and
        room.add_object(Objects.get("fire").id) and
        PLAYER.remove_object(Objects.get("wood").id) and
        GAME.write("  You started a {}.", GAME.blue("fire")) and cut
    ) or (GAME.write("Wish you had {} and {}.\n", GAME.blue("wood"), GAME.blue("matches")) and false);

_exists(obj: Object) if
    not (
        forall(room in Rooms.all(),
            not (obj.id in room.objects)
        ) and
        not (obj.id in PLAYER.objects)
    );

# using the pot makes soup (if there isn't already soup somewhere)

# using a source gives you the item it creates (if the item isn't already somewhere)
_use(source: Source{produces: obj_desc}) if
    (   
        obj = Objects.get(obj_desc) and
        not _exists(obj) and
        PLAYER.add_object(obj.id) and
        GAME.write("  You took {}.\n", GAME.blue(obj_desc))
        and cut
    ) or (GAME.write("  The {} is empty.\n", GAME.blue(source.desc)));
        

_use(_: Object{desc: fav_item}, animal: Animal{favorite_item: fav_item}) if
    GAME.write("  {} smiles, they love the {}\n", GAME.blue(animal.desc), GAME.blue(fav_item));

_open(container: Container) if
    GAME.write("  You open the {}.\n", GAME.blue(container.desc));

_close(container: Container) if
    GAME.write("  You close the {}.\n", GAME.blue(container.desc));



# Printing


_player_inventory(_: []) if GAME.write("  You don't have anything.\n") and cut;
_player_inventory(obj_ids: List) if
    forall(obj_id in obj_ids,
        object = Objects.get_by_id(obj_id) and
        GAME.write("  You have a {}\n", GAME.blue(object.desc)));

_inventory() if
    GAME.write("You check your pockets\n") and _player_inventory(PLAYER.objects);

# COMMANDS
inventory() if _inventory();

look() if _look_room();
look(object_desc: String) if _look_object(object_desc);

go(passage_desc: String) if _go_passage(passage_desc);
north() if _go_direction("north");
south() if _go_direction("south");
east() if _go_direction("east");
west() if _go_direction("west");
northeast() if _go_direction("northeast");
northwest() if _go_direction("northwest");
southeast() if _go_direction("southeast");
southwest() if _go_direction("southwest");

use(object_desc: String) if _action("use", object_desc);
use(object_desc: String, on_desc: String) if _action("use", object_desc, on_desc);
feed(food_desc: String, to_desc: String) if _action("feed", food_desc, to_desc);
take(object_desc: String) if _action("take", object_desc);
place(object_desc: String) if _action("place", object_desc);
place(object_desc: String, container: String) if _action("place", object_desc, container);
open(object_desc: String) if _action("open", object_desc);
close(object_desc: String) if _action("close", object_desc);






# cheat codes
_cheat_teleport(room_desc: String) if
    room = Rooms.get(room_desc) and PLAYER.set_room(room.id);


#?= _cheat_teleport("a kitchen") and take("matches") and _cheat_teleport("a woodshed") and take("wood") and _cheat_teleport("a library");
#?= _take("spores") and look();