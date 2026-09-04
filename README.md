# claude-skills

Agent Skills ส่วนตัวสำหรับ Claude Code แจกจ่ายในรูปแบบ plugin marketplace

## ติดตั้ง

ใน Claude Code แบบ interactive terminal:

```
/plugin marketplace add EARTH157/claude-skills
/plugin install toolkit@claude-skills
```

หรือจาก CLI:

```bash
claude plugin marketplace add EARTH157/claude-skills
```

หลังติดตั้งแล้ว `/plugin marketplace update claude-skills` จะดึงของใหม่จาก GitHub มาให้

## Skills ในนี้

| Skill | ทำอะไร |
|---|---|
| `lean-context` | ลดการใช้ token ในงานที่ต้องอ่านโค้ดเยอะ โดยไม่ลดคุณภาพงาน |

## โครงสร้าง

```
.claude-plugin/
  plugin.json        # manifest ของ plugin
  marketplace.json   # manifest ของ marketplace (repo นี้เป็นทั้งสองอย่าง)
skills/
  <skill-name>/
    SKILL.md         # บังคับ — frontmatter + คำสั่ง
    references/      # เอกสารที่ Claude อ่านเพิ่มเมื่อจำเป็น
```

## เพิ่ม skill ใหม่

1. `mkdir -p skills/<name>` แล้วสร้าง `SKILL.md`
2. frontmatter ต้องมี `name` (ตรงกับชื่อโฟลเดอร์, ตัวพิมพ์เล็ก-ตัวเลข-ขีดกลาง) และ `description`
3. `description` คือสิ่งเดียวที่ Claude เห็นตอนยังไม่โหลด skill — ต้องบอกทั้ง *ทำอะไร* และ *เมื่อไหร่ควรใช้* พร้อมคำที่ผู้ใช้จะพิมพ์จริง
4. commit + push แล้ว `/plugin marketplace update claude-skills`

> SKILL.md เขียนเป็นภาษาอังกฤษโดยตั้งใจ — เป็น instruction ที่โมเดลอ่าน ไม่ใช่เอกสารสำหรับคน
> และกินโทเคนน้อยกว่าภาษาไทยราวครึ่งหนึ่งที่เนื้อหาเท่ากัน

## ทดสอบก่อน push

ให้ Claude Code ชี้มาที่ repo นี้แบบ local marketplace:

```
/plugin marketplace add /path/to/claude-skills
```
