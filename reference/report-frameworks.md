# Report Frameworks Reference

Frameworks used by the ai-bu-status-report commands to ensure every report is structured, honest, and actionable. These are not optional guidelines. They are baked into the command prompts.

## SCQA Framework

**Situation, Complication, Question, Answer**

Every good status update tells a story. SCQA is the framework that structures that story so it lands with any audience.

### How It Works

1. **Situation**: State the current known context. What does the audience already know or expect?
   - "The inference gateway is targeted for GA in Q3."
   - "The team has been focused on reducing model serving latency."

2. **Complication**: What changed, went wrong, or created an opportunity? This is the tension that makes the update worth reading.
   - "A new requirement from the enterprise team added GPU scheduling constraints we had not planned for."
   - "Testing revealed that p99 latency spikes under concurrent load, which blocks the SLA commitment."

3. **Question**: What needed to happen as a result of the complication? This is implied, not always written explicitly.
   - "How do we hit the Q3 GA date while accommodating the new constraints?"
   - "Can we resolve the latency issue without a major architecture change?"

4. **Answer**: What the team did, is doing, or recommends. This is the actionable part.
   - "We redesigned the scheduling loop (PR #42), cutting p99 by 40%. GA timeline holds."
   - "Shipping a phased fix: immediate mitigation this week (PR #50), full solution next sprint."

### When to Use It

- **Executive summaries**: SCQA structures the entire paragraph. The reader follows a logical thread from context to conclusion.
- **Risk descriptions**: Situation (what we expected) + Complication (what went wrong) + Answer (what we are doing).
- **Quarterly narratives**: The quarter's story arc follows SCQA naturally. Where were we? What happened? What did we deliver?

### Examples

**Bad** (no structure):
"We worked on the inference gateway this week and made good progress on several items including the scheduling loop and some performance improvements."

**Good** (SCQA):
"The inference gateway is on track for Q3 GA (Situation). Load testing revealed p99 latency spikes at 200+ concurrent requests, which would violate our enterprise SLA (Complication). The team redesigned the scheduling loop and shipped a fix that reduces p99 from 500ms to 300ms under load, bringing us within SLA (Answer). The GA timeline holds with one week of buffer."

---

## Traffic Light Criteria

Status colors must be earned by evidence, never assigned by vibes. These criteria define exactly when each color applies.

### GREEN - On Track

