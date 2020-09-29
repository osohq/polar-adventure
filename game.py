from dataclasses import dataclass, field
from typing import List
from oso import Oso

RESET = "\001\x1b[0m\002"
FG_BLUE = "\001\x1b[34m\002"
FG_RED = "\001\x1b[31m\002"


@dataclass
class Game:
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


@dataclass
class Room:
    id: int
    objects: List[int]
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


@dataclass
class Object:
    id: int
    desc: str


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
        return False

    def get(self, key):
        idx = self.by_key.get(key)
        if idx is not None:
            return self.elems[idx]
        return False

    def all(self):
        return self.elems


GAME = Game()
PLAYER = Player()
ROOMS = Collection(
    [
        Room(id=1, objects=[], desc="the woods"),
        Room(id=2, objects=[], desc="a front yard"),
        Room(id=3, objects=[], desc="a foyer"),
        Room(id=4, objects=[8], desc="a kitchen"),
        Room(id=5, objects=[4], desc="a living room"),
        Room(id=6, objects=[5, 6], desc="a library"),
        Room(id=7, objects=[], desc="an attic"),
        Room(id=8, objects=[], desc="a farm plot"),
        Room(id=9, objects=[7], desc="a woodshed"),
        Room(id=10, objects=[], desc="the deep woods"),
    ],
    "desc",
)
PASSAGES = Collection(
    [
        Passage(id=1, rooms=[1, 2], desc="front gate", locked=False),
        Passage(id=2, rooms=[2, 3], desc="front door", locked=False),
        Passage(id=3, rooms=[2, 8], desc="garden gate", locked=True),
        Passage(id=4, rooms=[3, 4], desc="west hallway", locked=False),
        Passage(id=5, rooms=[3, 5], desc="east hallway", locked=False),
        Passage(id=6, rooms=[4, 7], desc="trap door", locked=True),
        Passage(id=7, rooms=[4, 8], desc="back door", locked=False),
        Passage(id=8, rooms=[5, 6], desc="large oak door", locked=True),
        Passage(id=9, rooms=[8, 9], desc="shed door", locked=False),
        Passage(id=10, rooms=[8, 10], desc="trail", locked=False),
    ],
    "desc",
)
OBJECTS = Collection(
    [
        Object(id=1, desc="dog"),
        Object(id=2, desc="cat"),
        Object(id=3, desc="duck"),
        Object(id=4, desc="key"),
        Object(id=5, desc="map"),
        Object(id=6, desc="fireplace"),
        Object(id=7, desc="wood"),
        Object(id=8, desc="matches"),
    ],
    "desc",
)


if __name__ == "__main__":
    oso = Oso()
    oso.register_class(Game)
    oso.register_class(Room)
    oso.register_class(Passage)
    oso.register_class(Object)
    oso.register_class(Player)
    oso.register_class(Collection)
    oso.register_constant("GAME", GAME)
    oso.register_constant("PLAYER", PLAYER)
    oso.register_constant("Rooms", ROOMS)
    oso.register_constant("Passages", PASSAGES)
    oso.register_constant("Objects", OBJECTS)
    oso.load_file("world.polar")
    oso.repl()
