# Admin Role Setup - Complete Guide

## 🎯 What Was Fixed

### **Problem**: Admin and Insurance were treated as the same role
- Admins were stored as `role: 'provider'` with metadata
- Insurance companies (ISPs) also stored as `role: 'provider'`
- Complex metadata parsing needed to distinguish them

### **Solution**: Three distinct roles
- `role: 'driver'` - Regular drivers
- `role: 'provider'` - Insurance companies (ISPs)
- `role: 'admin'` - App developers/owners ✅ NEW!

---

## 📝 Changes Made

### 1. **Backend (auth_user.py)**
- ✅ Added `'admin'` to valid roles (line 398)
- ✅ Added admin-specific field handling (lines 457-476)
- ✅ Stores admins with `role: 'admin'` directly (not in metadata)

### 2. **Frontend (login_page.dart)**
- ✅ Fixed role mapping: admin → 'admin' (not 'provider')
- ✅ Simplified login routing: direct role check (no metadata parsing)
- ✅ Lines 195-200: Proper role mapping
- ✅ Lines 463-475: Clean navigation logic

### 3. **Routing (main.dart)**
- ✅ Changed home from `AdminHomePage` to `LoginPageWidget`
- ✅ App now starts at login page for all users

### 4. **Super Admin Creation**
- ✅ Created `create_super_admin.py` script
- ✅ Safely inserts first admin into DynamoDB

---

## 🚀 How to Create the Super Admin

### **Step 1: Ensure AWS Credentials**
Make sure your AWS credentials are configured:
```bash
aws configure
# Or set environment variables:
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-west-1
```

### **Step 2: Run the Script**
```bash
cd /Users/nealmann/Documents/Neal/No_Track_Drive/Backend_Integrated_No_Track_Drive

python3 create_super_admin.py
```

### **Step 3: Follow the Prompts**
The script will ask you:
1. **Email**: Default is `admin@driveguard.com` (press Enter to use)
2. **Name**: Default is "Super Admin"
3. **Password**: Generate random secure password (recommended) or enter your own

**Example output:**
```
🚀 DRIVEGUARD SUPER ADMIN CREATION
==============================================================

📧 Enter super admin email (default: admin@driveguard.com): [press Enter]
👤 Enter super admin name (default: Super Admin): [press Enter]

🔐 Generate secure random password? (Y/n): Y

✅ Generated temporary password: xK9#mP2@vL5$nQ8!

⚠️  IMPORTANT: Save this password! You'll need to change it on first login.

📋 Creating admin account:
   Email: admin@driveguard.com
   Name: Super Admin
   Role: admin

✅ Create this admin account? (Y/n): Y

🔒 Hashing password...
💾 Inserting into DynamoDB (Users-Neal table)...
✅ Super admin created successfully!

==============================================================
🎉 SETUP COMPLETE
==============================================================

📧 Email: admin@driveguard.com
🔑 Temporary Password: xK9#mP2@vL5$nQ8!

⚠️  IMPORTANT:
   1. Save the password above - you'll need it to login
   2. You'll be prompted to change it on first login
   3. After logging in, you can create more admin accounts

🚀 You can now login to the app with these credentials!
==============================================================
```

### **Step 4: Save Your Credentials**
**IMPORTANT**: Copy the password shown and save it somewhere safe!

---

## 🧪 Testing the Flow

### **Test 1: App Starts at Login**
1. Run your Flutter app
2. ✅ Should see LoginPageWidget (not AdminHomePage)

### **Test 2: Admin Login**
1. Enter the super admin email (e.g., `admin@driveguard.com`)
2. Enter the temporary password from the script
3. ✅ Should route to AdminHomePage

### **Test 3: Create More Admins**
1. On AdminHomePage, go to "Create Account"
2. Select "Admin" role
3. Fill in:
   - Email
   - Password
   - First Name / Last Name
   - Admin ID (e.g., ADMIN-002)
   - Server Number (e.g., SERVER-001)
