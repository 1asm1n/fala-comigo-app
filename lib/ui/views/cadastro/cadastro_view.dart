import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'cadastro_viewmodel.dart';

class CadastroView extends StackedView<CadastroViewModel> {
  const CadastroView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CadastroViewModel viewModel,
    Widget? child,
  ) {
    final Color backgroundColor = const Color(0xFFFFF0F3); // Rosa pastel claro
    final Color primaryColor = const Color(0xFFFFCDD2); // Vermelho claro
    final Color accentColor = const Color(0xFFF8BBD0); // Rosa pastel suave

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Cadastro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                onChanged: (value) => viewModel.nome = value,
                decoration: InputDecoration(
                  hintText: 'Nome',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => viewModel.email = value,
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  viewModel.setIdade(value);
                },
                decoration: InputDecoration(
                  hintText: 'Idade',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (viewModel.menorDeIdade)
                Text(
                  "O app é proibido para menores de 12 anos.",
                  style: TextStyle(color: Colors.red[300]),
                ),
              if (!viewModel.menorDeIdade) ...[
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  onChanged: (value) => viewModel.senha = value,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  CadastroViewModel viewModelBuilder(BuildContext context) =>
      CadastroViewModel();
}
