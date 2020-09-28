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
        idx = self.by_id[i]
        return self.elems[idx]

    def get(self, key):
        idx = self.by_key[key]
        return self.elems[idx]

    def all(self):
        return self.elems


GAME = Game()
PLAYER = Player()
ROOMS = Collection(
    [
        Room(id=1, objects=[], desc="the woods"),
        Room(id=2, objects=[], desc="a front yard"),
        Room(id=3, objects=[], desc="a foyer"),
        Room(id=4, objects=[], desc="a kitchen"),
        Room(id=6, objects=[], desc="a living room"),
        Room(id=7, objects=[], desc="a library"),
        Room(id=8, objects=[], desc="an attic"),
        Room(id=9, objects=[], desc="a farm plot"),
        Room(id=10, objects=[], desc="a woodshed"),
        Room(id=11, objects=[], desc="the deep woods"),
    ],
    "desc",
)
PASSAGES = Collection(
    [
        Passage(id=1, rooms=[1, 2], desc="front gate", locked=False),
        Passage(id=2, rooms=[2, 3], desc="front door", locked=False),
        Passage(id=3, rooms=[2, 9], desc="garden gate", locked=True),
        Passage(id=4, rooms=[3, 4], desc="left hallway", locked=False),
        Passage(id=5, rooms=[3, 6], desc="right hallway", locked=False),
        Passage(id=6, rooms=[4, 8], desc="trap door", locked=True),
        Passage(id=7, rooms=[4, 9], desc="back door", locked=False),
        Passage(id=8, rooms=[6, 7], desc="large oak door", locked=True),
        Passage(id=9, rooms=[9, 10], desc="shed door", locked=False),
        Passage(id=10, rooms=[9, 11], desc="trail", locked=False),
    ],
    "desc",
)
OBJECTS = Collection(
    [
        Object(id=1, desc="dog"),
        Object(id=2, desc="cat"),
        Object(id=3, desc="duck"),
    ],
    "desc",
)


if __name__ == "__main__":
    oso = Oso()
    oso.load_file("world.polar")
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
    oso.repl()
