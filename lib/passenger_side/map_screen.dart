import 'dart:async';
import 'dart:math' as math;
import 'select_driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

const _blue = Color(0xFF1A73E8);
const _blueLight = Color(0xFFE8F0FD);
const _blueDark = Color(0xFF1557B0);
const _blueGlow = Color(0x401A73E8);
const _green = Color(0xFF34A853);
const _greenGlow = Color(0x4034A853);
const _amber = Color(0xFFF29900);
const _surface = Color(0xFFF8F9FA);
const _card = Color(0xFFFFFFFF);
const _textPri = Color(0xFF202124);
const _textSec = Color(0xFF3C4043);
const _textMuted = Color(0xFF5F6368);
const _divider = Color(0xFFE8EAED);
const _chipBg = Color(0xFFF1F3F4);

enum LocationCategory {
  airports,
  universities,
  landmarks,
  malls,
  hospitals,
  stations,
  hotels,
  mosques,
  cities,
}

class EgyptPlace {
  final String name;
  final String address;
  final String governorate;
  final IconData icon;
  final double lat;
  final double lng;
  final LocationCategory category;
  final String? description;

  const EgyptPlace({
    required this.name,
    required this.address,
    required this.governorate,
    required this.icon,
    required this.lat,
    required this.lng,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'governorate': governorate,
    'icon': icon,
    'lat': lat,
    'lng': lng,
    'category': category,
  };
}

const List<EgyptPlace> kEgyptPlaces = [
  EgyptPlace(
    name: 'مطار القاهرة الدولي',
    address: 'الحلمية الجديدة، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.flight_rounded,
    lat: 30.1219,
    lng: 31.4056,
    category: LocationCategory.airports,
  ),
  EgyptPlace(
    name: 'مطار برج العرب',
    address: 'برج العرب، الإسكندرية',
    governorate: 'الإسكندرية',
    icon: Icons.flight_rounded,
    lat: 30.9176,
    lng: 29.6963,
    category: LocationCategory.airports,
  ),
  EgyptPlace(
    name: 'مطار شرم الشيخ',
    address: 'شرم الشيخ، جنوب سيناء',
    governorate: 'جنوب سيناء',
    icon: Icons.flight_rounded,
    lat: 27.9773,
    lng: 34.3956,
    category: LocationCategory.airports,
  ),
  EgyptPlace(
    name: 'مطار الغردقة',
    address: 'الغردقة، البحر الأحمر',
    governorate: 'البحر الأحمر',
    icon: Icons.flight_rounded,
    lat: 27.1783,
    lng: 33.7994,
    category: LocationCategory.airports,
  ),
  EgyptPlace(
    name: 'مطار أسوان',
    address: 'أسوان',
    governorate: 'أسوان',
    icon: Icons.flight_rounded,
    lat: 23.9644,
    lng: 32.8199,
    category: LocationCategory.airports,
  ),
  EgyptPlace(
    name: 'مطار الأقصر',
    address: 'الأقصر',
    governorate: 'الأقصر',
    icon: Icons.flight_rounded,
    lat: 25.6710,
    lng: 32.7066,
    category: LocationCategory.airports,
  ),
  EgyptPlace(
    name: 'مطار أبو سمبل',
    address: 'أبو سمبل، أسوان',
    governorate: 'أسوان',
    icon: Icons.flight_rounded,
    lat: 22.3760,
    lng: 31.6118,
    category: LocationCategory.airports,
  ),
  EgyptPlace(
    name: 'مطار مرسى علم',
    address: 'مرسى علم، البحر الأحمر',
    governorate: 'البحر الأحمر',
    icon: Icons.flight_rounded,
    lat: 25.5571,
    lng: 34.5836,
    category: LocationCategory.airports,
  ),

  EgyptPlace(
    name: 'الأهرامات الثلاثة',
    address: 'الجيزة، مصر',
    governorate: 'الجيزة',
    icon: Icons.account_balance_rounded,
    lat: 29.9792,
    lng: 31.1342,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'المتحف المصري الكبير',
    address: 'الرماية، الجيزة',
    governorate: 'الجيزة',
    icon: Icons.museum_rounded,
    lat: 29.9886,
    lng: 31.1180,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'ميدان التحرير',
    address: 'وسط القاهرة',
    governorate: 'القاهرة',
    icon: Icons.place_rounded,
    lat: 30.0444,
    lng: 31.2357,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'برج القاهرة',
    address: 'الزمالك، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.location_city_rounded,
    lat: 30.0459,
    lng: 31.2243,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'قلعة صلاح الدين',
    address: 'القاهرة الإسلامية',
    governorate: 'القاهرة',
    icon: Icons.castle_rounded,
    lat: 30.0286,
    lng: 31.2600,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'معبد الكرنك',
    address: 'الأقصر',
    governorate: 'الأقصر',
    icon: Icons.account_balance_rounded,
    lat: 25.7188,
    lng: 32.6573,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'معبد أبو سمبل',
    address: 'أبو سمبل، أسوان',
    governorate: 'أسوان',
    icon: Icons.account_balance_rounded,
    lat: 22.3372,
    lng: 31.6258,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'معبد فيلة',
    address: 'أسوان',
    governorate: 'أسوان',
    icon: Icons.account_balance_rounded,
    lat: 24.0244,
    lng: 32.8839,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'مكتبة الإسكندرية',
    address: 'الشاطبي، الإسكندرية',
    governorate: 'الإسكندرية',
    icon: Icons.local_library_rounded,
    lat: 31.2089,
    lng: 29.9091,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'قلعة قايتباي',
    address: 'الإسكندرية',
    governorate: 'الإسكندرية',
    icon: Icons.castle_rounded,
    lat: 31.2138,
    lng: 29.8854,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'وادي الملوك',
    address: 'الأقصر',
    governorate: 'الأقصر',
    icon: Icons.account_balance_rounded,
    lat: 25.7402,
    lng: 32.6014,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'معبد حتشبسوت',
    address: 'الدير البحري، الأقصر',
    governorate: 'الأقصر',
    icon: Icons.account_balance_rounded,
    lat: 25.7381,
    lng: 32.6072,
    category: LocationCategory.landmarks,
  ),
  EgyptPlace(
    name: 'أبو الهول',
    address: 'الجيزة',
    governorate: 'الجيزة',
    icon: Icons.account_balance_rounded,
    lat: 29.9753,
    lng: 31.1376,
    category: LocationCategory.landmarks,
  ),

  EgyptPlace(
    name: 'جامعة القاهرة',
    address: 'الجيزة، القاهرة',
    governorate: 'الجيزة',
    icon: Icons.school_rounded,
    lat: 30.0264,
    lng: 31.2099,
    category: LocationCategory.universities,
  ),
  EgyptPlace(
    name: 'الجامعة الأمريكية بالقاهرة',
    address: 'التجمع الخامس، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.school_rounded,
    lat: 30.0215,
    lng: 31.4980,
    category: LocationCategory.universities,
  ),
  EgyptPlace(
    name: 'جامعة عين شمس',
    address: 'عباسية، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.school_rounded,
    lat: 30.0756,
    lng: 31.2822,
    category: LocationCategory.universities,
  ),
  EgyptPlace(
    name: 'جامعة الإسكندرية',
    address: 'الإسكندرية',
    governorate: 'الإسكندرية',
    icon: Icons.school_rounded,
    lat: 31.2001,
    lng: 29.9187,
    category: LocationCategory.universities,
  ),
  EgyptPlace(
    name: 'جامعة المنصورة',
    address: 'المنصورة، الدقهلية',
    governorate: 'الدقهلية',
    icon: Icons.school_rounded,
    lat: 31.0411,
    lng: 31.3785,
    category: LocationCategory.universities,
  ),
  EgyptPlace(
    name: 'جامعة أسيوط',
    address: 'أسيوط',
    governorate: 'أسيوط',
    icon: Icons.school_rounded,
    lat: 27.1826,
    lng: 31.1858,
    category: LocationCategory.universities,
  ),
  EgyptPlace(
    name: 'جامعة جنوب الوادي',
    address: 'قنا',
    governorate: 'قنا',
    icon: Icons.school_rounded,
    lat: 26.1553,
    lng: 32.7160,
    category: LocationCategory.universities,
  ),
  EgyptPlace(
    name: 'جامعة الأزهر',
    address: 'الأزهر، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.school_rounded,
    lat: 30.0444,
    lng: 31.2629,
    category: LocationCategory.universities,
  ),

  EgyptPlace(
    name: 'مول مصر',
    address: 'السادس من أكتوبر، الجيزة',
    governorate: 'الجيزة',
    icon: Icons.shopping_bag_rounded,
    lat: 29.9774,
    lng: 30.9355,
    category: LocationCategory.malls,
  ),
  EgyptPlace(
    name: 'سيتي ستارز',
    address: 'هليوبوليس، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.shopping_bag_rounded,
    lat: 30.0731,
    lng: 31.3440,
    category: LocationCategory.malls,
  ),
  EgyptPlace(
    name: 'مول العرب',
    address: 'السادس من أكتوبر',
    governorate: 'الجيزة',
    icon: Icons.shopping_bag_rounded,
    lat: 29.9672,
    lng: 30.9278,
    category: LocationCategory.malls,
  ),
  EgyptPlace(
    name: 'كايرو فستيفال سيتي',
    address: 'التجمع الخامس، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.shopping_bag_rounded,
    lat: 30.0283,
    lng: 31.4616,
    category: LocationCategory.malls,
  ),
  EgyptPlace(
    name: 'مول العثيم',
    address: 'مصر الجديدة، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.shopping_bag_rounded,
    lat: 30.0855,
    lng: 31.3341,
    category: LocationCategory.malls,
  ),
  EgyptPlace(
    name: 'مول سان ستيفانو',
    address: 'سموحة، الإسكندرية',
    governorate: 'الإسكندرية',
    icon: Icons.shopping_bag_rounded,
    lat: 31.2219,
    lng: 29.9608,
    category: LocationCategory.malls,
  ),

  EgyptPlace(
    name: 'مستشفى المنيل الجامعي',
    address: 'المنيل، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.local_hospital_rounded,
    lat: 30.0196,
    lng: 31.2237,
    category: LocationCategory.hospitals,
  ),
  EgyptPlace(
    name: 'مستشفى سعاد كفافي',
    address: 'حدائق الأهرام، الجيزة',
    governorate: 'الجيزة',
    icon: Icons.local_hospital_rounded,
    lat: 29.9913,
    lng: 31.1086,
    category: LocationCategory.hospitals,
  ),
  EgyptPlace(
    name: 'معهد ناصر',
    address: 'باب الشعرية، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.local_hospital_rounded,
    lat: 30.0644,
    lng: 31.2542,
    category: LocationCategory.hospitals,
  ),
  EgyptPlace(
    name: 'مستشفى 57357',
    address: 'العباسية، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.local_hospital_rounded,
    lat: 30.0737,
    lng: 31.2854,
    category: LocationCategory.hospitals,
  ),

  EgyptPlace(
    name: 'محطة رمسيس',
    address: 'رمسيس، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.train_rounded,
    lat: 30.0639,
    lng: 31.2480,
    category: LocationCategory.stations,
  ),
  EgyptPlace(
    name: 'محطة صدر الإسكندرية',
    address: 'الإسكندرية',
    governorate: 'الإسكندرية',
    icon: Icons.train_rounded,
    lat: 31.1991,
    lng: 29.9024,
    category: LocationCategory.stations,
  ),
  EgyptPlace(
    name: 'محطة قنا',
    address: 'قنا',
    governorate: 'قنا',
    icon: Icons.train_rounded,
    lat: 26.1575,
    lng: 32.7156,
    category: LocationCategory.stations,
  ),
  EgyptPlace(
    name: 'محطة أسوان',
    address: 'أسوان',
    governorate: 'أسوان',
    icon: Icons.train_rounded,
    lat: 24.0886,
    lng: 32.8996,
    category: LocationCategory.stations,
  ),
  EgyptPlace(
    name: 'محطة الأقصر',
    address: 'الأقصر',
    governorate: 'الأقصر',
    icon: Icons.train_rounded,
    lat: 25.6877,
    lng: 32.6421,
    category: LocationCategory.stations,
  ),

  EgyptPlace(
    name: 'فندق النيل ريتز كارلتون',
    address: 'كورنيش النيل، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.hotel_rounded,
    lat: 30.0459,
    lng: 31.2295,
    category: LocationCategory.hotels,
  ),
  EgyptPlace(
    name: 'فندق شيراتون الغردقة',
    address: 'الغردقة',
    governorate: 'البحر الأحمر',
    icon: Icons.hotel_rounded,
    lat: 27.2490,
    lng: 33.8312,
    category: LocationCategory.hotels,
  ),
  EgyptPlace(
    name: 'فندق الشيراتون شرم',
    address: 'شرم الشيخ',
    governorate: 'جنوب سيناء',
    icon: Icons.hotel_rounded,
    lat: 27.9132,
    lng: 34.3282,
    category: LocationCategory.hotels,
  ),
  EgyptPlace(
    name: 'فندق سوفيتيل الجيزة',
    address: 'الدقي، الجيزة',
    governorate: 'الجيزة',
    icon: Icons.hotel_rounded,
    lat: 30.0476,
    lng: 31.2131,
    category: LocationCategory.hotels,
  ),

  EgyptPlace(
    name: 'مسجد عمرو بن العاص',
    address: 'الفسطاط، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.mosque_rounded,
    lat: 30.0077,
    lng: 31.2321,
    category: LocationCategory.mosques,
  ),
  EgyptPlace(
    name: 'مسجد محمد علي',
    address: 'القلعة، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.mosque_rounded,
    lat: 30.0286,
    lng: 31.2594,
    category: LocationCategory.mosques,
  ),
  EgyptPlace(
    name: 'الأزهر الشريف',
    address: 'الأزهر، القاهرة',
    governorate: 'القاهرة',
    icon: Icons.mosque_rounded,
    lat: 30.0460,
    lng: 31.2622,
    category: LocationCategory.mosques,
  ),
  EgyptPlace(
    name: 'مسجد القائد إبراهيم',
    address: 'منشية، الإسكندرية',
    governorate: 'الإسكندرية',
    icon: Icons.mosque_rounded,
    lat: 31.2001,
    lng: 29.9073,
    category: LocationCategory.mosques,
  ),

  EgyptPlace(
    name: 'القاهرة',
    address: 'العاصمة',
    governorate: 'القاهرة',
    icon: Icons.location_city_rounded,
    lat: 30.0444,
    lng: 31.2357,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الإسكندرية',
    address: 'عروس البحر المتوسط',
    governorate: 'الإسكندرية',
    icon: Icons.location_city_rounded,
    lat: 31.2001,
    lng: 29.9187,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الجيزة',
    address: 'محافظة الجيزة',
    governorate: 'الجيزة',
    icon: Icons.location_city_rounded,
    lat: 30.0131,
    lng: 31.2089,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'أسوان',
    address: 'محافظة أسوان',
    governorate: 'أسوان',
    icon: Icons.location_city_rounded,
    lat: 24.0889,
    lng: 32.8998,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الأقصر',
    address: 'محافظة الأقصر',
    governorate: 'الأقصر',
    icon: Icons.location_city_rounded,
    lat: 25.6872,
    lng: 32.6396,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'قنا',
    address: 'محافظة قنا',
    governorate: 'قنا',
    icon: Icons.location_city_rounded,
    lat: 26.1553,
    lng: 32.7160,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'سوهاج',
    address: 'محافظة سوهاج',
    governorate: 'سوهاج',
    icon: Icons.location_city_rounded,
    lat: 26.5590,
    lng: 31.6967,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'أسيوط',
    address: 'محافظة أسيوط',
    governorate: 'أسيوط',
    icon: Icons.location_city_rounded,
    lat: 27.1826,
    lng: 31.1858,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'المنيا',
    address: 'محافظة المنيا',
    governorate: 'المنيا',
    icon: Icons.location_city_rounded,
    lat: 28.0871,
    lng: 30.7618,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'بني سويف',
    address: 'محافظة بني سويف',
    governorate: 'بني سويف',
    icon: Icons.location_city_rounded,
    lat: 29.0661,
    lng: 31.0960,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الفيوم',
    address: 'محافظة الفيوم',
    governorate: 'الفيوم',
    icon: Icons.location_city_rounded,
    lat: 29.3084,
    lng: 30.8428,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'المنصورة',
    address: 'محافظة الدقهلية',
    governorate: 'الدقهلية',
    icon: Icons.location_city_rounded,
    lat: 31.0411,
    lng: 31.3785,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'طنطا',
    address: 'محافظة الغربية',
    governorate: 'الغربية',
    icon: Icons.location_city_rounded,
    lat: 30.7865,
    lng: 31.0003,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الزقازيق',
    address: 'محافظة الشرقية',
    governorate: 'الشرقية',
    icon: Icons.location_city_rounded,
    lat: 30.5877,
    lng: 31.5021,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'بورسعيد',
    address: 'محافظة بورسعيد',
    governorate: 'بورسعيد',
    icon: Icons.location_city_rounded,
    lat: 31.2653,
    lng: 32.3019,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الإسماعيلية',
    address: 'محافظة الإسماعيلية',
    governorate: 'الإسماعيلية',
    icon: Icons.location_city_rounded,
    lat: 30.5965,
    lng: 32.2715,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'السويس',
    address: 'محافظة السويس',
    governorate: 'السويس',
    icon: Icons.location_city_rounded,
    lat: 29.9668,
    lng: 32.5498,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'دمياط',
    address: 'محافظة دمياط',
    governorate: 'دمياط',
    icon: Icons.location_city_rounded,
    lat: 31.4165,
    lng: 31.8133,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'شرم الشيخ',
    address: 'جنوب سيناء',
    governorate: 'جنوب سيناء',
    icon: Icons.beach_access_rounded,
    lat: 27.9158,
    lng: 34.3300,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الغردقة',
    address: 'محافظة البحر الأحمر',
    governorate: 'البحر الأحمر',
    icon: Icons.beach_access_rounded,
    lat: 27.2579,
    lng: 33.8116,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'العاصمة الإدارية الجديدة',
    address: 'القاهرة الجديدة',
    governorate: 'القاهرة',
    icon: Icons.domain_rounded,
    lat: 30.0165,
    lng: 31.7480,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'العين السخنة',
    address: 'السويس',
    governorate: 'السويس',
    icon: Icons.beach_access_rounded,
    lat: 29.5978,
    lng: 32.3500,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'مرسى مطروح',
    address: 'محافظة مطروح',
    governorate: 'مطروح',
    icon: Icons.beach_access_rounded,
    lat: 31.3543,
    lng: 27.2373,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'دهب',
    address: 'جنوب سيناء',
    governorate: 'جنوب سيناء',
    icon: Icons.beach_access_rounded,
    lat: 28.5109,
    lng: 34.5146,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'طابا',
    address: 'شمال سيناء',
    governorate: 'شمال سيناء',
    icon: Icons.location_city_rounded,
    lat: 29.5025,
    lng: 34.9016,
    category: LocationCategory.cities,
  ),
  EgyptPlace(
    name: 'الغردقة - سهل حشيش',
    address: 'البحر الأحمر',
    governorate: 'البحر الأحمر',
    icon: Icons.beach_access_rounded,
    lat: 26.8810,
    lng: 33.9310,
    category: LocationCategory.cities,
  ),
];

String _categoryLabel(LocationCategory c) {
  switch (c) {
    case LocationCategory.airports:
      return 'مطارات';
    case LocationCategory.universities:
      return 'جامعات';
    case LocationCategory.landmarks:
      return 'معالم سياحية';
    case LocationCategory.malls:
      return 'مولات';
    case LocationCategory.hospitals:
      return 'مستشفيات';
    case LocationCategory.stations:
      return 'محطات';
    case LocationCategory.hotels:
      return 'فنادق';
    case LocationCategory.mosques:
      return 'مساجد';
    case LocationCategory.cities:
      return 'مدن ومحافظات';
  }
}

IconData _categoryIcon(LocationCategory c) {
  switch (c) {
    case LocationCategory.airports:
      return Icons.flight_rounded;
    case LocationCategory.universities:
      return Icons.school_rounded;
    case LocationCategory.landmarks:
      return Icons.account_balance_rounded;
    case LocationCategory.malls:
      return Icons.shopping_bag_rounded;
    case LocationCategory.hospitals:
      return Icons.local_hospital_rounded;
    case LocationCategory.stations:
      return Icons.train_rounded;
    case LocationCategory.hotels:
      return Icons.hotel_rounded;
    case LocationCategory.mosques:
      return Icons.mosque_rounded;
    case LocationCategory.cities:
      return Icons.location_city_rounded;
  }
}

Color _categoryColor(LocationCategory c) {
  switch (c) {
    case LocationCategory.airports:
      return const Color(0xFF1A73E8);
    case LocationCategory.universities:
      return const Color(0xFF7B1FA2);
    case LocationCategory.landmarks:
      return const Color(0xFFF29900);
    case LocationCategory.malls:
      return const Color(0xFF00897B);
    case LocationCategory.hospitals:
      return const Color(0xFFE53935);
    case LocationCategory.stations:
      return const Color(0xFF1565C0);
    case LocationCategory.hotels:
      return const Color(0xFF6D4C41);
    case LocationCategory.mosques:
      return const Color(0xFF2E7D32);
    case LocationCategory.cities:
      return const Color(0xFF5F6368);
  }
}

double _calcDistance(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng = (lng2 - lng1) * math.pi / 180;
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

class MapScreenPro extends StatefulWidget {
  const MapScreenPro({super.key});
  @override
  State<MapScreenPro> createState() => _MapScreenProState();
}

class _MapScreenProState extends State<MapScreenPro>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _pickup, _dest;
  bool _pickingDest = false;
  bool _searching = false;
  String _query = '';
  LocationCategory? _filterCategory;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  late final MapController _mapCtrl;
  LatLng _centre = const LatLng(30.0444, 31.2357);
  LatLng? _userLatLng;

  StreamSubscription<Position>? _locationSub;
  bool _locationLoaded = false;
  bool _followUser = true;
  double _userHeading = 0;

  late AnimationController _bounceCtrl, _panelCtrl, _pulseCtrl, _rippleCtrl;
  late Animation<double> _bounce, _panel, _pulse, _ripple;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _bounce = Tween<double>(
      begin: 0,
      end: -18,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));
    _panel = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic);
    _pulse = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _ripple = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    _panelCtrl.forward();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('خدمة الموقع مغلقة — فعّلها من الإعدادات', isError: true);
      _setFallback();
      return;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      _showSnack('تم رفض إذن الموقع', isError: true);
      _setFallback();
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      _onPos(pos, first: true);
    } catch (_) {
      _setFallback();
    }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(_onPos, onError: (_) {});
  }

  void _onPos(Position pos, {bool first = false}) {
    if (!mounted) return;
    final ll = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _userLatLng = ll;
      _userHeading = pos.heading;
      if (!_locationLoaded || first) {
        _locationLoaded = true;
        _centre = ll;
        _pickup = {
          'name': 'موقعي الحالي',
          'address': _fmtCoords(pos.latitude, pos.longitude),
          'icon': Icons.my_location_rounded,
          'lat': pos.latitude,
          'lng': pos.longitude,
          'isCurrentLocation': true,
        };
      } else if (_pickup != null && _pickup!['isCurrentLocation'] == true) {
        _centre = ll;
        _pickup = {
          ..._pickup!,
          'address': _fmtCoords(pos.latitude, pos.longitude),
          'lat': pos.latitude,
          'lng': pos.longitude,
        };
      }
    });

    if (_followUser || first) {
      _mapCtrl.move(ll, first ? 15.0 : _mapCtrl.camera.zoom);
      if (first) _bounceCtrl.forward(from: 0);
    }
  }

  String _fmtCoords(double lat, double lng) =>
      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';

  void _setFallback() {
    if (!mounted) return;
    setState(() {
      _pickup = {
        'name': 'موقعي الحالي',
        'address': 'ميدان التحرير، القاهرة',
        'icon': Icons.my_location_rounded,
        'lat': 30.0444,
        'lng': 31.2357,
        'isCurrentLocation': true,
      };
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: isError
            ? const Color(0xFFEA4335)
            : const Color(0xFF34A853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _bounceCtrl.dispose();
    _panelCtrl.dispose();
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<EgyptPlace> get _filtered {
    var list = kEgyptPlaces.toList();
    if (_filterCategory != null) {
      list = list.where((p) => p.category == _filterCategory).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) {
        return p.name.contains(q) ||
            p.address.contains(q) ||
            p.governorate.contains(q) ||
            _categoryLabel(p.category).contains(q);
      }).toList();
    }
    if (_userLatLng != null) {
      list.sort((a, b) {
        final da = _calcDistance(
          _userLatLng!.latitude,
          _userLatLng!.longitude,
          a.lat,
          a.lng,
        );
        final db = _calcDistance(
          _userLatLng!.latitude,
          _userLatLng!.longitude,
          b.lat,
          b.lng,
        );
        return da.compareTo(db);
      });
    }
    return list;
  }

  void _fly(double lat, double lng, {double zoom = 14.5}) {
    final t = LatLng(lat, lng);
    _mapCtrl.move(t, zoom);
    setState(() => _centre = t);
    _bounceCtrl.forward(from: 0);
  }

  void _select(EgyptPlace p) {
    HapticFeedback.lightImpact();
    final m = p.toMap();
    setState(() {
      if (_pickingDest)
        _dest = m;
      else
        _pickup = m;
      _searching = false;
      _query = '';
      _searchCtrl.clear();
      _filterCategory = null;
    });
    _fly(p.lat, p.lng);
  }

  void _confirm() {
    if (_pickup == null || _dest == null) {
      _showSnack('حدد نقطة الانطلاق والوجهة أولاً', isError: true);
      return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) =>
            SelectDriverScreen(pickup: _pickup!, destination: _dest!),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _swap() {
    HapticFeedback.mediumImpact();
    setState(() {
      final tmp = _pickup;
      _pickup = _dest;
      _dest = tmp;
    });
    if (_dest != null) {
      _fly(_dest!['lat'] as double, _dest!['lng'] as double);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mapH = size.height * 0.55;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _surface,
        body: Stack(
          children: [
            _buildMap(mapH),
            _buildGradientFade(mapH),
            SafeArea(child: _buildTopBar()),
            _buildRightControls(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_panel),
                child: _buildPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(double mapH) {
    final pickupLatLng = _pickup != null
        ? LatLng(_pickup!['lat'] as double, _pickup!['lng'] as double)
        : _centre;
    final destLatLng = _dest != null
        ? LatLng(_dest!['lat'] as double, _dest!['lng'] as double)
        : null;

    return SizedBox(
      height: mapH,
      child: FlutterMap(
        mapController: _mapCtrl,
        options: MapOptions(
          initialCenter: _centre,
          initialZoom: 14.5,
          minZoom: 4,
          maxZoom: 19,
          onPositionChanged: (camera, hasGesture) {
            if (hasGesture) {
              setState(() {
                _followUser = false;
                _centre = camera.center;
              });
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.mashroo3i.app',
            retinaMode: false,
            maxZoom: 19,
          ),

          if (destLatLng != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [pickupLatLng, destLatLng],
                  color: _blue,
                  strokeWidth: 4.5,
                  borderColor: _blueGlow,
                  borderStrokeWidth: 12,
                ),
              ],
            ),

          if (destLatLng != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: destLatLng,
                  width: 50,
                  height: 68,
                  child: const _DestPin(),
                ),
              ],
            ),

          MarkerLayer(
            markers: [
              Marker(
                point: _userLatLng ?? _centre,
                width: 80,
                height: 80,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_bounce, _pulse, _ripple]),
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _bounce.value),
                    child: _UserPin(
                      pulse: _pulse.value,
                      ripple: _ripple.value,
                      heading: _userHeading,
                      loaded: _locationLoaded,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradientFade(double mapH) => Positioned(
    top: mapH * 0.55,
    left: 0,
    right: 0,
    height: mapH * 0.45,
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, _surface.withOpacity(0.95)],
          ),
        ),
      ),
    ),
  );

  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
    child: Row(
      children: [
        _CircleBtn(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: _blue, size: 19),
                const SizedBox(width: 8),
                Text(
                  'ابحث في كل مصر...',
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 13.5,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _CircleBtn(
          icon: Icons.layers_rounded,
          onTap: () {},
          color: Colors.white,
        ),
      ],
    ),
  );

  Widget _buildRightControls() {
    final top = MediaQuery.of(context).padding.top + 66;
    return Positioned(
      right: 12,
      top: top,
      child: Column(
        children: [
          _buildZoomPanel(),
          const SizedBox(height: 10),
          _MyLocBtn(
            isFollowing: _followUser,
            isLoaded: _locationLoaded,
            onTap: () {
              setState(() => _followUser = true);
              if (_userLatLng != null) {
                _mapCtrl.move(_userLatLng!, 15.5);
                _bounceCtrl.forward(from: 0);
              }
            },
          ),
          if (_dest != null) ...[
            const SizedBox(height: 10),
            _CircleBtn(
              icon: Icons.swap_vert_rounded,
              onTap: _swap,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildZoomPanel() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _mapCtrl.move(_centre, _mapCtrl.camera.zoom + 1),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.add_rounded, color: _textPri, size: 22),
          ),
        ),
        Container(height: 0.5, width: 28, color: _divider),
        GestureDetector(
          onTap: () => _mapCtrl.move(_centre, _mapCtrl.camera.zoom - 1),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.remove_rounded, color: _textPri, size: 22),
          ),
        ),
      ],
    ),
  );

  Widget _buildPanel() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: _divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPanelHeader(),
                const SizedBox(height: 14),
                _buildRouteTiles(),
                const SizedBox(height: 14),
                if (_searching) ...[
                  _buildSearchField(),
                  const SizedBox(height: 8),
                  _buildCategoryChips(),
                  const SizedBox(height: 8),
                  _buildPlacesList(),
                ] else ...[
                  if (_dest != null) _buildDistanceInfo(),
                  const SizedBox(height: 12),
                  _buildConfirmBtn(),
                ],
                SizedBox(height: bottom + 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إلى أين تريد الذهاب؟',
              style: const TextStyle(
                color: _textPri,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              'اختر من ${kEgyptPlaces.length}+ مكان في مصر',
              style: const TextStyle(
                color: _textMuted,
                fontSize: 11.5,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
      if (_dest != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_rounded, color: _green, size: 13),
              SizedBox(width: 4),
              Text(
                'جاهز',
                style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _buildRouteTiles() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: _blue,
              shape: BoxShape.circle,
            ),
          ),
          Container(width: 1.5, height: 36, color: _divider),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: _greenGlow, blurRadius: 6)],
            ),
          ),
        ],
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          children: [
            _LocTile(
              dot: _blue,
              place: _pickup,
              hint: 'حدد نقطة الانطلاق',
              isActive: !_pickingDest,
              userLatLng: _userLatLng,
              onTap: () {
                setState(() => _pickingDest = false);
                _openSearch();
              },
            ),
            const SizedBox(height: 6),
            _LocTile(
              dot: _green,
              place: _dest,
              hint: 'أين تريد الذهاب؟',
              isActive: _pickingDest,
              userLatLng: _userLatLng,
              onTap: () {
                setState(() => _pickingDest = true);
                _openSearch();
              },
            ),
          ],
        ),
      ),
    ],
  );

  void _openSearch() {
    setState(() => _searching = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocus.requestFocus();
    });
  }

  Widget _buildSearchField() => TextField(
    controller: _searchCtrl,
    focusNode: _searchFocus,
    onChanged: (v) => setState(() => _query = v),
    textAlign: TextAlign.right,
    style: const TextStyle(color: _textPri, fontSize: 14, fontFamily: 'Cairo'),
    cursorColor: _blue,
    decoration: InputDecoration(
      hintText: _pickingDest
          ? 'ابحث: القاهرة، أسوان، الأقصر...'
          : 'ابحث عن موقع الانطلاق...',
      hintStyle: const TextStyle(
        color: _textMuted,
        fontFamily: 'Cairo',
        fontSize: 13,
      ),
      prefixIcon: const Icon(Icons.search_rounded, color: _blue, size: 20),
      suffixIcon: _query.isNotEmpty
          ? GestureDetector(
              onTap: () => setState(() {
                _query = '';
                _searchCtrl.clear();
              }),
              child: const Icon(
                Icons.close_rounded,
                color: _textMuted,
                size: 18,
              ),
            )
          : GestureDetector(
              onTap: () => setState(() => _searching = false),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _textMuted,
                size: 20,
              ),
            ),
      filled: true,
      fillColor: _chipBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );

  Widget _buildCategoryChips() => SizedBox(
    height: 34,
    child: ListView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      children: [
        _ChipFilter(
          label: 'الكل',
          icon: Icons.apps_rounded,
          selected: _filterCategory == null,
          onTap: () => setState(() => _filterCategory = null),
        ),
        const SizedBox(width: 6),
        ...LocationCategory.values.map(
          (c) => Padding(
            padding: const EdgeInsets.only(left: 6),
            child: _ChipFilter(
              label: _categoryLabel(c),
              icon: _categoryIcon(c),
              selected: _filterCategory == c,
              color: _categoryColor(c),
              onTap: () => setState(
                () => _filterCategory = _filterCategory == c ? null : c,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPlacesList() {
    final list = _filtered;
    return SizedBox(
      height: 230,
      child: list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    color: _textMuted,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لا توجد نتائج لـ "$_query"',
                    style: const TextStyle(
                      color: _textMuted,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: list.length,
              itemBuilder: (_, i) => _PlaceRow(
                place: list[i],
                userLatLng: _userLatLng,
                onTap: _select,
              ),
            ),
    );
  }

  Widget _buildDistanceInfo() {
    if (_pickup == null || _dest == null) return const SizedBox.shrink();
    final dist = _calcDistance(
      _pickup!['lat'] as double,
      _pickup!['lng'] as double,
      _dest!['lat'] as double,
      _dest!['lng'] as double,
    );
    final mins = (dist / 40 * 60).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _blueLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            icon: Icons.straighten_rounded,
            label: '${dist.toStringAsFixed(1)} كم',
            sub: 'المسافة',
          ),
          Container(width: 1, height: 30, color: _blue.withOpacity(0.2)),
          _InfoChip(
            icon: Icons.access_time_rounded,
            label: '$mins دقيقة',
            sub: 'الوقت المتوقع',
          ),
          Container(width: 1, height: 30, color: _blue.withOpacity(0.2)),
          _InfoChip(
            icon: Icons.route_rounded,
            label: '${(dist * 3.5).toStringAsFixed(0)} ج',
            sub: 'السعر المتوقع',
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmBtn() => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: _confirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: _dest != null ? _blue : _divider,
        foregroundColor: _dest != null ? Colors.white : _textMuted,
        elevation: _dest != null ? 4 : 0,
        shadowColor: _blueGlow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _dest != null ? 'تأكيد الوجهة' : 'اختر وجهتك أولاً',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Cairo',
              color: _dest != null ? Colors.white : _textMuted,
            ),
          ),
          if (_dest != null) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Colors.white,
            ),
          ],
        ],
      ),
    ),
  );
}

