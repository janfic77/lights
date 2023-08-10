
@if not exist "output" md "output"

openscad -o output/lustr_blok.stl       lustr_blok.scad
openscad -o output/lustr_rameno.stl     lustr_rameno.scad
openscad -o output/lustr_sokl.stl       lustr_sokl.scad
