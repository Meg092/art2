import 'package:art_painting/pages/art_painting_category_list/art_painting_category_list_binding.dart';
import 'package:art_painting/pages/art_painting_category_list/art_painting_category_list_filter.dart';
import 'package:art_painting/pages/art_painting_category_list/art_painting_category_list_view.dart';
import 'package:art_painting/pages/art_painting_daily/art_painting_daily_binding.dart';
import 'package:art_painting/pages/art_painting_daily/art_painting_daily_view.dart';
import 'package:art_painting/pages/art_painting_detail/art_painting_detail_binding.dart';
import 'package:art_painting/pages/art_painting_detail/art_painting_detail_view.dart';
import 'package:art_painting/pages/art_painting_favorites_detail/art_painting_favorites_detail_binding.dart';
import 'package:art_painting/pages/art_painting_favorites_detail/art_painting_favorites_detail_view.dart';
import 'package:art_painting/pages/art_painting_favorites_list/art_painting_favorites_list_binding.dart';
import 'package:art_painting/pages/art_painting_favorites_list/art_painting_favorites_list_view.dart';
import 'package:art_painting/pages/art_painting_get/art_painting_get_binding.dart';
import 'package:art_painting/pages/art_painting_get/art_painting_get_view.dart';
import 'package:art_painting/pages/art_painting_home/art_painting_home_binding.dart';
import 'package:art_painting/pages/art_painting_home/art_painting_home_view.dart';
import 'package:art_painting/pages/art_painting_settings/art_painting_settings_binding.dart';
import 'package:art_painting/pages/art_painting_settings/art_painting_settings_view.dart';
import 'package:art_painting/pages/art_painting_tab/art_painting_tab_binding.dart';
import 'package:art_painting/pages/art_painting_tab/art_painting_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'db_art_painting/data.dart';

Color primaryColor = const Color(0xFF000000);
Color bgColor = const Color(0xFFFFFFFF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  Get.put<ArtPaintingDatabase>(ArtPaintingDatabase(), permanent: true);
  await Get.find<ArtPaintingDatabase>().database;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: Gallery,
          initialRoute: '/',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              surface: const Color(0xFFFFFFFF),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF000000),
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 24, color: Color(0xFF000000)),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Color(0xFF000000),
              unselectedItemColor: Color(0xFF757575),
              elevation: 0,
              backgroundColor: Color(0xFFFAFAFA),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            dividerTheme: DividerThemeData(
              thickness: 1,
              color: Colors.grey[200],
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> Gallery = [
  GetPage(
    name: '/',
    page: () => const ArtPaintingGetView(),
    binding: ArtPaintingGetBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_tab',
    page: () => const ArtPaintingTabView(),
    binding: ArtPaintingTabBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_home',
    page: () => const ArtPaintingHomeView(),
    binding: ArtPaintingHomeBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_daily',
    page: () => const ArtPaintingDailyView(),
    binding: ArtPaintingDailyBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_settings',
    page: () => const ArtPaintingSettingsView(),
    binding: ArtPaintingSettingsBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_detail',
    page: () => const ArtPaintingDetailView(),
    binding: ArtPaintingDetailBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_category_filter',
    page: () => ArtPaintingCategoryListFilter(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_category_list',
    page: () => const ArtPaintingCategoryListView(),
    binding: ArtPaintingCategoryListBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_favorites_list',
    page: () => const ArtPaintingFavoritesListView(),
    binding: ArtPaintingFavoritesListBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/art_painting_favorites_detail',
    page: () => const ArtPaintingFavoritesDetailView(),
    binding: ArtPaintingFavoritesDetailBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];