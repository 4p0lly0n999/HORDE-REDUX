-- =============================================================
-- DIFFICULTY: Tower Defense (Index 6) — PLACEHOLDER
-- Будущий режим защиты башен. Пока идентичен Chaos.
-- =============================================================
HORDE:RegisterDifficulty({
    Name  = "TOWDEF",
    Index = 6,

    DamageMult   = 2.185,
    HealthMult   = 1.725,
    RewardMult      = 0.46,
    StartMoneyMult  = 0.69,
    EnemyCountMult          = 1.955,
    SpawnRadiusMult         = 0.46,
    MaxEnemiesScaleFactor   = 1.495,
    AdditionalPack          = 4,
    AdditionalAmmoboxes     = 0,
    StatusDurationBonus      = 5,
    BreakHealthLeft          = 0.04,
    ShockDamageIncrease      = 0.35,
    FrostbiteSlow            = 0.60,
    PoisonHeadcrabDamage     = 90,
    EliteHealthScaleAdd         = 0.145,
    EliteHealthScaleMultiplier  = 1.38,
    MutationProbability         = 0.45,
    EliteMutationProbability    = 0.55,
})
