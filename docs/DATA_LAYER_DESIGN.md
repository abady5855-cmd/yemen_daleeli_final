# تصميم طبقة البيانات (Data Layer Design) - مشروع يمن دليلي

## 📋 نظرة عامة
تتبع طبقة البيانات في مشروع "يمن دليلي" نمط **Clean Architecture**، حيث تنقسم إلى ثلاثة مكونات رئيسية تضمن فصل المسؤوليات وسهولة الاختبار والتبديل بين مصادر البيانات.

---

## 🏗️ المكونات الرئيسية

### 1. النماذج (Models)
تمثل النماذج هيكل البيانات كما ترد من مصدر البيانات (مثل Firestore).
- **الوراثة:** ترث النماذج من الكيانات (Entities) الموجودة في طبقة Domain.
- **التحويل:** تحتوي على دوال `fromJson` و `toJson` للتعامل مع Firestore.
- **التوافق:** تدعم حقول التدقيق (Audit Fields) مثل `createdAt` و `updatedAt` وحقل الحذف الناعم `isDeleted`.

### 2. مصادر البيانات (DataSources)
تنقسم إلى نوعين لضمان عمل التطبيق بكفاءة:
- **Remote DataSources:** تتعامل مباشرة مع Firebase (Auth, Firestore, Storage).
- **Local DataSources:** (مخطط لها) تتعامل مع التخزين المحلي (مثل Hive أو SharedPreferences) لدعم العمل دون اتصال (Offline-first).

### 3. المستودعات (Repositories Implementation)
تقوم بربط مصادر البيانات وتقديم البيانات لطبقة Domain.
- **معالجة الأخطاء:** تحويل الاستثناءات (Exceptions) إلى إخفاقات (Failures) معرفة.
- **تنسيق النتائج:** تستخدم نمط `(Data?, Failure?)` لتبسيط معالجة الحالات في طبقة العرض.

---

## 🛠️ خريطة التنفيذ (Implementation Map)

| الميزة (Feature) | الحالة | المكونات المكتملة |
|----------------|-------|-------------------|
| **المصادقة (Auth)** | ✅ مكتمل | Models, RemoteDS, Repo, Providers |
| **التصنيفات (Categories)** | ✅ مكتمل | Models, RemoteDS, Repo, Providers |
| **الخدمات (Services)** | 🏗️ قيد التنفيذ | Models, RemoteDS, Repo (الـ Providers قيد الإنشاء) |
| **التقييمات (Reviews)** | 🏗️ قيد التنفيذ | Models (الـ DS, Repo, Providers قيد الإنشاء) |
| **الإعلانات (Ads)** | 🏗️ قيد التنفيذ | Models (الـ DS, Repo, Providers قيد الإنشاء) |

---

## 🔄 تدفق البيانات (Data Flow)
1. **الطلب:** يطلب الـ ViewModel/Provider بيانات من الـ Repository.
2. **الجلب:** يتحقق الـ Repository من الـ Local DS (إذا وجد) أو يطلب من الـ Remote DS.
3. **التحويل:** يقوم الـ Remote DS بتحويل استجابة Firestore إلى `Model`.
4. **التمرير:** يعيد الـ Repository البيانات كـ `Entity` لضمان استقلالية طبقة Domain.

---

## 📝 المبادئ المتبعة
- **UUID:** استخدام المعرفات الفريدة عالمياً لجميع السجلات.
- **Type Safety:** استخدام الأنواع القوية والتحقق من البيانات عند التحويل من JSON.
- **Scalability:** تصميم الاستعلامات لدعم الـ Pagination والفرز المتقدم.

---
**تم إعداد هذا المستند بواسطة:** Manus AI
**التاريخ:** أغسطس 2026
