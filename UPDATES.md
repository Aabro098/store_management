# Mobile app changes: day-based documents, remove Work, profile updates

This supersedes any earlier note about "merging Work into Documents with a Tasks strip." Build against this version — the final decision is to **remove "Work" entirely** as its own feature, not fold it into another screen.

Everything below is written for you to implement in the Flutter app. The API endpoints/response shapes listed are exactly what the backend already exposes — build directly against them.

---

## 1. Build: day-based document tracking screen

This is the primary, most-used screen in the app. A client uploads documents/notes on a given day (often multiple per day), and needs to see status by day.

**Important: review status is per DAY, not per file.** Staff review everything a client uploaded on one day as a single unit — one status (`PENDING`/`VERIFIED`/`REJECTED`) and one reviewer note cover the whole day, not each file individually. `Document` itself has no `status` field at all. This is a `DailySubmission` record (one per client per calendar day).

**API calls to use:**
- `GET /documents/daily-submissions?status=PENDING|VERIFIED|REJECTED` — **use this, not `GET /documents`, to build the screen.** It returns the client's submissions already grouped by day, each with its files embedded:
  ```json
  {
    "data": [
      {
        "id": "clx...",
        "dateKey": "2026-09-19",
        "status": "PENDING",
        "reviewNote": null,
        "documents": [
          { "id": "clx...", "fileName": "invoice.pdf", "documentType": "invoice", "uploadedAt": "...", "clientNote": null, "uploadBatchId": "clx..." }
        ]
      }
    ]
  }
  ```
  No client-side day-bucketing needed — the server already groups by `dateKey`. Match a submission to a calendar cell by `dateKey`.
