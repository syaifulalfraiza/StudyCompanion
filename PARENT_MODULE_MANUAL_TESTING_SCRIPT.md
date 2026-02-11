# Parent Module - Manual Testing Script

**Date:** February 11, 2026  
**Purpose:** Step-by-step guide to manually test Parent Module functionality  
**Duration:** ~30-45 minutes for complete testing

---

## 🚀 SETUP & LAUNCH

### Step 1: Clean Build
```bash
cd e:\Github\StudyCompanion
flutter clean
flutter pub get
```
**Expected:** No errors, all dependencies resolved ✅

### Step 2: Run App
```bash
flutter run
```
**Expected:** App launches, shows login/home screen

### Step 3: Navigate to Parent Login
- Look for login screen or parent selection
- Should show "Parent Dashboard" option
- Or input parent ID if prompted

---

## 🧪 TEST SUITE 1: Single-Child Parents (p1-p7)

### Test 1.1: p1 - Abdullah Hassan
**Expected:** 1 child - Siti Mariah (s4)

**Steps:**
1. Login with parent ID: `p1`
2. Wait for dashboard to load
3. **VERIFY:**
   - [ ] Family Overview shows "1 child" OR "1 student"
   - [ ] Child name displays: "Siti Mariah"
   - [ ] Form level shows: "Form 4A" (NOT "Form 1C")
   - [ ] GPA displays: 3.9
   - [ ] No errors in console

**Actions:**
- [ ] Click on child card → should show details
- [ ] Click on notifications → should load
- [ ] Click on calendar → should show events

**Result:** ✅ PASS / ❌ FAIL

---

### Test 1.2: p2 - Encik Karim Ahmad
**Expected:** 1 child - Amir Abdullah (s1)

**Steps:**
1. Go back to login / re-login with: `p2`
2. Wait for dashboard to load
3. **VERIFY:**
   - [ ] Child name: "Amir Abdullah"
   - [ ] Form: "Form 4A"
   - [ ] GPA: 3.8
   - [ ] No errors

**Result:** ✅ PASS / ❌ FAIL

---

### Test 1.3: p3 - Puan Norhaida Mahmud
**Expected:** 1 child - Muhammad Azhar (s2)

**Steps:**
1. Login with: `p3`
2. **VERIFY:**
   - [ ] Child: "Muhammad Azhar"
   - [ ] Form: "Form 4B"
   - [ ] GPA: 3.7

**Result:** ✅ PASS / ❌ FAIL

---

### Test 1.4: p4 - Encik Lim Chen Hao
**Expected:** 1 child - Lim Wei Chen (s5)

**Steps:**
1. Login with: `p4`
2. **VERIFY:**
   - [ ] Child: "Lim Wei Chen"
   - [ ] Form: "Form 4B"
   - [ ] GPA: 3.6

**Result:** ✅ PASS / ❌ FAIL

---

### Test 1.5: p5 - Mr. Raj Nair Kumar (CRITICAL FIX TEST)
**Expected:** 1 child - Raj Kumar (s6) ← FIXED from s3

**Steps:**
1. Login with: `p5`
2. **VERIFY:**
   - [ ] Child: "Raj Kumar" (NOT "Nur Azlina")
   - [ ] Form: "Form 4A"
   - [ ] GPA: 3.1 (lowest in system)
   - [ ] If shows "Nur Azlina" → TEST FAILED, mapping not fixed

**🔴 CRITICAL:** This test verifies the p5 → s6 mapping fix

**Result:** ✅ PASS / ❌ FAIL (if still shows s3)

---

### Test 1.6: p6 - Encik Wong Tian Huat (NEW PARENT)
**Expected:** 1 child - Sophia Wong (s7)

**Steps:**
1. Login with: `p6`
2. **VERIFY:**
   - [ ] Child: "Sophia Wong"
   - [ ] Form: "Form 4B"
   - [ ] GPA: 3.2

**Result:** ✅ PASS / ❌ FAIL

---

### Test 1.7: p7 - Mr. Viswanathan Sharma (NEW PARENT)
**Expected:** 1 child - Priya Sharma (s8)

