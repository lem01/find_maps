import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:find_maps/ui/home/local_widgets/detail_location.dart';
import 'package:find_maps/ui/home/local_widgets/list_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSwitcher extends StatelessWidget {
  const CustomSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    var homeProvider = context.watch<HomeProvider>();

    List<Widget> listWidget = [
      ListLocations(onPressedDirection: () {}),
      const DetailLocation(),
    ];

    var switcher = Positioned(
      bottom: size.hp(15),
      left: 0,
      right: 0,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: listWidget[homeProvider.indexListWidget],
      ),
    );

    return switcher;
  }
}
