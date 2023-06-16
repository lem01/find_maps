import 'dart:math';

import 'package:find_maps/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_maps_directions/google_maps_directions.dart" as gmd;
import 'package:location/location.dart' as loc;

class HomeProvider extends ChangeNotifier {
//barra de busqueda
  static final TextEditingController controllerSearchAddress =
      TextEditingController();

// Localitation

  double latitude = 0;
  double longitude = -0;

  LatLng _destinationPosition = LatLng(0, 0);
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(0, 0), zoom: 14.0);
  static late final GoogleMapController googleMapController;
  final TextEditingController _controllerLocation = TextEditingController();

  get destinationPosition => _destinationPosition;
  get cameraPosition => _cameraPosition;
  // get googleMapController => _googleMapController;

  // set setGoogleMapController(value) {
  //   googleMapController = value;
  //   notifyListeners();
  // }

  bool _serviceEnabled = false;
  late loc.PermissionStatus _permissionGranted;

//  navegacion
  Set<Marker> _markers = <Marker>{};

  get markers => _markers;

// para mis rutas dibujadas en el mapa
  List<Polyline> polylines = [];

// para mis marcadores personalizados
  late BitmapDescriptor _sourceIcon;
  late BitmapDescriptor _destinationIcon;

// la ubicación inicial del usuario y la ubicación actual
// a medida que se mueve
  late loc.LocationData currentLocation = loc.LocationData.fromMap({
    "latitude": 0.0,
    "longitude": 0.0,
    // Otros valores necesarios en LocationData
  });
// una referencia a la ubicación de destino
  // late loc.LocationData destinationLocation;
// envoltorio alrededor de la API de ubicación
  late loc.Location location = loc.Location();

  List<Placemark> _placeMark = [];

  List<Placemark> get placeMark => _placeMark;

  set placeMark(List<Placemark> value) {
    _placeMark.clear();
    _placeMark.addAll(value);
    notifyListeners();
  }

  String _distance = "";

  String get distance => _distance;

  set distance(value) {
    _distance = value;
    notifyListeners();
  }

  String _timeDuration = "";

  String get timeDuration => _timeDuration;

  set timeDuration(value) {
    _timeDuration = value;
    notifyListeners();
  }

  int _indexListWidget = 0;

  get indexListWidget => _indexListWidget;

  void setindexListWidget() {
    _indexListWidget == 0 ? _indexListWidget = 1 : _indexListWidget = 0;

    notifyListeners();
  }

  String _address = '';
  TextEditingController _addressController = TextEditingController();

  String get address => _address;
  TextEditingController get addressController => _addressController;

  set setAddressController(TextEditingController value) {
    _addressController = value;
    notifyListeners();
  }

  set setAddressText(String value) {
    _address = value;
    notifyListeners();
  }

//Funciones

  //create method for search address
  Future<void> searchAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.length > 0) {
        googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
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
      icon: _destinationIcon,
      markerId: MarkerId(Random().nextInt(10000).toString()),
      position: LatLng(
          _destinationPosition!.latitude, _destinationPosition!.longitude),
    ));

    notifyListeners();
  }

  Future<void> getdataPlace() async {
    _placeMark = (await placemarkFromCoordinates(
      _destinationPosition?.latitude as double,
      _destinationPosition?.longitude as double,
    ));
    _destinationPosition?.latitude.toString();
    _destinationPosition?.longitude.toString();
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

    _distance = distance;

    _timeDuration = timeDuration;
    return route;
  }

  Future<void> marcarDestino({required LatLng latLgn}) async {
    _destinationPosition = latLgn;

    // establece las líneas de ruta en el mapa desde el origen hasta   el destino
    // para más información sigue este tutorial
    _markers.add(Marker(
      markerId: MarkerId('destPin'),
      position: LatLng(
          _destinationPosition!.latitude, _destinationPosition!.longitude),
      icon: _destinationIcon,
    ));

    _addShortDirecion(
      source: LatLng(currentLocation!.latitude as double,
          currentLocation!.longitude as double),
      destination: LatLng(
          _destinationPosition!.latitude, _destinationPosition!.longitude),
    ).then((value) => _getPolyline(route: value));

    getdataPlace();
    notifyListeners();
  }

  Future<void> initMarkerIcons() async {
    _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    _destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/point_marker.png');
    notifyListeners();
  }

  _getPolyline({required gmd.DirectionRoute route}) async {
    List<LatLng> points = PolylinePoints()
        .decodePolyline(route.overviewPolyline.points)
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    polylines = [
      Polyline(
        width: 5,
        polylineId: PolylineId("UNIQUE_ROUTE_ID"),
        color: Colors.green,
        points: points,
      ),
    ];

    notifyListeners();
  }

  marcarPosicionInicial() {
// obtener un LatLng para la ubicación de origen
    // del objeto LocationData currentLocation

    var pinPosition =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    _markers.add(Marker(
      markerId: MarkerId(Random().nextInt(10000).toString()),
      position: pinPosition,
      icon: _sourceIcon,
      anchor: Offset(0.5, 0.9), // Ajustar el valor Y (0.9 en este ejemplo)
    ));
    notifyListeners();
  }

  Future<BitmapDescriptor> setMarkerIcon() async {
    final byteData = await rootBundle.load('assets/point_marker.png');
    final Uint8List bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  Future initCurrentLocation() async {
    _destinationPosition = LatLng(latitude, longitude);

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied)
      _permissionGranted = await location.requestPermission();
    if (_permissionGranted == loc.PermissionStatus.granted) {
      try {
        // Find and store your location in a variable
        currentLocation = await location.getLocation();
      } on Exception {
        print(Exception());
        return;
      }
    } else {
      print("No se dieron permisos de localizacion");
    }

    latitude = currentLocation.latitude as double;
    longitude = currentLocation.longitude as double;
    _destinationPosition = LatLng(latitude, longitude);

    // _destinationPosition = LatLng(latitude, longitude);

    // _cameraPosition =
    //     CameraPosition(target: _destinationPosition!, zoom: 15.0, bearing: 0);
    if (googleMapController != null) {
      // Move the map camera to the found location using the controller
      _cameraPosition = CameraPosition(
          target: LatLng(
            currentLocation.latitude as double,
            currentLocation.longitude as double,
          ),
          zoom: 12.0);
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    }
    notifyListeners();

    // establecer pines marcadores personalizados
    initMarkerIcons().then((value) {
      //marcar posicion inicial
      marcarPosicionInicial();
    });
  }
}
