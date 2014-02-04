package edu.uoc.meteoPocket
{
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	
	public class StaticField extends Sprite
	{
		// timeline instances
		private var _label:String;
		private var _data:String;
		public var labelField_tf:TextField;
		public var dataField_tf:TextField;
		
		public function StaticField(label:String = "")
		{
			super();
			
			_label = label;
			labelField_tf.text = _label;
			dataField_tf.text = "Introduiu " + _label;
			
		}
		
		public function setLabel(label:String){
			changeLabel(label);
		}
		
		public function setData(data:String){
			changeData(data);
		}
		
		private function changeLabel(label:String){
			trace("Changelabel");
			_label = label;
			labelField_tf.text = _label;
		}
		
		private function changeData(data:String){
			trace("Changelabel");
			_data = data;
			dataField_tf.text = _data;
		}
		
		public function getInput() {
			return readInput();
		}
		
		private function readInput(){
			return (dataField_tf.text);
		}

	}
}