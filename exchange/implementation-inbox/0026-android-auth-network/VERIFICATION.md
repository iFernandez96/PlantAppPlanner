# VERIFICATION — handoff 0026-android-auth-network (3c-net, red→green)

Gate: `:network:testDebugUnitTest`, Drive mounted.

## RED driver
`AuthDtoTest` references `OtpRequest`/`VerifyOtpRequest`/`SessionResponse` +
`SupabaseAuthApiFactory.json` — none exist before the change → compile-red.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
BUILD SUCCESSFUL in 9s
# AuthDtoTest tests="3" skipped="0" failures="0" errors="0"
```
- `otpRequestEncodesSnakeCaseCreateUserAndRoundTrips` — JSON contains `"create_user"`
  (not `createUser`); decode==encode.
- `verifyOtpRequestEncodesFieldsAndRoundTrips` — email/token/type present; round-trips.
- `sessionResponseDecodesGoTrueJsonIgnoringUnknownKeys` — decodes a GoTrue body with an
  unknown `user` key → `accessToken == "abc.def.ghi"`, token_type/expires_in/refresh_token
  mapped.
- All prior `:network` tests still green.

## Scope / integrity
- Only `android/network/**` changed (`git show --stat`: 4 files, +134 — 3 new main + 1 new
  test). No `:data`/`:domain`/`:feature-inventory`/`:app`/backend/schema change. No new deps.
  No token persistence/UI; no hard-coded URL/anon-key. `local.properties` not committed
  (grep 0).

## Final repo state
- origin/master = `a2f5e75ec8d4307155933d7cc04b7045ef97a6b4`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
