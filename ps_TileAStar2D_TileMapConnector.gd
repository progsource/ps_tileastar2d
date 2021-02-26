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
extends TileMap


# available cell sizes for drawing the walkable path
const ps_TileAStar2D_CellSize : Array = [ 16, 32, 48, ]
# this is set up to fit the ps_TileAStar2D_Blocks.tres TileSet
const walkable_tile_types : Array = [ 0, 1, 2, ]

# if debug is on, it will render the TileMap and the debug node in the scene
export(bool) var debug = false
# select the size of the TileMap cells
export(int, "16x16", "32x32", "48x48") var con_cell_size : int = 0 setget set_con_cell_size

# the astar object from which you can generate the paths
var astar : AStar2D = null

# getter and setter ------------------------------------------------------------

# The setter initializes the map with the wanted size - default is 16x16
func set_con_cell_size(var size : int) -> void :
  con_cell_size = size
  _init_cell_size(ps_TileAStar2D_CellSize[size])

# "public" functions -----------------------------------------------------------

# Initialize astar, generate the nodes and connections, and draw the debug paths
func initialize() -> void :
  _init_astar()
  _generate_vertices()
  $ps_TileAStar2D_DebugNode.set_astar_tilemap_connector(self)
  if Engine.editor_hint:
    if not is_connected("visibility_changed", self, "_on_visibility_changed"):
      connect("visibility_changed", self, "_on_visibility_changed")
    if not $ps_TileAStar2D_DebugNode.is_connected("visibility_changed", self, "_on_visibility_changed"):
      $ps_TileAStar2D_DebugNode.connect("visibility_changed", self, "_on_visibility_changed")
  if visible:
    $ps_TileAStar2D_DebugNode.update()

# "protected" functions --------------------------------------------------------

# On entering the tree it decides if the TileMap is visible, so if it is in
# editor or debug is on and calls initialize.
func _enter_tree():
  visible = debug or Engine.editor_hint
  initialize()

# "private" functions ----------------------------------------------------------

# Whenever the visibility changes, initialize is called, so that the debug path
# is redrawn. Sadly I couldn't find a way to redraw the debug path whenever you
# draw on the TileMap.
func _on_visibility_changed() -> void :
  initialize()


# This initializes the TileMap with one of the possible cell sizes.
func _init_cell_size(var i_cell_size : int) -> void :
  assert(i_cell_size in ps_TileAStar2D_CellSize)
  set_cell_size(Vector2(i_cell_size, i_cell_size))
  cell_quadrant_size = i_cell_size
  property_list_changed_notify()


# Initialize astar and makes sure, that the debug node has the correct position.
func _init_astar() -> void :
  if not astar:
    astar = AStar2D.new()
  $ps_TileAStar2D_DebugNode.position = Vector2(
    (get_used_rect().position.x - 1) * cell_quadrant_size * 0.5,
    (get_used_rect().position.y - 1) * cell_quadrant_size * 0.5)


# Get the index of a tile by its position.
func _get_index_for_xy(x : int, y : int, used_rect : Rect2) -> int :
  var x_modifier = used_rect.position.x * -1 if used_rect.position.x < 0 else used_rect.position.x
  var y_modifier = used_rect.position.y * -1 if used_rect.position.y < 0 else used_rect.position.y
  var id : int = int((y + y_modifier) * used_rect.size.x + x + x_modifier);
  assert(id >= 0)
  return id


# Generate the possible astar nodes and connections
func _generate_vertices() -> void :
  var nav_vertices := []
  var nav_connections := []
  var used_rect = get_used_rect()

  for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
    for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
      var tile = get_cell(x, y)
      if tile == TileMap.INVALID_CELL:
        continue
      if tile in walkable_tile_types:
        nav_vertices.push_back({"id": _get_index_for_xy(x, y, used_rect), "pos": Vector2(x, y)})

  astar.clear()
  for p in nav_vertices:
    var pos = p["pos"]
    pos.x = pos.x * cell_quadrant_size
    pos.y = pos.y * cell_quadrant_size
    astar.add_point(p["id"], pos)

  for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
    for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
      if get_cell(x, y) == TileMap.INVALID_CELL:
        continue
      # x x x
      # x # 0
      # 0 0 0
      if (get_cell(x - 1, y - 1) in walkable_tile_types and
        (get_cell(x - 1, y) in walkable_tile_types or
        get_cell(x, y - 1) in walkable_tile_types)
      ):
        nav_connections.push_back({
          "id" : _get_index_for_xy(x, y, used_rect),
          "to_id" : _get_index_for_xy(x - 1, y - 1, used_rect)
          })

      if get_cell(x, y - 1) in walkable_tile_types:
        nav_connections.push_back({
          "id" : _get_index_for_xy(x, y, used_rect),
          "to_id" : _get_index_for_xy(x, y - 1, used_rect)
          })

      if (get_cell(x + 1, y - 1) in walkable_tile_types and
        (get_cell(x + 1, y) in walkable_tile_types or
        get_cell(x, y - 1) in walkable_tile_types)
      ):
        nav_connections.push_back({
          "id" : _get_index_for_xy(x, y, used_rect),
          "to_id" : _get_index_for_xy(x + 1, y - 1, used_rect)
          })

      if get_cell(x - 1, y) in walkable_tile_types:
        nav_connections.push_back({
          "id" : _get_index_for_xy(x, y, used_rect),
          "to_id" : _get_index_for_xy(x - 1, y, used_rect)
          })

  for c in nav_connections:
    astar.connect_points(c["id"], c["to_id"])
