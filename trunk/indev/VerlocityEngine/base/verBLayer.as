package VerlocityEngine.base
{
	import VerlocityEngine.Verlocity;

	public class verBLayer extends verBScreenObject
	{
		public function Fill( uiColor:uint = 0xFFFFFF, nAlpha:Number = 1 ):void
		{
			graphics.beginFill( uiColor, nAlpha );
				graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
			graphics.endFill();
		}
	}
}