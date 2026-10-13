# FINCO Customer PWA — Design System

Developer reference for building and extending the FINCO Customer Progressive Web App. Tokens live in `src/index.css`. UI primitives live in `src/components/ui/`.

---

## Brand

| Asset | Path | Usage |
| --- | --- | --- |
| Logo | `/public/FINCOLogo.png` | Header, sidebar, login, PWA icons — logo only, no “FINCO” text beside it |
| Theme color | `#0f9696` | Browser chrome / PWA `theme-color` |

**Voice:** calm, professional, mobile-first. Prefer clear hierarchy and compact type over large marketing-style headlines.

---

## Color

### Semantic tokens (`@theme inline`)

| Token | Hex | Role |
| --- | --- | --- |
| `background` | `#f7f6f4` | App canvas (warm off-white) |
| `foreground` | `#2c2c2c` | Primary text |
| `card` | `#ffffff` | Elevated surfaces |
| `card-foreground` | `#2c2c2c` | Text on cards |
| `primary` | `#0f9696` | Primary actions, active states, focus ring |
| `primary-foreground` | `#ffffff` | Text on primary |
| `primary-dark` | `#0b7575` | Primary hover |
| `secondary` | `#eef6f6` | Soft teal fill |
| `secondary-foreground` | `#0f9696` | Text on secondary |
| `muted` | `#efeeec` | Subtle fills, track backgrounds |
| `muted-foreground` | `#6a6a6a` | Secondary / helper text |
| `accent` | `#e6f4f4` | Soft highlight (icons, active nav desktop) |
| `accent-foreground` | `#0f9696` | Text on accent |
| `destructive` | `#d03050` | Destructive actions / errors |
| `border` / `input` | `#e8e6e3` | Borders and inputs |
| `ring` | `#0f9696` | Focus ring |

### Brand accents

| Token | Hex | Role |
| --- | --- | --- |
| `finco-teal` | `#10a0a0` | Brand teal (logo-aligned) |
| `finco-orange` | `#e08030` | Upload / FAB / attention dots |
| `finco-magenta` | `#d03050` | Rejected / danger emphasis |
| `finco-charcoal` | `#404040` | Dark chrome (bottom nav pill) |
| `finco-yellow` | `#f5c518` | Optional highlight |

### Status mapping

| Status | Badge variant | Color cue |
| --- | --- | --- |
| Pending | `warning` | Amber (`bg-amber-50` / `text-amber-700`) |
| Verified / Approved / Success | `success` | Emerald |
| Rejected / Danger | `danger` | Magenta (`finco-magenta`) |
| In Progress / Default | `default` | Primary teal tint |
| Neutral / Completed | `secondary` | Muted gray |

**Do not** invent new palette colors. Extend via existing tokens or brand accents above.

---

## Typography

| Property | Value |
| --- | --- |
| Font family | **Plus Jakarta Sans** (`400`, `500`, `600`, `700`) |
| Base size | `15px` (`html` + `body`) |
| Body leading | `leading-relaxed` |
| Antialiasing | on |

### Scale (practical)

| Element | Classes |
| --- | --- |
| Page title (mobile header) | `text-base font-semibold` |
| Section title | `text-base`–`text-lg font-semibold tracking-tight` |
| Card title | `text-base font-semibold leading-snug tracking-tight` |
| Body | `text-sm`–`text-[15px]` |
| Helper / meta | `text-xs text-muted-foreground` |
| Overline / section label | `text-xs font-semibold uppercase tracking-widest text-muted-foreground` |
| Calendar weekday | `text-[10px] font-medium` |

Prefer compact mobile type. Avoid oversized display headlines.

---

## Spacing & radius

### Radius tokens

| Token | Value | Typical use |
| --- | --- | --- |
| `radius-sm` | `0.5rem` | Small chips |
| `radius-md` | `0.75rem` | Compact controls |
| `radius-lg` | `1rem` | Buttons default |
| `radius-xl` | `1.25rem` | Large controls |
| `radius-2xl` | `1.5rem` | Cards, dialogs |

