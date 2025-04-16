// lib/screens/social/leaderboard_screen.dart
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Örnek liderlik tablosu verileri
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'User1',
      'points': 120,
      'hours': 6,
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      'isFriend': true,
    },
    {
      'id': '2',
      'name': 'User2',
      'points': 115,
      'hours': 4,
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
      'isFriend': true,
    },
    {
      'id': '3',
      'name': 'User3',
      'points': 110,
      'hours': 3,
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
      'isFriend': true,
    },
    {
      'id': '4',
      'name': 'User4',
      'points': 105,
      'hours': 5,
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
      'isFriend': false,
    },
    {
      'id': '5',
      'name': 'User5',
      'points': 100,
      'hours': 4,
      'avatar': 'https://randomuser.me/api/portraits/men/5.jpg',
      'isFriend': false,
    },
    {
      'id': '6',
      'name': 'User6',
      'points': 95,
      'hours': 3,
      'avatar': 'https://randomuser.me/api/portraits/women/6.jpg',
      'isFriend': false,
    },
    {
      'id': '7',
      'name': 'User7',
      'points': 90,
      'hours': 2,
      'avatar': 'https://randomuser.me/api/portraits/men/7.jpg',
      'isFriend': true,
    },
    {
      'id': '8',
      'name': 'User8',
      'points': 85,
      'hours': 3,
      'avatar': 'https://randomuser.me/api/portraits/women/8.jpg',
      'isFriend': false,
    },
    {
      'id': '9',
      'name': 'User9',
      'points': 80,
      'hours': 2,
      'avatar': 'https://randomuser.me/api/portraits/men/9.jpg',
      'isFriend': false,
    },
    {
      'id': '10',
      'name': 'User10',
      'points': 75,
      'hours': 2,
      'avatar': 'https://randomuser.me/api/portraits/women/10.jpg',
      'isFriend': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Weekly Ranking'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingTab(),
          _buildFriendsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFriendDialog();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  // Haftalık sıralama sekmesi
  Widget _buildRankingTab() {
    // Puanlara göre sırala
    final rankedUsers = List<Map<String, dynamic>>.from(_users)
      ..sort((a, b) => b['points'].compareTo(a['points']));
    
    return Column(
      children: [
        // İlk 3 kullanıcı
        if (rankedUsers.length >= 3) _buildTopThreeUsers(rankedUsers.take(3).toList()),
        
        // Diğer kullanıcılar listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rankedUsers.length,
            itemBuilder: (context, index) {
              return _buildUserRankItem(rankedUsers[index], index + 1);
            },
          ),
        ),
      ],
    );
  }

  // İlk 3 kullanıcı görünümü
  Widget _buildTopThreeUsers(List<Map<String, dynamic>> topUsers) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2. sıra
          if (topUsers.length > 1)
            _buildTopUserWidget(topUsers[1], 2, 90, Colors.grey.shade400),
          
          // 1. sıra
          _buildTopUserWidget(topUsers[0], 1, 110, Colors.amber),
          
          // 3. sıra
          if (topUsers.length > 2)
            _buildTopUserWidget(topUsers[2], 3, 70, Colors.brown.shade300),
        ],
      ),
    );
  }

  // İlk 3 kullanıcı widget'ı
  Widget _buildTopUserWidget(Map<String, dynamic> user, int rank, double size, Color color) {
    return Column(
      children: [
        // Rozet
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Icon(
              Icons.person,
              size: size / 2,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // İsim
        Text(
          user['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        
        // Puan
        Text(
          '${user['points']} points',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Kullanıcı sıralama öğesi
  Widget _buildUserRankItem(Map<String, dynamic> user, int rank) {
    // İlk 3 sıradaki kullanıcıları atla (zaten üstte gösteriliyor)
    if (rank <= 3) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${user['points']} points'),
        trailing: user['isFriend']
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(
                onPressed: () {
                  // Arkadaş ekle
                  setState(() {
                    user['isFriend'] = true;
                  });
                },
                child: const Text('Add Friend'),
              ),
      ),
    );
  }

  // Arkadaşlar sekmesi
  Widget _buildFriendsTab() {
    final friends = _users.where((user) => user['isFriend']).toList();
    
    return friends.isEmpty
        ? const Center(child: Text('No friends added yet.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return _buildFriendItem(friends[index]);
            },
          );
  }

  // Arkadaş öğesi
  Widget _buildFriendItem(Map<String, dynamic> friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person),
        ),
        title: Text(
          friend['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${friend['points']} points'),
        trailing: Text('${friend['hours']} hours'),
      ),
    );
  }

  // Arkadaş ekleme iletişim kutusu
  void _showAddFriendDialog() {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Friends'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Arama işlemi
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend request sent'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
