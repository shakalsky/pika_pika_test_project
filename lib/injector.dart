import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'features/pokemon_app/data/local_data_source/helpers/sqlite_open_helper.dart';
import 'features/pokemon_app/data/local_data_source/interfaces/i_local_data_source.dart';
import 'features/pokemon_app/data/local_data_source/local_data_provider.dart';
import 'features/pokemon_app/data/remote_data_sources/api_data_source.dart';
import 'features/pokemon_app/data/remote_data_sources/interfaces/api_data_interface.dart';
import 'features/pokemon_app/data/local_data_source/cash_data_repository.dart';
import 'features/pokemon_app/domain/repositories/data_repository.dart';
import 'features/pokemon_app/domain/repositories/interfaces/pokemon_data_interface.dart';
import 'features/pokemon_app/data/remote_data_sources/remote_data_repository.dart';
import 'features/pokemon_app/presentation/pages/detailed_info/bloc/detailed_info_bloc.dart';
import 'features/pokemon_app/presentation/pages/main/bloc/home_bloc.dart';

GetIt get i => GetIt.instance;

Future<int> initInjector() async {
  i.registerSingleton<http.Client>(
    http.Client(),
  );

  await _setUpProviders();
  await _setUpRepository();
  await _setUpBloc();

  return 0;
}

Future<void> _setUpBloc() async {
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

Future<void> _setUpProviders() async {
  Database database = await SqliteDataBaseOpenHelper.initDatabase();
  await SqliteDataBaseOpenHelper.initialize();

  i.registerFactory<ILocalDataSourceEntity>(
    () => LocalDataProvider(database),
  );
  i.registerFactory<IRemoteDataProvider>(
    () => ApiDataProvider(),
  );
}

Future<void> _setUpRepository() async {
  final connectivity = await Connectivity().checkConnectivity();

  i.registerSingleton<ILocalDataRepository>(
    CashDataRepository(),
  );
  i.registerSingleton<IRemoteDataRepository>(
    RemoteDataRepository(),
  );
  final IDataRepository dataRepository =
      (connectivity != ConnectivityResult.none)
          ? i.get<IRemoteDataRepository>()
          : i.get<ILocalDataRepository>();

  i.registerFactory<IDataRepository>(
    () => DataReository(dataRepository),
  );
}
