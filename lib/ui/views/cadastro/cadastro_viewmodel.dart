import 'package:stacked/stacked.dart';

class CadastroViewModel extends BaseViewModel {
  String nome = '';
  String email = '';
  String senha = '';
  int idade = 0;
  bool menorDeIdade = false;

  void setIdade(String value) {
    final intValue = int.tryParse(value) ?? 0;
    idade = intValue;
    menorDeIdade = idade < 12;
    notifyListeners();
  }
}
