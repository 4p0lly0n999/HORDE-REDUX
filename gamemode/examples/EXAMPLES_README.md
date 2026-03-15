# Примеры модульных аддонов для Horde v2.0

## Структура внешнего аддона

```
addons/my_addon/
└── lua/
    └── horde/
        └── modules/
            ├── perks/assault/assault_my_perk.lua
            ├── gadgets/gadget_my_gadget.lua
            ├── spells/my_spell.lua
            ├── classes/class_my_class.lua
            └── systems/my_system/
                ├── sh_my_system.lua
                ├── sv_my_system.lua
                └── cl_my_system.lua
```

## Файлы в этой папке

- `external_perk_example.lua`   — добавить перк из аддона
- `external_gadget_example.lua` — добавить гаджет
- `external_class_example.lua`  — добавить новый класс
- `achievements/`               — полная система достижений как пример новой системы
