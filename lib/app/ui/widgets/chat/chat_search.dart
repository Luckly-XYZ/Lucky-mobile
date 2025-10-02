import 'package:flutter/material.dart';
import 'package:flutter_im/constants/app_colors.dart';

import '../../../../constants/app_sizes.dart';

class ChatSearchDecoration extends StatelessWidget {
  const ChatSearchDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kSize70,
      margin: const EdgeInsets.symmetric(horizontal: kSize36),
      decoration: BoxDecoration(
          color: kColor33, borderRadius: BorderRadius.circular(kSize35)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: kSize20, right: kSize16),
            child: Icon(Icons.search, color: kColor99),
          ),
          Text("搜索", style: TextStyle(color: kColor99))
        ],
      ),
    );
  }
}
