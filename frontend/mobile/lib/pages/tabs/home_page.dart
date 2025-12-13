import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// İlan modeli
class Ilan {
  final String baslik;
  final String aciklama;
  final String fiyat;
  final String konum;
  final String tarih;
  final String? resimUrl;

  Ilan({
    required this.baslik,
    required this.aciklama,
    required this.fiyat,
    required this.konum,
    required this.tarih,
    this.resimUrl,
  });

  // API'den gelen JSON'dan Ilan nesnesi oluşturma
  factory Ilan.fromJson(Map<String, dynamic> json) {
    return Ilan(
      baslik: json['baslik'] ?? '',
      aciklama: json['aciklama'] ?? '',
      fiyat: json['fiyat']?.toString() ?? '0 TL',
      konum: json['konum'] ?? '',
      tarih: json['tarih'] ?? '',
      resimUrl: json['resimUrl'],
    );
  }

  // İlan nesnesini JSON'a çevirme (POST/PUT istekleri için)
  Map<String, dynamic> toJson() {
    return {
      'baslik': baslik,
      'aciklama': aciklama,
      'fiyat': fiyat,
      'konum': konum,
      'tarih': tarih,
      'resimUrl': resimUrl,
    };
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _pageSize = 10;
  final PagingController<int, Ilan> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      
      // final response = await http.get(Uri.parse('YOUR_API_URL?page=$pageKey&limit=$_pageSize'));
      // final data = json.decode(response.body);
      // final List<Ilan> newItems = (data['items'] as List).map((json) => Ilan.fromJson(json)).toList();
      
      // Şimdilik simülasyon
      await Future.delayed(const Duration(seconds: 1));
      
      // Bu kısım veritabanından gelen verilerle değiştirilecek
      final newItems = _generateMockData(pageKey);

      // API'den gelen total count'a göre son sayfa belirlenir
      // final isLastPage = newItems.length < _pageSize;
      final isLastPage = pageKey >= 4; // Geçici: 5 sayfa simülasyonu
      
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // Geçici mock data generator - API'den veri gelince silinecek
  List<Ilan> _generateMockData(int pageKey) {
    return List.generate(
      _pageSize,
      (index) {
        final itemNumber = pageKey * _pageSize + index + 1;
        final fiyat = itemNumber * 100;
        return Ilan(
          baslik: 'İlan Başlığı $itemNumber',
          aciklama: 'Bu bir örnek ilan açıklamasıdır. İlan hakkında detaylı bilgi...',
          fiyat: '$fiyat TL',
          konum: 'İstanbul, Türkiye',
          tarih: '${itemNumber} saat önce',
          resimUrl: 'https://via.placeholder.com/150',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Ilan>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Ilan>(
        itemBuilder: (context, ilan, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // İlan detayına git
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İlan resmi
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      ilan.resimUrl ?? 'https://via.placeholder.com/150',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // İlan bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ilan.baslik,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ilan.aciklama,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              ilan.konum,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ilan.fiyat,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              ilan.tarih,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        firstPageErrorIndicatorBuilder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Hata oluştu'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _pagingController.refresh(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => const Center(
          child: Text('Hiç ilan bulunamadı'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
