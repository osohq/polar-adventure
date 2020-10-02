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
    GAME.write("\n{}\n\n", GAME.yellow(room.desc)) and
    # describe room
    _room_overview(room) and
    # describe objects in room
    forall(
        obj_id in room.objects,
        object = Objects.get_by_id(obj_id) and
        _object_overview(object, room) and
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
    ) and
    # describe all passages
    GAME.write("\n") and
    forall(
        passage_id in room.passages,
        passage = Passages.get_by_id(passage_id) and
        GAME.write("To the {} you see ", GAME.green(passage.get_direction(room.id))) and
        _passage_overview(passage, room)
    );

# Room descriptions get shown every time you "look()"
_room_overview(_: Room) if
    GAME.write("This is a room.\n");

_room_overview(_: Room{desc: "The Clearing"}) if
    GAME.write("You are standing at the edge of a forest.\n") and
    GAME.write("Dappled sunlight filters through the trees, and you realize it is daybreak.\n") and
    GAME.write("Your legs feel tired, as though they've walked many miles.\n") and cut;

_room_overview(_: Room{desc: "The Garden"}) if
    GAME.write("You're surrounded by a lush, overgrown garden.\n") and
    GAME.write("In front of you is a large log cabin.\n") and cut;

_room_overview(_: Room{desc: "The Foyer"}) if
    GAME.write("You step into a bright, airy entryway.\n") and
    GAME.write("Sunlight streams in from windows high above your head.\n") and
    GAME.write("The air smells of wood and dust.\n") and cut;

_room_overview(_: Room{desc: "The Kitchen"}) if
    GAME.write("You step into a clean kitchen.\n") and
    GAME.write("A large pot sits on a stove, ready to be used.\n") and cut;

_room_overview(_: Room{desc: "The Living Room"}) if
    GAME.write("You've entered a large, formal living room.\n") and
    GAME.write("Thin slivers of light shine through the dusty curtains onto antique furniture.\n") and cut;

_room_overview(_: Room{desc: "The Library"}) if
    GAME.write("Shelves of books and trinkets line the walls of the room.\n") and
    GAME.write("In the center of the room is a majestic oak desk.\n") and cut;

_room_overview(_: Room{desc: "The Attic"}) if
    GAME.write("You've squirmed into a small dusty attic.\n") and
    GAME.write("You don't think anyone has been here in a long time.\n") and cut;

_room_overview(_: Room{desc: "The Farm Plot"}) if
    GAME.write("You step into a vast farmstead.\n") and
    GAME.write("There are many different kinds of vegetables growing.\n") and cut;

_room_overview(_: Room{desc: "The Woodshed"}) if
    GAME.write("You're crammed in a small wood shed.\n") and
    GAME.write("It's hard to breathe in here.\n") and cut;

_room_overview(_: Room{desc: "The North Forest"}) if
    GAME.write("You're a little lost out here.\n") and
    GAME.write("You should probably be getting back.\n") and cut;

# Passage Descriptions
_passage_overview(passage: Passage, _) if
    GAME.write("a {}.\n", GAME.blue(passage.desc));

_passage_overview(_passage: Passage{desc: "front door"}, room: Room) if
    room.desc = "The Garden" and
    GAME.write("the {} of the cabin.\n", GAME.blue("front door"));

_passage_overview(passage: Passage{desc: "iron gate"}, room: Room) if
    ((room.desc = "The Clearing" and
    GAME.write("an overgrown path, leading toward an imposing")) or
    GAME.write("an")) and
    GAME.write(" {}.\n", GAME.blue(passage.desc)) and cut;

_passage_overview(passage: Passage{desc: "trap door", locked: locked}, _room: Room) if
    (locked and GAME.write("a locked {}, you don't see any way to open it.\n", GAME.blue(passage.desc)) and cut) or
    GAME.write("a big hole where the {} used to be, something must have broke it open.\n", GAME.blue(passage.desc));