class _UserPin extends StatelessWidget {
  final double pulse, ripple, heading;
  final bool loaded;
  const _UserPin({
    required this.pulse,
    required this.ripple,
    required this.heading,
    required this.loaded,
  });

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 70 * ripple,
        height: 70 * ripple,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _blue.withOpacity(0.08 * (1.0 - ripple)),
        ),
      ),
      Container(
        width: 58 * pulse,
        height: 58 * pulse,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _blue.withOpacity(0.12 * (1.0 - (pulse - 0.5) * 2)),
        ),
      ),
      if (loaded)
        Transform.rotate(
          angle: heading * math.pi / 180,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _blue,
              boxShadow: [
                BoxShadow(color: _blueGlow, blurRadius: 14, spreadRadius: 3),
                BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 3),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
        )
      else
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: CircularProgressIndicator(strokeWidth: 2, color: _blue),
          ),
        ),
    ],
  );
}

class _DestPin extends StatelessWidget {
  const _DestPin();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(color: _greenGlow, blurRadius: 18, spreadRadius: 2),
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.flag_rounded, color: Colors.white, size: 21),
      ),
      Container(width: 3, height: 12, color: _green),
      Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
      ),
    ],
  );
}

class _MyLocBtn extends StatelessWidget {
  final bool isFollowing, isLoaded;
  final VoidCallback onTap;
  const _MyLocBtn({
    required this.isFollowing,
    required this.isLoaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: isFollowing
            ? Border.all(color: _blue.withOpacity(0.4), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isFollowing ? _blueGlow : Colors.black12,
            blurRadius: isFollowing ? 18 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: !isLoaded
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2, color: _blue),
            )
          : Icon(
              isFollowing
                  ? Icons.my_location_rounded
                  : Icons.location_searching_rounded,
              color: isFollowing ? _blue : _textMuted,
              size: 20,
            ),
    ),
  );
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _CircleBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: _textPri, size: 20),
    ),
  );
}

