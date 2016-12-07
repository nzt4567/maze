from setuptools import setup
from Cython.Build import cythonize
import numpy

setup(
    name='cmaze',
    ext_modules=cythonize('cmaze.pyx', language_level=3, include_dirs=[numpy.get_include()]),
    include_dirs=[numpy.get_include()],
    install_requires=[
        'Cython',
        'NumPy',
    ],
)