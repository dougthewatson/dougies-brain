# PKM System Landscape Catalog

Research date: 2026-05-01. Compiled as design reference for building a self-hosted personal knowledge management system. Snapshot only: star counts, versions, pricing and company details below reflect that date and will drift.

---

## Khoj

**GitHub:** https://github.com/khoj-ai/khoj  
**Stars:** ~34k  
**Last commit:** Active -- release v2.0.0-beta.28, March 2026  

Khoj is a self-hostable personal AI assistant that indexes your documents (PDF, Markdown, Notion, org-mode, Word) and connects to the web to answer questions. Backed by YC (W24). Supports both local LLMs (Llama, Qwen, Mistral) and cloud providers (GPT, Claude, Gemini), with access via browser, Obsidian plugin, Emacs, desktop app, and WhatsApp.

**Does well:** Document indexing across diverse formats, multi-platform access, local/cloud LLM flexibility, custom agent personas, Obsidian integration, scheduled automations. Genuinely self-hostable with Docker. Good community.

**Missing/weak:** Memory is document-retrieval-only -- no structured entity memory, no relationship graph, no temporal reasoning. Responses don't compound over time; every query re-searches the same corpus. No provenance model (source vs. synthesis not distinguished). Chunking is standard; context accumulation is not a design goal.

**Steal:** Obsidian integration pattern, the multi-platform access surface (browser + plugin + mobile), and the local-LLM-first deployment model.

---

## Quivr

**GitHub:** https://github.com/QuivrHQ/quivr  
**Stars:** ~38k (peaked before 2025 pivot)  
**Last commit:** Actively maintained, but mission changed  

Quivr originally billed itself as a RAG-powered second brain -- drop any file, chat with it. Grew to 38k stars fast. Then in February 2025 it pivoted entirely to B2B customer support automation (Zendesk integration). The open-source repo remains but the product vision is gone. It's now "opinionated RAG for integrating GenAI in your apps" -- a library, not a personal brain.

**Does well:** Clean, pluggable RAG architecture. Supports any LLM, any vector store (PGVector, Faiss), and any file type. The infra plumbing is solid for teams building document-chat products.

**Missing/weak:** No personal memory model, no entity tracking, no temporal structure. The second-brain vision was abandoned. Using the library for personal brain work means building all the UX and memory logic yourself on top of generic RAG scaffolding.

**Steal:** The pluggable vector store abstraction (swap backends without changing retrieval logic), and the multi-parser document ingestion pipeline.

---

## mem0

**GitHub:** https://github.com/mem0ai/mem0  
**Stars:** ~54k  
**Last commit:** Active -- April 2026 algorithm update  

mem0 (pronounced "mem-zero") is a universal memory layer for AI agents. Multi-store architecture: vector search for semantic similarity, graph relationships for entity links, and key-value for explicit facts. Three memory scopes: user-level (persistent preferences), session-level (current context), agent-level (agent-specific knowledge). Raised $24M (Seed + Series A). Self-hostable via Docker or pip.

**Does well:** Best-in-class contradiction resolution -- when a user corrects a preference, mem0 updates the existing memory rather than appending a duplicate. Hybrid retrieval (semantic + BM25 + entity matching) as of April 2026. Strong Python and TypeScript SDKs. Good benchmark scores (91.6 LoCoMo, 93.4 LongMemEval). Provenance is implicit per memory entry.

**Missing/weak:** Memory is flat fact extraction -- not a knowledge graph, not a wiki, not a timeline. No concept of compiled synthesis vs. raw source. The scoping model (user/session/agent) doesn't map to personal vault concepts like project, area, or time period. Requires cloud LLM by default (GPT-5-mini). Personal-brain use requires significant custom orchestration on top.

**Steal:** The conflict-resolution mechanism (update-in-place vs. append), the three-scope memory isolation model, and the hybrid retrieval stack (vector + BM25 + entity).

---

## Letta / MemGPT

**GitHub:** https://github.com/letta-ai/letta  
**Stars:** ~22k  
**Last commit:** Active -- v0.16.7, March 2026  

