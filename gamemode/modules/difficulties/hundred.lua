-- =============================================================
-- DIFFICULTY: Hundred (Index 7)
-- 100 волн без перерыва после волны 10.
-- После волны 10 голосование не показывается —
-- волны 11-100 идут автоматически с нарастающей сложностью.
-- Урон и HP врагов растут на 10% за каждую волну после 10.
-- =============================================================
HORDE:RegisterDifficulty({
    Name  = "HUNDRED",
    Index = 7,

    -- Базовые параметры как у Apocalypse
    DamageMult   = 1.9,
    HealthMult   = 1.5,
    RewardMult      = 0.4,
    StartMoneyMult  = 0.6,
    EnemyCountMult          = 1.7,
    SpawnRadiusMult         = 0.4,
    MaxEnemiesScaleFactor   = 1.3,
    AdditionalPack          = 3,
    AdditionalAmmoboxes     = 0,
    StatusDurationBonus      = 4,
    BreakHealthLeft          = 0.05,
    ShockDamageIncrease      = 0.30,
    FrostbiteSlow            = 0.55,
    PoisonHeadcrabDamage     = 75,
    EliteHealthScaleAdd         = 0.125,
    EliteHealthScaleMultiplier  = 1.2,
    MutationProbability         = 0.30,
    EliteMutationProbability    = 0.40,

    -- Специальные флаги — читаются sv_horde.lua
    IsHundred    = true,   -- включает логику 100 волн
    MaxWaves     = 100,    -- 100 волн вместо 10
    ScalePerWave = 0.025,   -- +10% урон/HP за каждую волну после 10
})
