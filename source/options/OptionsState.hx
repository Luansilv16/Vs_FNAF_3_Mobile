package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.animation.FlxAnimationController;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.ui.FlxButton;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	private static var curSelected:Int = 0;

	// Bgs
	var bg:FlxSprite;
	var darkenBG:FlxSprite;
	
	var menuList:Array<String> = ['Notecolors', 'Controls', 'Notedelay', 'Graphics', 'Visuals', 'Gameplay', 'Mobile Controls'];

	// Filepath shortcut
	var spritePath:String = 'menus/optionsMenu/';

	// UI Button stuff
	var btnGroup:FlxTypedGroup<FlxButton>;
	var btnGroups:Array<FlxTypedGroup<FlxButton>> = [];

	// Button properties 
	// DO NOT CHANGE THESE VARIABLES THEY'RE HANDLED IN A FUNCTION LATER ON.
	var btnWidth:Int = 0; // Width of each button.
	var btnHeight:Int = 0; // Height of each button.
	var btnX:Int = 0; // X position of the button row.
	var btnY:Int = 0; // Y position of the button row.
	var btnSpacing:Int = 0; // Space between each button.

	// Bullshit position work around for frames.
	var highlightedFrames:Array<FlxSprite> = [];
	var pressedFrames:Array<FlxSprite> = [];

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menus/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var tipText:FlxText = new FlxText(150, FlxG.height - 24, 0, 'Press C to Go Mobile Controls Menu', 16);
		tipText.setFormat("stalker2.ttf", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 1.25;
		tipText.scrollFactor.set();
		tipText.antialiasing = ClientPrefs.globalAntialiasing;
		add(tipText);

		/* Call our separated function for creating menu buttons */
		btnGroups.push(createGroup(menuList));

		ClientPrefs.saveSettings();

		addVirtualPad(NONE, B_C);

		super.create();
	}

	
	public function createGroup(menuList:Array<String>):FlxTypedGroup<FlxButton> 
	{
		// Initialize group.
		btnGroup = new FlxTypedGroup<FlxButton>();
	
		for (i in 0...menuList.length) {
			btnWidth = FlxG.width; // Set the button width to the game width, to prevent a really dumb bug I have no clue how to properly fix.
			btnHeight = 55;
			btnSpacing = 24;
			btnX = 69; // haha funny number.
			btnY = 100 + (btnHeight + btnSpacing) * i;
	
			// Automatically create the appropiate amount of buttons.
			var button = createButton(btnX, btnY, i, menuList);
			btnGroup.add(button);
		}
		add(btnGroup);
	
		return btnGroup;
	}

	function createButton(btnX:Int, btnY:Int, index:Int, menuList:Array<String>):FlxButton
	{
		// Button creation.
		var button = new FlxButton(btnX, btnY, "", onButtonClicked.bind(index, menuList));

		// Load a sprite sharing the name of the menu.
		button.loadGraphic(Paths.image(spritePath + menuList[index].toLowerCase()));
		button.frames = Paths.getSparrowAtlas(spritePath + menuList[index].toLowerCase());
		button.animation.addByPrefix('idle', menuList[index] + ' idle', 24, true);
		button.animation.addByPrefix('highlighted', menuList[index] + ' highlighted', 24, true);
		button.animation.addByPrefix('pressed', menuList[index] + ' pressed', 24, true);

		button.width = btnWidth;
		button.height = btnHeight;

		// Assign button events to functions.
		button.onOver.callback = onButtonHighlight.bind(index, menuList);
		button.onOut.callback = onButtonDeselect.bind(index, menuList); 

		button.animation.play('idle');

		/* 	
			The onDown and onUp event triggers even when you hold your mouse button down and hover over/hover out of the button. 
			Setting allowSwiping to false will prevent this.
		*/
		button.allowSwiping = false;
		
		return button;
	}

	function onButtonClicked(index:Int, menuList:Array<String>) 
	{
		// Set the current selection to the index of the clicked button.
		curSelected = index;

		var button = btnGroup.members[curSelected];
		button.animation.play('pressed');

		// Play a sound when the button is clicked.
		FlxG.sound.play(Paths.sound('done'), 1);
		
		switch(index) {
			case 0: //'Notecolors':
				openSubState(new options.NotesSubState());
			case 1: //'Controls':
				openSubState(new options.ControlsSubState());
			case 2: //'Notedelay':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
			case 3: //'Visuals':
				openSubState(new options.VisualsUISubState());
			case 4: //'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 5: //'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 6: //'Mobile Options':
				openSubState(new mobile.options.MobileOptionsSubState());
		}
		button.x = 69;
		button.y = button.y + 1;
	}


	function onButtonHighlight(index:Int, menuList:Array<String>)
	{
		curSelected = index;

		var button = btnGroup.members[curSelected];
		button.x = 4;
		button.y = button.y - 1; // No, using -= doesn't work here due to how dumb the FlxButton events are handled.
		button.animation.play('highlighted');
	}

	function onButtonDeselect(index:Int, menuList:Array<String>) 
	{
		curSelected = index;

		var button = btnGroup.members[curSelected];
		button.x = 69;
		button.y = button.y + 1;
		button.animation.play('idle');

		index = -1;
		curSelected = index;
	}

	override function closeSubState() {
		super.closeSubState();
		removeVirtualPad();
		addVirtualPad(NONE, B_C);
		persistentUpdate = true;
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.BACK) {
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (virtualPad.buttonC.justPressed) {
			persistentUpdate = false;
			openSubState(new mobile.MobileControlsSelectSubState());
		}
	}
}
