import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heads_upp/db%20state%20management/head_up_logic.dart';
import 'package:heads_upp/db%20state%20management/head_up_state.dart';
import 'package:heads_upp/display_words.dart';

class CategorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch categories only if they are not already fetched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<HeadsUplogic>().state is! CategoriesFetched) {
        context.read<HeadsUplogic>().fetchCategories();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Select Category')),
      body: BlocBuilder<HeadsUplogic, HeadUpState>(
        builder: (context, state) {
          if (state is CategoriesFetched) {
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameScreen(categoryId: category.id),
                      ),
                    );
                  },
                  child: Text(category.name),
                );
              },
            );
          } else if (state is ErrorState) {
            return Center(child: Text(state.message));
          } else {
            // Show a loading indicator while categories are being fetched
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
