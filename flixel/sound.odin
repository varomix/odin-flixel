package flixel

import "core:fmt"
import rl "vendor:raylib"

// Sound system - manages audio playback
// Based on original Flixel's FlxSound implementation

Sound :: struct {
	using base:  Object,
	sound:       rl.Sound,
	music:       rl.Music,
	is_music:    bool, // Determines if this is music (streamed) or sound effect
	volume:      f32,
	looped:      bool,
	survive:     bool, // If true, survives state changes
	loaded:      bool,
	path:        string, // Store the path for debug purposes
}

// Global sound cache to avoid reloading the same sound
sound_cache: map[string]rl.Sound
music_cache: map[string]rl.Music

// Global music control
current_music: ^Sound
global_volume: f32 = 1.0
global_muted: bool = false

// Initialize the sound system
sound_system_init :: proc() {
	rl.InitAudioDevice()
	sound_cache = make(map[string]rl.Sound)
	music_cache = make(map[string]rl.Music)
	fmt.println("Sound system initialized")
}

// Cleanup the sound system
sound_system_cleanup :: proc() {
	// Stop and unload current music
	if current_music != nil {
		sound_stop(current_music)
		sound_destroy(current_music)
	}

	// Unload all cached sounds
	for path, sound in sound_cache {
		rl.UnloadSound(sound)
	}
	delete(sound_cache)

	// Unload all cached music
	for path, music in music_cache {
		rl.UnloadMusicStream(music)
	}
	delete(music_cache)

	rl.CloseAudioDevice()
	fmt.println("Sound system cleaned up")
}

// Create a new sound object
sound_new :: proc() -> ^Sound {
	s := new(Sound)
	s.volume = 1.0
	s.looped = false
	s.active = false
	s.survive = false
	s.loaded = false
	s.is_music = false
	return s
}

// Load a sound effect from a file
sound_load :: proc(s: ^Sound, path: string, looped: bool = false) -> bool {
	s.path = path
	s.looped = looped
	s.is_music = false

	// Check if sound is already cached
	if path in sound_cache {
		s.sound = sound_cache[path]
		s.loaded = true
		fmt.println("Sound loaded from cache:", path)
		return true
	}

	// Load the sound
	s.sound = rl.LoadSound(cstring(raw_data(path)))
	if s.sound.frameCount > 0 {
		sound_cache[path] = s.sound
		s.loaded = true
		fmt.println("Sound loaded:", path)
		return true
	}

	fmt.println("Failed to load sound:", path)
	return false
}

// Load music from a file (streamed)
music_load :: proc(s: ^Sound, path: string, looped: bool = true) -> bool {
	s.path = path
	s.looped = looped
	s.is_music = true

	// Check if music is already cached
	if path in music_cache {
		s.music = music_cache[path]
		s.loaded = true
		fmt.println("Music loaded from cache:", path)
		return true
	}

	// Load the music
	s.music = rl.LoadMusicStream(cstring(raw_data(path)))
	if s.music.frameCount > 0 {
		music_cache[path] = s.music
		s.loaded = true
		s.music.looping = looped
		fmt.println("Music loaded:", path)
		return true
	}

	fmt.println("Failed to load music:", path)
	return false
}

// Play a sound
sound_play :: proc(s: ^Sound, restart: bool = false) {
	if !s.loaded {
		return
	}

	if s.is_music {
		// Stop current music if different
		if current_music != nil && current_music != s {
			sound_stop(current_music)
		}
		current_music = s

		if restart {
			rl.StopMusicStream(s.music)
		}
		rl.PlayMusicStream(s.music)
		rl.SetMusicVolume(s.music, s.volume * global_volume * (global_muted ? 0.0 : 1.0))
		s.active = true
	} else {
		if restart {
			rl.StopSound(s.sound)
		}
		rl.SetSoundVolume(s.sound, s.volume * global_volume * (global_muted ? 0.0 : 1.0))
		rl.PlaySound(s.sound)
		s.active = true
	}
}

// Stop a sound
sound_stop :: proc(s: ^Sound) {
	if !s.loaded {
		return
	}

	if s.is_music {
		rl.StopMusicStream(s.music)
	} else {
		rl.StopSound(s.sound)
	}
	s.active = false
}

// Pause a sound
sound_pause :: proc(s: ^Sound) {
	if !s.loaded {
		return
	}

	if s.is_music {
		rl.PauseMusicStream(s.music)
	}
	s.active = false
}

// Resume a sound
sound_resume :: proc(s: ^Sound) {
	if !s.loaded {
		return
	}

	if s.is_music {
		rl.ResumeMusicStream(s.music)
		s.active = true
	}
}

// Update music (call this every frame for music to work properly)
sound_update :: proc(s: ^Sound) {
	if s.is_music && s.loaded && s.active {
		rl.UpdateMusicStream(s.music)
	}
}

// Set volume for a sound (0.0 to 1.0)
sound_set_volume :: proc(s: ^Sound, volume: f32) {
	s.volume = clamp(volume, 0.0, 1.0)

	if !s.loaded {
		return
	}

	final_volume := s.volume * global_volume * (global_muted ? 0.0 : 1.0)

	if s.is_music {
		rl.SetMusicVolume(s.music, final_volume)
	} else {
		rl.SetSoundVolume(s.sound, final_volume)
	}
}

// Destroy a sound
sound_destroy :: proc(s: ^Sound) {
	if s.loaded {
		sound_stop(s)
		// Note: We don't unload from cache, as other sounds might be using it
		s.loaded = false
	}
}

// Check if sound is playing
sound_is_playing :: proc(s: ^Sound) -> bool {
	if !s.loaded {
		return false
	}

	if s.is_music {
		return rl.IsMusicStreamPlaying(s.music)
	} else {
		return rl.IsSoundPlaying(s.sound)
	}
}

// Global helper functions (similar to FlxG.play(), FlxG.playMusic())

// Play a sound effect once (convenience function)
play :: proc(path: string, volume: f32 = 1.0) -> ^Sound {
	s := sound_new()
	if sound_load(s, path, false) {
		sound_set_volume(s, volume)
		sound_play(s)
		return s
	}
	free(s)
	return nil
}

// Play background music (convenience function)
play_music :: proc(path: string, volume: f32 = 1.0, looped: bool = true) -> ^Sound {
	s := sound_new()
	if music_load(s, path, looped) {
		s.survive = true // Music survives state changes by default
		sound_set_volume(s, volume)
		sound_play(s)
		return s
	}
	free(s)
	return nil
}


// Set global volume
set_volume :: proc(volume: f32) {
	global_volume = clamp(volume, 0.0, 1.0)
	rl.SetMasterVolume(global_volume * (global_muted ? 0.0 : 1.0))
}

// Get global volume
get_volume :: proc() -> f32 {
	return global_volume
}

// Mute/unmute all sounds
set_muted :: proc(muted: bool) {
	global_muted = muted
	rl.SetMasterVolume(global_volume * (global_muted ? 0.0 : 1.0))
}

// Check if muted
is_muted :: proc() -> bool {
	return global_muted
}

// Update the current music (call this in your game loop)
update_music :: proc() {
	if current_music != nil {
		sound_update(current_music)
	}
}
