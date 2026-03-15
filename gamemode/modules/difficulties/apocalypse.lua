-- =============================================================
-- DIFFICULTY: Apocalypse (Index 5)
-- Maximum chaos. Mutated hordes, massive enemy counts, minimal resources.
-- The ultimate survival challenge.
-- =============================================================
HORDE:RegisterDifficulty({
    Name  = "APOCALYPSE",
    Index = 3,

    -- ── Combat ────────────────────────────────────────────────
    DamageMult   = 1.9,
    HealthMult   = 1.5,

    -- ── Economy ───────────────────────────────────────────────
    RewardMult      = 0.4,
    StartMoneyMult  = 0.6,

    -- ── Spawning ──────────────────────────────────────────────
    EnemyCountMult          = 1.7,
    SpawnRadiusMult         = 0.4,
    MaxEnemiesScaleFactor   = 1.3,
    AdditionalPack          = 3,
    AdditionalAmmoboxes     = 0,

    -- ── Status Effects ────────────────────────────────────────
    StatusDurationBonus      = 4,
    BreakHealthLeft          = 0.05,
    ShockDamageIncrease      = 0.30,
    FrostbiteSlow            = 0.55,
    PoisonHeadcrabDamage     = 75,

    -- ── Elite & Mutations ─────────────────────────────────────
    EliteHealthScaleAdd         = 0.125,
    EliteHealthScaleMultiplier  = 1.2,
    MutationProbability         = 0.30,
    EliteMutationProbability    = 0.40,
})
