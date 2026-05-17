import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  StreamSubscription<QuerySnapshot>? _analysisSubscription;

  ReportsBloc() : super(ReportsInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<ReportsUpdatedEvent>(_onReportsUpdated);
    on<ReportsErrorEvent>(_onReportsError);
    on<ChangeTimeFilterEvent>(_onChangeTimeFilter);
  }

  void _onLoadReports(LoadReportsEvent event, Emitter<ReportsState> emit) {
    emit(ReportsLoading());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const ReportsError("Lütfen giriş yapın."));
      return;
    }

    _analysisSubscription?.cancel();

    // NOT: where + orderBy birlikte composite index gerektirir.
    // Sadece orderBy ile tüm koleksiyonu çekip client-side filter yapıyoruz.
    _analysisSubscription = FirebaseFirestore.instance
        .collection('Analyses')
        .orderBy('AnalysisDate', descending: true)
        .limit(50) // Performans için max 50 kayıt
        .snapshots()
        .listen(
      (snapshot) async {
        try {
          final List<Map<String, dynamic>> mergedHistory = [];

          for (final doc in snapshot.docs) {
            final analysisData = doc.data();

            // Client-side kullanıcı filtresi (index gerekmez)
            if (analysisData['UserId'] != user.uid) continue;

            final analysisId = doc.id;

            // İlgili AIFeedback'i çek
            final feedbackSnap = await FirebaseFirestore.instance
                .collection('AIFeedbacks')
                .where('AnalysisId', isEqualTo: analysisId)
                .limit(1)
                .get();

            String feedbackText    = '';
            String detailedFeedback = '';
            String kritikCumle     = '';

            if (feedbackSnap.docs.isNotEmpty) {
              final fb = feedbackSnap.docs.first.data();
              feedbackText     = fb['FeedbackText']     as String? ?? '';
              detailedFeedback = fb['DetailedFeedback'] as String? ?? '';
              kritikCumle      = fb['KritikCumle']      as String? ?? '';
            }

            // UI'ın beklediği field isimlerine dönüştür
            mergedHistory.add({
              'analysisId':       analysisId,
              'exerciseName':     analysisData['MovementTypeId'] ?? '',
              'score':            (analysisData['OverallScore'] as num?)?.toInt() ?? 0,
              'kritik_cumle':     kritikCumle,
              'feedback':         feedbackText,
              'detailedFeedback': detailedFeedback,
              'date':             analysisData['AnalysisDate'] ?? '',
              // analiz_raporu.dart için uyumlu alanlar
              'skor':             (analysisData['OverallScore'] as num?)?.toInt() ?? 0,
              'ozet':             feedbackText,
              'geribildirimler':  detailedFeedback,
              'tam_metin':        detailedFeedback,
              'guclu_yonler':     analysisData['guclu_yonler'] ?? [],
              'zayif_yonler':     analysisData['zayif_yonler'] ?? [],
              'oneriler':         analysisData['oneriler'] ?? [],
            });
          }

          // emit yerine add — stream callback'ten emit çağırmak BLoC hatasına yol açar
          add(ReportsUpdatedEvent(mergedHistory));
        } catch (e) {
          add(ReportsErrorEvent(e.toString()));
        }
      },
      onError: (error) {
        // Stream hatalarını da event olarak ilet
        add(ReportsErrorEvent(error.toString()));
      },
    );
  }

  void _onReportsError(ReportsErrorEvent event, Emitter<ReportsState> emit) {
    emit(ReportsError(event.message));
  }

  void _onReportsUpdated(ReportsUpdatedEvent event, Emitter<ReportsState> emit) {
    final history = event.history;

    // ── Branş bazlı ortalama skorlar ───────────────────────────
    final Map<String, List<int>> scoresByExercise = {};
    for (final data in history) {
      final exerciseName = (data['exerciseName'] ?? 'Diğer') as String;
      final score = (data['score'] ?? 0) as int;
      scoresByExercise.putIfAbsent(exerciseName, () => []).add(score);
    }

    final Map<String, double> averageScores = {};
    scoresByExercise.forEach((key, scores) {
      averageScores[key] = scores.reduce((a, b) => a + b) / scores.length;
    });

    // ── Haftalık ortalama (bu haftanın her günü) ───────────────
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final List<List<int>> weekBuckets = List.generate(7, (_) => []);

    for (final data in history) {
      final dateVal = data['date'];
      DateTime? date;
      if (dateVal is String && dateVal.isNotEmpty) {
        date = DateTime.tryParse(dateVal)?.toLocal();
      } else if (dateVal != null) {
        try { date = (dateVal as Timestamp).toDate().toLocal(); } catch (_) {}
      }
      if (date == null) continue;
      final dayDiff = date.difference(
        DateTime(weekStart.year, weekStart.month, weekStart.day)
      ).inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        weekBuckets[dayDiff].add((data['score'] ?? 0) as int);
      }
    }

    final weeklyAverages = weekBuckets.map((b) =>
      b.isEmpty ? 0.0 : b.reduce((a, c) => a + c) / b.length
    ).toList();

    // ── Aylık ortalama (bu ayın 4 haftası) ────────────────────
    final List<List<int>> monthBuckets = List.generate(4, (_) => []);

    for (final data in history) {
      final dateVal = data['date'];
      DateTime? date;
      if (dateVal is String && dateVal.isNotEmpty) {
        date = DateTime.tryParse(dateVal)?.toLocal();
      } else if (dateVal != null) {
        try { date = (dateVal as Timestamp).toDate().toLocal(); } catch (_) {}
      }
      if (date == null) continue;
      if (date.year == now.year && date.month == now.month) {
        final weekOfMonth = ((date.day - 1) / 7).floor().clamp(0, 3);
        monthBuckets[weekOfMonth].add((data['score'] ?? 0) as int);
      }
    }

    final monthlyAverages = monthBuckets.map((b) =>
      b.isEmpty ? 0.0 : b.reduce((a, c) => a + c) / b.length
    ).toList();

    final bool isWeekly = state is ReportsLoaded
        ? (state as ReportsLoaded).isWeekly
        : true;

    emit(ReportsLoaded(
      history: history,
      averageScores: averageScores,
      isWeekly: isWeekly,
      weeklyAverages: weeklyAverages,
      monthlyAverages: monthlyAverages,
    ));
  }

  void _onChangeTimeFilter(ChangeTimeFilterEvent event, Emitter<ReportsState> emit) {
    if (state is ReportsLoaded) {
      final current = state as ReportsLoaded;
      emit(current.copyWith(isWeekly: event.isWeekly));
    }
  }

  @override
  Future<void> close() {
    _analysisSubscription?.cancel();
    return super.close();
  }
}
