import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class ApiService {
  // GANTI Alamat dasar (Base URL) API nya menjadi TVMAZE
  // static const String baseUrl = 'https://restaurant-api.dicoding.dev';  
  


static const String baseUrl = 'https://dummyjson.com'; 


  // 1. Fungsi untuk mengambil daftar artikel (News, Blog, atau Reports)
  // parameter category diisi: 'articles', 'blogs', atau 'reports'
  static Future<List<ItemModel>> getItems(String endpoint) async {
    // Menambahkan ?limit=30 agar data yang diambil cukup banyak untuk filter dan scroll
    // final url = Uri.parse('$baseUrl/$category/?limit=30');

    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        // 💡 KUNCI SUKSES RESPONSI:
        // Cek apakah bentuknya [ ... ] (List) atau { "results": [ ... ] } (Map)
        final List<dynamic> results;
        if (decoded is List) {
          // TVMaze langsung berupa List!
          results = decoded;
        } else if (decoded is Map) {
          // Jika ada bungkusannya seperti Spaceflight / TMDB atau yang lain
          results = decoded['recipes'] ?? 
            decoded['data'] ?? 
            decoded['items'] ?? 
            decoded['products'] ?? 
            decoded['meals'] ?? 
            decoded['articles'] ?? 
            [];
        } else {
          results = [];
        }
        return results
            .map((item) => ItemModel.fromJson(item, category: endpoint))
            .toList();
      } else {
        throw Exception('Gagal memuat data dari server (Kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
  // 2. Fungsi untuk mengambil detail satu artikel berdasarkan ID
  static Future<ItemModel> getItemDetail(String category, int id) async {
    final url = Uri.parse('$baseUrl/$category/$id/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ItemModel.fromJson(data, category: category);
      } else {
        throw Exception('Gagal memuat detail artikel (Kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan saat memuat detail: $e');
    }
  }
}

