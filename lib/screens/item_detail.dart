import 'package:flutter/material.dart';
import '../models/lost_and_found.dart';

class ItemDetailScreen extends StatefulWidget {
  final FoundItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF132E9E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.item.id,
          style: const TextStyle(
            color: Color(0xFF132E9E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Use a Stack to place the button over the scrollable content
      body: Stack(
        children: [
          // Your scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Add padding at bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Text(widget.item.description, style: const TextStyle(color: Colors.black54, height: 1.5)),
                const SizedBox(height: 24),
                _buildImageCarousel(),
                const SizedBox(height: 16),
                _buildPageIndicator(),
                const SizedBox(height: 24),
                _buildInfoRow('Unique Identification Mark:', widget.item.category),
                const SizedBox(height: 16),
                _buildInfoRow('Last seen on:', '${widget.item.date} | 06:45 PM'),
                const SizedBox(height: 16),
                _buildInfoRow('Last seen at:', widget.item.location),
              ],
            ),
          ),
          // "I have found this item" button at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () => print("I have found this item Tapped!"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132E9E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('I have found this item', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
      // --- REMOVE THE bottomNavigationBar PROPERTY ---
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.item.imageList.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(widget.item.imageList[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.item.imageList.length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? const Color(0xFF132E9E) : Colors.grey.shade400,
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}