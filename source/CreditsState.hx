package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
        var background:FlxSprite;
        private var camGame:FlxCamera;
        var debugKeys:Array<FlxKey>;

        var sprites:Array<FlxSprite> = [];
        var buttons:Array<FlxButton> = [];

        var spritePath:String = 'menus/creditsMenu/';
        var peopleSprites:String = 'menus/creditsMenu/people/';
	
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		
		background = new FlxSprite(-400, -300);
                background.frames = Paths.getSparrowAtlas(spritePath + 'bg');
                background.animation.addByPrefix('play', 'idle', 18, true);
                background.setGraphicSize(Std.int(background.width * 1.175));
                background.updateHitbox();
                background.screenCenter();
                add(background);
                background.animation.play('play');
                background.scale.set(0.666666, 0.666666);
		
	var names = ['pouria', 'thunder', 'penove', 'glitch', 'lulu', 'aleks', 'vev', 'dom', 'others'];
        for (i in 0...names.length)
        {
            var sprite = new FlxSprite();
            sprite.loadGraphic(Paths.image(peopleSprites + names[i]));
            add(sprite);
            sprite.scale.set(0.66, 0.66);
            sprite.screenCenter();
            sprite.visible = i == 0;
            sprites.push(sprite);

            var button = new FlxButton(450, 500, "", onButtonClicked.bind(i));
            button.screenCenter();
            button.loadGraphic(Paths.image(spritePath + 'button' + '${i+1}'), true, 100, 100);
            add(button);
            button.x = 450 + i * 85;
            button.y = 40;
            button.scale.set(0.85, 0.85);
            button.updateHitbox();

		addVirtualPad(NONE, B);

		super.create();

		buttons.push(button);
	}
   }

	function onButtonClicked(index:Int)
        {
            for (i in 0...sprites.length)
            {
            sprites[i].visible = i == index;
            }
        }

	override function update(elapsed:Float)
	{
	    if (controls.BACK)
	    {
		FlxG.sound.play(Paths.sound('cancelMenu'));
		MusicBeatState.switchState(new MainMenuState());
	    }
		
           super.update(elapsed);
	}
}
