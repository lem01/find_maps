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
  double latitude = 12.106509502683751;
  double longitude = -86.26329875983458;

  late LatLng? destinationPosition;
  late CameraPosition _cameraPosition;
  late GoogleMapController _controller;
  final TextEditingController _controllerLocation = TextEditingController();
  var address;

  late BitmapDescriptor markerIcon;

  // loc.Location location = loc.Location();

  bool _serviceEnabled = false;
  late loc.PermissionStatus _permissionGranted;
  // late loc.LocationData currentLocation;

//  navegacion
  Set<Marker> _markers = <Marker>{};

// para mis rutas dibujadas en el mapa

  List<Polyline> polylines = [];
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  // String googleAPIKey = "AIzaSyD9aH9-SZKB-DskiZ2WcbxB-8ErWfGcUAs";
  String googleAPIKey = "AIzaSyDECt6G853VOuXC-VrkeBB9lFotsSzSB4U";
// para mis marcadores personalizados
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;

// la ubicación inicial del usuario y la ubicación actual
// a medida que se mueve
  late loc.LocationData currentLocation;
// una referencia a la ubicación de destino
  late loc.LocationData destinationLocation;
// envoltorio alrededor de la API de ubicación
  late loc.Location location = loc.Location();

  @override
  void initState() {
    // addMarkers();
    //inicializar Las direcciones para que pueda tomar la ruta mas corta
    gmd.GoogleMapsDirections.init(googleAPIKey: googleAPIKey);
    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 14.0);

