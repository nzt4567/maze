import numpy as np
from collections import deque


class Maze:
    def __init__(self, maze: np.array):
        self.rows, self.columns = maze.shape
        self.directions = np.full((self.rows, self.columns), '#', dtype=('a', 1))
        self.distances = np.full((self.rows, self.columns), -1, dtype=int)
        self.exit = np.where(maze == 1)
        self.exit = self.exit[0][0], self.exit[1][0]
        self.maze = maze
        self.is_reachable = True
        self.analyze()

    def analyze(self):
        def direction(src, dst):
            src_x = src[0]
            src_y = src[1]
            dst_x = dst[0]
            dst_y = dst[1]

            if dst_x == src_x - 1:  # up
                return b"^"
            if dst_y == src_y - 1:  # left
                return b"<"
            if dst_x == src_x + 1:  # down
                return b"v"
            if dst_y == src_y + 1:  # right
                return b">"

            raise Exception("THIS SHOULD NEVER HAPPEN")

        q = deque()
        self.distances[self.exit] = 0
        self.directions[self.exit] = b"X"
        q.append(self.exit)

        while q:
            current = q.popleft()
            for n in self.valid_neighbors(current):
                self.distances[n] = self.distances[current] + 1
                self.directions[n] = direction(n, current)
                q.append(n)

        for n in zip(*np.where(self.directions == b"#")):
            if self.maze[n] >= 0:
                self.is_reachable = False
                self.directions[n] = b" "

    def valid_neighbors(self, node):
        x = node[0]
        y = node[1]
        for n_x, n_y in [(x - 1, y), (x, y - 1), (x + 1, y), (x, y + 1)]:
            if 0 <= n_x <= self.rows - 1 and 0 <= n_y <= self.columns - 1:
                if self.maze[n_x, n_y] >= 0 and self.distances[n_x, n_y] == -1:
                    yield n_x, n_y

    def path(self, row, column):
        path_map = {b">": lambda x, y: (x, y + 1),
                    b"<": lambda x, y: (x, y - 1),
                    b"v": lambda x, y: (x + 1, y),
                    b"^": lambda x, y: (x - 1, y),
                    b"X": lambda x, y: (x, y)}

        if self.distances[row, column] == -1:
            raise Exception("Wrong start")

        ret = [(row, column)]
        while True:
            row, column = path_map[self.directions[row, column]](row, column)
            ret += [(row, column)]

            if (row, column) == self.exit:
                return ret


def analyze(maze):
    return Maze(maze)


def test():
    pass

if __name__ == '__main__':
    in_maze = np.array([[-1, 0, 0, 0, -1, -1],
                        [-1, -1, -1, 0, 0, -1],
                        [0, 0, 0, -1, 0, -1],
                        [-1, 0, -1, 0, 0, -1],
                        [0, 0, 0, 0, -1, -1],
                        [0, 0, 0, 0, -1, 0],
                        [0, -1, -1, 0, 0, -1],
                        [0, 1, 0, 0, -1, -1]])
    m = analyze(in_maze)
    print(m.path(5, 3))
