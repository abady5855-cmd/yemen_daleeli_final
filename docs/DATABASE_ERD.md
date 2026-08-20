# مخطط علاقات الكيانات (ERD) لقاعدة بيانات Firestore

## 📋 ملخص تنفيذي

يوضح هذا المستند مخطط علاقات الكيانات (Entity Relationship Diagram - ERD) لقاعدة بيانات Firestore لمشروع "يمن دليلي"، مع تحديد جميع المجموعات (Collections)، العلاقات بينها، والفهارس المقترحة لتحسين الأداء.

---

## 🗂️ المجموعات الرئيسية

### 1. مجموعة المستخدمين (users)

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `email` - Unique, Indexed
- `displayName`
- `role` - Indexed (Guest, User, BusinessOwner, Moderator, Admin, SuperAdmin)
- `governorate` (UUID) - Indexed
- `district` (UUID) - Indexed
- `isActive`, `isEmailVerified`, `isPhoneVerified`
- Audit Fields: `createdAt`, `updatedAt`, `deletedAt`, `createdBy`, `updatedBy`, `deletedBy`, `isDeleted`, `version`

**Subcollections:**
- `favorites` - الخدمات المفضلة
- `notifications` - الإشعارات
- `businessOwners` - بيانات صاحب العمل

---

### 2. مجموعة المحافظات (governorates)

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `name_ar`, `name_en` - Indexed
- `code` - Unique
- `description_ar`, `description_en`
- `location` (GeoPoint)
- `status` - Indexed
- Audit Fields

**Subcollections:**
- `districts` - المديريات التابعة

---

### 3. مجموعة المديريات (districts) - Subcollection تحت governorates

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `name_ar`, `name_en` - Indexed
- `code` - Unique
- `governorateId` (UUID) - Indexed
- `location` (GeoPoint)
- `status` - Indexed
- Audit Fields

**Subcollections:**
- `subDistricts` - العزل التابعة

---

### 4. مجموعة العزل (subDistricts) - Subcollection تحت districts

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `name_ar`, `name_en` - Indexed
- `code` - Unique
- `districtId` (UUID) - Indexed
- `governorateId` (UUID) - Indexed
- `location` (GeoPoint)
- `status` - Indexed
- Audit Fields

---

### 5. مجموعة التصنيفات (categories)

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `name_ar`, `name_en` - Indexed
- `description_ar`, `description_en`
- `icon`, `color`
- `serviceCount` - يتم تحديثه بواسطة Cloud Functions
- `status` - Indexed
- Audit Fields

---

### 6. مجموعة الخدمات (services)

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `name_ar`, `name_en` - Indexed
- `description_ar`, `description_en`
- `categoryId` (UUID) - Indexed
- `ownerId` (UUID) - Indexed
- `governorateId` (UUID) - Indexed
- `districtId` (UUID) - Indexed
- `subDistrictId` (UUID)
- `address_ar`, `address_en`
- `location` (GeoPoint) - Indexed
- `phone`, `whatsapp`, `email`, `website`
- `rating` - Indexed
- `reviewCount`, `favoriteCount`
- `galleryImages` (Array)
- `workingHours` (Map)
- `tags` (Array)
- `status` - Indexed (Active, Pending, Hidden, Closed)
- `verified` - Indexed
- `featured` - Indexed
- Audit Fields

**Subcollections:**
- `reviews` - التقييمات والتعليقات

---

### 7. مجموعة التقييمات (reviews) - Subcollection تحت services

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `userId` (UUID) - Indexed
- `serviceId` (UUID) - Indexed
- `rating` (1-5) - Indexed
- `comment`
- `images` (Array)
- `helpful` (Integer)
- `status` - Indexed
- Audit Fields

---

### 8. مجموعة المفضلات (favorites) - Subcollection تحت users

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `userId` (UUID) - Indexed
- `serviceId` (UUID) - Indexed
- `addedAt` (Timestamp) - Indexed
- Audit Fields

---

### 9. مجموعة الإشعارات (notifications) - Subcollection تحت users

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `userId` (UUID) - Indexed
- `title_ar`, `title_en`
- `body_ar`, `body_en`
- `type` - Indexed (Service, Review, Message, etc.)
- `relatedId` (UUID) - معرف الكيان المرتبط
- `read` - Indexed
- `readAt` (Timestamp)
- Audit Fields

---

### 10. مجموعة الإعلانات (advertisements)