### Common radii in UI

| Pattern | Value |
| --- | --- |
| Buttons | `rounded-xl` (sm: `rounded-lg`) |
| Cards | `rounded-2xl` |
| Dialogs | `rounded-2xl` |
| Bottom nav pill | `rounded-full` |
| Active nav pill | `rounded-full` |
| Profile / settings groups | `rounded-3xl` |
| Bezel outer | `rounded-[1.35rem]` |
| Bezel inner | `rounded-[1.05rem]` |
| Icon wells | `rounded-lg`–`rounded-2xl` |

### Layout spacing

| Context | Guidance |
| --- | --- |
| Page stack | `space-y-4` or `space-y-5` |
| Main padding | `px-4 py-5` (mobile), `lg:px-6` |
| Bottom clearance (nav) | `pb-28` on mobile main |
| Card padding | `p-3`–`p-5` |
| Max content width | `max-w-xl`–`max-w-2xl` for detail; shell `max-w-6xl` |

---

## Elevation & surfaces

| Utility / class | Shadow | Use |
| --- | --- | --- |
| `shadow-soft` | `0 2px 10px -4px rgb(44 44 44 / 0.08)` | Cards, soft panels |
| `shadow-card` | `0 8px 28px -12px rgb(44 44 44 / 0.12)` | Dialogs / stronger lift |
| `shadow-fab` | Orange-tinted FAB glow | Upload / orange CTA |
| `shadow-nav` | Deep dark stack | Floating bottom nav |

### Surface utilities

| Class | Purpose |
| --- | --- |
| `surface-wash` | Soft teal / orange / magenta radial wash behind the app shell |
| `bezel` + `bezel-inner` | Nested “inset frame” for important content blocks (work detail overview) |

---

## Motion

| Token / pattern | Value |
| --- | --- |
| Easing | `cubic-bezier(0.32, 0.72, 0, 1)` |
| Button / control duration | `300ms` |
| Page enter | `.page-enter` — `280ms`, fade + `translateY(8px)` |

Keep motion purposeful and light. No neon glows or bounce-heavy animations.

---

## Icons

