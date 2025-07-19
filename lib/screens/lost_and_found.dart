import 'package:flutter/material.dart';
import '../services/lost_and_found_api.dart';
import '../models/lost_and_found.dart';
import 'item_detail.dart';
import 'report.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  int _selectedTabIndex = 0;
  final LostAndFoundApiService _apiService = LostAndFoundApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<FoundItem> _lostItems = [];
  List<FoundItem> _foundItems = [];
  List<FoundItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
      setState(() {
        _searchQuery = _searchController.text;
        _filterItems();
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.fetchItems('LOST'),
        _apiService.fetchItems('FOUND'),
      ]);

      if (mounted) {
        setState(() {
          _lostItems = results[0];
          _foundItems = results[1];
          _isLoading = false;
          _filterItems();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterItems() {
    final sourceList = (_selectedTabIndex == 0) ? _lostItems : _foundItems;

    if (_searchQuery.isEmpty) {
      _filteredItems = sourceList;
    } else {
      _filteredItems = sourceList
          .where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      _filterItems();
    });
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('An error occurred:\n$_errorMessage',
              textAlign: TextAlign.center),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      final status = _selectedTabIndex == 0 ? 'lost' : 'found';
      final message = _searchQuery.isNotEmpty
          ? 'No results found for "$_searchQuery".'
          : 'No $status items reported yet.';
      return Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8, // Adjusted for shorter card
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) => ItemCard(item: _filteredItems[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(19, 46, 158, 1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Row(
          children: [
            Text(
              'Lost & found',
              style: TextStyle(
                color: Color.fromRGBO(19, 46, 158, 1),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Text('🔎', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchData,
            color: const Color.fromRGBO(19, 46, 158, 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildFilterTabs(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 95,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => const ReportItemScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              backgroundColor: const Color.fromRGBO(19, 46, 158, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Report Item',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for items...',
        hintStyle: const TextStyle(color: Color(0xFF9EA3B0), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9EA3B0)),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Color(0xFF9EA3B0)),
          onPressed: () => _searchController.clear(),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFFD9DBE0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFFD9DBE0)),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildChoiceChip(label: 'Lost Items', index: 0),
        const SizedBox(width: 8),
        _buildChoiceChip(label: 'Found Items', index: 1),
      ],
    );
  }

  Widget _buildChoiceChip({required String label, required int index}) {
    final isSelected = _selectedTabIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _onTabSelected(index);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: const Color.fromRGBO(19, 46, 158, 1),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black54),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final FoundItem item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String personLabel = item.isLost ? 'Lost by' : 'Found by';
    final String personName =
        (item.isLost ? item.owner?.name : item.finder?.name) ?? 'N/A';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x264661D1),
              blurRadius: 24,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // To fit content
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        child:
                        const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 0,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isLost
                          ? const Color(0xFFD15846)
                          : const Color(0xFF7AB938),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    child: Text(item.isLost ? 'MISSING' : 'FOUND',
                        style:
                        const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.date.toUpperCase(),
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (item.owner?.avatarUrl != null)
                            ? NetworkImage(item.owner!.avatarUrl!)
                            : null,
                        child: (item.owner?.avatarUrl == null)
                            ? const Icon(Icons.person_outline,
                            size: 12, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$personLabel: $personName',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // REMOVED Spacer, Divider, and InkWell
          ],
        ),
      ),
    );
  }
}