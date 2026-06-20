import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/models/history_state.dart';
import 'package:momentum/models/session_with_project.dart';
import 'package:momentum/notifiers/history_notifier.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);

    return SafeArea(
      child: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.red)
          ),
        ),
        data: (historyState) => _HistoryList(historyState: historyState),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final HistoryState historyState;

  const _HistoryList({required this.historyState});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _HistoryCard(sessionWithProjectName: historyState.sessions[i]),
            childCount: historyState.sessions.length
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SessionWithProjectName sessionWithProjectName;

  const _HistoryCard({required this.sessionWithProjectName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 2, color: Colors.black),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionWithProjectName.session.date.toLocal().toString().split(' ')[0],
                    style: TextStyle(
                      color: Colors.greenAccent
                    ),
                  ),

                  Text(sessionWithProjectName.session.note,
                    style: const TextStyle(
                      color: Color(0xFFE8E8E8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600
                    )
                  ),

                  Text(sessionWithProjectName.projectName,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    )
                  )
                ],
              ),

              Text("${sessionWithProjectName.session.durationMinutes} minutes",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
