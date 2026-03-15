-- =============================================================
-- DIFFICULTY: Casual (Index 1)
-- Объединяет Normal/Hard/Realism в один удобный режим.
-- Хорошо подходит для новых игроков и небольших групп.
-- =============================================================
HORDE:RegisterDifficulty({
    Name  = "CASUAL",
    Index = 1,

    -- ── Combat ────────────────────────────────────────────────
    DamageMult   = 1.0,
    HealthMult   = 1.0,

    -- ── Economy ───────────────────────────────────────────────
    RewardMult      = 1.0,
    StartMoneyMult  = 1.0,

    -- ── Spawning ──────────────────────────────────────────────
    EnemyCountMult          = 1.0,
    SpawnRadiusMult         = 1.0,
    MaxEnemiesScaleFactor   = 1.0,
    AdditionalPack          = 0,
    AdditionalAmmoboxes     = 2,

    -- ── Status Effects ────────────────────────────────────────
    StatusDurationBonus      = 0,
    BreakHealthLeft          = 0.20,
    ShockDamageIncrease      = 0.15,
    FrostbiteSlow            = 0.40,
    PoisonHeadcrabDamage     = 50,

    -- ── Elite & Mutations ─────────────────────────────────────
    EliteHealthScaleAdd         = 0.025,
    EliteHealthScaleMultiplier  = 1.0,
    MutationProbability         = 0,
    EliteMutationProbability    = 0,
})
