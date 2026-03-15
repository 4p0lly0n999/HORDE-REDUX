-- =============================================================
-- DIFFICULTY: Nightmare (Index 4)
-- Severe enemy scaling. Heavy mutation rates. Elites are dangerous.
-- Only for coordinated teams.
-- =============================================================
HORDE:RegisterDifficulty({
    Name  = "NIGHTMARE",
    Index = 2,

    -- ── Combat ────────────────────────────────────────────────
    DamageMult   = 1.7,
    HealthMult   = 1.5,

    -- ── Economy ───────────────────────────────────────────────
    RewardMult      = 0.5,
    StartMoneyMult  = 0.75,

    -- ── Spawning ──────────────────────────────────────────────
    EnemyCountMult          = 1.6,
    SpawnRadiusMult         = 0.5,
    MaxEnemiesScaleFactor   = 1.25,
    AdditionalPack          = 2,
    AdditionalAmmoboxes     = 0,

    -- ── Status Effects ────────────────────────────────────────
    StatusDurationBonus      = 3,
    BreakHealthLeft          = 0.10,
    ShockDamageIncrease      = 0.25,
    FrostbiteSlow            = 0.50,
    PoisonHeadcrabDamage     = 75,

    -- ── Elite & Mutations ─────────────────────────────────────
    EliteHealthScaleAdd         = 0.100,
    EliteHealthScaleMultiplier  = 1.1,
    MutationProbability         = 0.20,
    EliteMutationProbability    = 0.30,
})
