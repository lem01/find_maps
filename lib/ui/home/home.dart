import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:find_maps/helper/constant.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import 'package:find_maps/ui/home/home_provider.dart';
import 'package:find_maps/ui/home/local_widgets/detail_location.dart';
import 'package:find_maps/ui/home/local_widgets/list_location.dart';
import 'package:find_maps/ui/home/local_widgets/lower_btn.dart';
import 'package:find_maps/ui/home/local_widgets/search_bar.dart';
import 'package:find_maps/ui/home/local_widgets/swicher.dart';
import 'package:find_maps/ui/street/street.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double latitude = 12.106509502683751;
  double longitude = -86.26329875983458;

  // final TextEditingController _controllerSearchAddress =
  //     TextEditingController();

  Set<Marker> _markers = <Marker>{};
  late LatLng? latlong;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  final TextEditingController _controllerLocation = TextEditingController();
  var address;

  late BitmapDescriptor markerIcon;

  @override
  void initState() {
    setMarkerIcon();
    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    getCurrentLocation();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    HomeProvider.controllerSearchAddress.dispose();
    _controller!.dispose();
    _controllerLocation.dispose();
  }

  Future<void> setMarkerIcon() async {
    final byteData = await rootBundle.load('assets/arrow_map.png');
    final Uint8List bytes = byteData.buffer.asUint8List();
    markerIcon = BitmapDescriptor.fromBytes(bytes);
  }

  Future getCurrentLocation() async {
    latlong = LatLng(latitude, longitude);
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
    var homeProvider = context.watch<HomeProvider>();
    MediaQueryData size = MediaQuery.of(context);

    var googleMap = GoogleMap(
      zoomControlsEnabled: false,
      initialCameraPosition: _cameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _controller = (controller);

        _controller!
            .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
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
    );

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: size.wp(100),
          height: size.hp(100),
          child: Stack(
            children: [
              (latlong != null) ? googleMap : Container(),
              const CustomSwitcher(),
              SearchBar(onPressed: () {
                searchAddress(HomeProvider.controllerSearchAddress.text);
              }, onSubmitted: (value) {
                searchAddress(value);
              }),
              const LowerBtn(),
            ],
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
