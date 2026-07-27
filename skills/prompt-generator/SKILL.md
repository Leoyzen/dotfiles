---
name: prompt-generator
description: "Tạo prompt chất lượng cao hoặc cải tiến prompt có sẵn — meta-prompting với task decomposition, expert personas, verification checklist. Dùng khi user nói 'tạo prompt', 'viết prompt cho tôi', 'giúp tôi viết prompt', 'cải tiến prompt này', 'prompt này chưa tốt', 'review prompt', hoặc cần prompt cho system/task/conversation/role. Phiên bản cơ bản — dùng prompt-generator-v2 (KERNEL) nếu cần cấu trúc chặt hơn và prompt chaining."
---

# Prompt Generator

Create high-quality, structured prompts using meta-prompting best practices: task decomposition, expert personas, iterative verification, and hallucination minimization.

## Workflow

### Bước 0: Detect Mode

| User cung cấp | Mode | Hành động |
|---|---|---|
| Mô tả yêu cầu (chưa có prompt) | **Create** | Chạy Phase 1 → 2 → 3 → 4 |
| Prompt có sẵn cần cải tiến | **Refine** | Chạy checklist Phase 4 trước → xác định điểm yếu → sửa theo kết quả |

### Phase 1: Gather Requirements

Ask the user (one at a time, maximum 4 questions). Skip when answers are obvious from context.

1. **Type**: Detect or ask — what type of prompt?
   - **System prompt**: Persistent AI behavior across a conversation
   - **Task prompt**: One-shot, input → specific output
   - **Conversational prompt**: Multi-turn, requires memory/context handling
   - **Role prompt**: Character/persona, tone-focused

2. **Goal**: "What is the primary goal or role of the system you want to create?"

3. **Output**: "What specific outputs do you expect? (format, length, style)"

4. **Accuracy**: "How should it handle uncertainty? (disclaim, ask for sources, or best-effort)"

Minimize friction — 1-2 questions usually suffice when context is clear.

### Phase 2: Decompose (if needed)

| Tín hiệu | Decompose? |
|---|---|
| Prompt yêu cầu >= 3 expert domains khác nhau | Yes |
| Output cần cả phân tích + sáng tạo + validation | Yes |
| Single domain, straightforward input → output | No — skip to Phase 3 |

Khi decompose, assign expert personas — mỗi expert nhận instructions riêng, không shared memory:

- **Expert Writer** — copywriting, narrative, tone
- **Expert Analyst** — data, logic, verification
- **Expert Python** — code generation, computation
- **Expert [Domain]** — specialized knowledge

"Fresh eyes" — không assign cùng expert cho cả create AND validate.

### Phase 3: Generate the Prompt

Consolidate vào 1 prompt cohesive. Dùng [prompt-template](references/prompt-template.md) — chỉ include sections phù hợp, omit phần không relevant.

Lưu ý khi generate:
- Match prompt structure theo prompt type (system vs task vs conversational vs role)
- Ưu tiên "must NOT" over "should" — negative framing hiệu quả hơn vì giảm ambiguity

### Phase 4: Verify and Deliver

Self-review checklist trước khi deliver:

- [ ] No vague virtue words ("good", "helpful", "detailed") without specific definition
- [ ] No contradictory instructions (e.g., "be concise" + "include all details")
- [ ] No implicit assumptions — all context is explicitly stated
- [ ] Negative constraints are included (what NOT to do)
- [ ] Prompt type matches the use case
- [ ] If complex: suggest splitting into multi-prompt pipeline instead of mega-prompt

Then:
- Present the final prompt, organized and easy to follow
- Note expert reviews if used
- Offer to iterate if user wants adjustments

## Anti-patterns to Avoid

When reviewing or generating prompts, flag these issues:

- **Vague virtues**: "Write a good summary" → "Write a 3-sentence summary focusing on key findings and action items"
- **Overloaded prompt**: Too many tasks in one prompt → suggest splitting
- **Sycophancy traps**: "Always agree" or "Never say no" → remove
- **Missing scope**: "Write marketing copy" without audience, channel, tone → clarify
- **Prompt stuffing**: Repeating the same instruction in multiple sections → deduplicate