**Steps:**
1. Login with: `p7`
2. **VERIFY:**
   - [ ] Child: "Priya Sharma"
   - [ ] Form: "Form 4C"
   - [ ] GPA: 3.3

**Result:** ✅ PASS / ❌ FAIL

---

## 🌟 TEST SUITE 2: CRITICAL - Multi-Child Parent (p8)

### Test 2.1: p8 - Puan Siti Nur Azizah (2 CHILDREN) ⭐

**Expected:** 2 children
1. Nur Azlina (s3) - Form 4C, GPA 3.5
2. Nurul Izzah (s11) - Form 4C, GPA 4.0 ⭐ Perfect Score

**Steps:**
1. Login with: `p8`
2. Wait for dashboard to load
3. **VERIFY Family Overview:**
   - [ ] Shows "2 children" OR "2 students" (NOT 1)
   - [ ] Both child names visible:
     - [ ] "Nur Azlina"
     - [ ] "Nurul Izzah"
   - [ ] No errors in console

4. **VERIFY Child Details:**
   - [ ] Child 1 (Nur Azlina):
     - Form: "Form 4C" ✅
     - GPA: 3.5 ✅
   - [ ] Child 2 (Nurul Izzah):
     - Form: "Form 4C" ✅
     - GPA: 4.0 ✅ (Perfect score)

5. **VERIFY Child Selection:**
   - [ ] Can click to select Child 1 (Nur Azlina)
   - [ ] Can click to select Child 2 (Nurul Izzah)
   - [ ] Can switch between them smoothly

6. **VERIFY Calendar for p8:**
   - [ ] Go to Calendar page
   - [ ] Should show events for BOTH children
   - [ ] Total should be ~30+ events
   - [ ] No filtering issues

7. **VERIFY Notifications for p8:**
   - [ ] Go to Notifications
   - [ ] Should show notifications for BOTH children
   - [ ] No missing notifications

**🔴 CRITICAL TEST POINTS:**
- ❌ FAIL if only 1 child shows
- ❌ FAIL if wrong child shows (e.g., only s3 or only s11)
- ❌ FAIL if form levels wrong (should be Form 4C, not Form 1-2)
- ❌ FAIL if can't select both children
- ❌ FAIL if calendar doesn't show events for both
- ✅ PASS if both children display with correct data

**Result:** ✅ PASS / ❌ FAIL

---

## 🧪 TEST SUITE 3: Remaining Single-Child Parents (p9-p11)

### Test 3.1: p9 - Encik Ooi Seng Keat (NEW PARENT)
**Expected:** 1 child - Davina Ooi (s12)

**Steps:**
1. Login with: `p9`
2. **VERIFY:**
   - [ ] Child: "Davina Ooi"
   - [ ] Form: "Form 4A"
   - [ ] GPA: 3.9

**Result:** ✅ PASS / ❌ FAIL

---

### Test 3.2: p10 - Encik Tan Cheng Huat (NEW PARENT)
**Expected:** 1 child - Tan Jun Wei (s10)

**Steps:**
1. Login with: `p10`
2. **VERIFY:**
   - [ ] Child: "Tan Jun Wei"
   - [ ] Form: "Form 4B"
   - [ ] GPA: 3.8

**Result:** ✅ PASS / ❌ FAIL

---

### Test 3.3: p11 - Encik Rashid Abdullah (NEW PARENT)
**Expected:** 1 child - Adnan Hassan (s9)

**Steps:**
1. Login with: `p11`
2. **VERIFY:**
   - [ ] Child: "Adnan Hassan"
   - [ ] Form: "Form 4A"
   - [ ] GPA: 3.4

**Result:** ✅ PASS / ❌ FAIL

---

## 🔍 TEST SUITE 3: UI Feature Tests

### Test 4.1: Form Levels (All Parents)
**Purpose:** Verify NO Form 1-2 data appears

**Steps:**
1. For each parent (p1-p11):
   - [ ] Check child form level
   - [ ] Should see "Form 4A", "Form 4B", or "Form 4C"
   - [ ] Should NEVER see "Form 1A", "Form 1C", "Form 2B", "Form 2D"

**Result:** ✅ PASS (all Form 4) / ❌ FAIL (any Form 1-2)

---

