import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentum/models/history_state.dart';
import 'package:momentum/models/session_with_project.dart';
import 'package:momentum/notifiers/history_notifier.dart';
import 'package:momentum/routing/routes.dart';

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
            style: TextStyle(color: Theme.of(context).colorScheme.error)
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
    if (historyState.sessions.isEmpty) {
      return Center(
        child: Text(
          "No sessions!",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
          ),
        ),
      );
    }

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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 2, color: colorScheme.surface),
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
                      color: colorScheme.secondary
                    ),
                  ),

                  Text(sessionWithProjectName.session.note,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600
                    )
                  ),

                  GestureDetector(
                    onTap: () {
                      final projectId = sessionWithProjectName.session.projectId;
                      context.push(
                        Routes.project.replaceAll(":id", projectId.toString())
                      );
                    },
                    child: Text(sessionWithProjectName.projectName,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline
                      )
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
