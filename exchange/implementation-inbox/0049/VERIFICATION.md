# Standalone verification — 0049

Type: regression + objective diff/grep evidence (interactive behavior verified by planner
on-device at W1 stage exit).

## 1. Bar + tab tags exist
```
$ grep -n "tab_today\|tab_garden\|tab_spaces" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt
83:    BottomTab(Routes.TODAY, "Today", Icons.Filled.WbSunny, "tab_today"),
84:    BottomTab(Routes.LIST, "My Garden", Icons.Filled.LocalFlorist, "tab_garden"),
85:    BottomTab(Routes.SPACES, "Spaces", Icons.Filled.Balcony, "tab_spaces"),
```
✓ 3 matches (each tag is applied to its `NavigationBarItem` via `Modifier.testTag(tab.testTag)`).

## 2. Placeholders exist
```
$ grep -n "today_placeholder\|spaces_placeholder" android/app/src/main/kotlin/dev/plantapp/android/PlaceholderScreens.kt
21:        tag = "today_placeholder",
31:        tag = "spaces_placeholder",
```
✓ 2 matches.

## 3. Catalog dep wired
```
$ grep -c "icons.extended" android/app/build.gradle.kts
1
```
✓

## 4. Start destination unchanged
```
$ grep -n "startDestination" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt
61:        setContent { PlantAppTheme { PlantAppBackground { PlantAppNavHost(startDestination = start) } } }
89:fun PlantAppNavHost(startDestination: String = Routes.LIST) {
121:        PlantAppNavGraph(nav, startDestination, Modifier.padding(padding))
128:    startDestination: String,
131:    NavHost(navController = nav, startDestination = startDestination, modifier = modifier) {

$ grep -n "tokenBlocking" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt
60:        val start = if (settings.tokenBlocking() != null) Routes.LIST else Routes.SIGN_IN
```
✓ still driven by the existing `settings.tokenBlocking()` check; home unchanged.

## 5. Module tests + assemble
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :data:testDebugUnitTest
BUILD SUCCESSFUL in 34s
109 actionable tasks: 18 executed, 91 up-to-date
```
JUnit XML aggregates: `feature-inventory: tests=20 failures+errors=0`,
`data: tests=15 failures+errors=0`. ✓

```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 21s
125 actionable tasks: 10 executed, 115 up-to-date
```
✓
