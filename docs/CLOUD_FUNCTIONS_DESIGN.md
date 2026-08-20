# تصميم وظائف السحابة (Cloud Functions Design)

## 📋 نظرة عامة
تستخدم Cloud Functions في مشروع "يمن دليلي" للقيام بالعمليات الخلفية التي تتطلب صلاحيات إدارية أو عمليات تجميع البيانات (Data Aggregation) لضمان أداء عالٍ للتطبيق وتقليل تكاليف القراءة من Firestore.

---

## 🛠️ الوظائف المقترحة

### 1. تحديث إحصائيات التقييم (updateServiceRating)
**المحفز (Trigger):** `onWrite` في مجموعة `services/{serviceId}/reviews/{reviewId}`.
**الوصف:** عند إضافة أو تعديل أو حذف تقييم، تقوم الوظيفة بحساب متوسط التقييم الجديد وعدد التقييمات وتحديث وثيقة الخدمة الرئيسية.
**المنطق:**
```javascript
const reviews = await db.collection(`services/${serviceId}/reviews`).where('isDeleted', '==', false).get();
let totalRating = 0;
reviews.forEach(doc => totalRating += doc.data().rating);
const averageRating = totalRating / reviews.size;
await db.collection('services').doc(serviceId).update({
  rating: averageRating,
  reviewCount: reviews.size
});
```

### 2. تحديث عدد الخدمات في التصنيف (updateCategoryServiceCount)
**المحفز (Trigger):** `onWrite` في مجموعة `services/{serviceId}`.
**الوصف:** عند إضافة خدمة جديدة أو تغيير حالتها إلى نشطة/غير نشطة، يتم تحديث حقل `serviceCount` في التصنيف المقابل.

### 3. إرسال الإشعارات (sendNotificationOnReview)
**المحفز (Trigger):** `onCreate` في مجموعة `services/{serviceId}/reviews/{reviewId}`.
**الوصف:** إرسال إشعار لصاحب الخدمة عند تلقي تقييم جديد.

### 4. تنظيف البيانات المحذوفة (cleanupSoftDeletedData)
**المحفز (Trigger):** `onSchedule` (يومياً).
**الوصف:** حذف السجلات التي مضى على حذفها ناعماً (Soft Delete) أكثر من 30 يوماً بشكل نهائي لتوفير المساحة.

---

## 🔐 الأمان والكفاءة
- **الصلاحيات:** تعمل الوظائف بصلاحيات الـ Service Account لتجاوز قواعس الأمان عند الضرورة.
- **التحكم في التكاليف:** استخدام `runWith` لتحديد الذاكرة والوقت المستغرق لكل وظيفة.
- **التعامل مع الأخطاء:** تسجيل جميع الأخطاء في Cloud Logging.

---
**تم إعداد هذا المستند بواسطة:** Manus AI
**التاريخ:** أغسطس 2026
