#!python
#cython: language_level=3, boundscheck=False, wraparound=False, initializedcheck=False, cdivision=True
import numpy as np
cimport numpy as np
from collections import deque

ctypedef struct coord:
    int x
    int y

cdef class Maze:
    cdef public np.int8_t[:, :] directions
    cdef public np.int64_t[:, :] distances
    cdef public bint is_reachable
    cdef coord exit

    def __cinit__(self, np.int8_t[:, :] directions, np.int64_t[:, :] distances, bint is_reachable, coord maze_exit):
        self.directions = directions
        self.distances = distances
        self.is_reachable = is_reachable
        self.exit = maze_exit

    def path(self, int row, int column):
        if self.distances[row, column] == -1:
            raise IndexError("Wrong start")

        ret = []
        while True:
            ret += [(row, column)]
            if self.directions[row, column] == ord(">"):
                column += 1
            elif self.directions[row, column] == ord("<"):
                column -= 1
            elif self.directions[row, column] == ord("v"):
                row += 1
            elif self.directions[row, column] == ord("^"):
                row -= 1
            elif self.directions[row, column] == ord("X"):
                return ret

cdef np.int8_t direction(coord src, coord dst):
        if dst.x == src.x - 1:  # up
            return ord('^')
        if dst.y == src.y - 1:  # left
            return ord("<")
        if dst.x == src.x + 1:  # down
            return ord("v")
        if dst.y == src.y + 1:  # right
            return ord(">")

cdef bint valid_neighbor(coord node, int rows, int columns, np.int64_t[:, :] maze, np.int64_t[:, :] distances):
    if 0 <= node.x <= rows - 1 and 0 <= node.y <= columns - 1:
        if maze[node.x, node.y] >= 0 and distances[node.x, node.y] == -1:
            return True

    return False

cdef bint reachability(np.int8_t[:, :] directions, np.int64_t[:, :] maze, int rows, int columns):
    cdef bint ret = True

    for i in range(rows):
        for j in range(columns):
            if directions[i, j] == ord('#') and maze[i, j] >= 0:
                ret = False
                directions[i, j] = ord(' ')

    return ret

cdef coord find_exit(np.int64_t[:, :] maze, int rows, int columns):
    for i in range(rows):
        for j in range(columns):
            if maze[i, j] == 1:
                return coord(i, j)

    return coord(-1, -1)

cpdef Maze analyze(np.int64_t[:, :] maze):
    cdef int rows = maze.shape[0]
    cdef int columns = maze.shape[1]
    cdef bint is_reachable
    cdef coord maze_exit = find_exit(maze, rows, columns)
    cdef np.ndarray[np.int8_t, ndim=2] directions = np.full((rows, columns), b'#', dtype=('a', 1))
    cdef np.ndarray[np.int64_t, ndim=2] distances = np.full((rows, columns), -1, dtype=int)
    cdef coord n_up
    cdef coord n_down
    cdef coord n_left
    cdef coord n_right
    cdef coord current

    q = deque()
    distances[maze_exit.x, maze_exit.y] = 0
    directions[maze_exit.x, maze_exit.y] = ord("X")
    q.append(maze_exit)

    while q:
        current = q.popleft()
        n_up = coord(current.x - 1, current.y)
        n_down = coord(current.x + 1, current.y)
        n_left = coord(current.x, current.y - 1)
        n_right = coord(current.x, current.y + 1)

        if valid_neighbor(n_up, rows, columns, maze, distances):
            distances[n_up.x, n_up.y] = distances[current.x, current.y] + 1
            directions[n_up.x, n_up.y] = direction(n_up, current)
            q.append(n_up)

        if valid_neighbor(n_down, rows, columns, maze, distances):
            distances[n_down.x, n_down.y] = distances[current.x, current.y] + 1
            directions[n_down.x, n_down.y] = direction(n_down, current)
            q.append(n_down)

        if valid_neighbor(n_left, rows, columns, maze, distances):
            distances[n_left.x, n_left.y] = distances[current.x, current.y] + 1
            directions[n_left.x, n_left.y] = direction(n_left, current)
            q.append(n_left)

        if valid_neighbor(n_right, rows, columns, maze, distances):
            distances[n_right.x, n_right.y] = distances[current.x, current.y] + 1
            directions[n_right.x, n_right.y] = direction(n_right, current)
            q.append(n_right)

    is_reachable = reachability(directions, maze, rows, columns)

    return Maze(directions, distances, is_reachable, maze_exit)