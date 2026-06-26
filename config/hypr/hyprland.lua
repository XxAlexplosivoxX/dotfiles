
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- ALEX'S HYPRLAND CONFIG.                        --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- 1. Hardware y Pantallas (Esencial para que renderice bien de entrada)
require("conf.monitors")

-- 2. Configuración del Sistema (Gaps, bordes, layouts, variables de entorno)
require("conf.preferences")
require("conf.settings")

-- 3. Input (Teclado, mouse, touchpad, distribución de idioma)
require("conf.input")

-- 4. Estética (Animaciones y decoración visual)
require("conf.looknfeel")
require("conf.animations")

-- 5. Interactividad (Atajos de teclado clave)
require("conf.keybinds")

-- 6. Procesos de fondo (Ejecutar al final cuando el entorno gráfico esté listo)
require("conf.autostart")