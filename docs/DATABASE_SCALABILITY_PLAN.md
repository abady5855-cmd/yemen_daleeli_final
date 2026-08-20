# خطة القابلية للتوسع والترحيل لقاعدة بيانات Firestore

## 📋 ملخص تنفيذي

يوضح هذا المستند خطة القابلية للتوسع (Scalability) وخطة الترحيل (Migration) لقاعدة بيانات Firestore لمشروع "يمن دليلي"، مع التركيز على دعم ملايين المستخدمين والخدمات، والتوسع المستقبلي لجميع محافظات اليمن، وحتى Multi-Tenant Architecture.

---

## 📈 خطة القابلية للتوسع (Scalability Plan)

### 1. التوسع الأفقي (Horizontal Scaling)

#### أ. تقسيم البيانات حسب المحافظات (Sharding by Governorate)

**الفكرة:** تقسيم البيانات إلى مجموعات منفصلة حسب المحافظة لتقليل حجم كل مجموعة.

**التطبيق:**
```
/governorates/{governorateId}/services/{serviceId}
/governorates/{governorateId}/users/{userId}
/governorates/{governorateId}/reviews/{reviewId}
```

**الفوائد:**
- تقليل حجم كل استعلام
- توازي الوصول من مناطق مختلفة
- تحسين الأداء

#### ب. تقسيم البيانات حسب التصنيفات (Sharding by Category)

**الفكرة:** تقسيم الخدمات حسب التصنيف لتحسين الأداء.

**التطبيق:**
```
/categories/{categoryId}/services/{serviceId}
```

#### ج. تقسيم البيانات حسب الوقت (Time-based Sharding)

**الفكرة:** تقسيم البيانات حسب الشهر أو السنة لتقليل حجم المجموعات.

**التطبيق:**
```
/services/{year}/{month}/{serviceId}
/reviews/{year}/{month}/{reviewId}
```

### 2. التوسع العمودي (Vertical Scaling)

#### أ. استخدام Cloud Firestore في وضع الإنتاج (Production Mode)

- استخدام الفهارس المركبة (Composite Indexes)
- تحسين الاستعلامات
- استخدام Cloud Functions للعمليات الثقيلة

#### ب. استخدام Cloud Storage للملفات الثقيلة

- تخزين الصور والفيديوهات في Cloud Storage
- تخزين فقط الروابط في Firestore
- استخدام CDN لتسريع التحميل

### 3. تحسين الأداء

#### أ. استخدام Pagination

```dart
// الاستعلام الأول
Query query = FirebaseFirestore.instance
    .collection('services')
    .where('governorateId', isEqualTo: governorateId)
    .where('status', isEqualTo: 'Active')
    .limit(20);

// الاستعلام التالي
Query nextQuery = query.startAfter([lastDocument]);
```

#### ب. استخدام Lazy Loading

- تحميل الصور فقط عند الحاجة
- استخدام `cached_network_image` package
- تحميل البيانات الإضافية عند التمرير

#### ج. استخدام Cloud Functions

- معالجة العمليات الثقيلة خارج التطبيق
- تحديث البيانات المشتقة (مثل `reviewCount`, `rating`)
- إرسال الإشعارات

---

## 🔄 خطة الترحيل (Migration Plan)

### مرحلة 1: إضافة محافظة جديدة

**الخطوات:**
1. إضافة سجل جديد في مجموعة `governorates`
2. إضافة مديريات وعزل جديدة تحت المحافظة الجديدة
3. تحديث التطبيق لعرض المحافظة الجديدة
4. السماح لأصحاب الأعمال بإضافة خدمات في المحافظة الجديدة

**الكود:**
```dart
// إضافة محافظة جديدة
await FirebaseFirestore.instance.collection('governorates').add({
  'id': Uuid().v4(),
  'name_ar': 'محافظة جديدة',
  'name_en': 'New Governorate',
  'code': 'NEW_GOV',
  'status': 'Active',
  'createdAt': FieldValue.serverTimestamp(),
  'createdBy': currentUserId,
  'isDeleted': false,
  'version': 1,
});
```

### مرحلة 2: إضافة تصنيف جديد

**الخطوات:**
1. إضافة سجل جديد في مجموعة `categories`
2. تحديث التطبيق لعرض التصنيف الجديد
3. السماح لأصحاب الأعمال بإضافة خدمات في التصنيف الجديد

### مرحلة 3: إضافة ميزة جديدة

