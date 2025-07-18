import 'package:flutter/material.dart';
import 'item_detail.dart'; // Assuming this file exists
import '../models/lost_and_found.dart'; // Assuming this file exists
import 'report.dart'; // ✨ Corrected import

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  int _selectedTabIndex = 0;

  // Your existing list of items
  final List<FoundItem> _allItems = [
    FoundItem(
      id: '#L0001',
      name: 'Apple Earpods with Red Case and blue keychain',
      date: '16 JULY 2025',
      location: 'Near LHC tapri',
      category: 'Electronics',
      imageUrl: 'https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?w=500',
      isLost: true,
      imageList: [
        'https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?w=500',
        'https://images.unsplash.com/photo-1610438235354-a6ae5528385c?w=500'
      ],
      description: 'Dell mouse RH6700 black color with RGb lights and red color scroll wheel, Dell mouse RH6700 black color with RGb lights and red color scroll wheel',
    ),
    FoundItem(
      id: '#F0002',
      name: 'Suncross Grey Cycle with Basket',
      date: '15 JULY 2025',
      location: 'Parking Lot',
      category: 'Vehicle',
      imageUrl: 'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=500',
      isLost: false,
    ),
  ];

  late List<FoundItem> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filterItems();
  }

  void _filterItems() {
    setState(() {
      _filteredItems = (_selectedTabIndex == 0)
          ? _allItems.where((item) => item.isLost).toList()
          : _allItems.where((item) => !item.isLost).toList();
    });
  }

  // ✨ The _showReportItemSheet method has been removed.

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterTabs(),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) => ItemCard(item: _filteredItems[index]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 95,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                // This is the corrected line with proper syntax
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => const ReportItemScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              backgroundColor: const Color.fromRGBO(19, 46, 158, 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Report Item',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Club',
        hintStyle: const TextStyle(color: Color(0xFF9EA3B0), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9EA3B0)),
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
        ChoiceChip(
          label: const Text('Lost Items'),
          selected: _selectedTabIndex == 0,
          onSelected: (selected) {
            if (selected) setState(() { _selectedTabIndex = 0; _filterItems(); });
          },
          backgroundColor: Colors.white,
          selectedColor: const Color.fromRGBO(19, 46, 158, 1),
          labelStyle: TextStyle(color: _selectedTabIndex == 0 ? Colors.white : Colors.black54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _selectedTabIndex == 0 ? Colors.transparent : Colors.grey.shade300)),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Found Items'),
          selected: _selectedTabIndex == 1,
          onSelected: (selected) {
            if (selected) setState(() { _selectedTabIndex = 1; _filterItems(); });
          },
          backgroundColor: Colors.white,
          selectedColor: const Color.fromRGBO(19, 46, 158, 1),
          labelStyle: TextStyle(color: _selectedTabIndex == 1 ? Colors.white : Colors.black54),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _selectedTabIndex == 1 ? Colors.transparent : Colors.grey.shade300)),
        ),
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  final FoundItem item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/itemDetail',
          arguments: item,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0x264661D1),
              blurRadius: 24,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isLost ? const Color(0xFFD15846) : const Color(0xFF7AB938),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    child: Text(item.isLost ? 'MISSING' : 'FOUND', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.date.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Divider(height: 1, color: Color(0xFFD1D7F4)),
            InkWell(
              onTap: () => print("${item.isLost ? 'Report as Found' : 'Claim this Item'} Tapped!"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  item.isLost ? 'Report as Found' : 'Claim this Item',
                  style: const TextStyle(color: Color(0xFF1E47F7), fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✨ The _ReportItemBottomSheet widget has been removed.