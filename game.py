from dataclasses import dataclass, field, make_dataclass, asdict
from typing import List
from oso import Oso

RESET = "\001\x1b[0m\002"
FG_BLUE = "\001\x1b[34m\002"
FG_RED = "\001\x1b[31m\002"


@dataclass
class Game:
    time: int = 0

    def write(self, fmt, *args):
        print(fmt.format(*args), end="")
        return True

    def write_blue(self, fmt, *args):
        s = fmt.format(*args)
        print(FG_BLUE + s + RESET, end="")
        return True

    def write_red(self, fmt, *args):
        s = fmt.format(*args)
        print(FG_RED + s + RESET, end="")
        return True

    def print_map(self):
        gate = "_ " if PASSAGES.get("garden gate").locked else "  "
        lib_door = "_ " if PASSAGES.get("large oak door").locked else "  "
        trap_door = "_ " if PASSAGES.get("trap door").locked else "  "
        rooms = []
        for room in ROOMS.elems:
            val = "x " if PLAYER.room == room.id else "  "
            rooms.insert(room.id, val)

        print("           ______     _____________________________")
        print("          |      |___|           deep woods        |")
        print("          |       ___     {}                       |".format(rooms[9]))
        print("          |      |   |_____________________________|")
        print("          | farm |")
        print("          | plot |    _____________________________")
        print(" ______   |      |   |         attic     {}        |".format(rooms[6]))
        print("| wood |  |      |   |____ {}______________________|".format(trap_door))
        print("| shed |__|      |   |             |   library     |")
        print("|  {}   __       |___|  kitchen    |               |".format(rooms[8]))
        print(
            "|______|  |       ___       {}     |   {}          |".format(
                rooms[3], rooms[5]
            )
        )
        print("          |      |   |   __________|______ {}______|".format(lib_door))
        print("          |  {}  |   |  |    living room           |".format(rooms[7]))
        print("          |      |   |  |            {}            |".format(rooms[4]))
        print("          |      |   |  |_______________________   |")
        print("          |      |   |            foyer         |  |")
        print("          |      |   |    {}                    |  |".format(rooms[2]))
        print("          |__ {}_|   |_______   ___________________|".format(gate))
        print("             | |_____|                  front      |")
        print("             |_______      {}           yard       |".format(rooms[1]))
        print("                     |_____________   _____________|")
        print("                                    {}".format(rooms[0]))
        print("                                 woods")

        return True

    def tick(self):
        self.time += 1
        return True


@dataclass
class Room:
    id: int
    objects: List[int]
    passages: List[int]
    desc: str

    def remove_object(self, obj_id):
        self.objects.remove(obj_id)
        return True

    def add_object(self, obj_id):
        self.objects.append(obj_id)
        return True


@dataclass
class Passage:
    id: int
    rooms: List[int]
    desc: str
    locked: bool

    def unlock(self):
        self.locked = False
        return True

    def room_ids(self):
        return list(self.rooms.keys())

    def get_direction(self, room_id):
        return self.rooms.get(room_id)


@dataclass
class Object:
    id: int
    desc: str
    classes: List


@dataclass
class Animal:
    favorite_item: str


class Container:
    pass


class Food:
    pass


@dataclass
class Takeable:
    pass


@dataclass
class Mushroomy:
    pass


def make_object(id, desc, classes=None, **kwargs):
    if Object not in classes:
        classes.append(Object)
    cls = make_dataclass(desc, [], bases=tuple(classes))
    return cls(id=id, desc=desc, classes=classes, **kwargs)


@dataclass
class Player:
    room: int = 1
    objects: List[int] = field(default_factory=list)

    def set_room(self, room_id):
        self.room = room_id
        return True

    def remove_object(self, obj_id):
        self.objects.remove(obj_id)
        return True

    def add_object(self, obj_id):
        self.objects.append(obj_id)
        return True


class Collection:
    def __init__(self, elems, key):
        self.elems = elems
        self.key = key

        by_id = {}
        by_key = {}

        for i, elem in enumerate(self.elems):
            by_id[elem.id] = i
            by_key[getattr(elem, key)] = i

        self.by_id = by_id
        self.by_key = by_key

    def get_by_id(self, i):
        idx = self.by_id.get(i)
        if idx is not None:
            return self.elems[idx]
        return None

    def get(self, key):
        idx = self.by_key.get(key)
        if idx is not None:
            return self.elems[idx]
        return None

    def all(self):
        return self.elems

    def add_class(self, i, class_name):
        obj = self.get_by_id(i)
        if obj:
            classes = {"Mushroomy": Mushroomy}
            new_class = classes[class_name]
            new_classes = obj.classes
            new_classes.insert(0, new_class)
            attrs = asdict(obj)
            del attrs["classes"]
            new_obj = make_object(classes=new_classes, **attrs)
            idx = self.by_id.get(obj.id)
            self.elems[idx] = new_obj
            return True
        return False


