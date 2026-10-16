# File Standard (Revision Format)

Every question is a pair: `Q##_<Title>.md` (the revision notes) and `Q##_<Title>.sql`
(the runnable query). Both follow the templates below so that, when revising, I can
immediately see **my approach**, **the solution I wrote**, **the mistakes I made**, and
**the correct/optimal version** — before the deeper teaching content.

---

## `.md` template

```markdown
# Q## · <Title>

> **Revision Card**
> **Category:** <area> | **Difficulty:** <Easy|Medium|Hard>
> **Concepts:** <A · B · C>
> **Outcome:** ✅ correct first attempt   (or)   ⚠️ had mistakes (see §4)   (or)   ❓ not recorded
> **Watch out for:** <the single biggest trap, one line>

## 1. Problem
<Problem statement, objective, tables used, expected output>

## 2. My Approach
<numbered steps / reasoning I used>

## 3. My Solution (as submitted)
` ``sql
<the query I actually wrote>
` ``

## 4. Mistakes I Made
- ⚠️ <specific error I made> → why it's wrong → the fix
<!-- If nothing was recorded, keep this line until filled: -->
- _Not recorded — add from memory, or change Outcome to ✅ "clean on first attempt"._

## 5. Correct / Optimal Solution
` ``sql
<corrected/optimal query>
` ``
<!-- If identical to §3, replace the block with: "Same as §3." -->

## 6. Why This Works
<deep explanation of the chosen join/aggregation/subquery technique>

## 7. Common Pitfalls (generic)
<general traps for this pattern — NOT necessarily mistakes I made>

## 8. Interview Follow-ups
<likely interviewer questions, with answers>

## 9. Key Takeaway
<one- to three-line revision summary — the transferable lesson>

---
📄 **SQL File:** [`Q##_<Title>.sql`](./Q##_<Title>.sql)
```

### Rules
- Sections appear in this exact order and numbering.
- **§4 (Mistakes I Made)** is personal; **§7 (Common Pitfalls)** is generic. Keep them distinct.
- `Outcome` in the Revision Card: `⚠️` if §4 records a real mistake, `✅` if solved clean, `❓` if unknown.
- If §5 equals §3, write `Same as §3.` rather than duplicating the query.

---

## `.sql` template

```sql
/* =====================================================================
   Q## · <Title>
   Category : <area>          Difficulty : <Easy|Medium|Hard>
   Concepts : <A · B · C>
   ---------------------------------------------------------------------
   PROBLEM : <one-line restatement>
   APPROACH:
     1. <step>
     2. <step>
   MISTAKES I MADE:
     • <error> → <fix>            (or: none recorded)
   ===================================================================== */

-- ── MY SUBMITTED ATTEMPT ────────────────────────────────────────────
-- (Comment this block out ONLY if it was wrong. If it was correct,
--  this IS the solution and no separate block below is needed.)
<query>

-- ── FINAL CORRECT SOLUTION ──────────────────────────────────────────
-- (Include only when my attempt differed. This is the runnable query.)
<query>
```

### Rules
- **Exactly one uncommented query** per file, so the `.sql` always runs. That query is
  the final correct one. A wrong attempt is kept for reference but commented out.
- The header's `MISTAKES I MADE` mirrors `§4` of the `.md`.
