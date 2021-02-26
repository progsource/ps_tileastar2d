#Copyright © 2021 Petra Baranski (progsource)
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the “Software”), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
#of the Software, and to permit persons to whom the Software is furnished to do
#so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
tool
extends Node2D


# Color of the debug draw
export var color : Color = Color(0, 50, 300)
# TileMap with possible paths drawn on it
var astar_tilemap_connector : TileMap = null setget set_astar_tilemap_connector


# This setter is called from ps_TileAStar2D_TileMapConnector.gd
func set_astar_tilemap_connector(var connector):
  astar_tilemap_connector = connector


# The draw function goes over every node of the astar object and draws the path
# on top of the TileMap
func _draw():
  if not astar_tilemap_connector:
    return

  if not astar_tilemap_connector.astar:
    return

  if astar_tilemap_connector.astar.get_points().size() == 0:
    return

  for a in astar_tilemap_connector.astar.get_points():
    for b in astar_tilemap_connector.astar.get_point_connections(a):
      var pa = astar_tilemap_connector.astar.get_point_position(a)
      var pb = astar_tilemap_connector.astar.get_point_position(b)
      draw_line(Vector2(pa.x, pa.y), Vector2(pb.x, pb.y), color)
