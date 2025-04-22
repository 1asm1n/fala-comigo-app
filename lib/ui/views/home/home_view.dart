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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(viewModel); // Chama o método de logout
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // StreamBuilder para ouvir mudanças nos usuários
        stream: viewModel.otherUsersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("Nenhum usuário encontrado")); // Sem dados
          }

          final users = snapshot.data!; // Lista de usuários
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['avatarUrl'] ??
                      ''), // Corrigido com valor padrão caso não tenha URL
                ),
                title: Text(user['nome'] ??
                    'Sem nome'), // Corrigido com valor padrão caso não tenha nome
                onTap: () {
                  // Navega para a tela de chat, passando o ID do usuário
                  locator<NavigationService>().navigateToChatView(
                    otherUserId: user['uid'], nome: user['nome'],
                    // Corrigido para usar o parâmetro 'otherUserId'
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) =>
      HomeViewModel(); // Builder do ViewModel

  // Método para logout
  void _logout(HomeViewModel viewModel) async {
    viewModel.logout(); // Chama o método de logout no ViewModel
    locator<NavigationService>()
        .navigateTo(Routes.cadastroView); // Redireciona para a tela de cadastro
  }
}
