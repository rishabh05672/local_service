import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_service_app/core/services/providers.dart';
import 'package:local_service_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:local_service_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:local_service_app/features/auth/domain/entities/user_entity.dart';
import 'package:local_service_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_service_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:local_service_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:local_service_app/core/utils/use_case.dart';

// ─── Datasource ───────────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

// ─── Repository ───────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
});

// ─── Use Cases ────────────────────────────────────────────────────────────────

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// ─── Current User State ───────────────────────────────────────────────────────

final currentUserProvider = StateProvider<UserEntity?>((ref) => null);

// ─── Auth State Notifier ─────────────────────────────────────────────────────

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.verificationId,
  });

  final AuthStatus status;
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final String? verificationId;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    String? verificationId,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        verificationId: verificationId ?? this.verificationId,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState());

  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    if (clean.length == 10 && !clean.startsWith('+')) {
      return '+91$clean';
    }
    return clean;
  }

  Future<bool> sendOtp({required String phone}) async {
    debugPrint('AuthNotifier: Starting sendOtp for $phone');
    state = state.copyWith(isLoading: true, errorMessage: null);
    final formattedPhone = _formatPhone(phone);
    
    // Increase delay to 500ms to ensure keyboard is gone and loader is spinning
    await Future.delayed(const Duration(milliseconds: 500));

    final completer = Completer<bool>();

    try {
      debugPrint('AuthNotifier: Calling Firebase verifyPhoneNumber now...');
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('AuthNotifier: Verification completed automatically');
          try {
            final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            final idToken = await userCredential.user?.getIdToken();
            if (idToken != null) {
              await verifyOtpAndLogin(phone: formattedPhone, otp: '', verificationIdOverride: idToken);
            }
          } catch (e) {
             debugPrint('AuthNotifier: Auto-sign-in error: $e');
             state = state.copyWith(isLoading: false, errorMessage: e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('AuthNotifier: Verification failed: ${e.code} - ${e.message}');
          state = state.copyWith(isLoading: false, errorMessage: e.message);
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('AuthNotifier: Code sent! VerificationId: $verificationId');
          state = state.copyWith(isLoading: false, verificationId: verificationId);
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('AuthNotifier: Auto-retrieval timeout');
          state = state.copyWith(verificationId: verificationId);
        },
      );
      
      debugPrint('AuthNotifier: verifyPhoneNumber call COMPLETED (Non-blocking)');


      // Timeout safety: if nothing happens in 30 seconds, complete with false
      Future.delayed(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          debugPrint('AuthNotifier: sendOtp timed out after 30s');
          state = state.copyWith(isLoading: false, errorMessage: 'Timeout. Please check your signal and SHA-1 setup.');
          completer.complete(false);
        }
      });

    } catch (e) {
      debugPrint('AuthNotifier: Unexpected error in sendOtp: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  Future<bool> verifyOtpAndLogin({
    required String phone, 
    required String otp,
    String? verificationIdOverride,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final formattedPhone = _formatPhone(phone);
    
    try {
      String? idToken = verificationIdOverride;
      
      if (idToken == null) {
        if (state.verificationId == null) {
          state = state.copyWith(isLoading: false, errorMessage: 'Verification ID missing. Try resending OTP.');
          return false;
        }

        final credential = PhoneAuthProvider.credential(
          verificationId: state.verificationId!,
          smsCode: otp,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        idToken = await userCredential.user?.getIdToken();
      }

      if (idToken == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to get Firebase token.');
        return false;
      }

      final result = await verifyOtpUseCase(VerifyOtpParams(phone: formattedPhone, idToken: idToken));
      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
          return false;
        },
        (token) {
          state = state.copyWith(
            isLoading: false,
            status: AuthStatus.authenticated,
            user: token.user,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String otp,
    required String role,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final formattedPhone = _formatPhone(phone);
    
    try {
      if (state.verificationId == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Verification ID missing. Try resending OTP.');
        return false;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: otp,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to get Firebase token.');
        return false;
      }

      final result = await registerUseCase(
        RegisterParams(name: name, phone: formattedPhone, idToken: idToken, role: role, email: email),
      );
      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
          return false;
        },
        (token) {
          state = state.copyWith(
            isLoading: false,
            status: AuthStatus.authenticated,
            user: token.user,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> logout() async {
    await logoutUseCase(const NoParams());
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    sendOtpUseCase: ref.watch(sendOtpUseCaseProvider),
    verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});
