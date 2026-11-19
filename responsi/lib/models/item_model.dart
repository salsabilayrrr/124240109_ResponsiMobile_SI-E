//ini api baru
class ItemModel {
  //KALO MISAL ID nya tipe INT
  final int id;

  final String title;
  final String author;
  final String imageUrl;
  final String summary;
  final String publishedAt;
  // final String url;
  final String category;
  final int platform;
  final String publisher;
  final int developer;
  // 1️⃣ TAMBAHKAN VARIABEL RATING DI SINI
  final double rating;

  ItemModel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.summary,
    required this.publishedAt,
    // required this.url,
    required this.category,
    // 2️⃣ MASUKKAN KE CONSTRUCTOR (DIBERI DEFAULT 0.0 AGAR TIDAK ERROR JIKA KOSONG)
    this.rating = 0.0, //jangan ada required
    required this.platform,
    required this.publisher,
    required this.developer,

  });

  // Mengubah data mentah Map/JSON dari internet menjadi objek ItemModel yang rapi
  factory ItemModel.fromJson(
    Map<String, dynamic> json, {
    String category = 'articles',
  }) {
    return ItemModel(
      //INI KALO ID NYA INT
      id: json['id'] ?? 0,

      title: json['name'] ?? 'Tanpa Judul', //hanya ganti menjadi name dari tittle
      // 2 yang berbeda formatnya yaitu author karena masuk genre dan image karna didalamnya masuk objek lagi
      //dari ini
      // author: json['news_site'] ?? 'Unknown',
      // imageUrl: json['image_url'] ?? '',
      // menjadi
      // 3. Di TVMaze kategorinya adalah array 'genres', kita gabung jadi teks
      // author: (json['genres'] as List?)?.join(', ') ?? 'Umum',

      // 4. Di TVMaze link gambar ada di dalam objek 'image' -> 'medium'
      imageUrl: json['image'] ?? '',

      //BARUUUU
      author: json['cuisine'] ?? 'Tidak ada gambar.',
      publishedAt: json['difficulty'] ?? '',

      summary: (json['ingredients'] as List?)?.join(', ') ?? 'Umum',
      // publishedAt: json['premiered'] ?? '',   //hanya ganti menjadi premiered dari published_at
      // url:
      //     json['freetogame_profile_url'] ??
          // '', //hanya ganti menjadi officialSite dari url
      category: category,

      // 3️⃣ CARA AMBIL RATING DARI TVMAZE:
      // Masuk ke 'rating' -> ambil 'average' -> ubah jadi double (angka desimal seperti 6.5)
      //KARNA DI TVMAZE ITU KAYA GINI FORMAT API NYA "rating": {
      // "average": 6.6
      // rating: (json['rating']?['average'] as num?)?.toDouble() ?? 0.0,

      //TAPI KARNA YANG RESTAURANT INI RATIING NYA MEMILIKI FORMAT API
      //"rating": 4.2
      //JADI NYA
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      platform: json['prepTimeMinutes'] ?? 0,

      publisher:  (json['instructions'] as List?)?.join(', ') ?? 'Umum',
      developer: json['cookTimeMinutes'] ?? 0,
    );
  }

  // Mengubah objek ItemModel kembali ke bentuk Map/JSON (berguna untuk SharedPreferences favorit)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'news_site': author,
      'summary': summary,
      'published_at': publishedAt,
      'category': category,
      // 'platform': platform,
      'publisher' : publisher,
      // 'developer' : developer,

      // SIMPAN JUGA RATING KE JSON FAVORIT
      'rating': rating,
    };
  }
}
