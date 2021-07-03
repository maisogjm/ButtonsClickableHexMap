extends Node2D

# Need to set the mouse_filter parameter of the TextureRect to ignore.
# Otherwise, the TextureRect intercepts button clicks
# and the MapRegion never detects them!
# Reference: https://godotengine.org/qa/45682/how-to-detect-click-inside-collisionobject2d

# The map is composed of hexagons in Flat-Top orientation.
# The map is 16 hexagons tall, or 600 pixels.
# This means that each hexagon is 37.5 pixels tall.
# Here is a NICE reference for hex grids: https://www.redblobgames.com/grids/hexagons/#basics

# There are 22 columns of hexagons from left to right.
const num_cols = 22
# Columns that are 16 hexes from top to bottom, alternating with columns 15 hexes from top to bottom.
const num_hexes0 = 16
const num_hexes1 = 15
# Map X extent: 1 to 600
# Map Y extent: 1 to 480
# Top-to-bottom height of a hexagon is H = 600 / 16 = 37.5
# Length of a side of a hexagon is W = (H/2)/sin(60 degrees) = 21.650635094610966169093079268823
# The center of the hexagon in the upper left (the "first" hexagon) is *very* approximately: [X,Y] = [1.5*W, H/2]
# The exact X-Y coordinates will need to be adjusted to align with the underlying map of Black Sphinx Bay.
# With respect to the hexagon center [X,Y], the six vertices are (starting with the left):
# [-L,Y]
# [-(L/2),+(H/2)]
# [+(L/2),+(H/2)]
# [0,+L]
# [+(L/2),-(H/2)]
# [-(L/2),-(H/2)]

# NICE reference for dynamically creating clickable polygons:
# https://godotengine.org/qa/88503/whats-the-best-way-to-instantiate-dozens-clickable-polygons?show=88629#a88629
# See also: https://github.com/t-karcher/ClickableMap
const MapRegionScene := preload("res://MapRegion.tscn")

# Supplemental information for each hexagon.
const HexTile := preload("res://HexTile.gd")
var HexTile_array : Array = []

func _ready():
	# Compute Height and side Length of the hexagons.
	# In the first column, there are 16 hexagons from top to bottom.
	# Also, the map is 6000 pixels from top to bottom.
	# One would think that the height H of a hexagon is therefore
	# 600/16, but for some reason we need to adjust the value of H
	# by a fudge factor of about 0.8.
	var H = 0.8 *( 600.0 / num_hexes0 )
	var L = (H/2.0)/sin(60.0*PI/180.0)
	
	# Keep track of the number of hexagons.
	var hex_count = 0
	
	# Half of the columns have 16 hexagons. The other half has only 15 hexagons.
	for hex in range((16*num_cols/2)+(15*num_cols/2)):
		# The columns come in pairs. First is a column with 16 hexagons,
		# followed by a column with 15 hexagons. The map continues
		# alternating between 16- and 15-hexagon columns.
		var col_pair = floor( 1.0 * hex / ( num_hexes0 + num_hexes1 ) )
		
		# Compute the column number within pair, col_num_within_pair.
		# This is either 0 or 1, and can be used to compute the final
		# column number, col_num.
		# 0 : means the column has 16 hexagons from top to bottom.
		# 1 : means the column has 15 hexagons from top to bottom.
		var modulo_hex = hex % ( num_hexes0 + num_hexes1 )
		var col_num_within_pair = floor( 1.0 * modulo_hex / num_hexes0 )
		var col_num = 2*col_pair + col_num_within_pair
		
		# Compute the row number.
		# The 15-hexagon columns are shifted down with
		# respect to the 16-hexagon rows. Compute the magnitude
		# of this column shift.
		var row_num
		var col_shift
		if col_num_within_pair == 0:
			row_num = modulo_hex
			col_shift = 0
		else:
			row_num = modulo_hex - 16
			col_shift = (3.0/4.0)*L

		# Compute center of hexagon. Note fudge factors of '26' and '16',
		# manually adjusted to align the grid of hexagonal polygons with
		# the underlying map of Black Sphinx Bay.
		var X = 26 + 1.5*L*col_num + 812
		var Y = 16 + H*row_num + col_shift
		
		# Compute the coordinates of the vertices of the current
		# hexagon, and create a hexagon shape.
		var hex_shape = PoolVector2Array()
		hex_shape.append(Vector2(X-L, Y))
		hex_shape.append(Vector2(X-(L/2.0), Y+(H/2.0)))
		hex_shape.append(Vector2(X+(L/2.0), Y+(H/2.0)))
		hex_shape.append(Vector2(X+L, Y))
		hex_shape.append(Vector2(X+(L/2.0), Y-(H/2.0)))
		hex_shape.append(Vector2(X-(L/2.0), Y-(H/2.0)))
	
		# Instantiate a map_region, add the map_region to the Demo node,
		# then add the hexagon shape to the map_region. Also connect up
		# the function _on_MapRegion_selected to the hexagon.
		var map_region : MapRegion = MapRegionScene.instance()
		add_child(map_region)
		map_region.shape = hex_shape
		var _connect_return
		_connect_return = map_region.connect("region_selected", self, "_on_MapRegion_selected", [hex])
		
		# Instantiate a HexTile containing X-Y coordinate and Row-Column
		# information on the current hexagon, then add it to the array
		# of HexTiles. Other pieces of ancillary hexagon information such as
		# the terrain type of each specific hex could be stored in this array.
		var r = int(row_num+1) # 1-offset row number
		var c = int(col_num+1) # 1-offset column number
		var hex_tile = HexTile.new(hex_count,r,c,X,Y)
		HexTile_array.append(hex_tile)
		
		# Keep track of the number of hexagons.
		hex_count = hex_count + 1
	print("Number of hexagons = " + str(hex_count))

func _on_MapRegion_selected(id : int):
	print ("Hexagon #" + str(id) + " was selected.")
	print("    X = " + str(HexTile_array[id].x) + " : Y = " + str(HexTile_array[id].y))
	print("    Row = " + str(HexTile_array[id].Row) + " : Column = " + str(HexTile_array[id].Column))
