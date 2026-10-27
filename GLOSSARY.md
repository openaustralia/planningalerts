# PlanningAlerts

PlanningAlerts collects planning applications from Australian local councils, tells people about the ones near them, and lets people comment on applications and have those comments sent to the responsible authority.

## Language

**Application**:
A planning application made to an authority. Can be hidden by an admin, which removes it from the site for everyone.
_Avoid_: Development application, DA

**Comment**:
A message a person writes about an application, which is sent to the authority once published.
_Avoid_: Submission, feedback

**Draft comment**:
A comment that has been written but not yet published, so it has not been sent to the authority.
_Avoid_: Unpublished comment, pending comment

**Hidden comment**:
A published comment an admin has removed from public view.

**Comments disabled**:
The state of an application that takes no new comments, set and cleared by an admin. Existing comments stay visible and draft comments are kept but cannot be published. Applies to everyone, admins included. People see it described as "closed".
_Avoid_: Comments closed, comments locked, comments frozen

**Comments disabled reason**:
A note an admin can record about why comments are disabled. Visible to staff only, never shown to the public.
_Avoid_: Hidden reason (that one is public and belongs to hiding an application)