# Object overviews
_object_overview(object: Object, _) if
    GAME.write("  You see a {}.\n", GAME.blue(object.desc));

_object_overview(_: Object{desc: "letter"}, _) if
    GAME.write("  A folded {} ", GAME.blue("letter")) and cut;

_object_overview(_: Object{desc: "envelope"}, _: Room{desc: "The Garden"}) if
    GAME.write("  An {} is taped to the front door of the cabin.\n", GAME.blue("envelope")) and cut;

_object_overview(soup: Object{desc: "soup"}, _) if
    GAME.write("  A ") and
    ingredients = soup.kind and
    ingredients matches List and
    forall(ingredient in soup.kind,
        ingredient matches String and
        GAME.write(" {} ", GAME.blue(ingredient))
    ) and GAME.write("{}\n", GAME.blue("soup")) and cut;

_object_overview(dog: Animal{desc: "dog"}, _) if
    GAME.write("  A shepherd {} lays sleepily in the corner.\n", GAME.blue(dog.desc)) and cut;

_object_overview(animal: Animal, _) if
    GAME.write("  A {} looks at you curiously.\n", GAME.blue(animal.desc)) and cut;

_object_overview(_: Object{desc: "cook book"}, _: Room{desc: "The Foyer"}) if
    GAME.write("  An old {} lies open on a shelf.\n", GAME.blue("cook book"));

_object_overview(object: Object{desc: "pond"}, _) if
    GAME.write("  There is a {} at the edge of the farm. It seems to be emitting a faint blue glow.\n", GAME.blue(object.desc));

_object_overview(obj: Object{desc: "trunk"}, _) if
    GAME.write("  A leather {} catches your eye.\n", GAME.blue(obj.desc));

_object_overview(obj: Object{desc: "map"}, _: Room{desc: "The Library"}) if
    GAME.write("A {} is spread out on the desk.\n", GAME.blue(obj.desc));

_object_overview(obj: Object{desc: "dresser"}, _: Room{desc: "The Attic"}) if
    GAME.write("A drawer of a shabby {} in the corner is rattling, as if something is trapped inside.\n", GAME.blue(obj.desc));

# Object Extras
_object_extras(obj: Mushroomy) if
    GAME.write("    The {} has little mushrooms growing out of it.\n", GAME.blue(obj.desc));

_object_extras(obj: Wet) if
    GAME.write("    The {} is soaking wet.\n", GAME.blue(obj.desc));

_object_extras(obj: OnFire) if
    GAME.write("    The {} is on fire.\n", GAME.blue(obj.desc));

_object_extras(obj: Leafy) if
    GAME.write("    The {} has little leaves growing out of it.\n", GAME.blue(obj.desc));

_object_extras(_: Object{desc: "duck"}, _: Room{desc: "The Farm Plot"}) if
    GAME.write("    The {} loves to swim.\n", GAME.blue("duck"));

# Object Interactions
_desc_object_interaction("cat", "dog") if
    GAME.write("    The {} and the {} are mad at each other.\n", GAME.blue("cat"), GAME.blue("dog"));

_object_interaction(a: Object, b: Object) if
    _desc_object_interaction(a.desc, b.desc);

# _object_interaction(animal: Animal, food: Food) if
#     GAME.write("    The {} is eyeing the {}\n", GAME.blue(animal.desc), GAME.blue(food.desc));

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

_object_detail(soup: Object{desc: "soup"}) if
    GAME.write("  A ") and
    ingredients = soup.kind and
    ingredients matches List and
    forall(ingredient in soup.kind,
        ingredient matches String and
        GAME.write(" {} ", GAME.blue(ingredient))
    ) and GAME.write("{}\n", GAME.blue("soup")) and cut;

_object_detail(_: Object{desc: "map"}) if
    GAME.print_map() and cut;

