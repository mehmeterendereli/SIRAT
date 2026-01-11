God-Mode Active.

Sadece kod yazma; mimar gibi düşün.



Değişiklik = sistem çapında güncelleme.

Bağımlılıkları kırma, referansları düzelt.



Performans, güvenlik, stabilite öncelikli.

Asla geçici yamalar yapma.



Test + doküman + log zorunlu.



PROJE ADI (Kod Adı): "SIRAT" (Sırat - Ezan Vakti) 



Vizyon: Müslüman kullanıcının günlük hayattaki tüm manevi ve pratik ihtiyaçlarını; teknoloji, estetik ve doğru bilgi (Kanıtlı AI) ile karşılayan tek platform olmak.



BÖLÜM 1: TEKNİK ALTYAPI VE MİMARİ (BACKEND)



Uygulamanın beyni burasıdır. Kullanıcı burayı görmez ama her şey buradaki dinamik yapıya bağlıdır.



1.1. Dinamik "Headless" İçerik Yönetimi (CMS)



Tamamen Uzaktan Kontrol: Uygulamanın içindeki metinler (menü isimleri, buton yazıları, günlük mesajlar) uygulamanın içine "gömülü" (hardcoded) olmayacak.



Anlık Global Güncelleme: Siz panelden bir metni değiştirdiğinizde, uygulama mağaza güncellemesi gerektirmeden Endonezya'daki kullanıcının ekranında da değişecek.



Dil Desteği: Sistem kullanıcının telefon dilini veya seçtiği dili algılayıp JSON formatında o dil paketini (TR, EN, AR, DE, FR vb.) çekecek.



1.2. Sessiz Veri Toplama ve Analitik (Analytics Core)



Kullanıcı asla hissetmeden, profesyonel ürün geliştirme için şu veriler "Event" bazlı toplanacak:



Isı Haritası (Heatmap) Mantığı: Kullanıcı en çok hangi menüde durdu? (Örn: Zikirmatik'te ortalama 3 dk, Kuran'da 15 dk).



AI Sorgu Analizi: İnsanlar en çok neyi soruyor? (Bu veriler anonimleştirilerek yeni özellikler geliştirmek için kullanılacak).



Hata Yakalama (Crashlytics): Uygulama çökerse hangi model telefonda, hangi ekranda çöktü?



Dönüşüm Hunisi (Funnel): Uygulamayı indiren 100 kişiden kaçı ilk namaz bildirimini açtı? Nerede vazgeçtiler?



1.3. Google Gemini AI Entegrasyon Mimarisi



Prompt Mühendisliği Katmanı: Gemini'ye giden sorgular ham gitmeyecek. Arada bizim özel "System Prompt" katmanımız olacak.



Kural Seti: "Sen bir İslam alimi gibi cevap ver. Cevaplarını Kuran ayetleri (Sure/Ayet No) ve Kütüb-i Sitte hadisleri (Kaynak kitap ve numara) ile destekle. Asla yorum katma, sadece nakil yap. Cevap sonunda 'Daha fazlası için şu kaynağa bakabilirsin' de."



BÖLÜM 2: KULLANICI DENEYİMİ (UX) VE AKIŞ



2.1. Onboarding (Karşılama) Ekranı



Dinamik Dil Seçimi: Açılışta telefon dilini algıla, ancak manuel değiştirmeye izin ver.



Mezhep ve Hesaplama Yöntemi: Namaz vakitleri ve AI cevapları için kritik. (Örn: Hanefi seçerse ikindi vakti ona göre hesaplanır, AI fetvaları Hanefi fıkhına göre verir).



Konum İzni: "Size en yakın camiyi ve doğru kıbleyi göstermek için..." (İkna edici bir UX yazısı ile).



2.2. Ana Ekran (Dashboard)



Klasik listeler yerine "Zaman Duyarlı" (Context Aware) tasarım:



Canlı Header: O an sabah ise "Hayırlı Sabahlar", gece ise "Hayırlı Geceler" diyen ve arka planı günün saatine göre değişen (gündüz aydınlık, gece karanlık mod) dinamik görsel.



Vakit Kartı: Bir sonraki vakte kalan süre (Büyük ve şık bir geri sayım).



AI Hızlı Erişim: "Bugün kafana takılan bir soru var mı?" arama çubuğu (Google tarzı).