### Test 4.2: Parent Profile Page
**Purpose:** Verify parent data loads in profile page

**Steps:**
1. Select any parent (e.g., p1)
2. Go to "Profile" or "Settings" page
3. **VERIFY displays:**
   - [ ] Parent name (e.g., "Abdullah Hassan")
   - [ ] Email (e.g., "abdullah.hassan@email.com")
   - [ ] Phone (e.g., "+60 12-345 6789")
   - [ ] Address (e.g., "123 Jalan Merdeka, ...")
   - [ ] Occupation (e.g., "Software Engineer")
   - [ ] Emergency contact info

**Result:** ✅ PASS / ❌ FAIL

---

### Test 4.3: Calendar Events
**Purpose:** Verify 30+ events display correctly

**Steps:**
1. Select any parent
2. Go to Calendar page
3. **VERIFY:**
   - [ ] Month view displays correctly
   - [ ] Can navigate between months
   - [ ] Events display with colors/icons
   - [ ] Can click on event to see details
   - [ ] ~30+ events total

**Result:** ✅ PASS / ❌ FAIL

---

### Test 4.4: Notifications
**Purpose:** Verify notifications load without errors

**Steps:**
1. Select any parent
2. Go to Notifications page
3. **VERIFY:**
   - [ ] Notifications load (not empty)
   - [ ] Can mark as read
   - [ ] No error messages
   - [ ] Pagination works if present

**Result:** ✅ PASS / ❌ FAIL

---

## 📊 SUMMARY CHECKLIST

### Overall Test Results

**Single-Child Parents (p1-p7, p9-p11):**
- [ ] p1: ✅ PASS / ❌ FAIL
- [ ] p2: ✅ PASS / ❌ FAIL
- [ ] p3: ✅ PASS / ❌ FAIL
- [ ] p4: ✅ PASS / ❌ FAIL
- [ ] p5: ✅ PASS / ❌ FAIL (CRITICAL: p5 → s6 fix)
- [ ] p6: ✅ PASS / ❌ FAIL
- [ ] p7: ✅ PASS / ❌ FAIL
- [ ] p9: ✅ PASS / ❌ FAIL
- [ ] p10: ✅ PASS / ❌ FAIL
- [ ] p11: ✅ PASS / ❌ FAIL

**🌟 Multi-Child Parent:**
- [ ] p8 (2 children): ✅ PASS / ❌ FAIL (CRITICAL TEST)

**UI Features:**
- [ ] Form levels: ✅ PASS / ❌ FAIL
- [ ] Parent profile: ✅ PASS / ❌ FAIL
- [ ] Calendar: ✅ PASS / ❌ FAIL
- [ ] Notifications: ✅ PASS / ❌ FAIL

### Overall Status

**Total Tests:** 14  
**Passed:** ___ / 14  
**Failed:** ___ / 14  
**Critical Tests (p5, p8):** ___ / 2

**Overall Result:** ✅ ALL PASS / ❌ SOME FAIL / ⚠️ PARTIAL PASS

---

## 📝 Issues Found

If any test fails, document here:

**Issue #1:**
- Test: [Which test]
- Expected: [What should happen]
- Actual: [What happened]
- Severity: ❌ CRITICAL / 🟡 HIGH / 🟢 LOW
- Steps to Reproduce: [How to reproduce]
- Suggested Fix: [Possible solution]

**Issue #2:**
[Same format]

---

## ✅ Sign-Off

**Tested By:** [Your name]  
**Date:** [Test date]  
**Device:** [Device/Emulator used]  
**Dart Version:** [Run `dart --version`]  
**Flutter Version:** [Run `flutter --version`]

**All Critical Tests Passed:** ✅ YES / ❌ NO  
**Ready for Next Phase:** ✅ YES / ❌ NO

**Notes:**
[Any additional observations]

---

## 🚀 Next Steps After Testing

If ✅ ALL TESTS PASS:
1. Commit changes to Git
2. Create pull request to main branch
3. Start Teacher Module implementation

If ❌ SOME TESTS FAIL:
1. Document issues (use template above)
2. Provide issue details to development team
3. Fix issues in order of severity
4. Re-test until all pass

---

**Good luck with testing!** 🎯

