import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/search.dart';
import '../../logic/chat_list_provider.dart';

class ChatSearchDelegate extends SearchDelegate {
  final String? chatId; 

  ChatSearchDelegate({this.chatId});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<List<SearchResult>>(
          future: ref.read(chatDBProvider).searchMessages(query, chatId: chatId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text("No results for '$query'", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            final results = snapshot.data!;
            
            return ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_,__) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final result = results[index];
                
                return ListTile(
                  title: chatId == null 
                      ? Text(result.chatTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
                      : null,
                  subtitle: Text(
                    result.content.replaceAll('\n', ' '), 
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatDate(result.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  onTap: () {
                    close(context, null);
                  },
                );
              },
            );
          },
        );
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text("Type to search..."));
  }
  
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}