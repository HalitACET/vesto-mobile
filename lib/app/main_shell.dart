import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/core/widgets/molecules/vesto_bottom_nav.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.child, super.key});
  
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    int currentIndex = 0;
    if (location.startsWith('/profile')) {
      currentIndex = 1;
    }
    
    return Scaffold(
      body: child,
      bottomNavigationBar: VestoBottomNav(
        selectedIndex: currentIndex,
        items: const [
          VestoBottomNavItem(
            icon: Icons.checkroom_outlined,
            label: 'Gardırop',
          ),
          VestoBottomNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/wardrobe');
              break;
            case 1:
              context.go('/profile');
              break;
          }
        },
      ),
      floatingActionButton: location == '/wardrobe' 
        ? FloatingActionButton(
            onPressed: () => context.push('/wardrobe/add'),
            backgroundColor: AppColors.onyx,
            foregroundColor: AppColors.pearl,
            elevation: 2,
            child: const Icon(Icons.add),
          )
        : null,
    );
  }
}
