/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package game.states 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import fl.motion.Color;

	import verlocity.Verlocity;
	import verlocity.logic.State;
	import verlocity.ents.spawners.BeatSpawner;
	import verlocity.sound.SoundObject;

	import game.ents.*;
	import game.AssetHolder;

	public class State_Demo extends State
	{
		private var ship:CharacterShip;
		private var music:SoundObject;
		private var beatSpawner:BeatSpawner;

		//private var cube:Cube;

		public override function Construct():void 
		{
			NextState = State_Empty;
			
			// Create pause menu
			Verlocity.pause.AddPauseMenuItem( "Restart", function() { Verlocity.state.Restart(); } );
			Verlocity.pause.AddPauseMenuItem( "Quit", function() { Verlocity.Quit(); } );

			// Create layers
			Verlocity.layers.Create( "Gameplay", false );
			Verlocity.SetGameLayer( "Gameplay" );
			
			Verlocity.layers.Create( "BG", false );
			Verlocity.layers.Create( "BG3D", false );


			// Create the ship
			ship = Verlocity.ents.Create( CharacterShip );
				ship.SetPos( 150, 250 );
			ship.Spawn( Verlocity.gameLayer );
			//ship.SpawnOnStage();

			Verlocity.SetPlayer( ship );
			
			// Create 3D
			/*Verlocity.a3D.Create( "BG3D" );
			cube = Verlocity.a3D.CreateCube( new Vector3D(), 50, 50, 50, Material( Verlocity.a3D.MatColor( 0x000000 ) ) );*/
			
			// Create beat spawner
			beatSpawner = Verlocity.ents.Create( BeatSpawner );
				beatSpawner.SetSpawnParams( 0, EnemyShip, Art_EnemyShip,
											Verlocity.ScrW - 10, Verlocity.ScrW - 50, 100, Verlocity.ScrH - 100 );
			beatSpawner.Spawn( Verlocity.gameLayer );
			
			// Create visualizer
			//var visualizer:Visualizer = Verlocity.ents.Create( Visualizer, false );
			//visualizer.Spawn( "BG" );
			
			// Create particles
			Verlocity.particles.Create( Verlocity.gameLayer );
		}

		public override function Init():void
		{
			// Start analyzer
			Verlocity.analyzer.EnableAnalyzer();
		
			// Play music
			music = Verlocity.sound.Create( Verlocity.ContentFolder + "music.mp3", 1, true, true );
		}
		
		public override function Update():void
		{
			/*cube.moveLeft( Verlocity.analyzer.AverageBass * 10 );
			cube.yaw( Verlocity.analyzer.AverageBass * 10 );
			
			var mat:Material = Material( Verlocity.a3D.MatColor( Color.interpolateColor( 0x000000, 0xFFFFFF, Verlocity.analyzer.AverageBass ) ) );
			cube.material = mat;*/
		}
		
		public override function DeInit():void
		{
			Verlocity.ResetSlate();
			Verlocity.ents.RemoveAllTypes( [ "bullet", "enemy" ] );
		}

		public override function Destruct():void 
		{
			Verlocity.CleanSlate();
			Verlocity.pause.ClearPauseMenuItems();
		}
		
		public override function ToString():String
		{
			return "Music Demo";
		}
	}
}