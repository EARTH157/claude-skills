# Worked examples

Four PRs. Note what each one leaves out, and which sections it omits entirely.

## Patch Note - fixes only

```markdown
**Patch Note**

## Bug fix
- Dashboard totals no longer double-count refunded orders.
- Date filter now respects the Asia/Bangkok timezone instead of UTC.
- Fixed a crash when opening a report with no rows.

---

## แก้บั๊ก
- ยอดรวมในแดชบอร์ดไม่นับออเดอร์ที่คืนเงินซ้ำอีกต่อไป
- ตัวกรองวันที่ใช้ timezone Asia/Bangkok แล้ว จากเดิมที่ใช้ UTC
- แก้อาการแครชตอนเปิดรายงานที่ไม่มีข้อมูล
```

Left out: a refactor of `dateUtils.ts` in the same PR. Invisible to users.

## Patch Note - visible change that is not a fix

```markdown
**Patch Note**

## Changed
- Report tables load about twice as fast on ranges over 30 days.
- The export button moved from the page footer to the toolbar.

---

## ปรับปรุง
- ตารางรายงานโหลดเร็วขึ้นราวเท่าตัวเมื่อเลือกช่วงเกิน 30 วัน
- ปุ่ม export ย้ายจากท้ายหน้าไปอยู่บน toolbar
```

Nothing was broken and nothing is new, so `Changed` stands alone. The tier is still
Patch Note - nobody has to do anything.

## Minor Update - all three sections

```markdown
**Minor Update**

## What's new
- Reports can be exported to CSV from the report page.

## Changed
- Filter selections now persist across page reloads instead of resetting.

## Bug fix
- Export no longer times out on ranges longer than 90 days.

---

## มีอะไรใหม่
- หน้ารายงาน export เป็น CSV ได้แล้ว

## ปรับปรุง
- ตัวกรองที่เลือกไว้ถูกจำไว้หลังรีเฟรชหน้า จากเดิมที่รีเซ็ตทุกครั้ง

## แก้บั๊ก
- การ export ไม่ timeout แล้วเมื่อเลือกช่วงวันเกิน 90 วัน
```

The filter bullet is `Changed`, not `Bug fix` - resetting on reload was the old design,
not a defect. Technical terms stay English in Thai: `export`, `timeout`, `CSV`.

## Major Update - Breaking leads its section

```markdown
**Major Update**

## What's new
- Exports support XLSX in addition to CSV.

## Changed
- **Breaking** — `POST /api/report/export` now requires a `format` field. Existing callers must send `format: "csv"` to keep current behavior.
- **Breaking** — Dropped Node 18. Minimum is now Node 20.

## Bug fix
- Export filenames no longer collide when two run in the same second.

---

## มีอะไรใหม่
- Export รองรับ XLSX เพิ่มจาก CSV

## ปรับปรุง
- **Breaking** — `POST /api/report/export` ต้องส่ง field `format` ด้วย ผู้ที่เรียกอยู่เดิมต้องส่ง `format: "csv"` เพื่อให้ทำงานเหมือนเดิม
- **Breaking** — เลิกรองรับ Node 18 ขั้นต่ำคือ Node 20

## แก้บั๊ก
- ชื่อไฟล์ที่ export ไม่ชนกันแล้วเมื่อสั่ง export สองครั้งในวินาทีเดียวกัน
```

Both `**Breaking**` bullets alter things that already existed, so they sit in `Changed`,
not `What's new`. XLSX support is genuinely new, so it stays above.

## Counter-examples

| Bad | Why | Good |
|---|---|---|
| `## Bug fix`<br>`- N/A` | Empty section | Omit the heading |
| `## Changed`<br>`- Refactored the export service` | Invisible to users | Omit it |
| `## Changed`<br>`- Bumped lodash to 4.17.21` | Dependency bump nobody perceives | Omit it |
| `## Bug fix`<br>`- Filters now persist on reload` | Old behavior was a design, not a defect | Put it in `Changed` |
| `- Updated exportService.ts` | Names a file, not an effect | `- Export now includes refunded orders` |
| `- อัปเดตเซอร์วิสการส่งออก` | Over-translated; nobody says this | `- ปรับ export service` |
| `This PR adds CSV export and fixes...` | Preamble | Go straight to bullets |
| `**Major Update**` for 40 bug fixes | Size is not consequence | `**Patch Note**` |
