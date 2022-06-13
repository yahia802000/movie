import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../cubits/home_cubit.dart';
import '../cubits/home_states.dart';
import '../models/category.dart';
import 'movie_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => HomeCubit()..getCategories(),
        child: BlocBuilder<HomeCubit, HomeStates>(
          builder: (context, state) {
            if (state is HomeLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is HomeSuccessState) {
              final movies = state.movies;
              final categories = state.categories;
              return Column(
                children: [
                  CategoriesDropMenu(
                    items: categories,
                    onChanged: (value) {
                      context.read<HomeCubit>().getMoviesByCategory(true);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: movies.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailsScreen(movie: movies[index]),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Image.network(movies[index].image),
                              Text(movies[index].title),
                              Text(movies[index].rate),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: ElevatedButton(
                  onPressed: context.read<HomeCubit>().getCategories,
                  child: const Text('Error, Try again!'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class CategoriesDropMenu extends StatefulWidget {
  const CategoriesDropMenu({Key? key, required this.onChanged, required this.items})
      : super(key: key);
  final List<Category> items;
  final Function(Category) onChanged;

  @override
  State<CategoriesDropMenu> createState() => _CategoriesDropMenuState();
}

class _CategoriesDropMenuState extends State<CategoriesDropMenu> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Category>(
      value: context.read<HomeCubit>().selectedCategory,
      items: widget.items.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e.name),
      )).toList(),
      onChanged: (value) {
        context.read<HomeCubit>().selectedCategory = value!;
        widget.onChanged(value);
        setState(() {});
      },
    );
  }
}