All of these must be true:
- The next milestone has a clear date and the current trajectory reaches it
- No open blockers (issues labeled "blocked" or PRs open more than 7 days without review)
- Velocity is steady or increasing (current week's output is within 20% of the rolling 4-week average)
- No critical or high-severity risks in the risk register
- All CI checks are passing on the main branch

Evidence required: "GREEN because [X of Y deliverables shipped], [next milestone is Z with W weeks of buffer], and [no open blockers]."

### YELLOW - At Risk

Any of these is true:
- A specific risk threatens the timeline, but mitigation is in progress
- One or more PRs have been open for more than 7 days without review
- Velocity has dropped more than 20% from the rolling average
- A dependency is at risk but has a backup plan
- CI is failing on a non-critical path

Evidence required: "YELLOW because [specific risk]. Mitigation: [specific action being taken]. Expected resolution: [date or condition]."

Do NOT use YELLOW as a default when unsure. If you cannot articulate the specific risk, the status is either GREEN or RED.

### RED - Blocked or Off Track

Any of these is true:
- A blocker exists that the team cannot resolve alone
- The next milestone date will be missed without additional resources or scope changes
- A critical system is failing and there is no workaround
- A key dependency has been delayed with no alternative path
- Data loss, security incident, or production outage is active

Evidence required: "RED because [specific blocker]. What is needed: [specific decision, resource, or escalation]. Impact if not resolved: [specific consequence with date]."

RED requires an ask. If you report RED without telling the reader what you need from them, the status is incomplete.

### Common Mistakes

| Mistake | Why It Is Wrong | Fix |
|---------|----------------|-----|
| "GREEN because no one reported issues" | Absence of reports is not evidence of health | Check metrics: velocity, open PRs, CI status |
| "YELLOW just to be safe" | Wastes attention; trains readers to ignore yellow | Either articulate the specific risk or go GREEN |
| "RED but we are working on it" | RED without an ask leaves the reader powerless | Add what decision or resource you need |
| Changing from RED to GREEN in one week | Suspicious without explanation | Show what changed: blocker resolved, scope adjusted |
| Never using RED | Either the project is charmed or risks are being hidden | Audit: are stale PRs and failing CI being ignored? |

---

## The "So What?" Test

Every bullet point in every report must pass this test: **"So what? Why does this matter?"**

If the answer is not obvious from the bullet itself, rewrite it.

### How to Apply It

Read each bullet point and ask: "If I were a VP scanning this report in 30 seconds, would I understand why this item matters?"

### Transformation Examples

| Before (Fails "So What?") | After (Passes "So What?") | What Changed |
|---------------------------|--------------------------|--------------|
| "Updated Helm chart values" | "Updated Helm chart to support multi-model routing, unblocking the Q3 inference gateway milestone (+67/-23 lines, PR #51)" | Added the outcome and what it unblocks |
| "Fixed bug in batch processor" | "Fixed token counting bug causing 15% overcharging on batch inference requests (PR #38, +28/-12 lines)" | Added the user impact |
| "Reviewed 5 PRs" | "Reviewed 5 PRs totaling 2,100 lines across the model router refactor, providing feedback that prevented a breaking API change" | Added what the reviews accomplished |
| "Worked on documentation" | "Published inference gateway quick-start guide, reducing new developer onboarding from 2 days to 4 hours based on team feedback" | Added measurable outcome |
| "Made progress on the API" | "Completed 3 of 5 API endpoints for the quota management service; on track for feature-complete by Friday (PR #50, +312/-0 lines)" | Replaced vague "progress" with specific completion status |
| "Attended planning meeting" | (Remove this bullet entirely) | Meetings are activities, not outcomes. Unless a decision was made, it does not belong. |

### The Rule

If a bullet point describes an **activity** ("worked on," "attended," "discussed," "looked into"), it fails the test. Rewrite it as an **outcome** or remove it.

Activities tell the reader what you did with your time. Outcomes tell the reader what the project gained. Status reports exist to communicate outcomes.

### Red Flags (Weasel Words)

These words almost always signal a bullet that fails the "So What?" test:

| Word/Phrase | Problem | Fix |
|------------|---------|-----|
| "some progress" | How much? 10%? 90%? | State the exact completion percentage or count |
| "good momentum" | Unmeasurable | State the metric: "velocity up 20% week over week" |
| "making progress" | On what? Toward what? | "Completed X of Y items toward [goal]" |
| "various improvements" | Name them or cut them | List each improvement with its impact |
| "several" | Use the actual number | "7 PRs" not "several PRs" |
| "working on" | Activity, not outcome | "Shipped X" or "X is at Y% complete" |
| "on track" | Evidence? | "On track: 8 of 10 deliverables complete, 2 remaining have PRs in review" |
| "significant" | Relative to what? | Use a number: "40% reduction" not "significant reduction" |
| "helped with" | What specifically? | "Reviewed PR #42, caught a race condition in the connection pool" |
| "contributed to" | How? | "Authored 3 of the 7 PRs in the release" |

---

## Combining the Frameworks

The strongest reports use all three frameworks together:

1. **SCQA** structures the narrative (executive summary, quarterly review narratives)
2. **Traffic Light** provides the honest status assessment (with evidence)
3. **"So What?"** ensures every bullet point earns its place in the report

### Quality Checklist

Before finalizing any report, run through this checklist:

- [ ] The summary/narrative follows SCQA structure (even if implicitly)
- [ ] Status color is justified by specific evidence, not by feeling
- [ ] Every bullet point passes the "So What?" test
- [ ] No weasel words survived (check the red flags table)
- [ ] Every claim has a number, a link, or both
- [ ] Bad news is stated directly, not hidden behind positive framing
- [ ] A VP could scan this in 30 seconds and understand the key points
- [ ] Activities without outcomes have been removed or rewritten
- [ ] Risks include mitigations and recommended actions
- [ ] The report is shorter than you think it should be (brevity is a feature)
