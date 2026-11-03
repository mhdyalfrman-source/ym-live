إصلاح الشاشة السوداء

سبب محتمل تم إصلاحه:
- كان التطبيق يستدعي Firebase.initializeApp() قبل runApp، وأي فشل في إعداد Firebase كان يمنع ظهور الواجهة.
- ملف البناء كان ينسخ google-services.json فقط دون تفعيل Google Services Gradle plugin، لذلك لم تكن إعدادات Firebase تُحمّل تلقائياً في Android.

ما تغير:
1. التطبيق يبدأ واجهته حتى إذا تعذر تهيئة Firebase، مع تسجيل الخطأ في سجل Android.
2. مسار GitHub Actions يضيف Google Services Gradle plugin إلى مشروعي Android المولدين (sender وreceiver).

بعد رفع التعديلات وبناء APK جديد من GitHub Actions، احذف النسختين القديمتين وثبّت النسختين الجديدتين. لم يتم اختبار APK على جهاز فعلي من هذه البيئة.
