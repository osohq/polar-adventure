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

?= look();