- `GET /documents/daily-submissions/stats?clientId=` → `{"data": {"pending": 3, "verified": 2, "rejected": 0}}` — **use this for your stat tiles**, not a count over the array above. This is a real server-side count, not capped by pagination, so it stays correct even once a client has accumulated far more days than any single page would return.
- Upload flow (3 calls, unchanged): `POST /documents/upload-url` (request a presigned S3 URL) → `PUT` the file bytes directly to that URL → `POST /documents` with `fileName`, `documentType`, `fileSizeBytes`, `mimeType`, optionally `clientNote` (for a text note instead of a file), and **`documentDate`** to confirm/persist it. **Do not send or ask the user for a work-item id anywhere in this flow.** A new upload either joins that day's existing submission or creates a new `PENDING` one if it's the first upload of that day — you don't manage this, the server does it automatically. After confirming an upload, refetch `/documents/daily-submissions` so the new file shows up under the right day (it may have created a new submission).
- **`documentDate` — this is how you backdate an upload to the day the user selected, instead of it always landing on today.** Send an ISO datetime string set to **local noon on the selected calendar day** (not midnight — noon avoids the date shifting by a day when the timestamp crosses a UTC boundary). Example: if the user selected Sept 19 in their local timezone, construct a `Date` for Sept 19 at 12:00:00 local time and send `.toISOString()` of that. The server rejects it with a `422` if the **calendar day** it represents is after today — compares dates, not exact instants, so uploading "for today" always works no matter what time of day it currently is (we hit a real bug where an exact-instant comparison incorrectly rejected "today" during the first half of the day, before local noon had actually passed in UTC terms — make sure your own validation, if any, compares dates only). Omit the field for "upload for today" (e.g. the global upload button with no day picker).
- **`uploadBatchId` (optional but recommended)** — an opaque string you generate client-side (e.g. a UUID), sent on every file *and* the note, if any, submitted together in one "Submit" tap. The server just stores and echoes it back on each `Document`. Use it to visually group a note with the specific files it was written for when displaying the day's list (see below) — without this, a note looks like an unrelated floating item instead of an annotation on the files next to it.
- `GET /dashboard/summary` → `{ overdue, pendingApproval, activeWork, pendingDocs, unreadNotifications }`. Use `unreadNotifications` for your notification bell badge (cap the displayed number at "9+" if it's large). Do not use `overdue`, `pendingApproval`, or `activeWork` — those are legacy fields for the Work feature you're removing (§2); ignore them. Prefer the dedicated `/documents/daily-submissions/stats` endpoint above over `pendingDocs` here if you need the pending count specifically for this screen.

**What to build:**
- Three stat tiles at the top: **Pending** / **Verified** / **Rejected** (capitalized) counts, from `/documents/daily-submissions/stats` directly — don't compute them from the fetched submissions array.
- A week calendar strip: previous/next week navigation buttons, a row of 7 days, a small dot under any day that has a submission, tap a day to select it, visually highlight the selected day.
- Below the calendar, for the selected day's submission (if one exists): **one** status badge and **one** reviewer-note box for the whole day (not per file), then the list of its files/notes underneath grouped by `uploadBatchId`:
  - If a batch contains a note **and** one or more files, show the note as a caption ("Note for these files: ...") in one bordered card together with those files listed right below it — this makes the association obvious.
  - If a batch is just a file (or files) with no note, or a lone standalone note, render it as its own simple row/card same as before — icon, filename or note text, upload time.
- An "Upload"/"Add" button, always scoped to the currently selected day (default: today). Tapping it opens the upload flow, sending `documentDate` computed from that selected day as described above, and a fresh `uploadBatchId` shared by everything submitted in that one action. **After a successful upload, stay on the currently selected day — do not jump back to today.** (We had this backwards initially: jumping to today after every upload hides a backdated item you just successfully submitted, since it's no longer showing under today. Only default to today when the screen first opens.)
- The submit button should just say **"Submit"** — don't append a count like "Submit 2 items", regardless of how many files/notes are in the batch.
- Empty state for a day with no submission: show a prompt with an "Upload for this day" button.

## 2. Remove: the "Work" feature

Delete this feature from the app entirely — do not replace it with a Tasks strip, a task list screen, or a task detail screen.

**What to delete/change in your app:**
- The dedicated "Work" screen/tab and its detail screen, if they exist.
- The nav entry pointing at it. You have two options: repurpose that nav destination to open the day-based document screen from §1 instead (keeps the same tab count), or remove the tab entirely. Either is fine — there's no fixed requirement here.
- Any home/dashboard widget listing "open work" or tasks (a card, a stat count, a "view all" link into a task list).
- Any local data models, repositories, or API-calling code you built for work-items — delete if nothing else in your app needs them.
- Notification handling for `WORK_*` notification types: these notifications will keep arriving from the backend (work items still exist for internal staff/accounting use), but you must stop deep-linking them to a task detail screen — that screen no longer exists. Route `WORK_*` notifications to the same place you route `DOCUMENT_*` notifications (the day-based screen from §1).

**Do not call `GET /work-items` anymore** — it still exists on the backend (internal tooling still uses it), you just don't need it.

## 3. Update: profile screen

**API response you'll get** — `POST /login` and `GET /me` now return these additional fields on the `user` object:
```json
{
  "clientId": "clx...",
  "businessName": "Cathy's Cafe",
  "phone": "9800000000",
  "panVat": "603214589",
  "nature": "Restaurant",
  "clientEmail": "cathy@example.com",
  "assignedSupervisorName": "Sam Supervisor"
}
```
- `panVat`, `nature`, `clientEmail` are new fields — these are values an admin/supervisor entered when they created this client account.
- `clientEmail` can be `null` — show a fallback like "—" when it is.
- `assignedSupervisorName` is present in the response but **you must not display it anywhere in the app.** Parse it if you like, just don't render it.

**What to build:**
- Keep the header as-is: name, login email, business name.
- In the account details section, **remove any "Supervisor" row** if you have one.
- Add these rows in its place, using this exact labeling (matches the admin panel's own terminology, keep it consistent):
  - **Phone** → `phone`
  - **Company** → `businessName`
  - **PAN / VAT** → `panVat`
  - **Nature** → `nature`
  - **Business email** → `clientEmail` (show "—" if null). Label it "Business email," not just "Email" — the account's login email is already shown in the header, and the two values can be different.

## 4. Update: notification settings — one toggle only

If your profile/settings screen currently has multiple separate notification toggles (e.g. "Work updates" / "Document alerts" / "Meeting reminders"), **replace all of them with a single "Notifications" on/off toggle.** This is a local UI preference only, not tied to any API call — same as before, just one switch instead of several.
- When on: subtext like "Alerts for work, documents, and meetings."
- When off: subtext like "All notifications are off," and swap the icon to a "bell off" state if you have one.

**Bug to avoid** — we hit this exact issue building the same change in the web app: if your toggle switch is a nested tappable control inside a larger tappable row (e.g. the whole row also toggles it on tap), a tap on the inner switch can bubble up and also fire the row's own tap handler — so it toggles on, then immediately back off, and looks like nothing happened. Make sure the switch's tap handler stops the tap from propagating to its parent row (or don't make the row itself independently tappable), so a single tap reliably flips the state once.

## 5. Build: delete account

Add a "Delete account" action to the profile/settings screen. **Implementation note for you, not for the user-facing copy:** under the hood this never actually erases any data — it deactivates the login so the user can't sign in, and only an admin/supervisor can restore access afterward from the admin panel. Know this so you build the confirmation flow correctly (no data-wipe warnings needed, no client-side cleanup of local data required), but **do not mention this to the user** — the confirmation copy should read as a normal account deletion, not reassure them their data is kept. Don't say "your data is not erased" or similar anywhere in the UI. There is also no self-service undo and no automatic re-enable after any time period — don't imply one.

**API call:**
```
POST /deactivate-account
Authorization: Bearer <token>
Content-Type: application/json

{ "confirmName": "Cathy Client" }
```
- `confirmName` must match the logged-in user's own `name` field exactly (case/whitespace-insensitive comparison is fine, done server-side).
- Success (`200`): `{"data": {"message": "Account deactivated."}}`. All of the user's active sessions are revoked server-side as part of this call, including the one making the request — immediately send the user to the login screen after success, same as your change-password flow.
- Wrong name (`422`): `{"message": "...", "errors": {"confirmName": ["..."]}}` — show this as a field error under the input, don't let the user submit.
- After this call succeeds, any future login attempt with this account fails with the same generic "credentials do not match" error as a wrong password — this is expected, not a bug on your end.

**What to build:**
- A "Delete account" row/button in the account settings section (destructive styling — red text/icon), with a sublabel like "You won't be able to log in until an admin restores access."
- Tapping it opens a confirmation screen/dialog that:
  - Explains plainly, e.g.: "This will delete your account and sign you out everywhere. You won't be able to log in again unless an admin or your supervisor restores access." Do not mention that data is preserved.
  - Shows an input labeled "Type your name (**\<their actual name\>**) to confirm" — interpolate the real logged-in user's name into the label.
  - Disables the confirm/delete button until the typed text matches their name exactly (case/whitespace-insensitive) — don't rely on the server call alone to block a premature tap.
  - On confirm, calls the endpoint above; on success, logs out locally and navigates to the login screen; on failure, shows the error inline and keeps the dialog open.

## Checklist

- [ ] Day-based document screen built per §1, wired to real `GET /documents/daily-submissions` and the 3-step upload flow. Status/reviewer note shown once per day, not per file. Stat tiles from `/documents/daily-submissions/stats`, labels capitalized.
- [ ] Notes grouped with the files they were submitted alongside via `uploadBatchId`.
- [ ] Submit button always says "Submit", no item count appended.
- [ ] Work screen(s), nav entry, home widget, and work-item API calls all removed per §2.
- [ ] `WORK_*` notifications route to the same place as `DOCUMENT_*` notifications.
- [ ] Profile screen shows Phone / Company / PAN/VAT / Nature / Business email; Supervisor is not shown anywhere.
- [ ] Notification settings collapsed to a single toggle, verified it actually flips state on tap (not blocked by event bubbling).
- [ ] Delete account flow built per §5: name-match confirmation, calls `POST /deactivate-account`, logs out and returns to login on success.
