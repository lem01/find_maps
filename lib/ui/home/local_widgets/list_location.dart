import 'package:card_swiper/card_swiper.dart';
import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:find_maps/main.dart';
import 'package:provider/provider.dart';

class ListLocations extends StatelessWidget {
  final VoidCallback onPressedDirection;

  const ListLocations({
    super.key,
    required this.onPressedDirection,
  });

  @override
  Widget build(BuildContext context) {
    var homeProvider = context.watch<HomeProvider>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      constraints: BoxConstraints(
        maxHeight: size.hp(18),
        minHeight: size.hp(12),
      ),
      height: size.hp(12),
      width: double.infinity,
      child: Swiper(
        loop: false,
        viewportFraction: 0.75, // Ajusta el tamaño de cada elemento
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: size.wp(1.5)),
            child: GestureDetector(
              onTap: () {
                onPressedDirection();
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      SizedBox(
                          height: size.dp(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              imagePath + 'pizza.png',
                              fit: BoxFit.cover,
                            ),
                          )),
                      SizedBox(
                        width: size.wp(5),
                      ),
                      Expanded(
                        flex: 2,
                        child: Wrap(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: size.hp(1)),
                              child: Text(homeProvider.placeMark.isNotEmpty
                                  ? homeProvider.placeMark[4].name.toString()
                                  : ''),
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