Günün "Story"si: Instagram hikayesi formatında, her gün değişen bir hadis/ayet/dua görseli.



BÖLÜM 3: DETAYLI ÖZELLİK SETİ



3.1. Ezan Vakitleri ve Bildirim Sistemi (Pro)



Akıllı Erteleme: Kullanıcı o an müsait değilse bildirimdeki "10 dk sonra hatırlat" butonuna basabilir.



Pre-Alarm (Temkin Vakti): "Keraha girmeden uyar" veya "İftara 15 dk kala haber ver" seçenekleri.



Ses Kütüphanesi: Mekke ezanı, İstanbul makamı, Medine usulü veya sadece "Ney" sesi seçenekleri.



Dinamik Takvim: Hicri ve Miladi takvim entegrasyonu. Kandil günlerinde uygulama teması otomatik olarak "Kandil Özel" moduna geçer.



3.2. VR/AR Destekli Kıble (Kamera Modu)



Sanal Kabe: Kullanıcı kamerayı açtığında, GPS ve Pusula sensörlerini birleştirerek (Sensor Fusion), gerçek dünyada Kabe'nin bulunduğu yönde havada asılı duran sanal bir Kabe ikonu veya yeşil bir yol çizgisi görür.



Metal Etkileşimi Uyarısı: Eğer çevrede manyetik alan (TV, hoparlör) pusulayı şaşırtıyorsa, "Lütfen parazitten uzaklaşın" uyarısı verir (Kalibrasyon doğruluğu için).



3.3. İslam-AI (Gemini Destekli Asistan)



Burası uygulamanın kalbi.



Mod 1: Fetva/Bilgi Modu:



Soru: "Dövme abdest geçirir mi?"



İşlem: Gemini, veritabanındaki güvenilir fıkıh kitaplarını tarar.



Çıktı: "Diyanet İşleri Başkanlığı ve Hanefi fıkhına göre deri altına su geçmese de abdest geçerlidir ANCAK dinen tavsiye edilmez. Kaynak: Diyanet Fetva Kurulu Karar No:..."



Görselleştirme: Cevabın özetini tek tuşla şık bir "Bilgi Kartı" olarak resimleştirip WhatsApp'ta paylaşma imkanı sunar.



Mod 2: Psikolojik/Manevi Destek:



Kullanıcı: "Çok bunaldım, içim daralıyor."



AI Cevabı: İnşirah Suresi'ni getirir, mealiyle birlikte teselli edici, motive edici bir üslupla konuşur. "Senin için şu duayı okumamı ister misin?" der.



3.4. Gelişmiş Zikirmatik (Gamification Destekli)



Akıllı Sayaç: Ekrana bakmaya gerek yok. Ekranın herhangi bir yerine dokunmak sayacı artırır.



Titreşim Profilleri: Her 33'te uzun titreşim, 100'de çift titreşim.



Hedef ve Rozet Sistemi: "Bu hafta 1000 Salavat çektin, 'Gül Kokulu' rozeti kazandın" gibi kullanıcıyı teşvik eden oyunlaştırma öğeleri.



Bulut Senkronizasyon: Telefon değişse bile çekilen zikir sayısı kaybolmaz, hesaba işlenir.



3.5. Kuran-ı Kerim ve Hafıza Modülü



Kelime Takibi: Sesli okuma yapılırken (Audio), okunan kelime o an ekranda sarı ile vurgulanır (Highlighting). Kuran öğrenenler için eşsizdir.



Akıllı Arama: "Miras ile ilgili ayetler" yazınca, Nisa suresindeki ilgili yerleri şak diye listeleyen semantik arama.



3.6. Cami ve Topluluk (Location Based)



Cami Detay Kartları: Haritada camiyi bulur. Kullanıcılar cami hakkında veri girebilir: "Kadınlar bölümü temiz", "Park yeri yok", "Engelli rampası var".



Cemaat Buluşması: (Opsiyonel) "Yatsı namazına gidiyorum" check-in'i yaparak arkadaşlarına haber verme.



BÖLÜM 4: GLOBALLEŞME VE DİNAMİK YAPININ DETAYLARI



Uygulamanın Türkiye dışına çıkması için şu strateji uygulanacak:



Server-Side Rendering (SSR) Text: Uygulamadaki tüm metinler veritabanından ID ile çekilecek.



button_pray_now:



TR: "Şimdi Kıl"