Originally MemGPT from UC Berkeley's Sky Computing Lab, rebranded Letta. The core insight: treat LLM context like OS memory -- core memory (RAM equivalent, always in context), archival memory (disk, searchable vector store), and recall memory (conversation history). Agents explicitly call memory functions to move information between tiers. Stateful agent runtime with durable storage. Full agent operating system abstraction.

**Does well:** The OS-memory metaphor is the right conceptual frame -- it forces explicit decisions about what stays in context vs. gets archived. Multi-agent coordination is native. Agents can call sub-agents and pass state. Memory management is auditable. Active community, model-agnostic.

**Missing/weak:** Developer-facing infrastructure, not a personal brain product. Core memory is small (fits in the system prompt), so the agent's "working knowledge" is limited. Archival memory is a flat vector store -- no graph, no compiled wiki, no entity model. Temporal reasoning requires custom work. High operational overhead for a solo user.

**Steal:** The explicit memory tier model (core / archival / recall) as a design vocabulary. The idea that agents should actively decide what to remember, not just passively embed everything.

---

## Cognee

**GitHub:** https://github.com/topoteretes/cognee  
**Stars:** ~17k  
**Last commit:** Active -- v1.0.4.dev0, April 2026  

Cognee is a knowledge engine that runs an ECL pipeline (Extract, Cognify, Load) on incoming documents, converting unstructured text into a knowledge graph that evolves as content changes. Combines vector search, graph databases (Neo4j, FalkorDB, KuzuDB, NetworkX), and cognitive-science-inspired memory structures. Claims "AI agent memory in 6 lines of code." Supports multi-agent knowledge sharing.

**Does well:** The graph-native approach is architecturally correct for personal knowledge -- relationships matter as much as content. Multi-backend pluggability is real (swap Neo4j for NetworkX locally). Four clean operations: Remember, Recall, Forget, Improve. Cross-agent knowledge sharing is explicit in the design.

**Missing/weak:** Operational complexity is high despite the tagline. "6 lines of code" belies the infrastructure requirements. The graph construction is automatic, which means entity extraction quality depends heavily on the underlying LLM. No human-curated ontology -- the graph emerges from LLM extraction, not from intentional schema. No distinction between source material and synthesis.

**Steal:** The Forget operation (explicit deletion, not just decay), the multi-backend graph abstraction, and the Improve operation as a scheduled maintenance pass.

---

## Danswer / Onyx

**GitHub:** https://github.com/onyx-dot-app/onyx  
**Stars:** ~15-18k  
**Last commit:** Active, ongoing releases  

Danswer rebranded to Onyx. Enterprise-grade open-source search and AI assistant. Connects to 40+ connectors (Slack, GitHub, Confluence, Google Drive, Jira, Notion, etc.). Designed for teams: natural language questions answered with citations from internal knowledge bases. Indexing scales to tens of millions of documents. Deployable on-premise.

**Does well:** Production-quality connector ecosystem -- this is the most complete ingestion library in the open-source space. Permissioned search (respects source ACLs). Citation-backed answers, not hallucinated responses. Handles multi-source retrieval across heterogeneous systems gracefully.

**Missing/weak:** Explicitly enterprise/team-oriented -- no personal memory, no entity graph, no timeline, no synthesis accumulation. The UX is a search interface, not a thinking partner. Overkill infrastructure for solo use. No concept of "what have I learned" vs. "what do my docs say."

**Steal:** The connector architecture (standardized ingestion from diverse sources), and the citation-in-answer pattern (every claim traces back to a source document and passage).

---

## Fabric

**GitHub:** https://github.com/danielmiessler/fabric  
**Stars:** ~41k  
**Last commit:** Active -- v1.4.447, April 2026 (added Claude Opus 4.7 support)  

Fabric is a modular framework for augmenting humans with AI via a crowdsourced library of named "patterns" -- system prompts designed for specific cognitive tasks (summarize, extract wisdom, create flashcards, rate content, identify claims, etc.). Not a memory system. The CLI pipes any content through any pattern to any LLM. Go-based rewrite for performance.

**Does well:** The Pattern library is genuinely valuable -- each pattern encodes a specific cognitive operation that would otherwise require prompt engineering per use. Composable via UNIX pipes. Active pattern community adds new templates continuously. Model-agnostic. The "extract_wisdom" and "create_summary" patterns in particular are well-tuned.