**الحقول الأساسية:**
- `id` (UUID) - Primary Key
- `title_ar`, `title_en`
- `description_ar`, `description_en`
- `image`
- `targetUrl`
- `isActive` - Indexed
- `startDate` - Indexed
- `endDate` - Indexed
- Audit Fields

---

## 🔍 الفهارس المقترحة (Recommended Indexes)

لتحسين أداء الاستعلامات، يتم اقتراح الفهارس التالية:

### فهارس بسيطة (Single Field Indexes)

| المجموعة | الحقل | الأولوية |
|---------|------|---------|
| `users` | `email` | عالية جداً |
| `users` | `role` | عالية |
| `users` | `governorate` | عالية |
| `users` | `isActive` | متوسطة |
| `governorates` | `name_ar` | متوسطة |
| `governorates` | `status` | متوسطة |
| `districts` | `name_ar` | متوسطة |
| `districts` | `governorateId` | عالية |
| `subDistricts` | `districtId` | عالية |
| `categories` | `name_ar` | متوسطة |
| `categories` | `status` | متوسطة |
| `services` | `name_ar` | عالية |
| `services` | `categoryId` | عالية جداً |
| `services` | `ownerId` | عالية |
| `services` | `governorateId` | عالية |
| `services` | `districtId` | عالية |
| `services` | `rating` | عالية |
| `services` | `status` | عالية |
| `services` | `verified` | عالية |
| `services` | `featured` | عالية |
| `reviews` | `userId` | عالية |
| `reviews` | `serviceId` | عالية |
| `reviews` | `rating` | متوسطة |
| `advertisements` | `isActive` | عالية |
| `advertisements` | `startDate` | متوسطة |

### فهارس مركبة (Composite Indexes)

| المجموعة | الحقول | الغرض | الأولوية |
|---------|--------|-------|---------|
| `services` | `categoryId`, `status` | البحث عن خدمات نشطة في تصنيف معين | عالية جداً |
| `services` | `governorateId`, `status` | البحث عن خدمات نشطة في محافظة معينة | عالية جداً |
| `services` | `districtId`, `status` | البحث عن خدمات نشطة في مديرية معينة | عالية |
| `services` | `categoryId`, `governorateId`, `status` | البحث عن خدمات نشطة في تصنيف ومحافظة معينة | عالية |
| `services` | `status`, `verified`, `featured` | البحث عن خدمات مميزة موثقة | متوسطة |
| `reviews` | `serviceId`, `rating` | الحصول على تقييمات خدمة معينة مرتبة حسب التقييم | متوسطة |
| `users` | `governorate`, `role` | البحث عن مستخدمين بدور معين في محافظة معينة | متوسطة |

---

## 📊 مخطط العلاقات

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                       │
│                    قاعدة بيانات "يمن دليلي"                          │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │    users     │
                              │  (المستخدمون) │
                              └──────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
            ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
            │ governorates │  │ favorites    │  │notifications│
            │ (المحافظات)  │  │ (المفضلات)   │  │ (الإشعارات)  │
            └──────────────┘  └──────────────┘  └──────────────┘
                    │                │                │
                    ▼                │                │
            ┌──────────────┐         │                │
            │  districts   │         │                │
            │ (المديريات)  │         │                │
            └──────────────┘         │                │
                    │                │                │
                    ▼                │                │
            ┌──────────────┐         │                │
            │ subDistricts │         │                │
            │   (العزل)    │         │                │
            └──────────────┘         │                │
                                     │                │
                    ┌────────────────┼────────────────┤
                    │                │                │
                    ▼                ▼                ▼
            ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
            │  categories  │  │   services   │  │    reviews   │
            │ (التصنيفات)  │  │  (الخدمات)   │  │ (التقييمات)  │
            └──────────────┘  └──────────────┘  └──────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
            ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
            │ advertisements
            │ (الإعلانات)   │  │ businessOwners
            │(أصحاب الأعمال)│  │ (الصور)      │
            └──────────────┘  └──────────────┘  └──────────────┘
```

---

## 🔐 ملاحظات أمنية

- جميع الحقول التي تحتوي على بيانات حساسة (مثل `email`, `phoneNumber`) يجب أن تكون محمية بقواعس أمان صارمة.
- الوصول إلى بيانات المستخدم يجب أن يكون مقيداً للمستخدم نفسه أو المسؤولين.
- الوصول إلى الخدمات يجب أن يكون مقيداً بناءً على حالة الخدمة (`status`) والتحقق منها (`verified`).

---

**تم إعداد هذا المستند بواسطة:** Manus AI
**التاريخ:** يوليو 2026
**الإصدار:** 1.1