class _LocTile extends StatelessWidget {
  final Color dot;
  final Map<String, dynamic>? place;
  final String hint;
  final bool isActive;
  final LatLng? userLatLng;
  final VoidCallback onTap;

  const _LocTile({
    required this.dot,
    required this.place,
    required this.hint,
    required this.isActive,
    required this.onTap,
    this.userLatLng,
  });

  @override
  Widget build(BuildContext context) {
    String? distStr;
    if (place != null && userLatLng != null) {
      final d = _calcDistance(
        userLatLng!.latitude,
        userLatLng!.longitude,
        place!['lat'] as double,
        place!['lng'] as double,
      );
      if (d < 1)
        distStr = '${(d * 1000).round()} م';
      else
        distStr = '${d.toStringAsFixed(1)} كم';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? dot.withOpacity(0.07) : _chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? dot.withOpacity(0.35) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [BoxShadow(color: dot.withOpacity(0.5), blurRadius: 6)]
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: place != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place!['name'] as String,
                                style: TextStyle(
                                  color: isActive ? dot : _textPri,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                place!['address'] as String,
                                style: const TextStyle(
                                  color: _textMuted,
                                  fontSize: 10.5,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (distStr != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            distStr,
                            style: TextStyle(
                              color: dot,
                              fontSize: 10,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Text(
                      hint,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
            ),
            Icon(
              Icons.edit_location_alt_rounded,
              color: isActive ? dot : const Color(0xFFBDC1C6),
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipFilter extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _ChipFilter({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? _blue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.12) : _chipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? c.withOpacity(0.4) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? c : _textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? c : _textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final EgyptPlace place;
  final LatLng? userLatLng;
  final ValueChanged<EgyptPlace> onTap;

  const _PlaceRow({required this.place, required this.onTap, this.userLatLng});

  @override
  Widget build(BuildContext context) {
    final c = _categoryColor(place.category);
    String? distStr;
    if (userLatLng != null) {
      final d = _calcDistance(
        userLatLng!.latitude,
        userLatLng!.longitude,
        place.lat,
        place.lng,
      );
      if (d < 1)
        distStr = '${(d * 1000).round()} م';
      else if (d < 10)
        distStr = '${d.toStringAsFixed(1)} كم';
      else
        distStr = '${d.round()} كم';
    }

    return GestureDetector(
      onTap: () => onTap(place),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _divider),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(place.icon, color: c, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      color: _textPri,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        place.governorate,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 10,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _categoryLabel(place.category),
                          style: TextStyle(
                            color: c,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (distStr != null) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    distStr,
                    style: TextStyle(
                      color: c,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const Icon(
                    Icons.north_west_rounded,
                    color: Color(0xFFBDC1C6),
                    size: 14,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  const _InfoChip({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: _blue, size: 16),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          color: _textPri,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'Cairo',
        ),
      ),
      Text(
        sub,
        style: const TextStyle(
          color: _textMuted,
          fontSize: 9.5,
          fontFamily: 'Cairo',
        ),
      ),
    ],
  );
}
