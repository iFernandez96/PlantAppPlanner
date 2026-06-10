# Catalog Phase 2 status — cited care-data research (2026-06-02)

## Result of run 1 (workflow `wf_a43f2284-06b`, 75-agent fan-out)

- **54 / 75 profiles written** to `scratch/catalog/profiles/<profileId>.json`.
- **Validation: 54/54 schema-valid** (`python3 scratch/catalog/validate.py` vs the real
  `PlantApp/shared-schemas/plant-profile.schema.json`, draft 2020-12), id==filename, every file
  has citations (**6–12 citations each**, university extension / RHS / Almanac / MoBot).
- The 5 already-seeded ids were **enriched as version 2** (solanum-lycopersicum,
  fragaria-x-ananassa, passiflora-edulis, physalis-philadelphica, ocimum-basilicum) — core seeded
  values kept, optional fields filled.
- Low-confidence fields per plant were reported by each agent (mostly `hotWeatherMultiplier`,
  `rainSkipThresholdMm`, `heatStressC`, container ideal ranges — i.e. the schema's tuning knobs
  that authoritative sources don't publish directly). Full lists in the workflow result:
  `/tmp/claude-1000/-home-israel-Documents-Development-PlantAppPlanner/d896226f-66ac-40c6-aef5-1464ebd48a1c/tasks/wtx1t8w0e.output`
- **Cost of run 1: ~1.90M subagent tokens, 645 tool uses, ~7.6 min wall-clock.**

## RUN 2 (resume, 2026-06-10): 75/75 COMPLETE — all schema-valid (validate.py 75/75), 6–12 citations each.
Run 2 cost: ~1.36M subagent tokens. Phase 2 DONE; next catalog step = owner sample review + Gates B/C (in W2).

## Missing 21 (tail of the queue — agents cut off by the session limit, resets 5:30pm)

ornamentals (8): dahlia-pinnata, impatiens-walleriana, begonia-semperflorens, rudbeckia-hirta,
cosmos-bipinnatus, antirrhinum-majus, salvia-splendens, lobularia-maritima
houseplants (9): epipremnum-aureum, dracaena-trifasciata, monstera-deliciosa,
chlorophytum-comosum, spathiphyllum-wallisii, zamioculcas-zamiifolia, ficus-elastica,
philodendron-hederaceum, aglaonema-commutatum
succulents (4): aloe-vera, crassula-ovata, echeveria-elegans, haworthia-attenuata

**Resume path:** re-invoke the workflow with
`Workflow({scriptPath: "scratch/catalog/phase2-research.workflow.js", resumeFromRunId: "wf_a43f2284-06b"})`
after the limit resets — completed agents return cached, only the 21 re-run. (Resume is
same-session only; if the session is gone, just re-run the script — agents overwrite their own
file and the 54 existing files are kept/overwritten idempotently.)

## Notes for the eventual impl-Claude install handoff (NOT yet)
- Pilot category `houseplant` is mapped to schema enum `other` (schema has no houseplant value).
- Profiles are staging only; install = seed migration via impl Claude after owner review.
- `lastReviewedAt: 2026-06-02`, new profiles `version: 1`, enriched seeded ones `version: 2`.
