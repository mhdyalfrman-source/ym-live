# GamePix implementation audit

Date: 2026-09-21. No production API calls, wallet operations, account changes, or real-fund transactions were performed.

## Build and scope findings

- Read all four files in `lib/features/rooms/game_pix`, their CodeCanyon counterparts, project/package READMEs, and the directly involved room, sheet, API, image, localization, platform, and WebView code. No applicable `AGENTS.md` was found in the searched project/ancestor paths.
- The buyer build uses **`CodeCanyon_Package/Main_File/flutter_app`**, package name `app_chat`. The primary tree is `tom_chat`. Both room screens call `Games2BottomSheet.show` from the floating game button. Initially, all four GamePix files were identical after accounting for those package names; the fixes were applied only to those verified counterparts.
- **High release-impact mismatch:** `CodeCanyon_Package/Main_File/Main_File.zip` contains **zero GamePix entries**. Updating the source folders does not update that archive. It was inspected but not repacked; package instructions specify manual ZIP creation, and it already had user changes.
- Dependency mismatch retained: primary uses the local Android WebView fork, declared version `3.12.0`; buyer build resolves upstream `webview_flutter_android 4.12.0`. Both use `webview_flutter 4.10.0`. Primary and buyer versions/configuration also differ. They must not be treated as interchangeable builds.
- Separate, currently unwired catalogue code also differs: primary `lib/features/rooms/bottom_sheets/games_bottom_sheet.dart` calls `openHtmlGame`; the buyer copy has that call commented out (line 171) and lacks the HTML-game Flutter directory and backend `Services/HtmlGames`. No active `GamesBottomSheet.show` call was found in either tree. This is separate from the working GamePix entry and was not silently imported into the buyer build.

## Confirmed findings, ordered by severity

| Severity | Affected behavior / evidence | Resolution |
| --- | --- | --- |
| P1 release | Existing buyer ZIP omits the GamePix implementation entirely. | Reported above; rebuild the submission archive from reviewed source before release. |
| P2 lifecycle | Game `PopScope(canPop: false)` had no callback, so system back did nothing. Async toolbar back could later pop an unrelated route; repeated taps could stack game sheets. | One guarded back path handles history and close, checks mounted/current route after awaiting, and uses the owning navigator. Guards prevent duplicate catalogue/game launches. |
| P2 lifecycle | The catalogue permanently registered its controller and never closed its HTTP client. Pending config could update an abandoned sheet; `liveuid` was unused, so room switching had no owned-sheet cleanup. | Sheet owns/disposes its controller, scroll/tab controllers and room workers. Disposal invalidates pending results. Room identity/leave changes remove only the catalogue's own routes. |
| P2 discovery | Feed failure after config loading could not retry because `loadInitial` returned whenever categories existed. Switching categories during pagination/refresh invalidated the old request without resetting its loading flag. | Retry reloads the selected category; new generations reset loading flags and discard stale results. |
| P2 config | Shared API helper returns `{}` on errors; GamePix interpreted this as an unrestricted catalogue. Its default waiting dialog could also outlive a failed request. | Invalid config fails visibly and can retry; config fetch uses the sheet's own loading UI, with `withMessage: false`. This preserves configured blocking on fetch failure; it does not make client-side blocks a security boundary. |
| P2 discovery | A fully blocked/invalid first page exposed no way to reach valid later pages; a short grid had no explicit pagination control. | Empty pages can continue loading; short grids expose a next-page control. Repeated pagination links terminate instead of repeatedly fetching the same URL. |
| P2 game errors | Native load errors/timeouts had no recovery UI; initial navigation relied on callers to validate it. | Initial URL and navigation are validated, async setup failures are caught, main-page failures/HTTP errors and a 30-second loading timeout expose localized retry. Subresource failures do not hide the game. |
| P2 integration | Selected app language was never passed; closing any game forced portrait even though the app otherwise had no orientation lock. | Launch adds `lang` while preserving publisher/game parameters and fragment. Only an applied game orientation is restored, to the app's unlocked policy. |
| P3 UI | Initial loading rendered empty boxes, absent images initiated empty-URL requests, and retry labels/tooltip were wrong. | Visible progress, validated image fallback, direct missing-image placeholder, localized retry, refresh-error feedback, RTL-aware back button, and keyboard inset handling. |

## Changed files

The following files changed in **both** `lib/` and `CodeCanyon_Package/Main_File/flutter_app/lib/`:

- `features/rooms/game_pix/controllers/game_pix_controller.dart`: config failure handling, request lifetime, retries, flags, feed/game validation and pagination.
- `features/rooms/game_pix/models/game_pix_models.dart`: validated launch URI with language and image URL selection.
- `features/rooms/game_pix/pages/game_bottom_sheet2.dart`: ownership/disposal, room cleanup, duplicate guards and catalogue states.
- `features/rooms/game_pix/pages/game_pix_game_page.dart`: guarded back/close, async WebView initialization, error/timeout/retry UI, orientation restoration and keyboard layout.

