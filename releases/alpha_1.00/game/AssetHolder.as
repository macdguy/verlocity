package game
{
	/**
	 * Holds all the assets of the game.
	 */
	public class AssetHolder extends Object
	{
		[Embed(source = "materials/tile.png")] public static const MatTile:Class;
		[Embed(source = "materials/grass.png")] public static const MatGrass:Class;
		[Embed(source = "materials/dirt.png")] public static const MatDirt:Class;
		[Embed(source = "materials/sky.png")] public static const MatSky:Class;
		
		[Embed(source = "materials/sprite_grass.png")] public static const MatGrassSprite:Class;
		[Embed(source = "materials/sprite_tree.png")] public static const MatTreeSprite:Class;
	}
}