4. ✅ New admin should be created with `role: 'admin'`

### **Test 4: Create Insurance Account**
1. On AdminHomePage, go to "Create Account"
2. Select "Insurance" role
3. Fill in:
   - Email
   - Password
   - Company Name
   - State
4. ✅ ISP should be created with `role: 'provider'`

### **Test 5: ISP Login**
1. Go to LoginPageWidget
2. Enter ISP email and password
3. ✅ Should route to InsuranceHomePage (not AdminHomePage)

---

## 📊 Database Schema

### **Admin User Structure**
```json
{
  "user_id": "admin-001",
  "email": "admin@driveguard.com",
  "password_hash": "<hashed>",
  "role": "admin",
  "name": "Super Admin",
  "created_at": "2024-01-31T10:00:00",
  "last_login": "2024-01-31T10:00:00",
  "account_status": "active",
  "metadata": {
    "admin_id": "ADMIN-001",
    "server_number": "SERVER-001",
    "permissions": "super",
    "first_login": true
  }
}
```

### **Insurance Provider Structure**
```json
{
  "user_id": "isp-123",
  "email": "contact@statefarm.com",
  "password_hash": "<hashed>",
  "role": "provider",
  "name": "State Farm Insurance",
  "created_at": "2024-01-31T10:00:00",
  "account_status": "active",
  "metadata": {
    "state": "CA",
    "original_role": "insurance"
  }
}
```

### **Driver Structure**
```json
{
  "user_id": "driver-456",
  "email": "john@example.com",
  "password_hash": "<hashed>",
  "role": "driver",
  "name": "John Doe",
  "zipcode": "10001",
  "base_point": {
    "latitude": 40.7589,
    "longitude": -73.9851,
    "city": "New York",
    "state": "NY"
  },
  "created_at": "2024-01-31T10:00:00",
  "account_status": "active"
}
```

---

## 🔐 Security Notes

### **Password Security**
- All passwords are hashed using PBKDF2-HMAC-SHA256
- 100,000 iterations for strong key derivation
- Unique salt per password
- Never stored in plain text

### **Admin Access Control**
- Only admins can create other admin accounts
- ISPs cannot create accounts (admins create them)
- Drivers self-register through LoginPageWidget

### **First Login**
- `metadata.first_login: true` flag set for new admin accounts
- (TODO) Prompt password change on first login

---

## 🛠️ Troubleshooting

### **Script fails with "Unable to locate credentials"**
**Solution**: Configure AWS credentials
```bash
aws configure
```

### **Script fails with "ResourceNotFoundException"**
**Solution**: Ensure you're using the correct AWS region (us-west-1)
```bash
export AWS_DEFAULT_REGION=us-west-1
```

### **Admin created but can't login**
**Check**:
1. Verify email is correct (case-insensitive)
2. Password copied exactly (no extra spaces)
3. Backend Lambda (auth_user.py) deployed with latest changes
4. Frontend rebuilt with latest changes

### **Login routes to wrong page**
**Check**:
1. Backend returns `role: 'admin'` (not 'provider')
2. Frontend login_page.dart has updated routing logic
3. Check browser/app console for role detection logs

---

## ✅ Deployment Checklist

Before deploying to production:

- [ ] Run `create_super_admin.py` to create first admin
- [ ] Save super admin credentials securely
- [ ] Deploy updated `auth_user.py` Lambda function
- [ ] Build and deploy updated Flutter app
- [ ] Test admin login flow
- [ ] Test ISP creation by admin
- [ ] Test driver self-registration
- [ ] (Optional) Implement first-login password change prompt
- [ ] (Optional) Set up email verification for ISPs

---

## 📞 Support

If you encounter any issues:
1. Check CloudWatch logs for Lambda errors
2. Check browser console for frontend errors
3. Verify DynamoDB Users-Neal table structure
4. Ensure all code changes deployed

---

**Created**: January 31, 2026
**Version**: 5.0 (Admin Role Separation)
