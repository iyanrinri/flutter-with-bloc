import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/core/widgets/layouts/main.dart';

class NewsPage extends StatefulWidget {
  static const routeName = '/news';
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsArticles = [];
  bool isLoading = true;
  String errorMessage = '';

  // Replace with your GNews API key
  final String apiKey = '4e564e6eb55037e9a6fe6095603abafa';
  final String apiUrl =
      'https://gnews.io/api/v4/top-headlines?lang=id&country=id&max=20&q=indonesia&apikey=';

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl$apiKey'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          newsArticles = data['articles'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load news: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: MainLayout(
        title: 'Berita Terkini',
        titleIcon: const Icon(Icons.newspaper),
        child:
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : RefreshIndicator(
          onRefresh: fetchNews,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: newsArticles.length,
            itemBuilder: (context, index) {
              final article = newsArticles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              'https://pbs.twimg.com/profile_images/1513741421937045504/8fEVPrh7_x96.jpg',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article['source']['name'] ??
                                      'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'News Source',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            article['publishedAt']?.substring(0, 10) ??
                                '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(article['title'] ?? 'No title'),
                      const SizedBox(height: 12),
                      if (article['image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            article['image'],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                            const SizedBox(),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: const [
                          Icon(Icons.thumb_up_alt_outlined, size: 20),
                          Icon(Icons.comment_outlined, size: 20),
                          Icon(Icons.repeat, size: 20),
                          Icon(Icons.send_outlined, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
