import 'package:flutter/material.dart';
import '../../../data/services/icoin_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<int?> _balanceFuture;
  late Future<List<ICoinTransaction>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _balanceFuture = ICoinService.getBalance();
      _historyFuture = ICoinService.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ví của tôi'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          _buildBalanceSummary(),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Icon(Icons.history, size: 20),
                SizedBox(width: 8),
                Text('Lịch sử giao dịch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ICoinTransaction>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final history = snapshot.data ?? [];
                if (history.isEmpty) {
                  return const Center(child: Text('Chưa có giao dịch nào'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final tx = history[index];
                    final isNegative = tx.transactionType == 'DEDUCT' || tx.transactionType == 'COMMIT';
                    final isHold = tx.transactionType == 'HOLD';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isHold ? Colors.orange[50] : (isNegative ? Colors.red[50] : Colors.green[50]),
                          child: Icon(
                            isHold ? Icons.lock : (isNegative ? Icons.arrow_downward : Icons.arrow_upward),
                            color: isHold ? Colors.orange : (isNegative ? Colors.red : Colors.green),
                            size: 20,
                          ),
                        ),
                        title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(tx.createdAt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isNegative ? '-' : '+'}${tx.amount} Xu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isHold ? Colors.orange : (isNegative ? Colors.red : Colors.green),
                              ),
                            ),
                            Text('Dư: ${tx.balanceAfter}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[800]!, Colors.blue[600]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Số dư hiện tại', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          FutureBuilder<int?>(
            future: _balanceFuture,
            builder: (context, snapshot) {
              final balance = snapshot.data ?? 0;
              return Text(
                '$balance Xu',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActionBtn(Icons.add_circle_outline, 'Nạp thêm'),
              const SizedBox(width: 12),
              _buildActionBtn(Icons.payment, 'Chuyển Xu'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}