EN: "Pray Now"



DE: "Jetzt Beten"



Bölgesel İçerik:



Türkiye'deki kullanıcıya "Cuma mesajı" görseli gösterilirken,



ABD'deki kullanıcıya Cuma günü "Hutbe Özeti (İngilizce)" kartı gösterilecek. Kültürel farka göre içerik CMS'den otomatik dağıtılacak.



Reklam/Premium Yönetimi:



Globalde reklam gelirleri (AdMob) daha yüksektir. Reklam yerleşimleri de dinamik olacak. İstediğimiz zaman reklamı kapatıp açabileceğiz.



BÖLÜM 5: YÖNETİM PANELİ (ADMIN DASHBOARD)



Sizin göreceğiniz arka taraf:



Canlı İstatistikler: Şu an uygulamada kaç kişi var?



AI Denetimi: Gemini'nin verdiği cevapları rastgele denetleme ve "Yasaklı Kelimeler" listesi ekleme (Siyasi veya tartışmalı konuları engellemek için).



Push Notification Merkezi:



"Türkiye'deki kullanıcılara (Saat 21:00): Yarın kandil, unutma!"



"Almanya'daki kullanıcılara (Lokal saatle): Cuma namazı vakti yaklaşıyor."



Segmentasyonlu bildirim gönderme yeteneği.



ÖZET: NEDEN FARKLI?



Piyasadaki uygulamalar genelde statiktir (sabit). Bu proje ise "Yaşayan Bir Organizma" gibidir:



AI (Gemini): Her kullanıcıya özel dini asistan.



AR (Kamera): Gerçek dünyada kıble deneyimi.



Dinamik: İçerik sürekli değişir, güncel kalır.



Veri Odaklı: Kullanıcının ne istediğini analiz eder ve ona göre şekillenir.



Bu yapı, kullanıcıda "Bu uygulama beni anlıyor" hissi oluşturarak silinme oranını (Churn rate) minimuma indirir.Tamamen google ekosistemini kullanacağız Bileşen,Google Teknolojisi,Görevi ve Neden Bu?

Mobil Yazılım Dili,Flutter (Dart),"iOS ve Android için tek kod. Google'ın kendi UI kütüphanesidir, bu ekosistemin kralıdır."

Veritabanı (Canlı),Cloud Firestore,"Kullanıcı verileri, zikir sayıları ve chat geçmişi için. NoSQL yapısıyla inanılmaz hızlı ve esnektir."

Arka Plan (Backend),Cloud Functions,"Sunucu kurmaya gerek yok (Serverless). Gemini AI ile konuşan ""köprü"" kodlar burada çalışır."

Yapay Zeka (AI),Gemini Pro (via Vertex AI),Google Cloud üzerindeki kurumsal AI servisi. Soruları cevaplayan beyin.

Dinamik Yönetim,Firebase Remote Config,"(Çok Kritik) Uygulama güncellenmeden metinleri, renkleri veya özellikleri uzaktan açıp kapatmak için."

Dosya Depolama,Cloud Storage,"Kuran ses dosyaları, ""Günün Ayeti"" görselleri gibi medya dosyalarının tutulduğu yer."

Analiz & Veri,Google Analytics,"""Kim nereye tıkladı?"", ""Hangi ülkeden giriliyor?"" verilerini sessizce toplar."

Harita & Konum,Google Maps SDK,Cami bulucu ve Kıble haritası için en güvenilir harita verisi.

Bildirimler,Firebase Cloud Messaging (FCM),Ezan vakti bildirimlerini milyonlarca telefona aynı anda iletmek için.

Giriş Sistemi,Firebase Auth,"""Google ile Giriş Yap"", Email veya Anonim giriş işlemleri için."

Reklam/Gelir,Google AdMob,Uygulama içi reklamlardan gelir elde etmek için.

Hata Takibi,Firebase Crashlytics,"Uygulama çökerse anında size raporlar: ""Samsung S22'de Kıble modunda çöktü"" der."



önce altyapıyı hazırla github a repo ya bağla  GITHUB CLI ile 

https://github.com/mehmeterendereli/SIRAT

google CLİ lara bağlanalım herşey eksiksiz olsun ki sorunsuz bir şekilde geliştirelim. 

TÜM CLI ları tam yetki ile kullanabilirsin. 

Dev tools ları kullanmayı unutma !


