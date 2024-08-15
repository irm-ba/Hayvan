import 'package:flutter/material.dart';
import 'package:pet_adoption/deneme_service.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          // child: Column(
          //   children: [],
          // ),
          child: SizedBox(
            height: 99999,
            child: FutureBuilder<dynamic>(
              future: DenemeService().getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                return ListView.builder(
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(data.docs[index]['Name']),
                      subtitle: const Text('subtitle'),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
