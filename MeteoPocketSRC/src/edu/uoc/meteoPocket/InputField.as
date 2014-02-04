package edu.uoc.meteoPocket
{
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	
	public class InputField extends Sprite
	{
		// timeline instances
		private var _label:String;
		private var _input:String;
		private var _defaultInputTxt:String;
		public var labelField_tf:TextField;
		public var inputField_tf:TextField;
		
		public function InputField()
		{
			super();
			
			inputField_tf.addEventListener(FocusEvent.FOCUS_IN,onFocusIn);
			inputField_tf.addEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
		}
		
		public function init(label:String = "", input:String = ""):void{
			
			_label = label;
			
			labelField_tf.text = label;
			inputField_tf.text = input;
			
			_defaultInputTxt = new String(inputField_tf.text);
		}
		
		public function setLabel(label:String){
			changeLabel(label);
		}
		
		public function setInput(input:String){
			changeInput(input);
		}
		
		private function changeLabel(label:String){
			_label = label;
			labelField_tf.text = _label;
		}
		
		private function changeInput(input:String){
			_input = input;
			inputField_tf.text = _input;
		}
		
		public function getInput() {
			return readInput();
		}
		
		private function readInput(){
			return (inputField_tf.text);
		}
		
		internal function resetInput(){
			inputField_tf.text = _defaultInputTxt
		}
		
		//EVENTLISTENERS
		private function onFocusIn(ev:FocusEvent):void{
			if (inputField_tf.text == _defaultInputTxt){
				inputField_tf.text = "";
			}
		}
		private function onFocusOut(ev:FocusEvent):void{
			if (inputField_tf.text == ""){
				inputField_tf.text = _defaultInputTxt;
			}
		}
	}
}