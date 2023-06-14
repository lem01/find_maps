import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LowerBtn extends StatelessWidget {
  const LowerBtn({super.key});

  @override
  Widget build(BuildContext context) {
    var homeProvider = context.read<HomeProvider>();

    Widget leftBtn() {
      var btnShowSingleLocation = Expanded(
        child: CupertinoButton(
          child: SvgPicture.asset(imagePath + 'location.svg'),
          onPressed: () {},
        ),
      );
      var btnshowImage = Expanded(
        child: CupertinoButton(
          child: SvgPicture.asset(imagePath + '360_icon.svg'),
          onPressed: () {},
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
            btnShowSingleLocation,
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
