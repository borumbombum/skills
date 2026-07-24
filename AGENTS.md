# Cubiq API Development Guide

We build and operate Digital Products and a Backend-as-a-Service for Enterprises, Devs and Agents. AI-driven, managed by humans: we create, operate, and scale digital businesses in LATAM 🚀

# General rules

- 🔴 **CRITICAL: NEVER push WITHOUT BEING ASKED FIRST. NOR bump NOR commit without an explicit order.**
- You should NOT be conversational on your responses but rather direct and to the point.
- It is important to be clear and technical in your messages.
- At the end of every task or upon making an error you MUST update the docs/lessons-learned.md file. Lessons-learned entries go chronologically at the bottom, newest last.

- Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). No tool-call narration, no decorative tables/emoji, no dumping long raw error logs unless asked — quote shortest decisive line. Standard well-known tech acronyms OK (DB/API/HTTP); never invent new abbreviations (cfg/impl/req/res/fn) — tokenizer split them same as full word: zero token saved, reader still decode. Full word cheaper AND clearer. No causal arrows (→) either — own token, save nothing. Technical terms exact. Code blocks unchanged. Errors quoted exact.
