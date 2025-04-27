import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    const Color backgroundColor = Color(0xFFFFF0F3);
    const Color primaryColor = Color(0xFFFFCDD2);
    const Color accentColor = Color(0xFFF8BBD0);

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
                controller: viewModel.nomeController,
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
                controller: viewModel.emailController,
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
                controller: viewModel.idadeController,
                keyboardType: TextInputType.number,
                onChanged: viewModel.setIdade,
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
                  controller: viewModel.passwordController,
                  obscureText: true,
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
                  onPressed: viewModel.cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: viewModel.loginComGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    elevation: 2,
                  ),
                  child: SvgPicture.asset(
                      'fala_comigo_app/lib/assets/icons/google.svg'),
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
