package VerlocityEngine.base
{
	public dynamic class verBState extends verBMovieClip
	{
		protected var Cutscene:Boolean;
		protected var AddToStage:Boolean;
		protected var NextState:Class;
		protected var Layer:String;

		public function SetupState():void {}
		public function BeginState():void {}
		public function Think():void {}
		public function EndState():void {}
		public function ShouldEnd():Boolean	{ return false; }
		public function KeyInput( key:uint ):void {}
		public function MouseInput():void {}

		public function verBState():void
		{
			mouseEnabled = false; mouseChildren = false;
		}

		public override function toString():String { return "Base State"; }
		
		public function GetClass():Object
		{
			return Object( this ).constructor;
		}

		public function get bIsCutscene():Boolean { return Cutscene; }
		public function get bAddToStage():Boolean { return AddToStage; }
		public function get cNextState():Class { return NextState; }
		public function get sLayer():String { return Layer; }
	}
}