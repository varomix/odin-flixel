package flixel

import "core:math/rand"
import rl "vendor:raylib"

Camera :: struct {
	rl_camera:       rl.Camera2D,

	// Shake properties
	shake_intensity: f32,
	shake_duration:  f32,
}

camera_new :: proc() -> ^Camera {
	cam := new(Camera)
	cam.rl_camera.zoom = 1.0
	return cam
}

camera_update :: proc(cam: ^Camera, dt: f32) {
	if cam.shake_duration > 0 {
		cam.shake_duration -= dt
		if cam.shake_duration <= 0 {
			cam.rl_camera.offset = {0, 0}
		} else {
			// Shake amount is a random value between -intensity and +intensity
			shake_amount_x :=
				rand.float32_range(-cam.shake_intensity, cam.shake_intensity) * f32(get_width())
			shake_amount_y :=
				rand.float32_range(-cam.shake_intensity, cam.shake_intensity) * f32(get_height())
			cam.rl_camera.offset = rl.Vector2{shake_amount_x, shake_amount_y}
		}
	}
}

camera_shake :: proc(cam: ^Camera, intensity: f32 = 0.05, duration: f32 = 0.5) {
	if cam.shake_duration <= 0 {
		cam.shake_intensity = intensity
		cam.shake_duration = duration
	}
}
