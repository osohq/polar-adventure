# Room long descriptions
_describe_room(_: Room{desc: "The Clearing"}) if
    GAME.write("\nYou are standing at the edge of a forest.\n") and
    GAME.write("Dappled sunlight filters through the trees, and you realize it is daybreak.\n") and
    GAME.write("Your legs feel tired, as though they've walked many miles.\n\n") and false;

_describe_room(_: Room{desc: "The Garden"}) if
    GAME.write("\nYou're surrounded by what was once a lovely garden.\n") and
    GAME.write("The garden is crowded with flower beds and planters that appear long abandoned.\n\n") and false;

# Room Passage Descriptions
_describe_room_passages(room: Room) if
    forall(
        _paths(room, passage),
        GAME.write("To the {} you see ", passage.get_direction(room.id)) and
        _describe(passage, room)
    ) and false;

# Passage Descriptions
_describe(passage: Passage, _) if
    GAME.write("a ") and GAME.write_blue("{}\n", passage.desc);

_describe(passage: Passage{desc: "iron gate"}, room: Room) if
    ((room.desc = "The Clearing" and
    GAME.write("an overgrown path, leading toward an imposing")) or
    GAME.write("an")) and
    GAME.write_blue(" {}.\n", passage.desc) and cut;

# Object descriptions
_describe(object: Object) if
    GAME.write("  You see a ") and
    GAME.write_blue("{}.\n", object.desc);

_describe(dog: Animal{desc: "dog"}) if
    GAME.write("  A shepherd ") and
    GAME.write_blue("{}", dog.desc) and
    GAME.write(" lays sleepily in the corner.\n") and cut;

_describe(animal: Animal) if
    GAME.write("  A ") and
    GAME.write_blue("{}", animal.desc) and
    GAME.write(" looks at you curiously.\n") and cut;