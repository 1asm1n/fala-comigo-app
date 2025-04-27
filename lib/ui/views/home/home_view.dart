import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: const Color.fromARGB(255, 230, 160, 183),
        actions: [
          if (viewModel.currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _logout(viewModel);
              },
            ),
        ],
      ),
      body: viewModel.currentUser == null
          ? Center(
              child: ElevatedButton.icon(
                onPressed: () => viewModel.loginWithGoogle(),
                icon: const Icon(Icons.login),
                label: const Text('Entrar com Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 188, 214),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            )
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: viewModel.otherUsersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum usuário encontrado"));
                }

                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user['isBot'] == true
                            ? const AssetImage('assets/images/bot_icon.png')
                            : NetworkImage(user['avatarUrl'] ?? '')
                                as ImageProvider,
                        child:
                            user['isBot'] == true && user['avatarUrl'] == null
                                ? const Icon(Icons.smart_toy)
                                : null,
                      ),
                      title: Text(user['nome']),
                      subtitle: user['isBot'] == true
                          ? const Text("Assistente virtual")
                          : null,
                      trailing: user['isBot'] == true
                          ? const Icon(Icons.smart_toy, color: Colors.green)
                          : null,
                      onTap: () => viewModel.navigateToChat(user),
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  void _logout(HomeViewModel viewModel) async {
    viewModel.logout();
    locator<NavigationService>().navigateTo(Routes.cadastroView);
  }
}
