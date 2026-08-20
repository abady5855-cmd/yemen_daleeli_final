# معمارية قاعدة بيانات Firestore لمشروع "يمن دليلي"

## 📋 ملخص تنفيذي

يوضح هذا المستند التصميم الشامل لقاعدة بيانات Firestore لمشروع "يمن دليلي"، والتي تم تصميمها لدعم ملايين المستخدمين والخدمات عبر جميع محافظات اليمن. تم تطبيق أفضل الممارسات في تصميم البيانات، مع الأخذ في الاعتبار Soft Delete، Audit Fields، وإمكانية التوسع المستقبلي لـ Multi-Tenant Architecture.

---

## 🏗️ هيكل المجموعات (Collections)

### 1. مجموعة المستخدمين (users)

| الحقل | النوع | الوصف | ملاحظات |
|------|------|--------|---------|
| `id` | string (UUID) | معرف المستخدم الفريد | Primary Key |
| `email` | string | البريد الإلكتروني | فريد، مفهرس |
| `displayName` | string | اسم المستخدم | قد يكون فارغاً |
| `photoUrl` | string | رابط الصورة الشخصية | اختياري |
| `phoneNumber` | string | رقم الهاتف | اختياري |
| `role` | string enum | دور المستخدم (Guest, User, BusinessOwner, Moderator, Admin, SuperAdmin) | مفهرس |
| `governorate` | string (UUID) | معرف المحافظة | مفهرس |
| `district` | string (UUID) | معرف المديرية | مفهرس |
| `isEmailVerified` | boolean | هل تم التحقق من البريد | افتراضي: false |
| `isPhoneVerified` | boolean | هل تم التحقق من الهاتف | افتراضي: false |
| `isActive` | boolean | هل الحساب نشط | افتراضي: true |
| `status` | string enum | حالة الحساب (Active, Suspended, Deleted) | افتراضي: Active |
| `createdAt` | timestamp | تاريخ الإنشاء | Audit Field |
| `updatedAt` | timestamp | تاريخ آخر تحديث | Audit Field |
| `deletedAt` | timestamp | تاريخ الحذف (Soft Delete) | اختياري |
| `createdBy` | string (UUID) | معرف المستخدم الذي أنشأ السجل | Audit Field |
| `updatedBy` | string (UUID) | معرف المستخدم الذي حدّث السجل | Audit Field |
| `deletedBy` | string (UUID) | معرف المستخدم الذي حذف السجل | Audit Field |
| `isDeleted` | boolean | هل تم حذف السجل (Soft Delete) | افتراضي: false |
| `version` | integer | رقم إصدار السجل | افتراضي: 1 |

**Subcollections:**
- `favorites`: الخدمات المفضلة للمستخدم
- `notifications`: إشعارات المستخدم
- `businessOwners`: بيانات صاحب العمل (إن وجدت)

---

### 2. مجموعة المحافظات (governorates)

| الحقل | النوع | الوصف | ملاحظات |
|------|------|--------|---------|
| `id` | string (UUID) | معرف المحافظة | Primary Key |
| `name_ar` | string | اسم المحافظة بالعربية | مفهرس |
| `name_en` | string | اسم المحافظة بالإنجليزية | اختياري |
| `code` | string | رمز المحافظة | فريد |
| `description_ar` | string | وصف المحافظة بالعربية | اختياري |
| `description_en` | string | وصف المحافظة بالإنجليزية | اختياري |
| `location` | geopoint | الموقع الجغرافي | اختياري |
| `population` | integer | عدد السكان | اختياري |
| `status` | string enum | حالة المحافظة (Active, Inactive) | افتراضي: Active |
| `isDeleted` | boolean | هل تم حذف السجل | افتراضي: false |
| `createdAt` | timestamp | تاريخ الإنشاء | Audit Field |
| `updatedAt` | timestamp | تاريخ آخر تحديث | Audit Field |
| `deletedAt` | timestamp | تاريخ الحذف | Audit Field |
| `createdBy` | string (UUID) | معرف المستخدم الذي أنشأ السجل | Audit Field |
| `updatedBy` | string (UUID) | معرف المستخدم الذي حدّث السجل | Audit Field |
| `version` | integer | رقم إصدار السجل | افتراضي: 1 |