_object_detail(_: Object{desc: "watch"}) if
    GAME.write("  The {} says {}\n", GAME.blue("watch"), GAME.red(GAME.time)) and cut;

# @TODO: This one
_object_detail(obj: Container{desc: "envelope"}) if
    not obj.is_open and
    GAME.write("  The {} is sealed, and has your name on it.\n", GAME.blue(obj.desc)) and cut;

_object_detail(obj: Object{desc: "letter"}) if
    GAME.write("  The letter says") and
    (not _player_has_wand() and
    GAME.write(" something in an ancient-looking language that you can't understand.\n", GAME.blue(obj.desc))
    and cut and cut) or
    forall((_player_has(Objects.get("blue wand")) and _blue_wand_msg()) or
    (_player_has(Objects.get("red wand")) and _red_wand_msg()) or
    (_player_has(Objects.get("green wand")) and _green_wand_msg()), true) and cut;

_player_has_wand() if
    obj_id in PLAYER.objects and
    obj = Objects.get_by_id(obj_id) and
    obj matches Wand{};

_blue_wand_msg() if
    GAME.write("\n\n  If what you seek is easy transport,\n") and
    GAME.write("  then use this spell, it's rather short:\n") and
    GAME.write("      teleport()\n");

_red_wand_msg() if
    GAME.write("\n\n  If it's objects you treasure,\n") and
    GAME.write("  this spell is a pleasure:\n") and
    GAME.write("      create()\n");

_green_wand_msg() if true;
    # GAME.write("\n\n  Perhaps memory holds the greatest power,\n") and
    # GAME.write("  with this spell if you leave your return won't be sour:\n") and
    # GAME.write("      save()\n");

_object_detail(obj: Object{desc: "dog"}) if
    GAME.write("  A real sleepy pup. Their collar says REX\n", GAME.blue(obj.desc)) and cut;

_object_detail(_: Object{desc: "cook book"}) if
    GAME.write("  There's a recipe in here.\n") and
    GAME.write("    Rex's favorite soup:\n") and
    GAME.write("    {}, {}, {}\n", GAME.blue("potato"), GAME.blue("onion"), GAME.blue("apple")) and cut;

_object_detail(_: Wand) if
    GAME.write("  The power of the glowing wand is tangible.\n") and cut;

_object_detail(pond: Container{desc: "pond"}) if
    wand = Objects.get("blue wand") and
    wand.id in pond.objects and
    (not (Objects.get("duck").id in pond.objects) and
    GAME.write("  Deep in the bottom of the pond, you see what looks like a {}. The wand is out of reach.\n", GAME.blue("blue wand"))
    and cut) or
    (GAME.write("  The {} swims to the bottom of the pond and retrieves the {}.\n", GAME.blue("duck"), GAME.blue("blue wand"))
    and (not (wand matches Takeable) and Objects.add_class(wand.id, "Takeable")) or true) and cut;

_object_detail(pot: Container{desc: "pot", objects: []}) if
    GAME.write("  The {} is empty. I need some ingredients\n", GAME.blue(pot.desc)) and cut;

_container_objects(container: Container{is_open: false}) if
    GAME.write("  You can't see into the {}.\n", GAME.blue(container.desc)) and cut;

_container_objects(container: Container{is_open: true, objects: []}) if
    GAME.write("  The {} is empty.\n", GAME.blue(container.desc)) and cut;

_container_objects(container: Container{is_open: true}) if
    GAME.write("  The {} contains: ", GAME.blue(container.desc)) and
    forall(obj_id in container.objects,
        object = Objects.get_by_id(obj_id) and
        GAME.write("\n    a {}", GAME.blue(object.desc))) and
    GAME.write("\n") and cut;

_object_detail(container: Container) if _container_objects(container) and cut;

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

