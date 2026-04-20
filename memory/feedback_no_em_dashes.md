---
name: No em dashes in comments
description: User does not want em dashes (--) used in code comments
type: feedback
---

Don't use em dashes (--) in code comments. Use a colon, comma, or rewrite the sentence.

**Why:** User preference — they rejected an edit that used em dashes in C comments (MARK: - style is fine, but inline `//` comments like "corrupts X -- triggers Y" are not).

**How to apply:** In any code comments, avoid `—` or `--` as punctuation. Use `: `, `. `, or rephrase instead.
