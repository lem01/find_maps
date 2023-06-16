import 'dart:ffi';
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
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:find_maps/helper/media_query_data_extensions.dart';
import "package:google_maps_directions/google_maps_directions.dart" as gmd;

import 'package:location/location.dart' as loc;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeProvider homeProvider = HomeProvider();
  @override
  void initState() {
    // addMarkers();
    //inicializar Las direcciones para que pueda tomar la ruta mas corta
    gmd.GoogleMapsDirections.init(googleAPIKey: googleAPIKey);
    // todo: por hacer
    // _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 14.0);

// establece la ubicación inicial
    Future.delayed(Duration.zero, () {
      homeProvider.initCurrentLocation();
    });

    // suscribirse a los cambios en la ubicación del usuario
    // "escuchando" el evento onLocationChanged de la ubicación
    // location.onLocationChanged.listen((loc.LocationData cLoc) {
    //   // cLoc contiene el lat y el largo del
    //   // posición del usuario actual en tiempo real,
    //   // así que nos aferramos a eso
    //   currentLocation = cLoc;
    // });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    HomeProvider.controllerSearchAddress.dispose();
    HomeProvider.googleMapController.dispose();
    //   _controllerLocation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var homeProvider = Provider.of<HomeProvider>(context);
    MediaQueryData size = MediaQuery.of(context);

    var googleMap = GoogleMap(
      tiltGesturesEnabled: true,
      compassEnabled: true,
      scrollGesturesEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      initialCameraPosition: homeProvider.cameraPosition,
      polylines: Set<Polyline>.of(homeProvider.polylines),
      onMapCreated: (GoogleMapController controller) {
        HomeProvider.googleMapController = (controller);

        HomeProvider.googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(homeProvider.cameraPosition));
      },
      markers: homeProvider.markers,
      onTap: (latLng) {
        if (mounted) {
          homeProvider.marcarDestino(latLgn: latLng);
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
              (homeProvider.destinationPosition != null)
                  ? googleMap
                  : Container(),
              const CustomSwitcher(),
              SearchBar(onPressed: () {
                homeProvider
                    .searchAddress(HomeProvider.controllerSearchAddress.text);
              }, onSubmitted: (value) {
                homeProvider.searchAddress(value);
              }),
              LowerBtn(
                btnShowSingleLocation: () {
                  homeProvider.setindexListWidget();
                },
                btn360: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Street(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
