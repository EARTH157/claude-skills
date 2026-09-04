# claude-skills

Agent Skills ส่วนตัว เขียนตาม [Agent Skills open standard](https://agentskills.io)
ใช้ได้กับ agent ที่รองรับ `SKILL.md` ทุกตัว ไม่ผูกกับ Claude Code

## Skills

| Skill | ทำอะไร |
|---|---|
| `lean-context` | ลดการใช้ token ในงานที่ต้องอ่านโค้ดเยอะ โดยไม่ลดคุณภาพงาน |

## ติดตั้ง

### Claude Code (ผ่าน plugin marketplace)

```
/plugin marketplace add EARTH157/claude-skills
/plugin install toolkit@claude-skills
```

อัปเดตทีหลังด้วย `/plugin marketplace update claude-skills`

### Agent อื่น ๆ (Cursor, Codex, Gemini CLI, ...)

spec กำหนดแค่ *รูปแบบไฟล์* ไม่ได้กำหนดว่า client ต้องหา skill ที่ไหน
แต่ละตัวเลยมี directory ของตัวเอง สคริปต์นี้สร้าง junction จาก directory
ของแต่ละเครื่องมือมาที่ repo นี้ — source of truth เดียว แก้ที่นี่ที่เดียวเห็นทุกตัว

```powershell
.\install.ps1 -WhatIf   # ดูก่อนว่าจะทำอะไรบ้าง
.\install.ps1           # ลงให้เฉพาะเครื่องมือที่ติดตั้งอยู่แล้ว
```

junction บน Windows ไม่ต้องใช้สิทธิ์ admin
ตาราง path อยู่ต้นไฟล์ `install.ps1` แก้ได้ตามต้องการ

> path ของแต่ละเครื่องมือเปลี่ยนได้เรื่อย ๆ — ในสคริปต์มีลิงก์ docs กำกับไว้ทุกบรรทัด
> ควรเช็คก่อนถ้าเครื่องมือไหนไม่ยอมโหลด

## โครงสร้าง

```
.claude-plugin/        # เฉพาะ Claude Code — เครื่องมืออื่นไม่สนใจโฟลเดอร์นี้
  plugin.json
  marketplace.json
skills/                # ตัวเนื้อจริง พกพาได้ตาม spec
  <skill-name>/
    SKILL.md           # บังคับ — frontmatter + คำสั่ง
    references/        # โหลดเมื่อจำเป็นเท่านั้น
install.ps1            # ลิงก์ skills/ เข้า agent ตัวอื่นบนเครื่องนี้
```

## เพิ่ม skill ใหม่

1. `mkdir skills/<name>` แล้วสร้าง `SKILL.md`
2. frontmatter บังคับ 2 ฟิลด์: `name` (ต้องตรงกับชื่อโฟลเดอร์ ตัวพิมพ์เล็ก/ตัวเลข/ขีดกลาง ห้ามขีดคู่) และ `description` (ไม่เกิน 1024 ตัวอักษร)
3. `description` คือสิ่งเดียวที่ agent เห็นตอนยังไม่โหลด skill — ต้องบอกทั้ง *ทำอะไร* และ *เมื่อไหร่ใช้* พร้อมคำที่ผู้ใช้จะพิมพ์จริง
4. เก็บ `SKILL.md` ให้ต่ำกว่า 500 บรรทัด รายละเอียดยาว ๆ ย้ายไป `references/`
5. `npx skills-ref validate ./skills/<name>` แล้ว commit + push

### เขียนให้พกพาได้

อย่าอ้างชื่อ tool ของ harness ใด harness หนึ่งใน `SKILL.md` (`Grep`, `/context`, ...)
ให้อธิบายเป็น *การกระทำ* แล้วยกชื่อจริงเป็นตัวอย่าง ถ้ามีเนื้อหาเฉพาะเครื่องมือจริง ๆ
แยกไปไว้ใน `references/<tool>.md` แบบที่ `lean-context` ทำกับ `claude-code.md`

> `SKILL.md` เขียนเป็นภาษาอังกฤษโดยตั้งใจ — เป็น instruction ที่โมเดลอ่าน ไม่ใช่เอกสารสำหรับคน
> และกินโทเคนน้อยกว่าภาษาไทยราวครึ่งหนึ่งที่เนื้อหาเท่ากัน

## ทดสอบก่อน push

```
/plugin marketplace add C:/Users/Jirapat Chumaungphan/Documents/claude-skills
```

local marketplace อ่านจากดิสก์ตรง ๆ แก้ `SKILL.md` แล้วเปิด session ใหม่ก็เห็นผลทันที