**Subcollections:**
- `districts`: المديريات التابعة للمحافظة

---

### 3. مجموعة التصنيفات (categories)

| الحقل | النوع | الوصف | ملاحظات |
|------|------|--------|---------|
| `id` | string (UUID) | معرف التصنيف | Primary Key |
| `name_ar` | string | اسم التصنيف بالعربية | مفهرس |
| `name_en` | string | اسم التصنيف بالإنجليزية | اختياري |
| `description_ar` | string | وصف التصنيف بالعربية | اختياري |
| `description_en` | string | وصف التصنيف بالإنجليزية | اختياري |
| `icon` | string | رابط الأيقونة | اختياري |
| `color` | string | لون التصنيف (Hex) | اختياري |
| `serviceCount` | integer | عدد الخدمات في هذا التصنيف | يتم تحديثه بواسطة Cloud Functions |
| `status` | string enum | حالة التصنيف (Active, Inactive) | افتراضي: Active |
| `isDeleted` | boolean | هل تم حذف السجل | افتراضي: false |
| `createdAt` | timestamp | تاريخ الإنشاء | Audit Field |
| `updatedAt` | timestamp | تاريخ آخر تحديث | Audit Field |
| `deletedAt` | timestamp | تاريخ الحذف | Audit Field |
| `createdBy` | string (UUID) | معرف المستخدم الذي أنشأ السجل | Audit Field |
| `updatedBy` | string (UUID) | معرف المستخدم الذي حدّث السجل | Audit Field |
| `version` | integer | رقم إصدار السجل | افتراضي: 1 |

---

### 4. مجموعة الخدمات (services)

| الحقل | النوع | الوصف | ملاحظات |
|------|------|--------|---------|
| `id` | string (UUID) | معرف الخدمة | Primary Key |
| `name_ar` | string | اسم الخدمة بالعربية | مفهرس |
| `name_en` | string | اسم الخدمة بالإنجليزية | اختياري |
| `description_ar` | string | وصف الخدمة بالعربية | - |
| `description_en` | string | وصف الخدمة بالإنجليزية | اختياري |
| `categoryId` | string (UUID) | معرف التصنيف | مفهرس |
| `ownerId` | string (UUID) | معرف صاحب الخدمة | مفهرس |
| `governorateId` | string (UUID) | معرف المحافظة | مفهرس |
| `districtId` | string (UUID) | معرف المديرية | مفهرس |
| `subDistrictId` | string (UUID) | معرف العزلة | اختياري |
| `address_ar` | string | العنوان بالعربية | - |
| `address_en` | string | العنوان بالإنجليزية | اختياري |
| `location` | geopoint | الموقع الجغرافي | مفهرس |
| `phone` | string | رقم الهاتف | - |
| `whatsapp` | string | رقم واتساب | اختياري |
| `email` | string | البريد الإلكتروني | اختياري |
| `website` | string | رابط الموقع | اختياري |
| `rating` | number | التقييم العام (0-5) | افتراضي: 0 |
| `reviewCount` | integer | عدد التقييمات | يتم تحديثه بواسطة Cloud Functions |
| `favoriteCount` | integer | عدد المفضلات | يتم تحديثه بواسطة Cloud Functions |
| `galleryImages` | array | روابط الصور | اختياري |
| `workingHours` | map | ساعات العمل (يومياً) | - |
| `tags` | array | وسوم البحث | - |
| `status` | string enum | حالة الخدمة (Active, Pending, Hidden, Closed) | افتراضي: Pending |
| `verified` | boolean | هل تم التحقق من الخدمة | افتراضي: false |
| `featured` | boolean | هل الخدمة مميزة | افتراضي: false |
| `isDeleted` | boolean | هل تم حذف السجل | افتراضي: false |
| `createdAt` | timestamp | تاريخ الإنشاء | Audit Field |
| `updatedAt` | timestamp | تاريخ آخر تحديث | Audit Field |
| `deletedAt` | timestamp | تاريخ الحذف | Audit Field |
| `createdBy` | string (UUID) | معرف المستخدم الذي أنشأ السجل | Audit Field |
| `updatedBy` | string (UUID) | معرف المستخدم الذي حدّث السجل | Audit Field |
| `version` | integer | رقم إصدار السجل | افتراضي: 1 |