// establece la ubicación inicial
    initCurrentLocation();

    // suscribirse a los cambios en la ubicación del usuario
    // "escuchando" el evento onLocationChanged de la ubicación
    location.onLocationChanged.listen((loc.LocationData cLoc) {
      // cLoc contiene el lat y el largo del
      // posición del usuario actual en tiempo real,
      // así que nos aferramos a eso
      currentLocation = cLoc;
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    HomeProvider.controllerSearchAddress.dispose();
    _controller!.dispose();
    _controllerLocation.dispose();
  }

  Future<void> initMarkerIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/point_marker.png');
  }

  _getPolyline({required gmd.DirectionRoute route}) async {
    List<LatLng> points = PolylinePoints()
        .decodePolyline(route.overviewPolyline.points)
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      polylines = [
        Polyline(
          width: 5,
          polylineId: PolylineId("UNIQUE_ROUTE_ID"),
          color: Colors.green,
          points: points,
        ),
      ];
    });
  }

  marcarPosicionInicial() {
// obtener un LatLng para la ubicación de origen
    // del objeto LocationData currentLocation

    var pinPosition =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);

    _markers.add(Marker(
      markerId: MarkerId('sourcePin'),
      position: pinPosition,
      icon: sourceIcon,
      anchor: Offset(0.5, 0.9), // Ajustar el valor Y (0.9 en este ejemplo)
    ));
  }

  Future<BitmapDescriptor> setMarkerIcon() async {
    final byteData = await rootBundle.load('assets/point_marker.png');
    final Uint8List bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  Future initCurrentLocation() async {
    destinationPosition = LatLng(latitude, longitude);

    _serviceEnabled = await location.serviceEnabled();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        try {
          // Find and store your location in a variable
          currentLocation = await location.getLocation();
        } on Exception {
          print(Exception());
        }

        return;
      }
    }
    currentLocation = await location.getLocation();

    latitude = currentLocation.latitude as double;
    longitude = currentLocation.longitude as double;
    destinationPosition = LatLng(latitude, longitude);

    if (mounted) {
      setState(() {
        destinationPosition = LatLng(latitude, longitude);

        _cameraPosition = CameraPosition(
            target: destinationPosition!, zoom: 15.0, bearing: 0);
        if (_controller != null) {
          // Move the map camera to the found location using the controller

          _controller
              .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
        }
      });

      // establecer pines marcadores personalizados
      initMarkerIcons().then((value) {
        //marcar posicion inicial
        marcarPosicionInicial();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var homeProvider = context.watch<HomeProvider>();
    MediaQueryData size = MediaQuery.of(context);

    Future<void> getdataPlace() async {
      homeProvider.placeMark = (await placemarkFromCoordinates(
        destinationPosition?.latitude as double,
        destinationPosition?.longitude as double,
      ));
      destinationPosition?.latitude.toString();
      destinationPosition?.longitude.toString();
    }

    Future<String> getDistanseRoute({
      required LatLng source,
      required LatLng destination,
    }) async {
      gmd.DistanceValue distanceBetween = await gmd.distance(
        source.latitude,
        source.longitude,
        destination.latitude,
        destination.longitude,
        googleAPIKey: googleAPIKey,
      ); //gmd.distance(9.2460524, 1.2144565, 6.1271617, 1.2345417) or without passing the API_KEY if the plugin is already initialized with it's value.

      int meters = distanceBetween
          .meters; // await gmd.distanceInMeters(9.2460524, 1.2144565, 6.1271617, 1.2345417, googleAPIKey : googleAPIKey);

      String textInKmOrMeters = distanceBetween
          .text; // await gmd.distanceText(9.2460524, 1.2144565, 6.1271617, 1.2345417, googleAPIKey : googleAPIKey);

      print("metros: $meters kilometros: $textInKmOrMeters");
      return textInKmOrMeters;
    }

    Future<String> getDuration({
      required LatLng source,
      required LatLng destination,
    }) async {
      gmd.DurationValue durationBetween = await gmd.duration(
        source.latitude,
        source.longitude,
        destination.latitude,
        destination.longitude,
        googleAPIKey: googleAPIKey,
      ); //gmd.distance(9.2460524, 1.2144565, 6.1271617, 1.2345417) or without passing the API_KEY if the plugin is already initialized with it's value.

      int seconds = durationBetween
          .seconds; //await gmd.durationInSeconds(9.2460524, 1.2144565, 6.1271617, 1.2345417, googleAPIKey : googleAPIKey);

      String durationInMinutesOrHours = durationBetween
          .text; // await gmd.durationText(9.2460524, 1.2144565, 6.1271617, 1.2345417, googleAPIKey : googleAPIKey);
      print("segundos: $seconds tiempo: $durationInMinutesOrHours");
      return durationInMinutesOrHours;
    }

    Future<gmd.DirectionRoute> _addShortDirecion({
      required LatLng source,
      required LatLng destination,
    }) async {
      gmd.Directions directions = await gmd.getDirections(
        source.latitude,
        source.longitude,
        destination.latitude,
        destination.longitude,
        language: "fr_FR",
      );

      gmd.DirectionRoute route = directions.shortestRoute;

      var distance =
          await getDistanseRoute(source: source, destination: destination);
      var timeDuration =
          await getDuration(source: source, destination: destination);

      homeProvider.distance = distance;

      homeProvider.timeDuration = timeDuration;
      return route;
    }

    Future<void> marcarDestino() async {
      // establece las líneas de ruta en el mapa desde el origen hasta   el destino
      // para más información sigue este tutorial
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: LatLng(
              destinationPosition!.latitude, destinationPosition!.longitude),
          icon: destinationIcon));

      _addShortDirecion(
        source: LatLng(currentLocation.latitude as double,
            currentLocation.longitude as double),
        destination: LatLng(
            destinationPosition!.latitude, destinationPosition!.longitude),
      ).then((value) => _getPolyline(route: value));

      setState(() {});

      getdataPlace();
    }

    var googleMap = GoogleMap(
      tiltGesturesEnabled: true,
      compassEnabled: true,
      scrollGesturesEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      initialCameraPosition: _cameraPosition,
      polylines: Set<Polyline>.of(polylines),
      onMapCreated: (GoogleMapController controller) {
        _controller = (controller);
        // showPinsOnMap();

        _controller
            .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      },
      markers: _markers,
      onTap: (latLng) {
        if (mounted) {
          setState(
            () {
              destinationPosition = latLng;

              marcarDestino();
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
              (destinationPosition != null) ? googleMap : Container(),
              const CustomSwitcher(),
              SearchBar(onPressed: () {
                searchAddress(HomeProvider.controllerSearchAddress.text);
              }, onSubmitted: (value) {
                searchAddress(value);
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

  addMarkerDestination() {
    _markers.add(Marker(
      icon: destinationIcon,
      markerId: MarkerId(Random().nextInt(10000).toString()),
      position:
          LatLng(destinationPosition!.latitude, destinationPosition!.longitude),
    ));

    setState(() {});
  }
}
