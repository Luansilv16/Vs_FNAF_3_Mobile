package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var fnafVersion:String = "1.0.1";
	public static var psychEngineVersion:String = '0.6.3(Modficado)'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var debugKeys:Array<FlxKey>;
	
        var spritePath:String = 'menus/mainMenu/';

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(spritePath + 'bg'));
		bg.frames = Paths.getSparrowAtlas(spritePath + 'bg');
		bg.animation.addByPrefix('play', 'idle', 18, true);
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		bg.scale.set(0.666666, 0.666666);
		bg.updateHitbox();
		bg.animation.play('play');
		add(bg);

		var logothing:FlxSprite = new FlxSprite().loadGraphic(Paths.image(spritePath + 'fnaf3logo'));
		logothing.scrollFactor.set(0, 0);
		logothing.screenCenter();
		logothing.updateHitbox();
		logothing.scale.set(0.666666, 0.666666);
		add(logothing);

		var versionShit:FlxText = new FlxText(1000, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("stalker2.ttf", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		
		var versionShit:FlxText = new FlxText(1000, FlxG.height - 24, 0, "Vs FNAF 3 v" + fnafVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("stalker2.ttf", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

	        addVirtualPad(NONE, NONE);

		super.create();

		var newgame = new FlxButton(0, 0, " ", newgamestart);
		newgame.loadGraphic(Paths.image(spritePath + 'buttonStory'), true, 500, 55);
		newgame.screenCenter();
		newgame.x = -1;
		newgame.y = 380;
		add(newgame);

		var loadgame = new FlxButton(0, 0, " ", loadgamestart);
		loadgame.loadGraphic(Paths.image(spritePath + 'buttonFreeplay'), true, 500, 55);
		loadgame.screenCenter();
		loadgame.x = -1;
		loadgame.y = 460;
		add(loadgame);
	
		var credits = new FlxButton(0, 0, " ", creditsstart);
		credits.loadGraphic(Paths.image(spritePath + 'buttonCredits'), true, 500, 55);
		credits.screenCenter();
		credits.x = -1;
		credits.y = 540;
		add(credits);

		var extra = new FlxButton(0, 0, " ", extrastart);
		extra.loadGraphic(Paths.image(spritePath + 'buttonOptions'), true, 500, 55);
		extra.screenCenter();
		extra.x = -1;
		extra.y = 620;
		add(extra);
	}

	function newgamestart()
	{
		MusicBeatState.switchState(new StoryMenuState());
		FlxG.sound.play(Paths.sound('done'), 0.7);
	}

	function loadgamestart()
	{
		MusicBeatState.switchState(new FreeplayState());
		FlxG.sound.play(Paths.sound('done'), 0.7);
	}

	function creditsstart()
	{
		MusicBeatState.switchState(new CreditsState());
		FlxG.sound.play(Paths.sound('done'), 0.7);
	}

	function extrastart()
	{
		MusicBeatState.switchState(new options.OptionsState());
		FlxG.sound.play(Paths.sound('done'), 0.7);
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		        else if (virtualPad.buttonE.justPressed || FlxG.keys.anyJustPressed(debugKeys)) {
			           selectedSomethin = true;
			           MusicBeatState.switchState(new MasterEditorMenu());
	        }
		
		super.update(elapsed);
	}
}