| Rule | Value |
| --- | --- |
| Library | [Lucide React](https://lucide.dev) |
| Default stroke | `1.75` (nav inactive / decorative), `2`–`2.5` for emphasis |
| Default size in buttons | `size-4` (enforced via `[&_svg]:size-4`) |
| Nav icons | ~`18px`–`22px` |

---

## Components

Import from `@/components/ui/*`.

### Button

```tsx
import { Button } from "@/components/ui/button";
```

| Variant | When |
| --- | --- |
| `default` | Primary teal actions |
| `secondary` | Soft teal secondary |
| `outline` | Secondary bordered actions |
| `ghost` | Tertiary / icon chrome |
| `destructive` | Destructive confirm |
| `orange` | High-attention upload / FAB-style |

| Size | Spec |
| --- | --- |
| `default` | `h-10 px-4` |
| `sm` | `h-9 px-3 text-xs` |
| `lg` | `h-11 px-5` |
| `icon` | `h-10 w-10` |

### Badge

| Variant | Use |
| --- | --- |
| `default` | Teal status |
| `secondary` | Neutral |
| `outline` | Bordered label |
| `success` | Verified / approved |
| `warning` | Pending |
| `danger` | Rejected |
| `orange` | Brand orange accent |

Prefer `className="normal-case tracking-normal"` when labels should not look like all-caps chips.

### Card

- Outer: `rounded-2xl border-border/60 bg-card shadow-soft`
- Prefer **bezel** pattern for hero/overview blocks instead of stacking many bordered cards
- Use cards for interactive or listable units (documents, meetings, settings groups)

### Input / Select / Label

- Height `h-10`, `rounded-xl`, border `border-input`
- Focus: `ring-2 ring-ring`
- Pair with `Label` above the field

### Dialog

- Centered modal, `max-w-lg`, `rounded-2xl`, `shadow-card`
- Overlay: `bg-foreground/40 backdrop-blur-sm`
- Close control top-right

### Empty state

```tsx
import { EmptyState } from "@/components/ui/empty-state";
```

Centered muted panel, accent icon well, title + short description, optional action button.

### Avatar

Circular initials fallback on `bg-accent text-primary` (or inverse on primary for active states).

---

## Layout & navigation

### App shell

- Desktop: left sidebar (`w-60`) + content
- Mobile: sticky top header + floating bottom pill nav
- Background: `bg-background surface-wash`

### Mobile bottom nav

- 4 items: **Home · Work · Meetings · Profile**
- Pill: `bg-[#363636]` (`finco-charcoal` family), `rounded-full`, `shadow-nav`
- Active: filled primary pill with icon + label
- Inactive: icon only, `text-white/45`

Documents are **not** a bottom-nav destination; upload and day views live under Work / Home upload flows.

### Header

- Home: logo only on mobile
- Other routes: logo + page title
- Alerts bell top-right (dot when unread)

### Safe areas

- `.safe-top` / `.safe-bottom` use `env(safe-area-inset-*)`

---

## Domain UI patterns

### Week-row calendar

Used on Documents views and Work detail → Documents tab.

- 7-column day strip with weekday letters `S M T W T F S`
- Selected day: `bg-primary text-primary-foreground`
- Today (unselected): soft primary circle
- Days with uploads: `finco-orange` dot (white when selected)
- Prev/next week chevrons + month/year label

### Document timeline

- Vertical rail + status-colored dots (emerald / orange / magenta)
- File vs note icon wells (`accent` vs amber)
- Show time with `formatTime`, day with `formatDate` / `toDateKey`

### Upload

- Combined files + optional note in one dialog
- Associate uploads to a calendar day via `uploadedAt`
- Home / shell upload opens dialog for **today** (one work per client — no work picker)

### Profile / settings

- Header: avatar + name + email
- Grouped `rounded-3xl` panels with overline labels
- Settings rows: icon well + label + optional toggle / chevron
- Destructive row (sign out) uses red text + red icon well

### Work detail tabs

- Segmented control: `rounded-full bg-muted` with active white pill
- Tabs: Overview | Documents

---

## Tailwind usage conventions

1. Prefer semantic tokens (`bg-primary`, `text-muted-foreground`) over raw hex.
2. Brand accents only when semantic tokens are insufficient (`bg-finco-orange`, etc.).
3. Compose with `cn()` from `@/lib/utils`.
4. Keep mobile-first; use `lg:` for desktop shell differences.
5. Match existing transition easing when adding interactive states.

---

## File map

| Area | Path |
| --- | --- |
| Tokens & utilities | `src/index.css` |
| UI primitives | `src/components/ui/` |
| App shell / nav | `src/components/layout/app-shell.tsx` |
| Upload dialog | `src/components/documents/document-upload-dialog.tsx` |
| Logo | `public/FINCOLogo.png` |
| Font load | `index.html` (Google Fonts) |

---

## Anti-patterns

- Do not add Inter / Roboto / system-only stacks as primary UI font
- Do not use purple-indigo “AI gradient” themes
- Do not put Alerts in the bottom nav (header only)
- Do not restore Documents as a bottom-nav item without product approval
- Do not use large display type that fights the compact PWA density
- Do not invent status colors outside the mapping above
- Avoid card-in-card nesting; prefer bezel or flat lists with dividers

---

## Quick copy-paste recipes

**Primary CTA**

```tsx
<Button>Upload</Button>
```

**Upload emphasis**

```tsx
<Button variant="orange">Upload for this day</Button>
```

**Status badge**

```tsx
<Badge variant="warning" className="normal-case tracking-normal">
  pending
</Badge>
```

**Bezel content block**

```tsx
<section className="bezel">
  <div className="bezel-inner space-y-4 p-5">{/* content */}</div>
</section>
```

**Page stack**

```tsx
<div className="mx-auto max-w-xl space-y-4">{/* sections */}</div>
```