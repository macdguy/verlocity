package game 
{
	import game.lang.English;
	import verlocity.settings.SettingsData;

	public dynamic class Settings extends SettingsData
	{
		public function Settings():void
		{
			DEBUG = true;
			DEBUG_COLLISION = false;
			STATE_TRANSITION_IN = new TransIn();
			STATE_TRANSITION_OUT = new TransOut();
			DEFAULT_LANGUAGE = new English();
			SHOW_SPLASH = false;
		}
	}
}