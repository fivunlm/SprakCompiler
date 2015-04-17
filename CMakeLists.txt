
cmake_minimum_required (VERSION 2.8.11)
project (SPRAK)

configure_file(test/prueba.txt prueba.txt COPYONLY)

add_executable(Grupo05 la/la.c main_la.c)
