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
      body: SingleChildScrollView(
        // Adjusted padding after removing the button
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.name,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text(widget.item.description,
                style: const TextStyle(color: Colors.black54, height: 1.5)),
            const SizedBox(height: 24),
            _buildImageCarousel(),
            const SizedBox(height: 16),
            _buildPageIndicator(),
            const SizedBox(height: 24),
            _buildInfoRow('Category:', widget.item.category),
            const SizedBox(height: 16),
            _buildInfoRow('Last seen on:', widget.item.date),
            const SizedBox(height: 16),
            _buildInfoRow('Last seen at:', widget.item.location),
          ],
        ),
      ),
      // REMOVED Positioned widget with the ElevatedButton
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
            child: Image.network(
              widget.item.imageList[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    if (widget.item.imageList.length <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.item.imageList.length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? const Color(0xFF132E9E)
                : Colors.grey.shade400,
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}