Added `test/game_pix_controller_test.dart` and `test/game_pix_widget_test.dart` to both trees, plus this report. Existing unrelated user edits, backend implementations, dependency overrides, and archives were preserved.

## Security, wallet and integration assessment

- GamePix launch uses the selected feed URL/identifier; it does **not** use the separate database game's `gid`, a room game token, or the HTML-game wallet SDK. Provider order (`order=quality`) is preserved, duplicate/blocked/invalid entries are filtered, and missing titles fall back to ID.
- Initial and subsequent permitted URLs use HTTPS GamePix hosts, with no URL credentials or nonstandard ports. Pagination is restricted to the actual feed host/path, including its observed trailing slash. Foreign/custom-scheme navigation remains blocked; no external URL launcher was added. This is navigation policy, not a claim that third-party subresources or game scripts are sandboxed from their own provider.
- There is no GamePix JavaScript channel, app credential injection, wallet callback, balance display, wager, or settlement path. No confirmed app-token leakage or unauthorized wallet operation was found in this integration. GamePix neither changes nor refreshes TomChat balances because no such transaction is connected here. Atomicity, idempotency, outcomes and interrupted wallet rounds are therefore not applicable to this path; the distinct HTML-wallet system is **not certified** by this audit.
- Accessible PHP `GameAppController::gamePixConfig` only returns category/block configuration; both backend copies were inspected. The router requires an authenticated app user for this endpoint. No deployed configuration, authenticated session expiry, or production server behavior was exercised.
- GamePix never calls Agora mute/join/leave methods. The underlying room stays mounted; native WebView camera/microphone requests are not granted by this code, and the inspected local Android plugin denies them when no permission callback is registered. Native audio focus/mixing still requires device testing.
- Closing disposes the Flutter platform view and cancels the load timer. `webview_flutter` has no public controller `dispose` method. No invented disposal API or automatic game restart was added.

## Validation

- Final targeted `flutter analyze --no-pub lib/features/rooms/game_pix test/game_pix_controller_test.dart test/game_pix_widget_test.dart`: **no issues found in either tree**.
- Final primary run of `game_pix_controller_test`, `game_pix_widget_test`, `game_catalog_test`, `html_game_client_test`, and `html_game_overlay_test`: **32/32 passed**.
- Final buyer run of the two GamePix regression files: **20/20 passed**, using that package's own dependency resolution.
- Coverage includes retry after config/feed failure, request-generation races, disposal during config/feed requests, duplicates and blocks, filtered empty pages, pagination loops/destinations, launch query preservation, URL rejection, system back/history, close during pending back, load errors/retry, loading timeout, invalid launch, small RTL/keyboard layout, orientation restoration, duplicate launches, reopening, and room-exit route cleanup.
- Final comparison: all four GamePix source files and both new test files match their explicitly reviewed buyer counterparts after package import substitution. This is not a whole-project parity claim.

- Public, unauthenticated network check: feed returned 24 records with the expected schema, `play.gamepix.com` game URLs and `feeds.gamepix.com/v2/json/` pagination. One representative wrapper returned HTTP 200 on the expected host with the selected-language query. This verifies HTTP integration only, not playable WebView rendering or ad behavior.
- PHP syntax: both local and buyer `GameAppController.php` passed `php -l`; no PHP changes were needed.
- Full primary `flutter test --no-pub` attempt: 31 tests passed; existing `test/widget_test.dart:16` failed compilation because the starter counter test constructs nonexistent `MyApp`. It was left untouched as unrelated.
- Buyer Android debug build attempted with `flutter build apk --debug --no-pub`: blocked at `:app:processDebugGoogleServices` by missing `android/app/google-services.json`. No app was installed or launched. An Android device was detected, but this package could not be built with the supplied configuration. iOS execution is unavailable on this Windows host.

## Remaining verification / limitations

- Provide buyer Firebase configuration and a non-production room/backend; then verify actual Android/iOS game rendering, rotation, ad/redirect behavior, hardware back/gestures, rapid close/reopen, room kick/end/switch, network loss/recovery, and mic/audio coexistence. Widget tests use a fake native WebView; they are not device gameplay tests.
- Background/foreground retains the existing view; GamePix supplies no room-round restoration contract here. Native WebView media, provider game progress and reconnect behavior remain unverified. The host page can load successfully while a provider's internal loader fails; host HTTP/error callbacks cannot certify every embedded game.
- Backend category labels remain English, and provider titles/category metadata are not translated by the app. App-owned controls use existing localizations and RTL layout; provider language support/fallback varies by game. The provider documents language support through [GamePix.lang](https://partners.gamepix.com/sdk/doc/javascript) and its [query-language integration](https://gpxprj.blob.core.windows.net/api/index.html).
- Verify the publisher SID for the buyer's account before distribution. It remains the existing configured constant; no attribution/account ownership change was made.
- Rebuild and inspect the buyer ZIP after configuration and release checks. The archive currently does not represent the audited source. Legacy HTML-wallet package mismatch, the old counter test, and missing Firebase configuration remain explicitly outside these focused GamePix fixes.
