# PauseMenu Scene - Testing Guide

## Overview
The PauseMenu is a CanvasLayer-based overlay with blur effect, scale-in animation, and button interactions.

## What Was Implemented

### 1. Script: `scripts/ui/pause_menu.gd`
- Extends CanvasLayer (layer = 100)
- Manages pause state with animations
- Handles ESC key for immediate resume
- Provides fade-out transitions before loading menu or quitting

### 2. Scene: `scenes/ui/menus/pause_menu.tscn`
- Root: CanvasLayer with PauseMenu script
- Structure:
  - Control (full screen overlay)
    - ColorRect (blur overlay with shader)
    - Panel (centered, 300x400)
      - VBoxContainer (with spacing)
        - PauseLabel "PAUSADO" (32px)
        - ButtonsContainer (VBoxContainer)
          - ResumeButton
          - SettingsButton
          - MenuButton
          - QuitButton

### 3. Test Scene: `scenes/ui/menus/test_pause_menu.tscn`
- Simple scene with PauseMenu instantiated
- Can be run to verify UI and animations

## Manual Testing Checklist

### Visual Verification
- [ ] PauseMenu appears when scene loads
- [ ] Panel scales from 0.8 to 1.0 (0.3s animation)
- [ ] Panel fades in from alpha 0.0 to 1.0 (0.3s animation)
- [ ] ColorRect blur is visible on background (alpha 0.7)
- [ ] Buttons are visible and properly spaced
- [ ] "PAUSADO" label is centered and readable

### Interactive Verification
- [ ] Hovering over buttons shows scale-up animation (1.05x)
- [ ] Buttons change color on hover (white to yellow)
- [ ] Clicking "Retomar" fades out and closes menu (0.2s)
- [ ] Pressing ESC fades out and closes menu immediately
- [ ] Clicking "Menu Principal" fades out (0.5s) and loads main menu
- [ ] Clicking "Sair" fades out (0.5s) and quits game
- [ ] "Configurações" button shows TODO message in console

### Console Verification
- [ ] "[PauseMenu] PauseMenu ready - Press ESC to resume" appears on load
- [ ] "[MenuController] Game paused" appears when MenuController.toggle_pause() is called
- [ ] "[MenuController] Game resumed" appears on resume
- [ ] No error messages about missing nodes

## How to Test

### Option 1: Run Test Scene Directly
1. Open Godot Editor
2. Open `scenes/ui/menus/test_pause_menu.tscn`
3. Click Play (F5)
4. Verify all checklist items above

### Option 2: Integrate into MainGame (Task 6)
1. In your main game scene's script, add:
   ```gdscript
   func _input(event: InputEvent) -> void:
       if Input.is_action_just_pressed("ui_cancel"):
           MenuController.toggle_pause()
           var pause_menu = load("res://scenes/ui/menus/pause_menu.tscn").instantiate()
           add_child(pause_menu)
   ```
2. Play the game and press ESC to trigger pause menu

## Expected Behavior

### On Scene Load
- Panel appears with scale-in animation (0.3s)
- ColorRect blur overlay fades in
- All buttons are ready for interaction

### Resume (Button or ESC)
- Panel fades out (0.2s)
- Menu disappears
- Game resumes (MenuController.toggle_pause() called)

### Load Menu
- Panel fades out (0.5s)
- Scene transitions to main menu
- Game unpauses and loads new scene

### Quit
- Panel fades out (0.5s)
- Settings saved
- Game closes

## Known Limitations

- Settings button is placeholder (TODO)
- Blur shader requires modern GPU support
- Input handling may conflict with other UI menus

## Future Improvements

1. Add settings menu integration
2. Add sound effects on button hover/click
3. Add confirmation dialog for quit
4. Add keyboard navigation (Tab between buttons)
5. Customize blur strength via shader_parameter/blur_amount

## Files Created/Modified

- ✅ Created: `scripts/ui/pause_menu.gd`
- ✅ Created: `scenes/ui/menus/pause_menu.tscn`
- ✅ Created: `scenes/ui/menus/test_pause_menu.tscn`
- ✅ Created: `scenes/ui/menus/test_pause_menu.gd`
