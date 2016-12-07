# maze
Simple maze solving using BFS and numpy arrays. Python version can be found in maze.py and tested by tests from test_analyze.py.
Optimized Cython version can be found in cmaze.pyx and tested by tests from test_canalyze.py. 

Use `python3 setup.py build_ext -i` to build the Cython version. Running `python3 -m pytest` fires up tests for both versions.
Use `from maze import analyze` to import the Python version and `from cmaze import analyze` to use the Cython one.