**الخطوات:**
1. إضافة مجموعة جديدة لتخزين البيانات
2. تحديث قواعس الأمان
3. تحديث التطبيق للعمل مع الميزة الجديدة

---

## 🌍 اعتبارات Multi-Tenant Architecture

### التصميم الحالي (Single-Tenant)

البنية الحالية مصممة لدعم دولة واحدة (اليمن) فقط.

### التصميم المستقبلي (Multi-Tenant)

لتحويل النظام إلى Multi-Tenant Architecture، يتم اتباع الخطوات التالية:

#### 1. إضافة حقل `tenantId` إلى جميع المجموعات

```
users:
  - tenantId (UUID)
  - ...

services:
  - tenantId (UUID)
  - ...

categories:
  - tenantId (UUID)
  - ...
```

#### 2. تعديل الاستعلامات لتشمل `tenantId`

```dart
// قبل
Query query = FirebaseFirestore.instance
    .collection('services')
    .where('governorateId', isEqualTo: governorateId);

// بعد
Query query = FirebaseFirestore.instance
    .collection('services')
    .where('tenantId', isEqualTo: currentTenantId)
    .where('governorateId', isEqualTo: governorateId);
```

#### 3. تعديل قواعس الأمان

```firestore
match /services/{serviceId} {
  allow read: if (isNotDeleted(resource.data) && 
                  resource.data.tenantId == currentTenantId && 
                  resource.data.status == 'Active' && 
                  resource.data.verified == true) || 
                isOwner(resource.data.ownerId) || 
                hasRole('Admin');
}
```

#### 4. إنشاء Tenant Management System

- إنشاء مجموعة `tenants` لتخزين معلومات المستأجرين
- إدارة الاشتراكات والدفع
- إدارة الموارد والحدود

---

## 📊 توقعات النمو والقدرات

### السنة الأولى (2026)

- **عدد المستخدمين:** 50,000 - 100,000
- **عدد الخدمات:** 10,000 - 20,000
- **عدد التقييمات:** 50,000 - 100,000
- **عدد الإشعارات:** 1,000,000 - 5,000,000

### السنة الثانية (2027)

- **عدد المستخدمين:** 200,000 - 500,000
- **عدد الخدمات:** 50,000 - 100,000
- **عدد التقييمات:** 500,000 - 1,000,000
- **عدد الإشعارات:** 10,000,000 - 50,000,000

### السنة الثالثة (2028)

- **عدد المستخدمين:** 1,000,000+
- **عدد الخدمات:** 500,000+
- **عدد التقييمات:** 5,000,000+
- **عدد الإشعارات:** 100,000,000+

---

## 💰 تقدير التكاليف

### Firestore Pricing (تقديري)

| العملية | السعر | الاستخدام الشهري | التكلفة الشهرية |
|--------|------|-----------------|-----------------|
| قراءة | $0.06 / 100,000 | 100,000,000 | $600 |
| كتابة | $0.18 / 100,000 | 10,000,000 | $18 |
| حذف | $0.02 / 100,000 | 1,000,000 | $0.20 |
| **الإجمالي** | | | **~$620/شهر** |

**ملاحظة:** هذا تقدير تقريبي ويعتمد على الاستخدام الفعلي.

---

## 🔍 مراقبة الأداء

### مقاييس الأداء الرئيسية (KPIs)

1. **وقت الاستجابة:** < 500ms
2. **معدل النجاح:** > 99.9%
3. **توفر الخدمة:** > 99.95%
4. **استهلاك البيانات:** < 100MB/يوم للمستخدم

### أدوات المراقبة

- **Firebase Console:** مراقبة الاستخدام والأخطاء
- **Google Cloud Monitoring:** مراقبة الأداء والموارد
- **Crashlytics:** تتبع الأخطاء والحوادث

---

## 📝 خطة الصيانة

### صيانة دورية

- **يومياً:** مراقبة الأخطاء والتنبيهات
- **أسبوعياً:** تحليل الأداء والاستخدام
- **شهرياً:** تحديث الفهارس والقواعس
- **ربع سنوياً:** مراجعة شاملة للنظام

### نسخ احتياطية

- **تفعيل النسخ الاحتياطية التلقائية:** Firestore يوفر نسخ احتياطية تلقائية
- **نسخ احتياطية يدوية:** تصدير البيانات شهرياً
- **اختبار استعادة البيانات:** اختبار استعادة النسخ الاحتياطية ربع سنوياً

---

**تم إعداد هذا المستند بواسطة:** Manus AI
**التاريخ:** يوليو 2026
**الإصدار:** 1.1
