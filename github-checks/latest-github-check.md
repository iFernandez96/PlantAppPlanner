# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `a2f5e75` — feat(android-network): Supabase GoTrue email-OTP auth client |
| Local == origin/master? | ✅ yes (`a2f5e75` both sides) |
| `0026` commits | `a2f5e75` (single commit; 4 new files `android/network/**`, +134) |
| Uncommitted changes? | none (clean; git-ignored `android/local.properties` may exist locally) |
| CI / workflows / checks / PRs / issues | **none** — no CI, no open PRs, no open issues |
| Default branch | `master` |

`0026` verified vs real git: `git diff 8d51874 a2f5e75` = only `android/network/**` (AuthDtos,
SupabaseAuthApi, SupabaseAuthApiFactory + AuthDtoTest); no anon key/URL hard-coded (only an example
URL in a doc comment); `local.properties` not committed. `AuthDtoTest` 3/3, all prior `:network`
tests green.

**"Do all" loop RUNNING.** (1)✅ (3a)✅ (3b)✅ (3c-net)✅. **3c-data `0027-android-auth-data`
published & IN FLIGHT:** `:domain` `AuthRepository` + `:data` impl persisting token via
`SettingsStore.setToken` (`TokenWriter` seam) + DI/config (auth URL + **public** local anon key
from `npx supabase status`, overridable). Gate: `:domain:test` + `:data:testDebugUnitTest`. Vision
ALIGNED-WITH-NOTES (secrets-safe — public anon key only; service_role never touched). Watcher armed
for `0027`. (3c-ui follows.)
