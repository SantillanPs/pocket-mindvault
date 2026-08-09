# Domain Map: Frontend Design (UI/UX)

Created 2026-08-10. Purpose: let the User work in a frontend redesign without frontend knowledge — name what's wrong, name what they want, find problems, and talk to designers. The method this map serves: `../method.md`.

## 1. Vocabulary (the words you need)

### Space and layout
| Word | Plain meaning |
|---|---|
| Layout | How things are arranged on a page |
| Grid | The invisible columns and rows that keep things aligned |
| Spacing / Padding / Margin | The empty space around and between things. "Too cramped" = too little |
| Whitespace | Empty area on a page. "It feels crowded" = not enough |
| Alignment | Things lining up on a shared line. "Messy" is often misaligned |
| Breakpoint | The screen width where a layout changes (phone → tablet → desktop) |
| Responsive | A page that adapts to any screen size |
| Hierarchy | What the eye sees first, second, third. "I don't know where to look" = no hierarchy |
| Hero | The big main area at the top of a page |
| Call to action (CTA) | The button you want someone to press |

### Looks
| Word | Plain meaning |
|---|---|
| Contrast | How much things stand out from their background. "Hard to read" = low contrast |
| Typography | The style of text — font, size, weight |
| Weight | How thick letters are (thin ↔ bold) |
| Color palette | The set of colors a design uses |
| Consistency | The same things looking the same everywhere |
| Visual priority | Which elements are made to stand out |
| Style / Theme | The overall look — colors, fonts, shapes, feel |
| Skeuomorphic vs flat | 3D-realistic look vs simple, flat shapes |
| State | How an element looks in different moments (normal, hovered, clicked, disabled, error) |

### Behavior and feel
| Word | Plain meaning |
|---|---|
| Usability | How easy a screen is to use |
| Affordance | A thing looking like what it does (a button looking pressable) |
| Feedback | The system reacting to your action (spinner, success message) |
| Navigation | The way you move between pages |
| Form | The page where you enter information |
| Empty state | What a screen shows when there's nothing to show yet |
| Error state | What happens when something goes wrong |
| Load state | What's shown while waiting |
| Accessibility | Making it usable by everyone, including disabled users |
| Friction | Anything that slows the user down |
| Conversion | Turning a visitor into someone who did the thing (bought, signed up) |

### The process words
| Word | Plain meaning |
|---|---|
| Wireframe | A rough sketch of a page's structure, no styling |
| Mockup | A static, styled picture of the final page |
| Prototype | A clickable version you can test |
| Component | A reusable piece (one button style used everywhere) |
| Design system | The shared rulebook of components, colors, and spacing |
| Redesign | Changing a system's look and structure |
| User testing | Watching real people use it and noting where they struggle |

## 2. Landscape (who does what, how a redesign works)

- **Designer** — decides the look and structure. You tell them what to change; they make it visual.
- **Developer** — builds it in code. Turns the design into the real system.
- **A redesign flows:** wireframe → mockup → prototype → user testing → live build. You don't need to do any of these steps — you need to *review* them at each stage.
- **Tools you'll hear:** Figma (design), Sketch, Storybook (component library), analytics dashboards (what users actually do).

## 3. Failure modes (how screens usually go wrong)

- Inconsistent spacing — things packed together in some places, scattered in others
- Too many fonts or colors — no system, everything shouting
- Low contrast — grey-on-grey text nobody can read
- No hierarchy — every element equally loud, eye has nowhere to land
- Cluttered — too much on screen, no whitespace
- Broken on mobile — the desktop view crammed into a phone
- Unclear actions — buttons that don't look like buttons
- No feedback — clicking does nothing visible; the user wonders if it broke
- Too many clicks to do one thing (friction)
- Same thing done differently on different pages (inconsistency)

## 4. Questions to ask (the field's questions — and the first one)

**First question to anyone, always:** "What should I be asking about this?"

Then, the questions people in this field actually ask:
- Who uses this, and what's their main task?
- What's the one thing the page must get the user to do?
- Where do users get stuck or leave? (analytics can show this)
- What's currently costing us the most — complaints, abandoned carts, support tickets?
- What does "good" look like for our users — what screens do they love?
- What can we NOT change (brand, backend limits, legal)?

## 5. Checklists (replace judgment — run these on any screen)

1. Can I always see how to go back?
2. Is the same thing in the same place on every page?
3. If I make a mistake, can I undo it?
4. Do buttons look like buttons and links look like links?
5. Is the most important thing the most visible thing?
6. When I click, does something happen right away (feedback)?
7. Can I read everything comfortably (contrast, size)?
8. Does it still work on a phone?
9. Is anything there just for decoration?
10. How many clicks to finish the main task — is it as few as possible?

## 6. Reference gallery (examples of "good" — collect as you find them)

| What it is | Where it's from | Why it feels good / bad |
|---|---|---|
| | | |

Rule: when you like or dislike any screen, drop it here. Later, say "make ours like THIS one, but keep THAT part" — the example speaks for you.
