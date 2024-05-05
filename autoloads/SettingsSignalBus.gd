extends Node

## Autoload encargado de manejar las multiples señales y funciones asociadas en torno a los cambios
## de configuraciones
##
## TASK Cada vez que agreguemos mas opciones, es necerio agregar las señales aca
# Accesibilidad
signal on_subtitles_toggled(value : bool)
# Graficos
signal on_window_mode_selected(index : int)
signal on_resolution_selected(index: int)
#Audio
signal on_master_sound_set(value: float)
signal on_music_sound_set(value: float)
signal on_sfx_sound_set(value: float)
signal on_ui_sound_set(value: float)
# Datos de guardado y carga
signal set_settings_dictionary(settings_d : Dictionary)
signal load_settings_data(settings_d : Dictionary)


## Todas estas funciones son similares, emiten las señales correspondientes con los paquetes de datos
## necesarios

# Datos de guardado y carga
func emit_set_settings_dictionary(settings_d : Dictionary) -> void:
	set_settings_dictionary.emit(settings_d)
func emit_load_settings_data(settings_d :Dictionary) -> void:
	load_settings_data.emit(settings_d)

# Accesibilidad
func emit_on_subtitles_toggled(value : bool) -> void:
	on_subtitles_toggled.emit(value)
# Graficos
func emit_on_window_mode_selected(index : int) -> void:
	on_window_mode_selected.emit(index)
func emit_on_resolution_selected(index : int) -> void:
	on_resolution_selected.emit(index)
#Audio
func emit_on_master_sound_set(value : float) -> void:
	on_master_sound_set.emit(value)
func emit_on_music_sound_set(value : float) -> void:
	on_music_sound_set.emit(value)
func emit_on_sfx_sound_set(value : float) -> void:
	on_sfx_sound_set.emit(value)
func emit_on_ui_sound_set(value : float) -> void:
	on_ui_sound_set.emit(value)
