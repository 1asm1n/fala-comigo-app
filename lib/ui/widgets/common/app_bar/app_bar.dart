import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'app_bar_model.dart';

class AppBarWidget extends StackedView<AppBarModel>
    implements PreferredSizeWidget {
  final String title;
  final Function()? onBack;
  final bool hasBackButton;
  final String? text;

  const AppBarWidget({
    super.key,
    required this.title,
    this.onBack,
    this.hasBackButton = true,
    this.text,
  });

  @override
  Widget builder(
    BuildContext context,
    AppBarModel viewModel,
    Widget? child,
  ) {
    return Container(
      // Substitua por decContainer se for um container customizado.
      color: Colors.blue, // Substitua por kcBlue3 se definido.
      child: SafeArea(
        child: Container(
          height: 59,
          color: Colors.pink,
          child: Row(
            children: [
              if (hasBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  color: Colors.white,
                ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (text != null) ...[
                const SizedBox(width: 10),
                Text(
                  text!,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  AppBarModel viewModelBuilder(BuildContext context) => AppBarModel();

  @override
  Size get preferredSize => const Size.fromHeight(62);
}
