# Dog Breed Diary

A Flutter app that lets you browse dog breeds, fetch random photos from the Dog CEO API, add captions, and save your favorites to a local diary.

---

## API Used

**Dog CEO REST API** — `https://dog.ceo/api`

| Purpose | Endpoint |
|---|---|
| Fetch all breeds | `https://dog.ceo/api/breeds/list/all` |
| Fetch random image for a breed | `https://dog.ceo/api/breed/husky/images/random` |

The breed name in the image endpoint is dynamic. For example, selecting "labrador" calls `https://dog.ceo/api/breed/labrador/images/random` and returns a JSON object with a `message` field containing the image URL.

---

## Storage Strategy

| Data | Storage | Why |
|---|---|---|
| Saved dog entries (breed, image URL, caption, timestamp) | SQLite via `sqflite` | Structured, relational data that needs to persist across sessions and support CRUD operations (insert, query, update, delete). |
| Dark/light theme preference | `shared_preferences` | A single boolean flag — no structure needed, and `shared_preferences` is the idiomatic Flutter solution for lightweight key-value settings. |

SQLite is used for anything that looks like a record. `shared_preferences` is used for anything that looks like a setting.

---

## Data Format

Each saved dog entry is a row in the `favorites` table:

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER (PK, autoincrement) | Unique identifier |
| `breed` | TEXT | Breed name from the API (e.g., `"husky"`) |
| `imageUrl` | TEXT | Full image URL returned by the Dog CEO API |
| `caption` | TEXT | User-written caption, or `"no caption"` if left blank |
| `savedAt` | TEXT | ISO 8601 timestamp of when the entry was saved (e.g., `"2026-06-14T10:30:00.000"`) |

---

## How to Run

**Prerequisites:**
- Flutter SDK installed and on your PATH (`flutter --version` should work)
- A connected device or simulator (iOS Simulator, Android Emulator, or a physical device)
- Internet connection (the app fetches data from the Dog CEO API)

**Steps:**

```bash
# 1. Navigate to the project directory
cd solo3_4150

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

If you have multiple devices connected, Flutter will prompt you to choose one. To target a specific device:

```bash
flutter run -d ios       # iOS Simulator
flutter run -d android   # Android Emulator
flutter run -d macos     # macOS desktop
```

No API keys or additional configuration are required.

---

## How to Test Persistence

**SQLite (saved dogs):**
1. Launch the app and select a breed from the dropdown.
2. Tap **Fetch a dog!** to load an image.
3. Type a caption and tap **Save to diary**.
4. Fully close the app (swipe it away from the app switcher / stop the process).
5. Reopen the app and tap the heart icon (top right) to open **My Dog Diary**.
6. Your saved entry should appear with the breed, image, caption, and date intact.

**shared_preferences (theme):**
1. Toggle the switch in the app bar to switch to dark mode.
2. Fully close and reopen the app.
3. The app should reopen in dark mode — the preference was persisted.

---

## Edge Cases

**1. No breed selected when tapping "Fetch a dog!"**

If the user taps the fetch button without selecting a breed from the dropdown, `_selectedBreed` is `null` and the `_fetchImage()` method returns immediately with no action. No network request is made and no error is shown the button is simply a no-op until a breed is chosen.

**2. Empty caption when saving**

If the user taps **Save to diary** without entering a caption, the app substitutes the string `"no caption"` rather than storing an empty string. This ensures the caption field in the database is never blank and the diary card always displays readable text.

---

## AI Assistance

This app was developed with the help of [Claude](https://claude.ai) (Anthropic's AI assistant) and [Claude Code](https://claude.ai/code) (Anthropic's AI-powered CLI for software engineering tasks).
