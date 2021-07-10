class_name HexTile

# Index number of the hexagon
var HexNum

# Row and column of the hexagon
var Row
var Column

# X and Y coordinates of the center of the hexagon
var x
var y

# Polygon
var polygon

func _init(hex_num,r,c,xx,yy,map_region):
	self.HexNum = hex_num
	self.Row = r
	self.Column = c
	self.x = xx
	self.y = yy
	self.polygon = map_region
