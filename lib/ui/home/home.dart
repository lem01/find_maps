import 'dart:math';

import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double latitude = 0;
  double longitude = 0;

  final TextEditingController _controllerSearchAddress =
      TextEditingController();
  // late GoogleMapController mapController;
  Set<Marker> _markers = <Marker>{};
  LatLng? latlong;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  final TextEditingController _controllerLocation = TextEditingController();
  var address;

  Color primaryColor = const Color(0xffB6E13D);
  Color secoondaryColor = const Color(0xffFFFFFF);
  late BitmapDescriptor markerIcon;

  @override
  void initState() {
    setMarkerIcon();
    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    getCurrentLocation();

    super.initState();
  }

  Future<void> setMarkerIcon() async {
    final byteData = await rootBundle.load('assets/arrow_map.png');
    final Uint8List bytes = byteData.buffer.asUint8List();
    markerIcon = BitmapDescriptor.fromBytes(bytes);
  }

  Future getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude;
    longitude = position.longitude;
    List<Placemark> placemark =
        await placemarkFromCoordinates(latitude, longitude);

    if (mounted) {
      setState(() {
        latlong = LatLng(latitude, longitude);

        _cameraPosition =
            CameraPosition(target: latlong!, zoom: 15.0, bearing: 0);
        if (_controller != null) {
          _controller!
              .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
        }

        _markers = <Marker>{
          Marker(
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            markerId: const MarkerId('Marker'),
            position: LatLng(latitude!, longitude!),
          )
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData size = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          width: size.wp(100),
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              (latlong != null)
                  ? GoogleMap(
                      zoomControlsEnabled: false,
                      initialCameraPosition: _cameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller = (controller);

                        _controller!.animateCamera(
                            CameraUpdate.newCameraPosition(_cameraPosition));
                      },
                      markers: myMarker(),
                      onTap: (latLng) {
                        if (mounted) {
                          setState(
                            () {
                              latlong = latLng;
                            },
                          );
                        }
                      },
                    )
                  : Container(),
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: Container(
              //     padding: const EdgeInsets.all(10.0),
              //     child: FloatingActionButton(
              //       backgroundColor: secoondaryColor,
              //       onPressed: () {
              //         getCurrentLocation();
              //       },
              //       child: Icon(
              //         Icons.my_location,
              //         color: primaryColor,
              //       ),
              //     ),
              //   ),
              // ),

              btnLeft(size),
              btnRight(size),
              _searchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Positioned btnRight(MediaQueryData size) {
    return Positioned(
              bottom: size.hp(5),
              right: size.wp(5),
              child: SizedBox(
                height: size.hp(6),
                width: size.wp(35),
                child: CupertinoButton(
                  
                  padding: EdgeInsets.zero,
                  color: primaryColor,
                  child: SvgPicture.asset(
                    imagePath + "arrow_map.svg",
                    fit: BoxFit.contain ,
                    height: size.hp(3),
                  ),
                  onPressed: () {},
                ),
              ),
            );
  }

  Positioned btnLeft(MediaQueryData size) {
    return Positioned(
      bottom: size.hp(5),
      left: size.wp(5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: size.hp(6),
        width: size.wp(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: CupertinoButton(
                child: SvgPicture.asset(imagePath + 'location.svg'),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: CupertinoButton(
                child: SvgPicture.asset(imagePath + '360_icon.svg'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    MediaQueryData size = MediaQuery.of(context);
    return Positioned(
      left: 0,
      right: 0,
      top: size.hp(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.wp(6)),
        child: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            searchAddress(value);
          },
          controller: _controllerSearchAddress,
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
                searchAddress(_controllerSearchAddress.text);
              },
              icon: const Icon(Icons.search, color: Colors.black),
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

  //create method for search address
  Future<void> searchAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.length > 0) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(locations[0].latitude, locations[0].longitude),
                zoom: 15.0)));
      }
    } catch (e) {
      print(e);
    }
  }

  Set<Marker> myMarker() {
    _markers.clear();

    _markers = <Marker>{
      Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        markerId: MarkerId(Random().nextInt(10000).toString()),
        position: LatLng(latlong!.latitude, latlong!.longitude),
      ),
    };

    getLocation();

    return _markers;
  }

  Future<void> getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(latlong!.latitude, latlong!.longitude);
    latlong?.latitude.toString();
    latlong?.longitude.toString();
    address = placemark[0].name;
    address = address + ',' + placemark[0].subLocality;
    address = address + ',' + placemark[0].locality;
    address = address + ',' + placemark[0].administrativeArea;
    address = address + ',' + placemark[0].country;
    address = address + ',' + placemark[0].postalCode;
    _controllerLocation.text = address;
    if (mounted) setState(() {});
  }
}
