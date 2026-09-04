# Worked examples

Three PRs, one per tier. Note what each one leaves out.

## Patch Note - fixes only, no `What's new`

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

## Minor Update - new feature plus a fix found along the way

```markdown
**Minor Update**

## What's new
- Reports can be exported to CSV from the report page.
- Filter selections persist across page reloads.

## Bug fix
- Export no longer times out on ranges longer than 90 days.

---

## มีอะไรใหม่
- หน้ารายงาน export เป็น CSV ได้แล้ว
- ตัวกรองที่เลือกไว้ถูกจำไว้หลังรีเฟรชหน้า

## แก้บั๊ก
- การ export ไม่ timeout แล้วเมื่อเลือกช่วงวันเกิน 90 วัน
```

Note `deploy`-style terms stay English in Thai: `export`, `timeout`, `CSV`.

## Major Update - breaking change leads

```markdown
**Major Update**

## What's new
- **Breaking** — `POST /api/report/export` now requires a `format` field. Existing callers must send `format: "csv"` to keep current behavior.
- **Breaking** — Dropped Node 18. Minimum is now Node 20.
- Exports support XLSX in addition to CSV.

## Bug fix
- Export filenames no longer collide when two run in the same second.

---

## มีอะไรใหม่
- **Breaking** — `POST /api/report/export` ต้องส่ง field `format` ด้วย ผู้ที่เรียกอยู่เดิมต้องส่ง `format: "csv"` เพื่อให้ทำงานเหมือนเดิม
- **Breaking** — เลิกรองรับ Node 18 ขั้นต่ำคือ Node 20
- Export รองรับ XLSX เพิ่มจาก CSV

## แก้บั๊ก
- ชื่อไฟล์ที่ export ไม่ชนกันแล้วเมื่อสั่ง export สองครั้งในวินาทีเดียวกัน
```

Every `**Breaking**` bullet says what the reader must do, not just what changed.

## Counter-examples

| Bad | Why | Good |
|---|---|---|
| `## Bug fix`<br>`- N/A` | Empty section | Omit the heading |
| `- Updated exportService.ts` | Names a file, not an effect | `- Export now includes refunded orders` |
| `- อัปเดตเซอร์วิสการส่งออก` | Over-translated; nobody says this | `- ปรับ export service` |
| `This PR adds CSV export and fixes...` | Preamble | Go straight to bullets |
| `**Major Update**` for 40 bug fixes | Size is not consequence | `**Patch Note**` |
