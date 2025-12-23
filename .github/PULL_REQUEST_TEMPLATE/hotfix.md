<!-- .github/PULL_REQUEST_TEMPLATE/hotfix.md -->

# Hotfix:
< short title >

## Reason for hotfix
<!-- Why is this urgent? Include severity, customer impact, incident link, etc. -->

## Scope
<!-- Keep it minimal. What’s included and explicitly NOT included? -->
Included:

-
Not included:

-

## Change summary
-
-

## Verification
<!-- What checks were done to ensure safety? -->
- [ ] CI passed
- [ ] Targeted tests run:
  - [ ] `make test` (or subset):
- [ ] Manual verification steps:
  1.
  2.

## Rollback plan
<!-- How do we revert/mitigate if this goes wrong? -->
-

## Follow-ups
<!-- Any tech debt or proper fix that should follow the hotfix. -->
- [ ] Create issue(s) for follow-up work:
  - #

## Checklist
- [ ] This change is the smallest viable fix
- [ ] I considered impact on backwards compatibility
- [ ] I added/updated tests where feasible for a hotfix
- [ ] I documented any operational steps (if relevant)
