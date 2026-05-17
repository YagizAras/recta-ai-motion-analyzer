import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'features/authentication/data/auth_repository.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';
import 'features/authentication/presentation/pages/giris_ekrani.dart';
import 'features/reports/presentation/pages/istatistik.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/reports/presentation/bloc/reports_event.dart';
// ── Mevcut UI sayfalarınızı buraya import edin: ──

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return RepositoryProvider.value(
      value: authRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepo: authRepository)..add(const AppStarted()),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) => ProfileBloc(repository: ProfileRepository())..add(LoadProfileSettings()),
          ),
          BlocProvider<ReportsBloc>(
            create: (_) => ReportsBloc()..add(LoadReportsEvent()),
          ),
        ],
        child: MaterialApp(
          title: 'Recta - Canlı Hareket Analizi',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF006400),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: AuthWrapper(cameras: cameras),
        ),
      ),
    );
  }
}

/// AuthWrapper – Auth durumuna göre sayfa yönlendirmesi
///
/// Bu widget hiçbir UI çizmez; sadece AuthBloc state'ine göre
/// mevcut sayfalarınıza yönlendirir:
///   - AuthInitial / AuthLoading → Yükleniyor (splash)
///   - AuthUnauthenticated / AuthFailure → WelcomePage / LoginPage
///   - AuthSuccess → HomePage (userName ile)
class AuthWrapper extends StatelessWidget {
  final List<CameraDescription> cameras;
  const AuthWrapper({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // ── 1. Uygulama İlk Açılışında (AuthInitial) Yükleniyor ──
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF536DFE))),
          );
        }

        // ── 2. Oturum açık → Ana Ekran (StatisticsScreen) ──
        if (state is AuthSuccess) {
          return StatisticsScreen(userName: state.userName, cameras: cameras);
        }

        // ── 3. Oturum yok (veya yükleniyor/hata durumu) → Giriş Ekranı ──
        // Yüklenme (AuthLoading) veya Hata (AuthFailure) durumlarında 
        // AuthScreen gösterilmeye devam etmeli ki formdaki veriler kaybolmasın 
        // ve SnackBar hatayı gösterebilsin.
        return const AuthScreen();
      },
    );
  }
}