**Subcollections:**
- `reviews`: التقييمات والتعليقات على الخدمة

---

### 5. مجموعة الإعلانات (advertisements)

| الحقل | النوع | الوصف | ملاحظات |
|------|------|--------|---------|
| `id` | string (UUID) | معرف الإعلان | Primary Key |
| `title_ar` | string | عنوان الإعلان بالعربية | - |
| `title_en` | string | عنوان الإعلان بالإنجليزية | اختياري |
| `description_ar` | string | وصف الإعلان بالعربية | - |
| `description_en` | string | وصف الإعلان بالإنجليزية | اختياري |
| `image` | string | رابط صورة الإعلان | - |
| `targetUrl` | string | رابط الهدف عند النقر | اختياري |
| `isActive` | boolean | هل الإعلان نشط | افتراضي: true |
| `startDate` | timestamp | تاريخ بدء الإعلان | - |
| `endDate` | timestamp | تاريخ انتهاء الإعلان | - |
| `isDeleted` | boolean | هل تم حذف السجل | افتراضي: false |
| `createdAt` | timestamp | تاريخ الإنشاء | Audit Field |
| `updatedAt` | timestamp | تاريخ آخر تحديث | Audit Field |
| `deletedAt` | timestamp | تاريخ الحذف | Audit Field |
| `createdBy` | string (UUID) | معرف المستخدم الذي أنشأ السجل | Audit Field |
| `updatedBy` | string (UUID) | معرف المستخدم الذي حدّث السجل | Audit Field |
| `version` | integer | رقم إصدار السجل | افتراضي: 1 |

---

## 🔗 العلاقات بين المجموعات

يوضح الجدول التالي العلاقات بين المجموعات المختلفة:

| من | إلى | نوع العلاقة | الوصف |
|----|----|----------|--------|
| `services` | `categories` | Many-to-One | كل خدمة تنتمي إلى تصنيف واحد |
| `services` | `users` | Many-to-One | كل خدمة مملوكة من قبل مستخدم واحد |
| `services` | `governorates` | Many-to-One | كل خدمة تقع في محافظة واحدة |
| `districts` | `governorates` | Many-to-One | كل مديرية تابعة لمحافظة واحدة |
| `subDistricts` | `districts` | Many-to-One | كل عزلة تابعة لمديرية واحدة |
| `reviews` | `services` | Many-to-One | كل تقييم يخص خدمة واحدة |
| `reviews` | `users` | Many-to-One | كل تقييم من قبل مستخدم واحد |
| `favorites` | `users` | Many-to-One | كل مفضلة تخص مستخدماً واحداً |
| `favorites` | `services` | Many-to-One | كل مفضلة تخص خدمة واحدة |
| `notifications` | `users` | Many-to-One | كل إشعار يخص مستخدماً واحداً |

---

## 🌍 اعتبارات Multi-Tenant Architecture

تم تصميم قاعدة البيانات بطريقة تسمح بالتوسع المستقبلي لمنصة متعددة الدول (Multi-Tenant Architecture) دون الحاجة إلى إعادة هيكلة جذرية. يمكن تحقيق ذلك مستقبلاً عن طريق:

1. **إضافة حقل `tenantId`:** إضافة حقل `tenantId` (UUID) إلى جميع المجموعات الرئيسية لتحديد المستأجر (الدولة أو الكيان).
2. **تعديل قواعس الأمان:** تعديل قواعد الأمان لفرض الوصول بناءً على `tenantId`.
3. **عزل البيانات:** استخدام `tenantId` في جميع الاستعلامات لضمان عزل البيانات بين المستأجرين.

---

## 📝 ملاحظات مهمة

- جميع المعرفات (IDs) تستخدم UUID بدلاً من معرفات Firestore التلقائية.
- جميع المجموعات الرئيسية تحتوي على حقول Soft Delete و Audit Fields.
- جميع الحقول التي تحتوي على نصوص متعددة اللغات لها نسخة عربية (`_ar`) ونسخة إنجليزية (`_en`).
- الحقول المفهرسة (مثل `email`, `categoryId`, `governorateId`) تم تحديدها لتحسين أداء الاستعلامات.

---

**تم إعداد هذا المستند بواسطة:** Manus AI
**التاريخ:** يوليو 2026
**الإصدار:** 1.1
