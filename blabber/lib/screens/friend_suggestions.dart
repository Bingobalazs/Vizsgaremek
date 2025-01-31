import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/suggested_friend.dart';

class FriendSuggestionsScreen extends StatelessWidget {
  const FriendSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friend Suggestions")),
      body: FutureBuilder<List<SuggestedFriend>>(
        future: GetSuggestedFriends.fetchFriendSuggestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No friends found."));
          }

          List<SuggestedFriend> friends = snapshot.data!;
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return ListTile(
                /*leading: CircleAvatar(
                  backgroundImage: NetworkImage(friends[index].profilePicture),
                ),*/
                title: Text(friends[index].name),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Add"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
