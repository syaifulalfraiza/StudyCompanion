# Parent Module Testing - Quick Reference Card

**Print this page and have it handy during testing!**

---

## 🎯 CRITICAL PARENT IDs TO TEST

### Must Test #1: p5 (Mapping Fix)
```
Login ID: p5
Expected Child: Raj Kumar (s6)
Form: 4A | GPA: 3.1
Status: ✅ FIXED (was s3, now s6)
```

### Must Test #2: p8 (Multi-Child) ⭐
```
Login ID: p8
Expected Children: 2
  - Nur Azlina (s3) - Form 4C, GPA 3.5
  - Nurul Izzah (s11) - Form 4C, GPA 4.0 ⭐
Status: ✅ NEW (2-child parent)
```

---

## 📋 ALL PARENTS QUICK REFERENCE

| ID | Parent Name | Child | Form | GPA | Type |
|----|------------|-------|------|-----|------|
| p1 | Abdullah Hassan | Siti Mariah | 4A | 3.9 | Single |
| p2 | Karim Ahmad | Amir Abdullah | 4A | 3.8 | Single |
| p3 | Norhaida Mahmud | Muhammad Azhar | 4B | 3.7 | Single |
| p4 | Lim Chen Hao | Lim Wei Chen | 4B | 3.6 | Single |
| p5 | Raj Nair Kumar | Raj Kumar | 4A | 3.1 | Single ✅ FIXED |
| p6 | Wong Tian Huat | Sophia Wong | 4B | 3.2 | Single ✅ NEW |
| p7 | Viswanathan Sharma | Priya Sharma | 4C | 3.3 | Single ✅ NEW |
| p8 | Siti Nur Azizah | [s3, s11] | 4C | [3.5, 4.0] | **Multi** ⭐ |
| p9 | Ooi Seng Keat | Davina Ooi | 4A | 3.9 | Single ✅ NEW |
| p10 | Tan Cheng Huat | Tan Jun Wei | 4B | 3.8 | Single ✅ NEW |
| p11 | Rashid Abdullah | Adnan Hassan | 4A | 3.4 | Single ✅ NEW |

---

## ✅ FORM LEVEL QUICK CHECK

**All should show "Form 4X" - NEVER "Form 1X" or "Form 2X"**

```
Form 4A: p1(3.9), p5(3.1), p9(3.9), p11(3.4)
Form 4B: p2(3.8), p3(3.7), p4(3.6), p6(3.2), p10(3.8)
Form 4C: p7(3.3), p8×2(3.5 & 4.0)
```

---

## 🚨 FAIL CONDITIONS (Stop Testing If Any Occur)

- ❌ Form 1 or Form 2 appears
- ❌ p5 shows Nur Azlina (should be Raj Kumar)
- ❌ p8 shows 1 child (should be 2)
- ❌ App crashes on parent login
- ❌ GPA outside range 3.1-4.0
- ❌ Console errors

---

## ✅ PASS CONDITIONS (Testing Complete When All True)

- ✅ p1-p11 all load without errors
- ✅ All children display correctly
- ✅ All form levels are Form 4
- ✅ p5 shows s6 (Raj Kumar)
- ✅ p8 shows s3 AND s11
- ✅ Can select both p8 children
- ✅ Calendar has 30+ events
- ✅ Notifications load
- ✅ No console errors

---

## 📱 TESTING WORKFLOW

```
1. Login with p1 → Verify → Check calendar
2. Login with p2 → Verify → Check notifications
3. Login with p3 → Verify → Check form level
4. Login with p4 → Verify → Test UI
5. Login with p5 → **CRITICAL** → Verify s6, not s3
6. Login with p6 → Verify → Check new parent
7. Login with p7 → Verify → Check new parent
8. Login with p8 → **CRITICAL** → Verify 2 children
9. Login with p9 → Verify → Check new parent
10. Login with p10 → Verify → Check new parent
11. Login with p11 → Verify → Check new parent
```

---

## 🔍 WHAT TO CHECK FOR EACH PARENT

### Family Overview
- [ ] Child count correct
- [ ] Child name displays
- [ ] Form level: Form 4X
- [ ] GPA: 3.1-4.0
- [ ] No error messages