**Missing/weak:** Not a memory system at all -- Fabric has no state, no persistence, no retrieval, no entity model. Each invocation is stateless. It's a prompt executor, not a brain. The patterns don't accumulate into a knowledge base.

**Steal:** The named-pattern vocabulary as a design primitive -- discrete, named cognitive operations that can be invoked on any content. Apply this to scheduled maintenance passes on a personal brain (lint, summarize, extract entities, surface contradictions).

---

## Rewind AI / Limitless

**Website:** https://limitless.ai (formerly rewind.ai)  
**Type:** Closed-source, commercial  
**Status:** Acquired by Meta, December 2025; screen/audio capture features discontinued December 19, 2025  

Rewind AI (launched 2022) pioneered local screen recording as personal memory -- everything you saw, heard, or typed was OCR'd, transcribed, and indexed on-device. Rebranded to Limitless in 2024 with a hardware Pendant for in-person conversation capture. Mac-first, M-chip optimized local processing. Acquired by Meta in late 2025; the non-hardware features were shut down.

**Did well:** On-device processing model (data never left your machine). Automatic capture without deliberate input. Meeting summaries generated post-hoc. The Pendant extended capture beyond the screen. Speaker identification and action-item extraction.

**Missing/weak (at shutdown):** Closed source, no self-hostable option, cloud lock-in despite the local-processing pitch. Search quality was keyword-heavy -- no entity graph, no synthesis layer. Memory was screen-capture archaeology, not structured knowledge. Query interface was rudimentary. Meta acquisition killed the product for all non-Pendant users.

**Steal:** The zero-friction capture model (passive recording vs. deliberate note-taking). The post-hoc summarization approach. The physical-world capture via pendant points toward ambient input pipelines.

---

## Karpathy's LLM Wiki (llm-wiki)

**Gist:** https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f  
**Type:** Design pattern / essay  

Karpathy proposed using LLMs not as chatbots but as compilers that maintain a structured wiki from raw source material. Three layers: immutable raw sources (drop-in folder), an LLM-maintained wiki (structured markdown with entity pages and cross-references), and a human-configured schema (governance file defining structure and conventions). Two special index files: index.md (content-oriented catalog) and log.md (append-only operations log). Periodic lint passes identify contradictions, stale claims, and orphaned pages.

**Core insight:** Human judgment drives curation direction; mechanical consistency is the LLM's job. Synthesis compounds because new sources are integrated into the existing wiki rather than re-retrieved from scratch. Bypasses RAG entirely for small-to-medium corpora by fitting the compiled wiki in a long context window.

**Steal everything:** The three-layer provenance model (sources / wiki / schema) maps directly to a vault design. The lint operation as a scheduled health check. The compilation metaphor (LLM rewrites the wiki from sources, not summarizes individual docs). The index.md + log.md pair for navigability and audit trail. The "humans curate, LLMs maintain structure" division of labor.

---

## gbrain (garrytan)

**GitHub:** https://github.com/garrytan/gbrain  
**Stars:** 26k+ (as of 2026-07)  
**Last commit:** Active  

Garry Tan (YC President) built GBrain as his actual production agent brain -- ~146k pages, ~24k people, ~5k companies, and 66 cron jobs (as of mid-2026). Key design: "Compiled Truth + Timeline Pattern" -- above the separator is current best understanding (editable), below is an append-only evidence trail (never edited). Self-wiring knowledge graph extracts typed relationships (attended, works_at, invested_in, founded, advises) deterministically without LLM calls. Hybrid retrieval stacks ~20 techniques: HNSV vectors, BM25 keyword, reciprocal rank fusion, intent classification, multi-query expansion, backlink boosting. Benchmarked at P@5 49.1%, R@5 97.9% -- 31 points above vector-only.

**Does well:** The compiled-truth-plus-timeline separation is the most elegant memory architecture in this survey. Deterministic graph extraction (no LLM tokens wasted on relationship tagging). The 43-skill modular system with explicit triggers and test coverage. Minions (job queue) for reliable background work. "Thin harness, fat skills" philosophy keeps core code stable. PGLite for local, PostgreSQL for cloud -- same interface.

