import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateHabitPage extends ConsumerStatefulWidget {
  const CreateHabitPage({super.key});

  @override
  ConsumerState<CreateHabitPage> createState() => _CreateHabitPageStage();

}

class _CreateHabitPageStage extends ConsumerState<CreateHabitPage>{
  late final PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();

  }

  void _nextPage() {
    // TODO: Incluir validacoes de escolha do usuario

    if(_currentPage < _totalPages - 1){
      _pageController.nextPage(
        duration: const Duration(
          milliseconds: 300
        ), 
        curve: Curves.easeInOut
      );
    } else{
      Navigator.pop(context);
    }
  }

  void _previousPage(){
    if(_currentPage > 0){
      _pageController.previousPage(
        duration: const Duration(
          milliseconds: 300,
        ), 
        curve: Curves.easeInOut
      );
    } else{
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


}