GAME = Game()
PLAYER = Player()
ROOMS = Collection(
    [
        Room(
            id=1, objects=[1, 2, 9, 10, 12, 13, 14], passages=[1], desc="The Clearing"
        ),
        Room(id=2, objects=[], passages=[1, 2, 3], desc="The Garden"),
        Room(id=3, objects=[], passages=[2, 4, 5], desc="The Foyer"),
        Room(id=4, objects=[8], passages=[4, 6, 7], desc="The Kitchen"),
        Room(id=5, objects=[4], passages=[5, 8], desc="The Living Room"),
        Room(id=6, objects=[5, 6], passages=[8], desc="The Library"),
        Room(id=7, objects=[], passages=[6], desc="The Attic"),
        Room(id=8, objects=[3], passages=[3, 7, 9, 10], desc="The Farm Plot"),
        Room(id=9, objects=[7], passages=[9], desc="The Woodshed"),
        Room(id=10, objects=[], passages=[10], desc="The North Forest"),
    ],
    "desc",
)
PASSAGES = Collection(
    [
        Passage(id=1, rooms={1: "north", 2: "south"}, desc="iron gate", locked=False),
        Passage(id=2, rooms={2: "north", 3: "south"}, desc="front door", locked=False),
        Passage(id=3, rooms={2: "west", 8: "south"}, desc="garden gate", locked=True),
        Passage(id=4, rooms={3: "west", 4: "south"}, desc="hallway", locked=False),
        Passage(id=5, rooms={3: "east", 5: "south"}, desc="corridor", locked=False),
        Passage(id=6, rooms={4: "north", 7: "south"}, desc="trap door", locked=True),
        Passage(id=7, rooms={4: "west", 8: "east"}, desc="back door", locked=False),
        Passage(
            id=8, rooms={5: "north", 6: "south"}, desc="large oak door", locked=True
        ),
        Passage(id=9, rooms={8: "west", 9: "east"}, desc="shed door", locked=False),
        Passage(id=10, rooms={8: "northeast", 10: "west"}, desc="trail", locked=False),
    ],
    "desc",
)
OBJECTS = Collection(
    [
        make_object(id=1, desc="dog", favorite_item="ball", classes=[Animal]),
        make_object(id=2, desc="cat", favorite_item="yarn", classes=[Animal, Takeable]),
        make_object(
            id=3, desc="duck", favorite_item="bathtub", classes=[Animal, Takeable]
        ),
        make_object(id=4, desc="key", classes=[Takeable]),
        make_object(id=5, desc="map", classes=[Takeable]),
        make_object(id=6, desc="fireplace", classes=[]),
        make_object(id=7, desc="wood", classes=[Takeable]),
        make_object(id=8, desc="matches", classes=[Takeable]),
        make_object(id=9, desc="carrot", classes=[Takeable, Food]),
        make_object(id=10, desc="apple", classes=[Takeable, Food]),
        make_object(id=11, desc="fire", classes=[]),
        make_object(id=12, desc="ball", classes=[]),
        make_object(id=13, desc="spores", classes=[Takeable]),
        make_object(id=14, desc="watch", classes=[]),
    ],
    "desc",
)


if __name__ == "__main__":
    oso = Oso()
    oso.register_class(Game)
    oso.register_class(Room)
    oso.register_class(Passage)
    oso.register_class(Player)
    oso.register_class(Collection)
    oso.register_class(Object)
    oso.register_class(Animal)
    oso.register_class(Food)
    oso.register_class(Container)
    oso.register_class(Takeable)
    oso.register_class(Mushroomy)
    oso.register_constant("GAME", GAME)
    oso.register_constant("PLAYER", PLAYER)
    oso.register_constant("Rooms", ROOMS)
    oso.register_constant("Passages", PASSAGES)
    oso.register_constant("Objects", OBJECTS)
    oso.load_file("world.polar")
    oso.repl()

# todo list

# finish up printing fail states
# use, object interactions
# effects
# tick