_feed_soup_to_dog(room: Room, _soup: Soup{kind: ingredients}, dog: Object{desc: "dog"}) if
    (
        "potato" in ingredients and
        "apple" in ingredients and
        "onion" in ingredients and
        trap_door = Passages.get("trap door") and
        trap_door.unlock() and
        room.remove_object(dog.id) and
        kitchen = Rooms.get("The Kitchen") and
        kitchen.add_object(dog.id) and
        GAME.write("The dog LOVES this {} the most!\n", GAME.blue("soup")) and
        GAME.write("They're so excited they bolt into the house and you hear a large crash in {}\n", GAME.blue("The Kitchen")) and cut
    ) or GAME.write("The dog LOVES {}, but this isn't their FAVORITE flavor.\n", GAME.blue("soup"));

_action_object("feed", room: Room, food: Food, animal: Animal) if
    (
        (food.id in room.objects and room.remove_object(food.id)) or
        (food.id in PLAYER.objects and PLAYER.remove_object(food.id))
    ) and (
        (_feed_soup_to_dog(room, food, animal) and cut) or
        GAME.write("  the {} ate the {}\n", GAME.blue(animal.desc), GAME.blue(food.desc))
    );

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
    (
        (container matches Container{} and container.remove_object(obj.id)) or
        room.remove_object(obj.id)
    ) and
    PLAYER.add_object(obj.id) and
    GAME.write("  You take the {}.\n", GAME.blue(obj.desc));

_place(room: Room, obj: Takeable) if
    obj.id in PLAYER.objects and
    PLAYER.remove_object(obj.id) and
    room.add_object(obj.id);

_place(obj: Takeable, container: Container) if
    obj.id in PLAYER.objects and
    ((container.is_open and cut) or
    (GAME.write("The {} is closed.\n", GAME.blue(container.desc)) and false)) and
    PLAYER.remove_object(obj.id) and
    container.add_object(obj.id);

_use(_: Object{desc: "bag of mushroom spores"}, obj: Mushroomy) if
    GAME.write("  It doesn't seem like {} needs any more.\n", GAME.blue(obj.desc)) and cut;

_use(_: Object{desc: "bag of mushroom spores"}, obj: Object) if
    Objects.add_class(obj.id, "Mushroomy") and
    GAME.write("  you sprinkle mushroom spores on {}.\n", GAME.blue(obj.desc));

_use(_: Object{desc: "blue wand"}, obj: Wet) if
    GAME.write("  {} is already soaked.\n", GAME.blue(obj.desc)) and cut;

_use(_: Object{desc: "blue wand"}, obj: Object{}) if
    Objects.add_class(obj.id, "Wet") and
    GAME.write("  a blue gush of light shoots out of the wand at {}.\n", GAME.blue(obj.desc));

_use(_: Object{desc: "red wand"}, obj: OnFire) if
    GAME.write("  {} is already on fire.\n", GAME.blue(obj.desc)) and cut;

_use(_: Object{desc: "red wand"}, obj: Object) if
    Objects.add_class(obj.id, "OnFire") and
    GAME.write("  a red flame of light shoots out of the wand at {} and sets it ablaze.\n", GAME.blue(obj.desc));

_use(_: Object{desc: "green wand"}, obj: Leafy) if
    GAME.write("  {} is already growing.\n", GAME.blue(obj.desc)) and cut;

_use(_: Object{desc: "green wand"}, obj: Object) if
    Objects.add_class(obj.id, "Leafy") and
    GAME.write("  a green vine of light shoots out of the wand at {}, it glows green.\n", GAME.blue(obj.desc));

