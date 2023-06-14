import 'package:card_swiper/card_swiper.dart';
import 'package:find_maps/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:find_maps/main.dart';

class ListLocations extends StatelessWidget {
  final VoidCallback onPressedDirection;

  const ListLocations({
    super.key,
    required this.onPressedDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          // width: size.dp(10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: size.hp(1)),
                              child: Text('Pizza Hot'),
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
                                  Text('10 mts')
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
