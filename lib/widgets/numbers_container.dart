import 'package:flutter/material.dart';

class NumbersContainer extends StatelessWidget {
  const NumbersContainer({
    super.key,
    required this.title,
    required this.data,
    this.colors,
  });

  final String title;
  final List<int> data;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext ctx, int index) {
                return Center(
                  child: Text(
                    "${data[index]}",
                    style: TextStyle(
                      color: colors == null ? Colors.white : colors![index],
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