### Child Details (Click Child Card)
- [ ] Homework loads
- [ ] Quiz loads
- [ ] Reminder loads
- [ ] No loading errors

### Calendar
- [ ] Events display
- [ ] Can navigate months
- [ ] Events have colors
- [ ] ~30+ total events

### Notifications
- [ ] Loads without hanging
- [ ] Shows notifications
- [ ] Can mark as read
- [ ] No error messages

---

## 🌟 p8 MULTI-CHILD DETAILED CHECK

### Step 1: Login
```
Input: p8
Expected: Dashboard loads
Time: <2 seconds
```

### Step 2: Family Overview
```
Expected:
- "2 children" OR "2 students"
- Card showing: "Nur Azlina"
- Card showing: "Nurul Izzah"
- NO "1 child" message
```

### Step 3: Child Selection
```
Expected:
- Can click: "Nur Azlina"
- Can click: "Nurul Izzah"
- Can switch between them
- Details load for each
```

### Step 4: Calendar
```
Expected:
- Shows events for both children
- ~30+ events total
- Covers both s3 and s11
```

### Step 5: Notifications
```
Expected:
- Shows notifications for both
- No missing data
- Can see both children names
```

---

## 📊 EXPECTED DATA

### GPA Distribution
```
3.1: Raj Kumar (s6, p5)
3.2: Sophia Wong (s7, p6)
3.3: Priya Sharma (s8, p7)
3.4: Adnan Hassan (s9, p11)
3.5: Nur Azlina (s3, p8)
3.6: Lim Wei Chen (s5, p4)
3.7: Muhammad Azhar (s2, p3)
3.8: Amir Abdullah (s1, p2) + Tan Jun Wei (s10, p10)
3.9: Siti Mariah (s4, p1) + Davina Ooi (s12, p9)
4.0: Nurul Izzah (s11, p8) ⭐ Perfect
```

### Student Distribution by Form

**Form 4A (5 students):**
- s1: Amir Abdullah (p2)
- s4: Siti Mariah (p1)
- s6: Raj Kumar (p5)
- s9: Adnan Hassan (p11)
- s12: Davina Ooi (p9)

**Form 4B (4 students):**
- s2: Muhammad Azhar (p3)
- s5: Lim Wei Chen (p4)
- s7: Sophia Wong (p6)
- s10: Tan Jun Wei (p10)

**Form 4C (3 students):**
- s3: Nur Azlina (p8)
- s8: Priya Sharma (p7)
- s11: Nurul Izzah (p8)

---

## 🐛 IF TEST FAILS

### p5 Shows Wrong Child
```
Problem: Shows Nur Azlina (s3) instead of Raj Kumar (s6)
Cause: Parent mapping not fixed in SampleChildData
File: lib/services/sample_child_data.dart
Fix: Change 'p5': ['s3'] to 'p5': ['s6']
```

### p8 Shows 1 Child Instead of 2
```
Problem: Shows only Nur Azlina, missing Nurul Izzah
Cause: Parent mapping incomplete
File: lib/services/sample_child_data.dart
Fix: Ensure 'p8': ['s3', 's11'] is in mapping
```

### Form Level Shows Form 1 or 2
```
Problem: Shows "Form 1A" or "Form 2B"
Cause: ChildModel grades not updated
File: lib/services/sample_child_data.dart
Fix: Change all grade: 'Form 1X' to 'Form 4X'
```

### Parent Profile Empty
```
Problem: No name/email/phone displaying
Cause: Parent data not integrated
File: lib/viewmodels/parent_dashboard_viewmodel.dart
Fix: Ensure SampleParentData methods are called
```

---

## 📞 TESTING SUPPORT

**Full Documentation:**
- PARENT_MODULE_MANUAL_TESTING_SCRIPT.md (step-by-step)
- PARENT_MODULE_CODE_INSPECTION_REPORT.md (technical details)
- PARENT_MODULE_TESTING_SUMMARY.md (overview)

**Need to check code?**
- lib/services/sample_child_data.dart (12 students)
- lib/services/sample_parent_data.dart (11 parents)
- lib/viewmodels/parent_dashboard_viewmodel.dart (parent methods)

---

**Status:** Ready to test! Good luck! 🚀

