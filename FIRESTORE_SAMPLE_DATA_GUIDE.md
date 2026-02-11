# Firestore Sample Data Setup Guide

This guide will help you populate your Firestore database with sample data for testing the StudyCompanion app.

## Quick Navigation
1. [Collection: announcements](#1-collection-announcements)
2. [Collection: notifications](#2-collection-notifications)

---

## How to Add Data to Firestore

### Step-by-Step Instructions:
1. Open **Firebase Console** (https://console.firebase.google.com)
2. Select your **StudyCompanion** project
3. Go to **Firestore Database** from the left menu
4. Click **"Start collection"** or select existing collection
5. For each document below:
   - Click **"Add document"**
   - Enter the **Document ID** (the `id` field value)
   - Add each field with the correct **field type**
   - Click **"Save"**

### Field Types Reference:
- **string** - Text data
- **number** - Numeric values
- **boolean** - true/false values
- **timestamp** - Date and time (click clock icon to set)
- **map** - Nested object data
- **array** - List of values

---

## 1. Collection: `announcements`

This collection stores school announcements visible to all users.

### Document 1: `ann_1`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_1` |
| title | string | `School Sports Day - February 15, 2026` |
| message | string | `Annual Sports Day will be held on February 15, 2026 at the school field. All students are required to participate in at least one event. Please register your participation with your Form Teacher by February 10.` |
| createdBy | string | `Cikgu Farah` |
| date | timestamp | `February 9, 2026 10:00:00 AM` |
| isPublished | boolean | `true` |

### Document 2: `ann_2`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_2` |
| title | string | `Mid-Year Examination Schedule Released` |
| message | string | `The Mid-Year Examination schedule for Form 1-3 has been released. Examinations will begin on March 1, 2026 and end on March 20, 2026. Detailed timetable is available at the school notice board and on the school portal.` |
| createdBy | string | `Admin` |
| date | timestamp | `February 10, 2026 9:00:00 AM` |
| isPublished | boolean | `true` |

### Document 3: `ann_3`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_3` |
| title | string | `Parent-Teacher Meeting - February 20, 2026` |
| message | string | `Annual Parent-Teacher Meeting will be held on February 20, 2026 from 2:00 PM to 5:00 PM. Parents are encouraged to meet with subject teachers to discuss their child's academic progress.` |
| createdBy | string | `Admin` |
| date | timestamp | `February 11, 2026 8:00:00 AM` |
| isPublished | boolean | `true` |

### Document 4: `ann_4`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_4` |
| title | string | `New Science Lab Equipment Available` |
| message | string | `The Science Department is pleased to announce the arrival of new laboratory equipment. All students will have the opportunity to use these equipment in their practical classes starting from next week.` |
| createdBy | string | `Cikgu Ravi` |
| date | timestamp | `February 8, 2026 3:00:00 PM` |
| isPublished | boolean | `true` |

### Document 5: `ann_5`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_5` |
| title | string | `Debate Club Registration Open` |
| message | string | `Calling all interested students! Debate Club is now open for registration. Weekly meetings every Thursday at 3:30 PM in the Academic Block. No prior experience required. Come join us!` |
| createdBy | string | `Cikgu Suhana` |
| date | timestamp | `February 6, 2026 2:00:00 PM` |
| isPublished | boolean | `true` |

### Document 6: `ann_6`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_6` |
| title | string | `Mathematics Competition - Registration Closes February 12` |
| message | string | `The National Mathematics Competition for secondary students is open for registration. Registration closes on February 12, 2026. Interested students should submit their names to Cikgu Ahmad immediately.` |
| createdBy | string | `Cikgu Ahmad` |
| date | timestamp | `February 7, 2026 11:00:00 AM` |
| isPublished | boolean | `true` |

### Document 7: `ann_7`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_7` |
| title | string | `Library Extended Hours During Examination Period` |
| message | string | `During the examination period (March 1-20), the library will be open until 6:00 PM on weekdays to support student revision. Weekend hours remain unchanged.` |
| createdBy | string | `Admin` |
| date | timestamp | `February 5, 2026 10:00:00 AM` |
| isPublished | boolean | `true` |

### Document 8: `ann_8`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `ann_8` |
| title | string | `English Language Club - Story Telling Competition` |
| message | string | `English Language Club is organizing a Story Telling Competition for all Form 1-3 students. Cash prizes worth RM500 for winners. Preliminary round on February 28, 2026.` |
| createdBy | string | `Cikgu Suhana` |
| date | timestamp | `February 4, 2026 1:00:00 PM` |
| isPublished | boolean | `true` |

---

## 2. Collection: `notifications`

This collection stores notifications for students and parents.

### Student Notifications

#### Document 1: `notif_1`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_1` |
| title | string | `Task Reminder: Algebra Worksheet` |
| body | string | `Your task "Algebra Worksheet" for Mathematics is due today. Make sure to submit it before 5:00 PM.` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `task` |
| relatedEntityId | string | `task_1` |
| createdAt | timestamp | `February 11, 2026 9:00:00 AM` |
| isRead | boolean | `false` |

#### Document 2: `notif_2`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_2` |
| title | string | `Task Due Tomorrow: Chapter 4 Reading` |
| body | string | `English: Chapter 4 Reading assignment is due tomorrow. Please complete your reading and prepare answers to discussion questions.` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `task` |
| relatedEntityId | string | `task_2` |
| createdAt | timestamp | `February 11, 2026 7:00:00 AM` |
| isRead | boolean | `true` |

#### Document 3: `notif_3`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_3` |
| title | string | `Task Overdue: History Essay Outline` |
| body | string | `Your task "History Essay Outline" was due yesterday. Please contact Cikgu Mei Ling for extension request.` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `task` |
| relatedEntityId | string | `task_4` |
| createdAt | timestamp | `February 10, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

#### Document 4: `notif_4`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_4` |
| title | string | `Achievement Unlocked! 🏆` |
| body | string | `Congratulations! You have completed 5 tasks. Achievement: "Task Master" unlocked!` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `achievement` |
| relatedEntityId | string | `achievement_1` |
| createdAt | timestamp | `February 9, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

#### Document 5: `notif_5`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_5` |
| title | string | `Achievement Unlocked! 🌟` |
| body | string | `Amazing! You have achieved 80% progress. Achievement: "Star Student" unlocked!` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `achievement` |
| relatedEntityId | string | `achievement_2` |
| createdAt | timestamp | `February 8, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

#### Document 6: `notif_6`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_6` |
| title | string | `New Announcement: School Sports Day` |
| body | string | `New announcement published: School Sports Day - February 15, 2026. All students must participate in at least one event.` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `announcement` |
| relatedEntityId | string | `ann_1` |
| createdAt | timestamp | `February 9, 2026 5:00:00 AM` |
| isRead | boolean | `false` |

#### Document 7: `notif_7`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_7` |
| title | string | `Exam Schedule Alert` |
| body | string | `Mid-Year Examinations will start in 24 days. Make sure you are well-prepared. Timetable: March 1-20, 2026.` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `alert` |
| relatedEntityId | string | `exam_1` |
| createdAt | timestamp | `February 7, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

#### Document 8: `notif_8`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_8` |
| title | string | `Class Cancellation: PE Class Today` |
| body | string | `Alert: Physical Education class has been cancelled today (Feb 5) due to weather. Class will resume tomorrow as scheduled.` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `alert` |
| relatedEntityId | string | `alert_1` |
| createdAt | timestamp | `February 10, 2026 4:00:00 AM` |
| isRead | boolean | `false` |

#### Document 9: `notif_9`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_9` |
| title | string | `Task Assigned: Science Lab Report` |
| body | string | `New task assigned in Science: Submit your lab report for the Photosynthesis experiment. Due: February 18, 2026.` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `task` |
| relatedEntityId | string | `task_5` |
| createdAt | timestamp | `February 6, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

#### Document 10: `notif_10`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `notif_10` |
| title | string | `Perfect Score! 💯` |
| body | string | `Excellent work! You scored 100% on the Mathematics quiz. Keep up the great work!` |
| studentId | string | `s1` *(replace with your actual student ID)* |
| notificationType | string | `achievement` |
| relatedEntityId | string | `achievement_3` |
| createdAt | timestamp | `February 5, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

---

### Parent Notifications

#### Document 11: `parent_notif_1`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `parent_notif_1` |
| title | string | `Child's Progress: 70% Task Completion` |
| body | string | `Your child Nurul Izzah has completed 70% of assigned tasks. Great progress!` |
| parentId | string | `p1` *(replace with your actual parent ID)* |
| notificationType | string | `alert` |
| createdAt | timestamp | `February 11, 2026 5:00:00 AM` |
| isRead | boolean | `false` |

**Note:** Leave `studentId` and `relatedEntityId` fields empty for parent notifications

#### Document 12: `parent_notif_2`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `parent_notif_2` |
| title | string | `Achievement: Nurul Izzah - Task Master` |
| body | string | `Your child has unlocked the "Task Master" achievement. She has completed 5 tasks successfully!` |
| parentId | string | `p1` *(replace with your actual parent ID)* |
| notificationType | string | `achievement` |
| createdAt | timestamp | `February 10, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

#### Document 13: `parent_notif_3`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `parent_notif_3` |
| title | string | `Parent-Teacher Meeting Reminder` |
| body | string | `Reminder: Parent-Teacher Meeting scheduled for February 20, 2026 from 2:00 PM to 5:00 PM.` |
| parentId | string | `p1` *(replace with your actual parent ID)* |
| notificationType | string | `announcement` |
| createdAt | timestamp | `February 9, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

#### Document 14: `parent_notif_4`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `parent_notif_4` |
| title | string | `Important: Overdue Task Alert` |
| body | string | `Your child has an overdue task: History Essay Outline (due yesterday). Please follow up with the teacher.` |
| parentId | string | `p1` *(replace with your actual parent ID)* |
| notificationType | string | `alert` |
| createdAt | timestamp | `February 10, 2026 10:00:00 AM` |
| isRead | boolean | `false` |

#### Document 15: `parent_notif_5`

| Field Name | Type | Value |
|-----------|------|-------|
| id | string | `parent_notif_5` |
| title | string | `School Announcement: Examination Schedule` |
| body | string | `Mid-Year examinations schedule has been released. Examinations: March 1-20, 2026.` |
| parentId | string | `p1` *(replace with your actual parent ID)* |
| notificationType | string | `announcement` |
| createdAt | timestamp | `February 9, 2026 10:00:00 AM` |
| isRead | boolean | `true` |

---

## Important Notes

### 1. Replace User IDs
- Replace `s1` with your actual **student ID** from your users/students collection
- Replace `p1` with your actual **parent ID** from your users/parents collection

### 2. Timestamp Format in Firebase Console
When adding timestamps in Firebase Console:
1. Click the **field type dropdown** → Select **timestamp**
2. Click the **calendar/clock icon**
3. Enter the date and time as shown in the guide
4. Times are approximate - adjust as needed for your testing

### 3. Composite Index Required
For notifications to work properly, you need a composite index:
- **Collection:** `notifications`
- **Fields indexed:**
  - `parentId` (Ascending)
  - `createdAt` (Descending)

You should have already created this index. If not, Firebase will prompt you when you first query notifications.

### 4. Optional Fields
Some fields are optional and can be left empty:
- `relatedEntityId` - Only needed for some notification types
- `studentId` - Not used in parent notifications
- `parentId` - Not used in student notifications

### 5. Disable Sample Data After Populating Firestore
Once you've added the data to Firestore, set the sample data flags to `false`:

**In [announcement_service.dart](lib/services/announcement_service.dart):**
```dart
static bool useSampleData = false;
```

**In [notification_service.dart](lib/services/notification_service.dart):**
```dart
static bool useSampleData = false;
```

Then hot reload (`r`) or hot restart (`R`) your app.

---

## Summary

You now have:
- ✅ **8 announcements** in the `announcements` collection
- ✅ **15 notifications** (10 student + 5 parent) in the `notifications` collection

This sample data will help you test all the features of the StudyCompanion app including:
- Announcement display and filtering
- Notification badges and counts
- Unread/read status
- Different notification types (task, achievement, alert, announcement)
- Student and parent notification streams

---

## Quick Start Checklist

- [ ] Create `announcements` collection
- [ ] Add all 8 announcement documents
- [ ] Create `notifications` collection  
- [ ] Add all 15 notification documents
- [ ] Replace `s1` and `p1` with actual user IDs
- [ ] Verify composite index exists for notifications
- [ ] Set `useSampleData = false` in both service files
- [ ] Hot reload the app
- [ ] Test notifications and announcements

---

**Need Help?** If you encounter any errors or need clarification, let me know!
