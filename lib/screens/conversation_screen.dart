import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/conversation_message.dart';
import '../providers/conversation_provider.dart';
import '../widgets/chat_bubble.dart';

class ConversationScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String? imagePath;

  const ConversationScreen({
    super.key,
    required this.imageBytes,
    this.imagePath,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationProvider>().startConversation(
        widget.imageBytes,
        imagePath: widget.imagePath,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildImagePreview(),
            Expanded(child: _buildChat()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppTheme.pureWhite,
            ),
            onPressed: () {
              context.read<ConversationProvider>().reset();
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.goldGradient.createShader(bounds),
              child: const Text(
                'Glam AI Stylist',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldAccent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.imagePath != null
            ? Image.file(
                File(widget.imagePath!),
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Image.memory(
                widget.imageBytes,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      ),
    );
  }

  Widget _buildChat() {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final message = provider.messages[index];
            return ChatBubble(
              content: message.content,
              isUser: message.sender == MessageSender.user,
              isLoading: message.isLoading,
              options: message.options,
              onOptionSelected: (option) {
                provider.selectStyle(option);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        if (provider.currentStep == ConversationStep.askingOwnership) {
          return _buildOwnershipSelector(provider);
        } else if (provider.currentStep == ConversationStep.askingBudget) {
          return _buildBudgetInput(provider);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOwnershipSelector(ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleziona i capi che possiedi:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.pureWhite,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isOwned = provider.ownedItems[index];

              return FilterChip(
                label: Text('${item.typeEmoji} ${item.itemType}'),
                selected: isOwned,
                onSelected: (_) => provider.toggleOwnedItem(index),
                selectedColor: AppTheme.goldAccent.withOpacity(0.3),
                checkmarkColor: AppTheme.goldAccent,
                backgroundColor: AppTheme.cardBackground,
                labelStyle: TextStyle(
                  color: isOwned ? AppTheme.goldAccent : AppTheme.pureWhite,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildGoldButton(
              label: 'Conferma',
              icon: Icons.check,
              onPressed: () => provider.confirmOwnedItems(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInput(ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.pureWhite),
              decoration: InputDecoration(
                hintText: 'Il tuo budget in €',
                hintStyle: const TextStyle(color: AppTheme.softGray),
                prefixIcon: const Icon(Icons.euro, color: AppTheme.goldAccent),
                filled: true,
                fillColor: AppTheme.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildGoldButton(
            label: 'Invia',
            icon: Icons.send,
            onPressed: () {
              final budget = double.tryParse(_budgetController.text);
              if (budget != null && budget > 0) {
                provider.setBudget(budget);
                _budgetController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoldButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.goldGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldAccent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryBlack, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
