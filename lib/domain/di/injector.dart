import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../../data/local_data_source/interfaces/i_local_data_source.dart';
import '../../data/local_data_source/local_data_provider.dart';
import '../../data/remote_data_sources/api_data_source.dart';
import '../../data/remote_data_sources/interfaces/api_data_interface.dart';
import '../../domain/repositories/cash_data_repository.dart';
import '../../domain/repositories/interfaces/pokemon_data_interface.dart';
import '../../domain/repositories/remote_data_repository.dart';
import '../../presentation/pages/detailed_info/bloc/detailed_info_bloc.dart';
import '../../presentation/pages/main/bloc/home_bloc.dart';
import '../../data/local_data_source/helpers/sqlite_open_helper.dart';
import '../repositories/data_repository.dart';

GetIt get i => GetIt.instance;

Future<void> initInjector() async {
  i.registerSingleton<http.Client>(
    http.Client(),
  );

  _setUpProviders();
  _setUpRepository();
  _setUpBloc();
}

void _setUpBloc() {
  i.registerFactory(
    () => HomeBloc()
      ..add(
        PokemonsFetched(),
      ),
  );
  i.registerFactory<DetailedInfoBloc>(
    () => DetailedInfoBloc()
      ..add(
        DetailedInfoConnectionChecked(),
      ),
  );
}

void _setUpProviders() async {
  Database database = await SqliteDataBaseOpenHelper.initDatabase();

  i.registerFactory<ILocalDataSourceEntity>(
    () => LocalDataProvider(database),
  );
  i.registerFactory<IRemoteDataProvider>(
    () => ApiDataProvider(),
  );
}

void _setUpRepository() async {
  final connectivity = await Connectivity().checkConnectivity();
  final IDataRepository dataRepository =
      (connectivity != ConnectivityResult.none)
          ? i.get<RemoteDataRepository>()
          : i.get<CashDataRepository>();

  i.registerSingleton<ILocalDataRepository>(
    CashDataRepository(),
  );
  i.registerSingleton<IRemoteDataRepository>(
    RemoteDataRepository(),
  );
  i.registerFactory<IDataRepository>(
    () => DataReository(dataRepository),
  );
}