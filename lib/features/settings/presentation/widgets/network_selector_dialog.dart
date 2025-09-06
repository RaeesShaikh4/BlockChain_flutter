import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/network_provider.dart';
import '../../../../core/constants/network_constants.dart';

class NetworkSelectorDialog extends ConsumerWidget {
  const NetworkSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkProvider);
    
    return AlertDialog(
      title: const Text('Select Network'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: NetworkConstants.networkConfigs.values.map((network) {
            final isSelected = network.id == networkState.currentChainId;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: network.isTestnet
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    network.isTestnet ? Icons.science : Icons.security,
                    color: network.isTestnet ? Colors.orange : Colors.green,
                    size: 20,
                  ),
                ),
                title: Text(
                  network.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  network.isTestnet ? 'Test Network' : 'Main Network',
                  style: TextStyle(
                    color: network.isTestnet ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () async {
                  if (!isSelected) {
                    await ref.read(networkProvider.notifier).switchNetwork(network.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
