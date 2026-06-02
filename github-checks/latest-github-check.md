# PlantApp — GitHub Check

**Date:** 2026-06-02 · **Repo:** `iFernandez96/PlantApp`

| Question | Answer |
|---|---|
| Latest `origin/master` | `28f69ea` — feat(android-data): AuthRepository (email-OTP request/verify) persisting the token |
| Local == origin/master? | ✅ yes (`28f69ea` both sides) |
| `0027` commits | `28f69ea` (single commit; 5 files `android/domain|data/**`, +133/−2) |
| Uncommitted changes? | none (clean; git-ignored `android/local.properties` may exist locally) |
| CI / workflows / checks / PRs / issues | **none** — no CI, no open PRs, no open issues |
| Default branch | `master` |

`0027` verified vs real git: `git diff a2f5e75 28f69ea` = only `android/domain/**` +
`android/data/**` (AuthRepository, AuthRepositoryImpl, SettingsStore+TokenWriter, DataModule,
AuthRepositoryImplTest); `:network`/backend untouched; `local.properties` not committed. **Secrets:
the committed `DEFAULT_ANON_KEY` JWT decodes `role=anon`/`iss=supabase-demo` — the public local-dev
key, NOT service_role.** `:data` 8→10, `:domain` 2 — all green.

**"Do all" loop RUNNING.** (1)✅ (3a)✅ (3b)✅ (3c-net)✅ (3c-data)✅. **3c-ui
`0028-android-signin-ui` published & IN FLIGHT:** stateless `SignInScreen` (email→send code→verify)
+ `SignInViewModel` over `AuthRepository` + `:app` token-gating + Robolectric tests. Gate:
`:feature-inventory:testDebugUnitTest` + `:app:assembleDebug`. Vision ALIGNED-WITH-NOTES (sign-in
in `:feature-inventory` = tracked structural debt). Watcher armed for `0028`. **After it lands, 3c
complete; then 3d advisory→accept→CareTask.**
