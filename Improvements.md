# Mobile app changes: day-based documents, remove Work, profile updates

This supersedes any earlier note about "merging Work into Documents with a Tasks strip." Build against this version — the final decision is to **remove "Work" entirely** as its own feature, not fold it into another screen.

Everything below is written for you to implement in the Flutter app. The API endpoints/response shapes listed are exactly what the backend already exposes — build directly against them.

---

## 1. Build: day-based document tracking screen

This is the primary, most-used screen in the app. A client uploads documents/notes on a given day (often multiple per day), and needs to see status by day.

**API calls to use:**
- `GET /documents` — the client's documents/notes. Supports `?status=PENDING`, `?status=VERIFIED`, `?status=REJECTED` as query filters. Each item has `uploadedAt` — group these client-side by the calendar day of this timestamp; there is no separate "day" endpoint.
- Upload flow (3 calls): `POST /documents/upload-url` (request a presigned S3 URL) → `PUT` the file bytes directly to that URL → `POST /documents` with `fileName`, `documentType`, `fileSizeBytes`, `mimeType`, and optionally `clientNote` (for a text note instead of a file) to confirm/persist it. **Do not send or ask the user for a work-item id anywhere in this flow** — that field doesn't exist here.
- `GET /dashboard/summary` → `{ overdue, pendingApproval, activeWork, pendingDocs, unreadNotifications }`. Use `pendingDocs` for a "pending docs" counter and `unreadNotifications` for your notification bell badge (cap the displayed number at "9+" if it's large — see your existing notification-badge work for the exact pattern). Do not use `overdue`, `pendingApproval`, or `activeWork` — those are legacy fields for the Work feature you're removing (§2); ignore them.

**What to build:**
- Three stat tiles at the top: pending / verified / rejected counts, computed from the fetched documents list.
- A week calendar strip: previous/next week navigation buttons, a row of 7 days, a small dot under any day that has at least one upload, tap a day to select it, visually highlight the selected day.
- Below the calendar: the list of documents/notes for the selected day. Each row needs: a status-colored indicator (pending/verified/rejected), an icon distinguishing file vs. note, the filename (tappable to preview/open) or the note text, the upload time, a status badge, and a reviewer-note box if the item has one.
- An "Upload"/"Add" button, always scoped to the currently selected day (default: today). Tapping it opens the upload flow from above, using the selected day only as display context (the server always timestamps uploads as "now" — you cannot backdate one). After a successful upload, switch the selected day back to today so the new item is immediately visible.
- Empty state for a day with nothing uploaded: show a prompt with an "Upload for this day" button.

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

## Checklist

- [ ] Day-based document screen built per §1, wired to real `GET /documents` and the 3-step upload flow.
- [ ] Work screen(s), nav entry, home widget, and work-item API calls all removed per §2.
- [ ] `WORK_*` notifications route to the same place as `DOCUMENT_*` notifications.
- [ ] Profile screen shows Phone / Company / PAN/VAT / Nature / Business email; Supervisor is not shown anywhere.
- [ ] Notification settings collapsed to a single toggle, verified it actually flips state on tap (not blocked by event bubbling).
