# خطة قواعس أمان Firestore واستراتيجية التخزين المؤقت

## 📋 ملخص تنفيذي

يوضح هذا المستند خطة قواعس أمان Firestore (Security Rules) لضمان حماية البيانات والتحكم في الوصول، بالإضافة إلى استراتيجية التخزين المؤقت (Offline Cache) لتحسين تجربة المستخدم. تم تحديث القواعس لتشمل حقول Soft Delete و Audit Fields.

---

## 🔒 قواعس أمان Firestore (Security Rules)

### المبادئ الأساسية

1. **الحد الأدنى من الوصول (Principle of Least Privilege):** كل مستخدم يحصل على الحد الأدنى من الصلاحيات المطلوبة لأداء عمله.
2. **التحقق من الهوية (Authentication):** يجب أن يكون المستخدم مسجلاً دخولاً قبل الوصول إلى أي بيانات.
3. **التحقق من الصلاحيات (Authorization):** يجب التحقق من صلاحيات المستخدم قبل السماح بأي عملية.
4. **حماية البيانات الحساسة:** البيانات الحساسة يجب أن تكون محمية بشكل إضافي.

### قواعس الأمان المقترحة

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // وظائف مساعدة
    function isSignedIn() {
      return request.auth != null;
    }

    function hasRole(role) {
      return isSignedIn() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function isNotDeleted(data) {
      return data.isDeleted == false;
    }

    // قواعس المستخدمين
    match /users/{userId} {
      allow read: if isOwner(userId) || hasRole('Admin');
      allow update: if isOwner(userId) && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['displayName', 'photoUrl', 'phoneNumber', 'updatedAt']);
      allow create: if hasRole('Admin');
      allow delete: if hasRole('Admin') && request.resource.data.isDeleted == true;
    }

    // قواعس المحافظات
    match /governorates/{governorateId} {
      allow read: if isNotDeleted(resource.data) && resource.data.status == 'Active';
      allow write: if hasRole('Admin');

      // قواعس المديريات
      match /districts/{districtId} {
        allow read: if isNotDeleted(resource.data) && resource.data.status == 'Active';
        allow write: if hasRole('Admin');

        // قواعس العزل
        match /subDistricts/{subDistrictId} {
          allow read: if isNotDeleted(resource.data) && resource.data.status == 'Active';
          allow write: if hasRole('Admin');
        }
      }
    }

    // قواعس التصنيفات
    match /categories/{categoryId} {
      allow read: if isNotDeleted(resource.data) && resource.data.status == 'Active';
      allow write: if hasRole('Admin');
    }

    // قواعس الخدمات
    match /services/{serviceId} {
      allow read: if (isNotDeleted(resource.data) && resource.data.status == 'Active' && resource.data.verified == true) || isOwner(resource.data.ownerId) || hasRole('Admin') || hasRole('Moderator');
      allow create: if hasRole('BusinessOwner') && request.resource.data.ownerId == request.auth.uid;
      allow update: if (isOwner(resource.data.ownerId) && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['name_ar', 'name_en', 'description_ar', 'description_en', 'address_ar', 'address_en', 'phone', 'whatsapp', 'email', 'website', 'galleryImages', 'workingHours', 'tags', 'updatedAt'])) || hasRole('Admin') || hasRole('Moderator');
      allow delete: if hasRole('Admin') && request.resource.data.isDeleted == true;

      // قواعس التقييمات
      match /reviews/{reviewId} {
        allow read: if isNotDeleted(resource.data);
        allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
        allow update: if isOwner(resource.data.userId) && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['rating', 'comment', 'updatedAt']);
        allow delete: if (isOwner(resource.data.userId) && request.resource.data.isDeleted == true) || hasRole('Admin') || hasRole('Moderator');
      }
    }

    // قواعس المفضلات
    match /users/{userId}/favorites/{favoriteId} {
      allow read, write: if isOwner(userId) && isNotDeleted(resource.data);
    }

    // قواعس الإشعارات
    match /users/{userId}/notifications/{notificationId} {
      allow read: if isOwner(userId) && isNotDeleted(resource.data);
      allow create: if hasRole('Admin');
      allow update: if isOwner(userId) && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['read', 'readAt', 'updatedAt']);
      allow delete: if hasRole('Admin') && request.resource.data.isDeleted == true;
    }

    // قواعس الإعلانات
    match /advertisements/{adId} {
      allow read: if resource.data.isActive == true && isNotDeleted(resource.data);
      allow write: if hasRole('Admin');
    }

    // قاعدة عامة (رفض جميع الطلبات الأخرى)
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 💾 استراتيجية التخزين المؤقت (Offline Cache Strategy)

### تفعيل التخزين المؤقت

```dart
// في main.dart أو عند تهيئة Firebase
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true, // تفعيل التخزين المؤقت
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // حجم التخزين المؤقت
);
```

### استراتيجيات جلب البيانات

| الاستراتيجية | الاستخدام | الأداء |
|-----------|---------|-------|
| `Source.default` | البيانات العادية | سريع (من التخزين المؤقت أولاً) |
| `Source.server` | البيانات الحساسة | أبطأ (من الخادم فقط) |
| `Source.cache` | البيانات المحفوظة | سريع جداً (من التخزين المؤقت فقط) |

### مزامنة البيانات

- **Real-time Listeners:** استخدام `snapshots()` للاستماع إلى التغييرات في الوقت الفعلي.
- **Background Sync:** Firestore يقوم بمزامنة التغييرات المعلقة تلقائياً عند الاتصال بالإنترنت.
- **Offline Writes:** يمكن للمستخدم الكتابة دون اتصال، وسيتم مزامنة البيانات عند الاتصال.

### اعتبارات الأداء

- **Pagination:** استخدام Pagination لتقليل حجم البيانات المخزنة مؤقتاً.
- **Lazy Loading:** تحميل الصور والمحتوى الثقيل عند الحاجة فقط.
- **Garbage Collection:** Firestore يدير التخزين المؤقت تلقائياً، لكن يجب مراقبة حجم البيانات.

---

## 🔐 ملاحظات أمنية إضافية

1. **Soft Delete:** استخدام `isDeleted` بدلاً من الحذف الفعلي يسمح باسترجاع البيانات والحفاظ على السجلات التاريخية.
2. **Audit Fields:** تتبع من قام بالعمليات ومتى يساعد في الكشف عن الأنشطة المريبة.
3. **Status Field:** استخدام `status` يسمح بالتحكم الدقيق في حالة البيانات (Active, Pending, Hidden, Closed).
4. **Version Field:** إدارة النسخ تساعد في التعامل مع التضاربات والتحديثات المتزامنة.

---

**تم إعداد هذا المستند بواسطة:** Manus AI
**التاريخ:** يوليو 2026
**الإصدار:** 1.1
