import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';

class WorkspaceSelectionPage extends StatelessWidget {
  const WorkspaceSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Select Workspace'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<SessionCubit, SessionState>(
        bloc: getIt<SessionCubit>(),
        builder: (context, state) {
          if (state is SessionLoaded) {
            final roles = state.availableRoles;
            if (roles.isEmpty) {
              return Center(
                child: Text(
                  'No workspaces available.\nPlease contact support.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: roles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final role = roles[index];
                final roleName = role.roleName.toUpperCase();
                
                return Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    title: Text(
                      roleName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: role.gymId != null 
                        ? Text('Gym ID: ${role.gymId}')
                        : const Text('Global Access'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    onTap: () {
                      getIt<SessionCubit>().selectWorkspace(role);
                    },
                  ),
                );
              },
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
