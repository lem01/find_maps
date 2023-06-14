import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:find_maps/ui/street/street.dart';
import 'package:flutter/material.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DetailLocation extends StatelessWidget {
  const DetailLocation({super.key});

  @override
  Widget build(BuildContext context) {
    var homeProvider = context.watch<HomeProvider>();
    return Container(
      height: size.hp(18),
      margin: EdgeInsets.symmetric(horizontal: size.wp(1.5)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Street(),
            ),
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                    child: Image.asset(
                  imagePath + 'pizza.png',
                  fit: BoxFit.cover,
                )),
                SizedBox(
                  width: size.wp(5),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: size.hp(1)),
                        child: Text(
                          homeProvider.placeMark.isNotEmpty
                              ? homeProvider.placeMark[4].name.toString()
                              : '',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.hp(1)),
                        child: Text(
                          'Pizza Hot',
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: size.dp(2),
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: size.hp(1)),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              imagePath + 'single_location.svg',
                              fit: BoxFit.contain,
                              height: size.dp(1.5),
                            ),
                            SizedBox(width: size.wp(1)),
                            Text(
                              homeProvider.distance.isNotEmpty
                                  ? homeProvider.distance
                                  : '',
                            ),
                            Text(
                              homeProvider.timeDuration.isNotEmpty
                                  ? ' ' + homeProvider.timeDuration
                                  : '',
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: SvgPicture.asset(imagePath + 'direction_arrow.svg')),
                SizedBox(
                  width: size.wp(2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }
}
