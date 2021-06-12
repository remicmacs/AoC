import sys
from dataclasses import dataclass, field
from typing import List

def return_empty_list() -> List:
    return list()

@dataclass
class Header:
    """Node header data.

    Attributes
    ----------
    children_nb : int
        The number of children the Node has.
    meta_nb : int
        The number of metadata entries the Node holds.
    """
    children_nb: int
    meta_nb: int

@dataclass
class Node:
    """Dataclass representing the Node of a tree.

    A tree is represented by its root Node and all Nodes linked from the
    root. Each Node has a Header specifying the quantity of child Nodes
    and metadata entries it holds.

    Attributes
    ----------
    header : Header
        The header of the Node. See Header dataclass.
    metadata : List[int]
        List of metadata entries.
    children : List[Node]
        List of child Nodes.
    """
    header: Header
    metadata: List[int] = field(default_factory=return_empty_list)
    children: List['Node'] = field(default_factory=return_empty_list)

def sum_tree_meta(root: Node) -> int:
    """Sums all metadata entries of a given tree."""
    acc = 0
    for child in root.children:
        acc += sum_tree_meta(child)
    return acc + sum(root.metadata)

def parse_tree(ints: List[int]) -> Node:
    """Recursively parses a tree from a list of integers"""

    # We create a root Node with the first two ints as Header data.
    root = Node(Header(*ints[:2]))
    # Everytime elements are consumed, the original list must be modified.
    ints[:] = ints[2:]

    # Because of the format of the input, we have to recursively parse
    #   children first if they exist.
    if root.header.children_nb != 0:
        for i in range(root.header.children_nb):
            child = parse_tree(ints)
            root.children.append(child)

    # After parsing children, we can parse metadata.
    root.metadata = ints[:root.header.meta_nb]
    ints[:] = ints[root.header.meta_nb:]
    return root

def node_value(root: Node) -> int:
    """Process the value of a Node"""

    if root.header.children_nb == 0:
        return sum(root.metadata)
    else:
        value = 0
        for index in root.metadata:
            index -= 1
            if index < len(root.children):
                value += node_value(root.children[index])
        return value

if __name__ == '__main__':
    ints = []
    with open(sys.argv[1], mode='r') as f:
        for line in f:
            new_ints = [int(x) for x in line.split()]
            ints.extend(new_ints)

    root = parse_tree(ints)
    print(sum_tree_meta(root))
    print(node_value(root))