# using the fireplace requires both wood and matches.
_use(fireplace: Object{desc: "fireplace"}) if
    room = Rooms.get_by_id(PLAYER.room) and
    fire = Objects.get("fire") and
    (
        _room_has(room, fire) and
        GAME.write("  There is already a {}.\n", GAME.blue("fire")) and cut
    ) or (
        _player_has(Objects.get("wood")) and
        _player_has(Objects.get("matches")) and
        PLAYER.remove_object(Objects.get("wood").id) and
        (
            (
                not _player_has(Objects.get("red wand")) and
                fireplace.add_object(Objects.get("red wand").id) and
                GAME.write("  You start a {}. It roars to life, casting the room in orange light.\n",GAME.blue("fire")) and
                GAME.write("  Then suddenly, it extinguishes, leaving an object in its place.\n")
                and cut
            ) or (
                fireplace.add_object(fire) and
                GAME.write("  You start a {}.", GAME.blue("fire"))
            )
        ) and cut
    ) or (GAME.write("Wish you had {} and {}.\n", GAME.blue("wood"), GAME.blue("matches")) and false);

_exists(obj: Object) if
    not (
        rooms = Rooms.all() and
        forall(room in rooms,
            room matches Room and
            obs = room.objects and
            forall(room_obj_id in obs,
                not (room_obj_id = obj.id) and
                room_obj = Objects.get_by_id(room_obj_id) and
                ((room_obj matches Container and
                  cut and
                  not (obj.id in room_obj.objects)
                ) or true)
            )
        ) and not (obj.id in PLAYER.objects)
    );

# using the pot makes soup (if there isn't already soup somewhere)
_use(pot: Object{desc: "pot"}) if
    soup = Objects.get("soup") and
    (
        # if soup exists
        _exists(soup) and
        (GAME.write("  You already made {}, I bet an animal would like some.\n", GAME.blue("soup"))) and cut
    ) or (
        # else if nothing in the pot
        pot.objects matches [] and
        (GAME.write("  You need to find some ingredients\n")) and cut
    ) or (
        # else if non food ingredients in the pot
        not forall(id in pot.objects,
            ingredient = Objects.get_by_id(id) and ingredient matches Food) and
        (GAME.write("  Only food can go in {}.\n", GAME.blue("soup"))) and cut
    ) or (
        # else turn the ingredients into soup.
        soup.reset() and
        forall(id in pot.objects,
            ingredient = Objects.get_by_id(id) and
            soup.add_ingredient(ingredient.desc) and
            pot.remove_object(ingredient.id)
        ) and
        pot.add_object(soup.id) and
        (GAME.write("  You made {}!\n", GAME.blue("soup")))
    );

# using a source gives you the item it creates (if the item isn't already somewhere)
_use(source: Source{produces: obj_desc}) if
    (
        obj = Objects.get(obj_desc) and
        not _exists(obj) and
        PLAYER.add_object(obj.id) and
        GAME.write("  You take the {}.\n", GAME.blue(obj_desc))
        and cut
    ) or (GAME.write("  The {} is empty.\n", GAME.blue(source.desc)));


_use(_: Object{desc: fav_item}, animal: Animal{favorite_item: fav_item}) if
    GAME.write("  {} smiles, they love the {}\n", GAME.blue(animal.desc), GAME.blue(fav_item));

_use(_: Wand, _letter: Object{desc: "letter"}) if
    GAME.write("You can now read part of the {}. Take another look.\n", GAME.blue("letter"));

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

# cheat codes
_cheat_teleport(room_desc: String) if
    room = Rooms.get(room_desc) and room matches Room{} and PLAYER.set_room(room.id);
_cheat_create(obj_desc: String) if
    (
        obj = Objects.get(obj_desc) and
        obj matches Object and
        GAME.write("There already is a {} somewhere.\n", GAME.blue(obj_desc)) and cut
    ) or
    (
        GAME.create_object(obj_desc) and
        GAME.write("You've created a {}!\n", GAME.blue(obj_desc)));

# secret rules
teleport(room_desc: String) if
    _player_has(Objects.get("blue wand")) and
    _cheat_teleport(room_desc) and look();

create(obj_desc: String) if
    _player_has(Objects.get("red wand")) and
    _cheat_create(obj_desc);

# save() if
#    _player_has(Objects.get("red wand")) and
#    _cheat_save();