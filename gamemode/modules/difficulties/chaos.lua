-- =============================================================
-- DIFFICULTY: Chaos (Index 4)
-- 1.15x сложнее Apocalypse. Экстремальный режим.
-- =============================================================
HORDE:RegisterDifficulty({
    Name  = "CHAOS",
    Index = 4,

    -- ── Combat ────────────────────────────────────────────────
    DamageMult   = 2.185,  -- APOCALYPSE × 1.15
    HealthMult   = 1.725,

    -- ── Economy ───────────────────────────────────────────────
    RewardMult      = 0.46,
    StartMoneyMult  = 0.69,

    -- ── Spawning ──────────────────────────────────────────────
    EnemyCountMult          = 1.955,
    SpawnRadiusMult         = 0.46,
    MaxEnemiesScaleFactor   = 1.495,
    AdditionalPack          = 4,
    AdditionalAmmoboxes     = 0,

    -- ── Status Effects ────────────────────────────────────────
    StatusDurationBonus      = 5,
    BreakHealthLeft          = 0.04,
    ShockDamageIncrease      = 0.35,
    FrostbiteSlow            = 0.60,
    PoisonHeadcrabDamage     = 90,

    -- ── Elite & Mutations ─────────────────────────────────────
    EliteHealthScaleAdd         = 0.145,
    EliteHealthScaleMultiplier  = 1.38,
    MutationProbability         = 0.45,
    EliteMutationProbability    = 0.55,
})
