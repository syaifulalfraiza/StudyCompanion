# Teacher Login Guide

## 🎓 Teacher Module Login Instructions

### Demo Mode (Sample Data)

The Teacher Module supports **Demo Mode** for testing without Firebase setup.

#### How to Login:

1. **Launch the app** and navigate to the Login screen
2. **Enable Demo Mode**: Check the ☑️ "Use Demo Mode (Sample Data)" checkbox
3. **Select Role**: Choose "Teacher" from the role dropdown
4. **Enter credentials**:
   - Email: Use any teacher email from the list below
   - Password: Enter any password (minimum 3 characters)
5. **Click "Sign In"**

#### Available Teacher Accounts:

| Email | Name | Subject | ID |
|-------|------|---------|-----|
| `ahmad@school.edu.my` | Cikgu Ahmad | Mathematics | t1 |
| `suhana@school.edu.my` | Cikgu Suhana | English | t2 |
| `ravi@school.edu.my` | Cikgu Ravi | Science | t3 |
| `meiling@school.edu.my` | Cikgu Mei Ling | History | t4 |
| `farah@school.edu.my` | Cikgu Farah | Bahasa Melayu | t5 |
| `zainul@school.edu.my` | Cikgu Zainul | Islamic Studies | t6 |

**Password for all demo accounts:** `password123`

#### Example Login:

```
Role: Teacher
Email: farah@school.edu.my
Password: password123
☑️ Use Demo Mode (Sample Data)
```

**Recommended for testing:** Use `farah@school.edu.my` (Cikgu Farah) as it has the most complete sample data.

---

## 🔐 Firebase Authentication (Production)

For production use with real Firebase backend:

1. **Disable Demo Mode**: Uncheck the demo mode checkbox
2. **Select Role**: Choose "Teacher"
3. **Enter real credentials**:
   - Email: Teacher's Firebase Auth email
   - Password: Teacher's Firebase Auth password
4. **Click "Sign In"**

The system will:
- Authenticate via Firebase Auth
- Fetch user data from Firestore `users` collection
- Verify the role matches "teacher"
- Navigate to Teacher Dashboard

---

## 🎯 Teacher Module Features

Once logged in, teachers can:

### ✅ 1. View Dashboard
- Class count, assignment count
- Pending submissions, overdue assignments
- Recent assignments with progress

### ✅ 2. Manage Tasks (Assignments)
- Create new assignments
- View all assignments with filters (All, Active, Overdue, Due Soon)
- Edit assignment details
- View student progress

### ✅ 3. Manage Announcements
- Create announcements (published or draft)
- Edit/update announcements
- Delete announcements
- Filter by status (All, Published, Draft)

### ✅ 4. View Student Progress
- See all students in a class
- View submission status (submitted/not submitted)
- **Record grades** inline (percentage + feedback)
- **View existing grades** with color-coded indicators
- Update grades as needed
- Track class averages

---

## 🧪 Testing Workflow

**Recommended testing sequence:**

1. **Login** as `farah@school.edu.my` / `password123` with demo mode
2. **Dashboard** - View summary statistics
3. **Tasks Tab**:
   - Click an assignment → "View Student Progress"
   - Record grades for students
   - See submission percentages
4. **Announcements Tab**:
   - Create a new announcement
   - Toggle published/draft status
   - Edit/delete announcements
5. **Quick Actions** - Test navigation shortcuts

---

## 📋 Sample Data Details

**Teachers:** 6 teachers (ahmad@, suhana@, ravi@, meiling@, farah@, zainul@ @school.edu.my)
**Classes:** 8 classes across different subjects
**Assignments:** 7 assignments with varying due dates
**Students:** 30 students per class with Malaysian names
**Grades:** Pre-loaded sample grades (can add/update via UI)
**Announcements:** 4 announcements (3 published, 1 draft) per teacher

---

## ⚠️ Known Limitations

- Sample data is **in-memory only** (resets on app restart)
- Changes made in demo mode are **not persisted**
- For production persistence, use Firebase backend
- Student/Parent roles not available in demo mode (only Teacher)

---

## 🔧 Troubleshooting

**Issue:** Login fails with demo mode
- **Solution:** Ensure you checked "Use Demo Mode" checkbox

**Issue:** Can't see any data after login
- **Solution:** Wait 0.5 seconds for data to load (simulated network delay)

**Issue:** Wrong teacher data displayed
- **Solution:** The teacher ID is stored in UserSession from login email

**Issue:** Changes disappear after restart
- **Solution:** Demo mode uses in-memory data. Use Firebase for persistence.

---

## 🚀 Next Steps

After testing the Teacher Module:

1. **Integrate Firebase** - Set up Firebase Auth and Firestore for production
2. **Add real student data** - Import actual student records
3. **Enable Firebase storage** - For assignment file uploads
4. **Configure notifications** - Push notifications for announcements
5. **Add analytics** - Track usage patterns

---

## 📞 Support

For issues or questions:
- Check the main [PROJECT_STATUS_AND_PENDING_WORK.md](PROJECT_STATUS_AND_PENDING_WORK.md)
- Review [TESTING_AND_VALIDATION.md](TESTING_AND_VALIDATION.md)

**Teacher Module Status:** ✅ **COMPLETE** (All 4 use cases implemented)
