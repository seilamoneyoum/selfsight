import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

class AppSetup {
  static Future<void> setupLocator() async {
    _registerServices();
    //_registerUseCases();
  }

  static void _registerServices() {
//    locator.registerLazySingleton(() => JwtDecoderWrapper());
    locator.registerLazySingleton(() => NavigationService());
    //locator.registerLazySingleton(() => DialogService());
    //locator.registerLazySingleton(() => http.Client());
    //locator.registerLazySingleton<AuthenticationService>(
    // () => AuthenticationServiceImpl(httpClient: locator<http.Client>()));
    //locator.registerLazySingleton<TokenManager>(() =>
    //TokenManagerImpl(jwtDecoderWrapper: locator<JwtDecoderWrapper>()));
    //locator.registerLazySingleton<UnauthenticationService>(
    //  () => UnauthenticationServiceImpl(httpClient: locator<http.Client>()));
    //locator.registerLazySingleton<ApiPostService>(
    //  () => ApiPostServiceImpl(httpClient: locator<http.Client>()));
  }

  /* static void _registerUseCases() {
    locator.registerLazySingleton<GetCurrentPositionUseCase>(() =>
        GetCurrentPositionUseCase(
            geoLocatorWrapper: locator<GeoLocatorWrapper>()));
    locator.registerLazySingleton<GetRangesUseCase>(
        () => GetRangesUseCase(rangesService: locator<RangesService>()));
    locator.registerLazySingleton<GetStationsUseCase>(
        () => GetStationsUseCase(stationsService: locator<StationsService>()));
    locator.registerLazySingleton<GetScaleUseCase>(
        () => GetScaleUseCase(scaleService: locator<ScaleService>()));
    locator.registerLazySingleton<LoginUserUseCase>(() => LoginUserUseCase(
        authenticationService: locator<AuthenticationService>(),
        tokenManager: locator<TokenManager>()));
    locator.registerLazySingleton<LogoutUserUseCase>(() => LogoutUserUseCase(
        unauthenticationService: locator<UnauthenticationService>(),
        tokenManager: locator<TokenManager>()));
    locator.registerLazySingleton<GetUserFavoriteStationsUseCase>(() =>
        GetUserFavoriteStationsUseCase(
            authFavoriteStationsService: locator<AuthFavoriteStationsService>(),
            tokenManager: locator<TokenManager>()));
    locator.registerLazySingleton<GetUserUnreadNotifsUseCase>(() =>
        GetUserUnreadNotifsUseCase(
            authUnreadNotifsService: locator<AuthUnreadNotifsService>(),
            tokenManager: locator<TokenManager>()));
    locator.registerLazySingleton<GetStatsUseCase>(
        () => GetStatsUseCase(apiRestService: locator<StatsService>()));
    locator.registerLazySingleton<PostRegisterUseCase>(
        () => PostRegisterUseCase(apiPostService: locator<ApiPostService>()));
  }*/
}
