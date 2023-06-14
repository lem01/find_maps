import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:find_maps/ui/street/street.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LowerBtn extends StatelessWidget {
  final VoidCallback btn360;
  final VoidCallback btnShowSingleLocation;

  const LowerBtn({
    super.key,
    required this.btn360,
    required this.btnShowSingleLocation,
  });

  @override
  Widget build(BuildContext context) {
    var homeProvider = context.watch<HomeProvider>();

    Widget leftBtn() {
      var btnShowSingleLocationWidget = Expanded(
        child: CupertinoButton(
          child: SvgPicture.asset(imagePath + 'location.svg'),
          onPressed: () {
            btnShowSingleLocation();
          },
        ),
      );
      var btnshowImage = Expanded(
        child: CupertinoButton(
          child: SvgPicture.asset(imagePath + '360_icon.svg'),
          onPressed: () {
            btn360();
          },
        ),
      );
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: size.hp(6),
        width: size.wp(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            btnShowSingleLocationWidget,
            btnshowImage,
          ],
        ),
      );
    }

    Widget rightBtn() {
      var btnLocation = SizedBox(
        height: size.hp(6),
        width: size.wp(35),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: primaryColor,
          child: SvgPicture.asset(
            imagePath + "arrow_map.svg",
            fit: BoxFit.contain,
            height: size.hp(3),
          ),
          onPressed: () {
            homeProvider.setindexListWidget();
          },
        ),
      );

      var btnClose = SizedBox(
        height: size.hp(6),
        width: size.wp(35),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: Color(0xff333333),
          child: SvgPicture.asset(
            imagePath + "close.svg",
            fit: BoxFit.contain,
            height: size.hp(3),
          ),
          onPressed: () {
            homeProvider.setindexListWidget();
          },
        ),
      );

      return homeProvider.indexListWidget == 0 ? btnLocation : btnClose;
    }

    return Positioned(
        left: 0,
        right: 0,
        bottom: size.hp(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            leftBtn(),
            rightBtn(),
          ],
        ));
  }
}
