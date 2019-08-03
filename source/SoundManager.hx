import openfl.Assets;

import flixel.FlxG;

using nova.animation.Director;
using nova.utils.ArrayUtils;

class SoundManager {
  public static var instance(default, null):SoundManager = new SoundManager();

  public var soundVolumes:Array<Float>;

  public function new() {
    soundVolumes = [];
  }

  public static function playMusic(path:String) {
    #if flash
    FlxG.sound.playMusic('assets/music/' + path + '.mp3');
    #else
    FlxG.sound.playMusic('assets/music/' + path + '.ogg');
    #end
  }

  public static function addSound(path:String, volume:Float, musicVolume:Float = 0.75, frames:Int = 10) {
    #if flash
    var s = FlxG.sound.load('assets/sounds/' + path + '.mp3');
    #else
    var s = FlxG.sound.load('assets/sounds/' + path + '.ogg');
    #end

    s.volume = volume;
    s.play();

    instance.soundVolumes.push(musicVolume);
    FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume, musicVolume);

    Director.wait(frames).call(function() {
      instance.removeSoundWithVolume(musicVolume);
    });
  }

  public function removeSoundWithVolume(volume:Float) {
    instance.soundVolumes.remove(volume);
    if (instance.soundVolumes.length == 0) {
      FlxG.sound.music.volume = 1.0;
      return;
    }
    FlxG.sound.music.volume = soundVolumes.min();
  }
}
