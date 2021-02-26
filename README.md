# ps_TileAStar2D

This Godot plugin provides pathfinding nodes for the A* algorithm on 2D TileMaps.

**Tested Godot version**: 3.2.3

Use it as you see fit.

**Info:** This repository is in maintenance mode. I do not work actively on it,
but if you create issues or Pull Requests, I will take a look. Time-wise that
might vary though.

## HowTo

* Add this folder to your Godot project `{project folder}/addons/ps_tileastar2d`
* Activate the plugin in your project settings
* Add `ps_TileAStar2D_TileMapConnector.tscn` to your scene
* Configure the tile size via "Con Cell Size" - possible sizes are "16x16", "32x32" and "48x48"
* Draw with the tile with the related size on the TileMap wherever your objects shall walk on
* If you want to see the created AStar path, make the debug node shortly invisible and then visible again
* If you want to see the created AStar path inside of your game, turn on the debug flag
* After that you should be able to use the `astar` object from `ps_TileAStar2D_TileMapConnector` to create your paths

## Example usage

```
var astar = null # get it from ps_TileAStar2D_TileMapConnector
var actor_position = Vector2() # get this from the object that you want to move around
var target_position = Vector2() # get this from the destination where you want your object to move to

var closest_point_to_actor = astar.get_closest_point(actor_position)
var closest_point_to_target = astar.get_closest_point(target_position)
var path = astar.get_point_path(closest_point_to_actor, closest_point_to_target)
```

## Why?

During the Global GameJam 2021 we needed pathfinding in our
[pet project](https://github.com/progsource/ggj2021). To not have to come up
with it again in any upcoming gamejams, I created this plugin.

The one TileMap to draw the possible path on has the reason, that you might have
multiple TileMaps for your floor and objects. This is an easy and short way to
make AStar work for you.

## License

MIT - for more info see [LICENSE](LICENSE) or check the GDScript files.