**Missing/weak:** Now installable in ~30 minutes (agent-led install; PGLite means no database server), but it is still an engine for AI agent stacks: a 24/7 daemon, a job queue, and retrieval infrastructure you operate. The from-zero full-stack path (agent platform + hosting + integrations) runs about 2 hours and assumes technical comfort. It is a memory layer for your agent, not a ready-made personal operating system.

**Steal:** The Compiled Truth + Timeline pattern (this is the single best idea in the entire landscape). The deterministic graph-extraction approach. The backlink-boosted ranking. The benchmark-driven search quality evaluation. The "agent-parseable output first" CLI design.

---

## Commercial PKM with AI

**Mem.ai** takes the most radical AI-memory approach of the commercial tools: no folders, no tags, single stream of notes, AI organizes everything automatically. "Mem 2.0" (early 2025) improved stability significantly. The AI builds a model of your thinking over time and surfaces relevant notes as you write. Strength: zero-overhead capture. Weakness: opaque organization, no data portability, cloud-only. Funded by the OpenAI Startup Fund at $23.5M.

**Reflect** treats AI as a writing and synthesis partner rather than an organizer. It was among the first to claim graph-aware AI -- the model reads the connections between notes, not just individual note content. End-to-end encryption is a differentiator. Queries like "what have I learned about X" synthesize across the note graph. Weakness: proprietary, no self-host, limited to text notes.

**Tana** is the most structurally sophisticated commercial PKM. Supertags function as lightweight ontology: tag any node as a "Person," "Company," or "Project" and attach typed fields. Live Queries create dynamic filtered views. In 2025-2026 Tana added AI agents that participate in meetings and autonomously generate structured outputs from the knowledge graph. Raised $25M (Feb 2025). Weakness: steep learning curve, no local storage, the graph is powerful but requires intentional design to get value.

**Heptabase** is spatial-first: infinite whiteboard, cards with bidirectional links, visual organization of research and learning. Added AI Actions on cards (translate, summarize, mind-map), an MCP server for connecting external AI tools, and an AI Tutor that reads across whiteboards. The whiteboard model is genuinely different from text-first tools -- it externalizes relationships visually. Weakness: not optimized for quick capture, best for deliberate research workflows.

**Notion AI** adds AI on top of a collaborative workspace platform. The AI memory approach is document-centric RAG over your Notion pages -- no entity graph, no synthesis accumulation. Strength: the platform ubiquity means it's where teams' knowledge already lives. Weakness: the AI layer is a thin wrapper on the document store, not a purpose-built memory architecture.

---

## Synthesis: Patterns and Gaps

**Patterns across successful systems.** Every system that works well combines at least two retrieval strategies -- semantic vector search plus keyword (BM25) at minimum, with graph traversal added for relational queries. Chunking is almost universally naive (fixed-size or sentence-boundary), with Cognee and gbrain as exceptions that preserve semantic units. Provenance tracking is consistently underbuilt: most systems treat all content as equivalent, losing the distinction between raw source, synthesis, and speculation. The best systems (gbrain, Karpathy's wiki, Letta) all have an explicit memory tier model -- different storage with different semantics, not one undifferentiated blob. Maintenance passes (lint, consolidation, contradiction resolution) appear in gbrain, Karpathy's wiki, and mem0 -- systems without them accumulate noise over time.

**What none of these provide out of the box for a self-hosted personal brain.** The combination of: (1) provenance-aware storage that permanently distinguishes immutable sources from editable synthesis, (2) a human-configured ontology (not LLM-extracted graph, but schema you define and the LLM populates), (3) compiled truth with append-only timeline per entity, (4) scheduled cognitive maintenance passes (lint, consolidate, extract, surface), (5) zero-friction ambient capture (passive input pipeline, not deliberate filing), and (6) temporal context across time -- "what did I believe six months ago, and what changed." RAG systems answer "what do my docs say." None of these answer "what have I learned, how has my thinking changed, and what should I revisit." That last question is the actual job of a second brain -- and it remains unbuilt.
