import 'package:fala_comigo_app/models/chatUserModel';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCDD2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Fala Comigo 💬',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 8),
          GestureDetector(
            //fazedor de botoes clicaveis(tipo ontap)
            onTap: viewModel
                .logout, //chamando a funçao de logout da viewmodel para o botao clicavel(ontap)
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: viewModel.chats.length,
              itemBuilder: (context, index) {
                final ChatUserModel chat = viewModel.chats[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade100.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(chat.avatarUrl),
                        radius: 25,
                      ),
                      title: Text(
                        chat.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAD1457),
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        chat.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6D4C41),
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: Color(0xFFBCAAA4)),
                      onTap: () {
                        // ir para tela de mensagens com o chat.id ou chat.email
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
