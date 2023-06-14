import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';

class SearchBar extends StatelessWidget {
  final VoidCallback onPressed;
  final Function(String)? onSubmitted;
  const SearchBar({
    super.key,
    required this.onPressed,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: size.hp(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.wp(6)),
        child: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          // searchAddress(value);
          // },
          controller: HomeProvider.controllerSearchAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Where are you going to?",
            hintStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: IconButton(
              onPressed: () {
                onPressed();
                // searchAddress(HomeProvider.controllerSearchAddress.text);
              },
              icon: SvgPicture.asset(
                imagePath + 'search.svg',
                fit: BoxFit.cover,
                height: size.hp(2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent, width: 0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent, width: 0),
            ),
          ),
        ),
      ),
    );
  }
}
